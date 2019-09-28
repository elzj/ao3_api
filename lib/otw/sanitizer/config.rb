module Otw
  module Sanitizer
    module Config
      ARCHIVE = Sanitize::Config.freeze_config(
        elements: %w(
          a abbr acronym address
          b big blockquote br
          caption center cite code col colgroup
          dd del dfn div dl dt em
          h1 h2 h3 h4 h5 h6 hr
          i img ins kbd li ol p pre q
          s samp small span strike strong sub sup
          table tbody td tfoot th thead tr tt
          u ul var
        ),
        attributes: {
          :all          => %w(align title dir),
          'a'           => %w(href name),
          'blockquote'  => %w(cite),
          'col'         => %w(span width),
          'colgroup'    => %w(span width),
          'hr'          => %w(align width),
          'img'         => %w(align alt border height src width),
          'ol'          => %w(start type),
          'q'           => %w(cite),
          'table'       => %w(border summary width),
          'td'          => %w(abbr axis colspan height rowspan width),
          'th'          => %w(abbr axis colspan height rowspan scope width),
          'ul'          => %w(type)
        },
        add_attributes: {
          'a' => { 'rel' => 'nofollow' }
        },
        protocols: {
          'a'           => { 'href' => ['ftp', 'http', 'https', 'mailto', :relative] },
          'blockquote'  => { 'cite' => ['http', 'https', :relative] },
          'img'         => { 'src'  => ['http', 'https', :relative] },
          'q'           => { 'cite' => ['http', 'https', :relative] }
        }
      )

      CSS_ALLOWED = Sanitize::Config.freeze_config(
        Sanitize::Config.merge(
          ARCHIVE,
          attributes: ARCHIVE[:attributes].merge(
            all: ARCHIVE[:attributes][:all] + ['class']
          )
        )
      )
    end
  end
end
