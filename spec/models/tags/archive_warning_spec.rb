require 'rails_helper'

RSpec.describe ArchiveWarning, type: :model do
  it { should validate_inclusion_of(:name).in_array(ArchiveWarning::DEFAULTS) }
end
