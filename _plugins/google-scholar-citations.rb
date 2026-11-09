module Jekyll
  class GoogleScholarCitationsTag < Liquid::Tag
    def initialize(tag_name, params, tokens)
      super
      @scholar_id, @article_id, @fallback = params.split
    end

    def render(context)
      scholar_id = context[@scholar_id]
      article_id = context[@article_id]
      cache = context['site.data.google_scholar_citations'] || {}
      count = cache.fetch('publications', {})[article_id] if cache['scholar_userid'] == scholar_id
      count = context[@fallback] if !valid_count?(count) && @fallback
      valid_count?(count) ? count.to_s : 'N/A'
    end

    private

    def valid_count?(count)
      count.to_s.match?(/\A\d+\z/)
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
