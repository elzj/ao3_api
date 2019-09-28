# frozen_string_literal: true

require 'spec_helper'
require 'sanitize'
require_relative '../../lib/otw/sanitizer'

RSpec.describe Otw::Sanitizer do
  describe ".sanitize" do
    it "completely sanitizes without arguments" do
      str = "<strong>hello</strong> sanitizer"
      result = Otw::Sanitizer.sanitize(str, [])
      expect(result).to eq("hello sanitizer")
    end

    it "allows html for designated fields" do
      str = "<p>hello sanitizer</p>"
      result = Otw::Sanitizer.sanitize(str, [:html])
      expect(result).to eq(str)
    end

    it "does not allow video in html fields" do
      str = "<video>hello sanitizer</video>"
      result = Otw::Sanitizer.sanitize(str, [:html])
      expect(result).to eq("hello sanitizer")
    end

    it "does allow video in multimedia fields" do
      str = "<video>hello sanitizer</video>"
      processed = "<video controls=\"controls\" playsinline=\"playsinline\" crossorigin=\"anonymous\" preload=\"metadata\">hello sanitizer</video>"
      result = Otw::Sanitizer.sanitize(str, [:multimedia])
      expect(result).to eq(processed)
    end

    it "never allows script tags" do
      str = "<script>nope</script>"
      result = Otw::Sanitizer.sanitize(str, [:html, :multimedia])
      expect(result).to eq("")
    end
  end
end
