require "jekyll"

module SdgMetadataPlugins
  class CreatePages < Jekyll::Generator
    safe true
    priority :normal

    def get_field_content(content, field_name)
      if content != ''
        return "\n\n" + content
      else
        return "\n\n**" + field_name + " is not yet translated.**"
      end
    end

    # Make any goal/target/indicator number suitable for use in sorting.
    def get_sort_order(number)
      if number.is_a? Numeric
        number = number.to_s
      end
      sort_order = ''
      parts = number.split('-')
      parts.each do |part|
        if part.length == 1
          part = '0' + part
        end
        sort_order += part
      end
      sort_order
    end

    def generate(site)
      base = site.source

      # Generate all the indicator pages.
      site.data['store']['metadata'].each do |language, indicators|
        indicators.each do |indicator, indicator_fields|
          dir = File.join('metadata', language, indicator) + '/'
          layout = 'indicator'
          title = 'Indicator: ' + indicator.gsub('-', '.')
          data = {'slug' => indicator}

          toc = site.data['store']['fields'][indicator].map {|k| '<a href="#' + k + '">' + k + '</a>'}
          toc = toc.join('<br>')

          content = site.data['store']['fields'][indicator].map {|k| '<a name="' + k + '"></a>' + get_field_content(indicator_fields[k], k) }
          content = content.join("\n\n")

          # This provides some data for the benefit of the Minimal Mistakes theme.
          data['sidebar'] = [
            {
              'title' => 'Fields',
              'text' => toc
            }
          ]

          site.pages << SdgMetadataPage.new(site, base, dir, layout, title, content, language, data)
        end
      end

      # Generate all the language pages.
      site.data['store']['metadata'].each do |language, indicators|
        dir = File.join('metadata', language) + '/'
        layout = 'language'
        title = 'Language: ' + site.config['languages'][language]
        content = ''
        language = language
        data = {'indicators' => indicators.keys.sort_by { |k| get_sort_order(k) }}
        site.pages << SdgMetadataPage.new(site, base, dir, layout, title, content, language, data)
      end
    end
  end

  # A Page subclass used in the `CreatePages` class.
  class SdgMetadataPage < Jekyll::Page
    def initialize(site, base, dir, layout, title, content, language, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.data = {}
      self.data['layout'] = layout
      self.data['title'] = title
      self.data['language'] = language
      self.data.merge!(data)
      self.content = content
    end
  end
end