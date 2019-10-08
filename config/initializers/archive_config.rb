# Create a sitewide ArchiveConfig object from yml files
require 'ostruct'
require 'yaml'

main_config = "#{Rails.root}/config/config.yml"
# Override options locally
local_config = "#{Rails.root}/config/local.yml"

data = YAML.load(ERB.new(File.read(main_config)).result)[Rails.env]
if File.exist?(local_config)
  local_data = YAML.load(ERB.new(File.read(local_config)).result)[Rails.env]
  data = data.deep_merge(local_data || {})
end
::ArchiveConfig = OpenStruct.new(data.with_indifferent_access).freeze
