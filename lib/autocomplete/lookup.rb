# frozen_string_literal: true

module Autocomplete
  class Lookup
    attr_reader :bucket, :search_param, :constraints, :limit

    # Constraint sets are keys to other redis sets
    def initialize(options = {})
      @bucket       = options[:autocomplete_prefix] || ""
      @search_param = options[:search_param] || ""
      @constraints  = options[:constraint_sets]
      @limit        = options[:limit] || 15
    end

    def redis
      REDIS
    end

    # For each word in our search param, find the matching values
    # in our completion set. For each of those,
    # get the scored results that correspond to it and sort them
    def autocomplete_results
      return @results if @results
      return cached_results if cached?

      @results = search_words.flat_map do |word|
        completions_for(word).flat_map { |token| fetch_results(token) }
      end
      @results = sorted_results(@results).first(limit)
      cache_results(@results)
      @results
    end

    # Get the scored results corresponding to a token
    # and ensure they're within any constraint sets
    # Each result is an array in [value, score] format
    def fetch_results(token)
      options = { with_scores: true }
      if !complete_word?(token) && word.length < 3
        options[:limit] = [0, 50] # use a limit
      end
      values = redis.zrevrangebyscore(
        scored_set(token),
        "inf", 0, # max and min
        options
      )
      values.select { |result| within_constraints?(result.first) }
    end

    # Get a list of possible matches from the completion set
    # and loop through looking for exact matches
    def completions_for(token)
      results = []
      possible_completions(token).each do |entry|
        return results unless matches?(token, entry)
        if complete_word?(entry)
          results << entry
          return results if entry == token
        end
      end
      results
    end

    # the rank of the word piece tells us where to start looking
    # in the completion set for possible completions
    # O(logN) N = number of things in the completion set
    # (ie all the possible prefixes for all the words)
    #
    # If my token is 'stair', the results might look something like:
    # ["stair", "stairw", "stairwa", "stairway", "stairway,,",
    # "stak", "stake"] etc.
    def possible_completions(token)
      start_position = redis.zrank(completion_set, token)
      return [] unless start_position
      redis.zrange(
        completion_set,
        start_position,
        start_position + 49
      )
    end

    # Sort results by relevance
    def sorted_results(unsorted)
      scores = []
      sorted = []

      unsorted.group_by(&:itself).each_pair do |result, results|
        relevance = result_relevance(result, results.length)
        new_index = scores.bsearch_index { |val| val < relevance }
        # if this result has the lowest score, add it to the end
        new_index ||= -1 

        scores.insert(new_index, relevance)
        sorted.insert(new_index, result.first)
      end
      sorted
    end

    # Returns a relevance score for a result array, weighting
    # exact matches highest, then results with multiple word matches
    # then results with higher scores (more uses, etc.)
    def result_relevance(result, count)
      result_string, score = result
      exact_match = 0
      exact_match = 100_000 if result_string =~ search_regex
      exact_match + (count * 100) + Math.log(score.to_i)
    end

    def cached?
      redis.exists(cache_set)
    end

    def cached_results
      redis.zrange(cache_set, 0, -1)
    end

    # cache the result for really quick response when only 1-2 letters entered
    # adds only a little bit to memory and saves doing a lot of processing of many phrases
    # expire every 24 hours so new entries get added if appropriate
    def cache_results(results)
      return if search_param.length > 2
      results.each_with_index do |result, index|
        redis.zadd(cache_set, index, result)
      end
      redis.expire(cache_set, 24 * 60 * 60)
    end

    def cache_set
      "#{bucket}_cache_#{search_param}"
    end

    def completion_set
      "#{bucket}_completion"
    end

    def scored_set(token)
      "#{bucket}_score_#{token}"
    end

    # Turn our search term into a regular expression
    def search_regex
      str = ArchiveConfig.autocomplete[:separator] + search_param
      Regexp.new(Regexp.escape(str) + "$", Regexp::IGNORECASE)
    end

    # we assume that if the user is typing in a phrase, any words they have
    # entered are the exact word they want, so we only get the prefixes for
    # the very last word they have entered so far
    def search_words
      @search_words ||= Tokenizer.new(search_param).words_with_terminator
    end

    # Set to ',,', as we've banned commas from autocomplete fields
    def complete_word?(term)
      term =~ /#{ArchiveConfig.autocomplete[:terminator]}$/
    end

    # Is one of these strings a substring of the other?
    def matches?(str1, str2)
      str1.start_with?(str2) || str2.start_with?(str1)
    end

    # If items need to be members of other specified sets,
    # run a comparison on each one (zrank checks for inclusion)
    def within_constraints?(value)
      return true if constraints.blank?
      constraints.all { |set_name| redis.zrank(set_name, value) }
    end
  end
end
