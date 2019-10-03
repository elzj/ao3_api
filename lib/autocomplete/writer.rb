# frozen_string_literal: true

module Autocomplete
  class Writer
    def self.add(bucket, value, score = 0)
      new(bucket, value, score).add
    end

    # Convenience class method
    def self.remove(bucket, value)
      new(bucket, value).remove
    end

    attr_reader :bucket, :value, :score

    def initialize(bucket, value, score = 0)
      @bucket = bucket
      @value = value
      @score = score
    end

    def redis
      REDIS
    end

    # add all possible tokens to the main completion set
    # only add complete words to our scored set
    def add
      tokens.each do |token|
        add_to_completion_set(token)
        add_to_scored_set(token, score) if complete_word?(token)
      end
    end

    # Remove a value from its scored sets, and if it's the only
    # match for a particular token, remove the token from the
    # main completion set
    def remove
      words.each do |word|
        val = "#{word}#{ArchiveConfig.autocomplete[:terminator]}"
        remove_from_scored_set(val)
        remove_from_completion_set(val) if only_use?(val)
      end
    end

    # Say we have a bucket here called "autocomplete_fandom_all"
    # Our scored set might be something like:
    # "autocomplete_fandom_all_score_star"
    # and that might have weighted values for "55: Star Wars"
    # and "97: Star Trek"
    def add_to_scored_set(token, score)
      redis.zadd(scored_set(token), score, value)
    end

    # This is the main set of all tokens to complete on
    # for this model field, scored to zero and sorted alphabetically
    def add_to_completion_set(token)
      redis.zadd(completion_set, 0, token)
    end

    def remove_from_completion_set(token)
      redis.zrem(completion_set, token)
    end

    # In this case, our set might be something like
    # "autocomplete_fandom_score_star" and our value could be
    # "3: Star Wars" where 3 is the tag id
    def remove_from_scored_set(token)
      redis.zrem(scored_set(token), value)
    end

    def completion_set
      "#{bucket}_completion"
    end

    # The name of the scored set for a particular token
    # ie, "autocomplete_fandom_score_star"
    def scored_set(token)
      "#{bucket}_score_#{token}"
    end

    # Is this value the only one mapped to this token?
    def only_use?(token)
      (get_scored_entries(token) - [value]).empty?
    end

    # So if my token here is 'star', this might be a set of
    # scored tag values for 'Star Wars', 'Star Trek', etc.
    def get_scored_entries(token)
      redis.zrevrangebyscore(scored_set(token), 'inf', 0)
    end

    # The value includes the id and potentially other data
    # so we want to split it back apart to get the part we
    # are using to tokenize
    def value_string
      separator = ArchiveConfig.autocomplete[:separator]
      value.split(separator)[1]
    end

    def tokens
      Tokenizer.new(value_string).tokens
    end

    def words
      Tokenizer.new(value_string).words
    end

    # Set to ',,', as we've banned commas from autocomplete fields
    def complete_word?(str)
      str =~ /#{ArchiveConfig.autocomplete[:terminator]}$/
    end
  end
end
