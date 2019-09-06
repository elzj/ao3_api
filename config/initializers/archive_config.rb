# Create a sitewide ArchiveConfig object from yml files
require 'ostruct'
require 'yaml'

main_config = "#{Rails.root}/config/config.yml"
# Override options locally
local_config = "#{Rails.root}/config/local.yml"

hash = YAML.load_file(main_config)[Rails.env] || {}
if File.exist?(local_config)
  hash = hash.deep_merge(YAML.load_file(local_config)[Rails.env] || {})
end
::ArchiveConfig = OpenStruct.new(hash.with_indifferent_access).freeze
