# frozen_string_literal: true

require 'rails_helper'

describe Otw::Sanitizer::Transformers::UserClassTransformer do
  let(:transformer) { Otw::Sanitizer::Transformers::UserClassTransformer }

  it "returns a callable object" do
    expect(transformer).to respond_to(:call)
  end

  context "when sanitizing" do
    let(:config) do
      Sanitize::Config.merge(
        Sanitize::Config::RELAXED,
        transformers: [transformer]
      )
    end

    it "removes non-alphanumeric class names" do
      html = "<p class=\"hello good!bye\"></span>"
      content = Sanitize.fragment(html, config)
      expect(content).to eq("<p class=\"hello\"></p>")
    end
  end
end
