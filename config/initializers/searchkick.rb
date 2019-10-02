# frozen_string_literal: true

ENV['ELASTICSEARCH_URL'] = ArchiveConfig.search[:url]
Searchkick.index_prefix = ArchiveConfig.search[:prefix]
