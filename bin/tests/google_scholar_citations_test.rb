require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'liquid'

require_relative '../lib/google_scholar_citations'
require_relative '../../_plugins/google-scholar-citations'

class GoogleScholarCitationsTest < Minitest::Test
  SCHOLAR_ID = 'ps20pnYAAAAJ'
  ARTICLE_ID = 'u5HHmVD_uO8C'

  def profile(count = '1,234', article_id = ARTICLE_ID, scholar_id = SCHOLAR_ID)
    <<~HTML
      <html><body><table id="gsc_a_t"><tbody id="gsc_a_b">
        <tr class="gsc_a_tr">
          <td class="gsc_a_t"><a class="gsc_a_at" href="/citations?view_op=view_citation&amp;user=#{scholar_id}&amp;citation_for_view=#{scholar_id}:#{article_id}">Publication</a></td>
          <td class="gsc_a_c"><a class="gsc_a_ac gs_ibl" href="#{count.empty? ? '' : '/scholar?cites=123'}">#{count}</a></td>
        </tr>
      </tbody></table></body></html>
    HTML
  end

  def test_profile_parses_formatted_count
    assert_equal({ ARTICLE_ID => 1234 }, GoogleScholarCitations.parse_profile(profile, SCHOLAR_ID))
  end

  def test_an_explicit_empty_citation_link_is_zero
    assert_equal({ ARTICLE_ID => 0 }, GoogleScholarCitations.parse_profile(profile(''), SCHOLAR_ID))
  end

  def test_a_block_page_does_not_turn_into_zero
    assert_raises(GoogleScholarCitations::InvalidProfile) do
      GoogleScholarCitations.parse_profile('<html>Our systems have detected unusual traffic</html>', SCHOLAR_ID)
    end
  end

  def test_missing_citation_markup_does_not_turn_into_zero
    html = profile.sub(/<a class="gsc_a_ac.*?<\/a>/, '')
    assert_raises(GoogleScholarCitations::InvalidProfile) do
      GoogleScholarCitations.parse_profile(html, SCHOLAR_ID)
    end
  end

  def test_non_numeric_citation_markup_is_rejected
    assert_raises(GoogleScholarCitations::InvalidProfile) do
      GoogleScholarCitations.parse_profile(profile('unavailable'), SCHOLAR_ID)
    end
  end

  def test_an_empty_link_to_citing_papers_is_not_an_explicit_zero
    html = profile('99').sub('>99</a>', '></a>')
    assert_raises(GoogleScholarCitations::InvalidProfile) do
      GoogleScholarCitations.parse_profile(html, SCHOLAR_ID)
    end
  end

  def test_a_different_author_profile_is_rejected
    assert_raises(GoogleScholarCitations::InvalidProfile) do
      GoogleScholarCitations.parse_profile(profile('4', ARTICLE_ID, 'different-author'), SCHOLAR_ID)
    end
  end

  def with_cache
    Dir.mktmpdir do |directory|
      path = File.join(directory, 'citations.yml')
      File.write(path, YAML.dump({
        'scholar_userid' => SCHOLAR_ID,
        'fetched_at' => '2025-01-01T00:00:00Z',
        'publications' => { ARTICLE_ID => 88 }
      }))
      yield path
    end
  end

  def test_successful_refresh_updates_the_persisted_cache
    with_cache do |path|
      fetch = lambda do |url|
        assert_equal 'https://scholar.google.com/citations?user=ps20pnYAAAAJ&hl=en&pagesize=100', url
        profile('99')
      end
      GoogleScholarCitations.refresh(path, SCHOLAR_ID, [ARTICLE_ID], fetch: fetch, now: Time.utc(2026, 11, 8))
      assert_equal({
        'scholar_userid' => SCHOLAR_ID,
        'fetched_at' => '2026-11-08T00:00:00Z',
        'publications' => { ARTICLE_ID => 99 }
      }, YAML.safe_load_file(path))
    end
  end

  def test_network_failure_keeps_the_last_verified_file_byte_for_byte
    with_cache do |path|
      previous = File.binread(path)
      assert_raises(IOError) do
        GoogleScholarCitations.refresh(path, SCHOLAR_ID, [ARTICLE_ID], fetch: ->(_) { raise IOError, 'network blocked' })
      end
      assert_equal previous, File.binread(path)
    end
  end

  def test_a_blocked_response_keeps_the_last_verified_file
    with_cache do |path|
      previous = File.binread(path)
      assert_raises(GoogleScholarCitations::InvalidProfile) do
        GoogleScholarCitations.refresh(path, SCHOLAR_ID, [ARTICLE_ID], fetch: ->(_) { '<html>CAPTCHA</html>' })
      end
      assert_equal previous, File.binread(path)
    end
  end

  def test_a_missing_publication_keeps_the_last_verified_file
    with_cache do |path|
      previous = File.binread(path)
      assert_raises(GoogleScholarCitations::InvalidProfile) do
        GoogleScholarCitations.refresh(path, SCHOLAR_ID, [ARTICLE_ID, 'missing'], fetch: ->(_) { profile })
      end
      assert_equal previous, File.binread(path)
    end
  end

  def render_count(count: nil, author: SCHOLAR_ID, fallback: nil)
    cache = { 'scholar_userid' => author, 'publications' => { ARTICLE_ID => count } }
    context = {
      'site' => { 'data' => { 'socials' => { 'scholar_userid' => SCHOLAR_ID }, 'google_scholar_citations' => cache } },
      'entry' => { 'google_scholar_id' => ARTICLE_ID, 'citations' => fallback }
    }
    Liquid::Template.parse('{% google_scholar_citations site.data.socials.scholar_userid entry.google_scholar_id entry.citations %}').render!(context)
  end

  def test_the_liquid_badge_uses_cached_counts_instead_of_manual_counts
    assert_equal '99', render_count(count: 99, fallback: '88')
  end

  def test_the_liquid_badge_preserves_a_verified_zero
    assert_equal '0', render_count(count: 0, fallback: '88')
  end

  def test_the_liquid_badge_falls_back_if_the_cache_is_for_another_author
    assert_equal '88', render_count(count: 99, author: 'different-author', fallback: '88')
  end

  def test_the_liquid_badge_does_not_make_up_an_unknown_count
    assert_equal 'N/A', render_count
  end
end
