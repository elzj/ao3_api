# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatCounter, type: :model do
  it { should belong_to(:work) }
end
