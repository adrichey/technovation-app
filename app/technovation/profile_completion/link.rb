module ProfileCompletion
  class Link < Struct.new(:text_path, :url_structure, :link_options, :tag_options)
    include Rails.application.routes.url_helpers

    def text
      I18n.t(text_path)
    end

    def url
      case url_structure
      when Array
        send(url_structure.first, *url_structure.last)
      when Symbol
        send(url_structure)
      else
        url_structure
      end
    end

    def prefix
      if path = Hash(link_options)[:prefix_path]
        I18n.t(path)
      end
    end

    def postfix
      if path = Hash(link_options)[:postfix_path]
        I18n.t(path)
      end
    end

    def options
      Hash(tag_options)
    end
  end
end
