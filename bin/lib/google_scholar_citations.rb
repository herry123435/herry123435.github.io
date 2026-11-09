require 'nokogiri'
require 'open-uri'
require 'tempfile'
require 'time'
require 'yaml'

module GoogleScholarCitations
  class InvalidProfile < StandardError; end

  # An empty citation link is Scholar's explicit zero. Missing or changed markup
  # is an error, so a CAPTCHA or an HTML change can never erase verified counts.
  def self.parse_profile(html, scholar_id)
    document = Nokogiri::HTML(html)
    counts = {}
    document.css('tr.gsc_a_tr').each do |row|
      publication = row.at_css('a.gsc_a_at')
      next unless publication

      parameters = URI.decode_www_form(URI.parse(publication['href']).query.to_s).to_h
      author, article_id = parameters['citation_for_view'].to_s.split(':', 2)
      next unless author == scholar_id && article_id && !article_id.empty?

      citation = row.at_css('td.gsc_a_c a.gsc_a_ac')
      raise InvalidProfile, "Missing citation count for #{article_id}" unless citation

      count = citation.text.strip
      if count.empty? && !citation['href'].to_s.empty?
        raise InvalidProfile, "Empty count links to citing publications for #{article_id}"
      end
      unless count.empty? || count.match?(/\A(?:\d+|\d{1,3}(?:,\d{3})+)\z/)
        raise InvalidProfile, "Unrecognized citation count for #{article_id}"
      end
      counts[article_id] = count.delete(',').to_i
    end
    raise InvalidProfile, 'No publications found for the configured Scholar profile' if counts.empty?

    counts
  end

  def self.fetch_profile(url)
    URI.open(url, 'User-Agent' => 'Mozilla/5.0 (compatible; academic-publications-site)', open_timeout: 10, read_timeout: 20, &:read)
  end

  def self.refresh(path, scholar_id, article_ids, fetch: method(:fetch_profile), now: Time.now.utc)
    raise InvalidProfile, 'No Google Scholar publication IDs configured' if article_ids.empty?
    raise InvalidProfile, 'No Google Scholar author ID configured' if scholar_id.to_s.empty?

    url = "https://scholar.google.com/citations?#{URI.encode_www_form(user: scholar_id, hl: 'en', pagesize: 100)}"
    counts = parse_profile(fetch.call(url), scholar_id)
    missing = article_ids - counts.keys
    raise InvalidProfile, "Profile did not include publication IDs: #{missing.join(', ')}" unless missing.empty?

    cache = {
      'scholar_userid' => scholar_id,
      'fetched_at' => now.utc.iso8601,
      'publications' => article_ids.sort.to_h { |id| [id, counts.fetch(id)] }
    }

    # Replace only after every expected article has been verified. A failed
    # request or incomplete profile leaves the previous file entirely intact.
    Tempfile.create(['google-scholar-citations', '.yml'], File.dirname(path)) do |file|
      file.write(YAML.dump(cache))
      file.flush
      File.rename(file.path, path)
    end
    cache
  end
end
