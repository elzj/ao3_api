require 'rails_helper'

RSpec.describe WorkBlurb do
  it "knows its title" do
    work = Work.new(title: "foo")
    blurb = WorkBlurb.new(work)
    expect(blurb.title).to eq("foo")
  end
end
