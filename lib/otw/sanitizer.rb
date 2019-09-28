# frozen_string_literal: true

require_relative 'sanitizer/config'
require_relative 'sanitizer/transformers/embed_transformer'
require_relative 'sanitizer/transformers/media_transformer'
require_relative 'sanitizer/transformers/user_class_transformer'

module Otw
  # Uses the sanitize gem and custom configs to sanitize html
  module Sanitizer
    def self.sanitize(text, sanitizers)
      config = {}
      transformers = []
      if sanitizers.include?(:html)
        config = Config::ARCHIVE
      end
      if sanitizers.include?(:css)
        config = Config::CSS_ALLOWED
        transformers += [
          Transformers::UserClassTransformer
        ]
      end
      if sanitizers.include?(:multimedia)
        transformers += [
          Transformers::EmbedTransformer,
          Transformers::MediaTransformer
        ]
      end

      Sanitize.fragment(
        text,
        Sanitize::Config.merge(
          config,
          transformers: transformers
        )
      )
    end
  end
end
