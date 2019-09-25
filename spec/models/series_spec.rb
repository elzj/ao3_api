# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series, type: :model do
  it { should validate_length_of(:series_notes).is_at_most(5000) }
  it { should validate_length_of(:summary).is_at_most(1250) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_most(255) }
end
