# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_length_of(:name).is_at_most(255) }
  it { should_not allow_value('my collection').for(:name) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_most(255) }
  it { should_not allow_value('hello, world').for(:name) }
end
