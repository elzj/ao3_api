module SearchHelper
  # Turn string values into truth
  def self.standardize_boolean(value)
    %w[1 T true].include?(value.to_s)
  end

  def self.sanitize_string(str)
    escape_slashes(str).gsub('!', '\\!').
                        gsub('+', '\\\\+').
                        gsub('-', '\\-').
                        gsub('?', '\\?').
                        gsub("~", '\\~').
                        gsub("(", '\\(').
                        gsub(")", '\\)').
                        gsub("[", '\\[').
                        gsub("]", '\\]').
                        gsub(':', '\\:')
  end

  # Only escape if it isn't already escaped
  def self.escape_slashes(word)
    word.gsub(/([^\\])\//) { |s| $1 + '\\/' }
  end

  # Generate an index name like ao3_development_tags
  # The first two parts are variable/configurable to avoid
  # index collisions
  def self.index_name(record_type)
    [
      ArchiveConfig.search[:prefix],
      Rails.env,
      record_type
    ].join('_')
  end
end
