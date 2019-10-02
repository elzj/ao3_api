# frozen_string_literal: true

require 'rails_helper'

describe Otw::Sanitizer::Transformers::EmbedTransformer do
  let(:transformer) { Otw::Sanitizer::Transformers::EmbedTransformer }

  it "returns a callable object" do
    expect(transformer).to respond_to(:call)
  end

  context "when sanitizing" do
    let(:config) do
      Sanitize::Config.merge(
        Sanitize::Config::BASIC,
        transformers: [transformer]
      )
    end
    
    %w{youtube.com youtube-nocookie.com vimeo.com player.vimeo.com static.ning.com ning.com dailymotion.com
       metacafe.com vidders.net criticalcommons.org google.com archiveofourown.org podfic.com archive.org
       open.spotify.com spotify.com 8tracks.com w.soundcloud.com soundcloud.com viddertube.com}.each do |source|

      it "keeps embeds from #{source}" do
        html = '<iframe width="560" height="315" src="//' + source + '/embed/123" frameborder="0"></iframe>'
        result = Sanitize.fragment(html, config)
        expect(result).to include(html)
      end
    end

    %w{youtube.com youtube-nocookie.com vimeo.com player.vimeo.com
       archiveofourown.org archive.org dailymotion.com 8tracks.com podfic.com
       open.spotify.com spotify.com w.soundcloud.com soundcloud.com viddertube.com}.each do |source|

      it "converts src to https for #{source}" do
        html = '<iframe width="560" height="315" src="http://' + source + '/embed/123" frameborder="0"></iframe>'
        result = Sanitize.fragment(html, config)
        expect(result).to match('https:')
      end
    end

    it "keeps google player embeds" do
      html = '<embed type="application/x-shockwave-flash" flashvars="audioUrl=http://dl.dropbox.com/u/123/foo.mp3" src="http://www.google.com/reader/ui/123-audio-player.swf" width="400" height="27" allowscriptaccess="never" allownetworking="internal">'
      result = Sanitize.fragment(html, config)
      expect(result).to include(html)
    end

    it "strips embeds with unknown source" do
      html = '<embed src="http://www.evil.org"></embed>'
      result = Sanitize.fragment(html, config)
      expect(result).to be_empty
    end

    %w(metacafe.com vidders.net criticalcommons.org static.ning.com ning.com).each do |source|
      it "doesn't convert src to https for #{source}" do
        html = '<iframe width="560" height="315" src="http://' + source + '/embed/123" frameborder="0"></iframe>'
        result = Sanitize.fragment(html, config)
        expect(result).not_to match('https:')
      end
    end
  end
end
