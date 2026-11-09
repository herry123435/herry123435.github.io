require 'minitest/autorun'
require 'liquid'
require 'nokogiri'
require 'jekyll-regex-replace'
require_relative '../../_plugins/remove-accents'

class PublicationAuthorsTest < Minitest::Test
  OTHER_AUTHORS = [
    ['Wongi', 'Park'], ['Jordan A.', 'James'], ['Myeongseok', 'Nam'],
    ['Soomok', 'Lee'], ['Sang-Hyun', 'Lee'], ['William J.', 'Beksi'], ['Alex', 'Kim']
  ].freeze

  def render_authors(self_position: nil, total: 7, last_name: 'Lee', limit: 3)
    authors = OTHER_AUTHORS.first(total).map { |first, last| { 'first' => first, 'last' => last } }
    authors.insert(self_position - 1, { 'first' => 'Minjae', 'last' => last_name }) if self_position
    authors = authors.first(total)
    layout = File.read(File.expand_path('../../_layouts/bib.liquid', __dir__))
    author_template = layout.split('<!-- Author -->', 2).last.split('<!-- Journal/Book title and date -->', 2).first
    html = Liquid::Template.parse(author_template).render!({
      'entry' => { 'author_array' => authors },
      'site' => {
        'max_author_limit' => limit,
        'scholar' => { 'first_name' => ['Minjae'], 'last_name' => ['Lee'] },
        'data' => { 'coauthors' => {} },
        'more_authors_animation_delay' => 10
      }
    }, strict_filters: true)
    Nokogiri::HTML.fragment(html).at_css('.author')
  end

  def text(node)
    node.text.gsub(/\s+/, ' ').strip.gsub(' ,', ',')
  end

  def test_fourth_author_is_visible_in_original_order_and_remaining_authors_expand
    authors = render_authors(self_position: 4)
    assert_equal 'Wongi Park, Jordan A. James, Myeongseok Nam, Minjae Lee, and 3 more authors', text(authors)
    assert_equal 'Minjae Lee', text(authors.at_css('em'))
    assert_includes authors.at_css('.more-authors')['onclick'], 'Soomok Lee, Sang-Hyun Lee, William J. Beksi'
  end

  def test_sixth_author_extends_the_limit_beyond_four
    authors = render_authors(self_position: 6, total: 8)
    assert_equal 'Wongi Park, Jordan A. James, Myeongseok Nam, Soomok Lee, Sang-Hyun Lee, Minjae Lee, and 2 more authors', text(authors)
    assert_equal 'Minjae Lee', text(authors.at_css('em'))
    assert_includes authors.at_css('.more-authors')['onclick'], 'William J. Beksi, Alex Kim'
  end

  def test_self_before_the_limit_keeps_the_default_visible_count
    authors = render_authors(self_position: 2)
    assert_equal 'Wongi Park, Minjae Lee, Jordan A. James, and 4 more authors', text(authors)
    assert_equal 'Minjae Lee', text(authors.at_css('em'))
  end

  def test_self_as_the_last_author_shows_everyone_without_an_expansion
    authors = render_authors(self_position: 7)
    assert_equal 'Wongi Park, Jordan A. James, Myeongseok Nam, Soomok Lee, Sang-Hyun Lee, William J. Beksi, and Minjae Lee', text(authors)
    assert_nil authors.at_css('.more-authors')
  end

  def test_no_self_match_preserves_the_default_limit
    authors = render_authors
    assert_equal 'Wongi Park, Jordan A. James, Myeongseok Nam, and 4 more authors', text(authors)
    assert_nil authors.at_css('em')
  end

  def test_contribution_markers_do_not_hide_the_self_author
    authors = render_authors(self_position: 4, last_name: 'Lee*†')
    assert_equal 'Minjae Lee*†', text(authors.at_css('em'))
    assert_equal '*†', authors.at_css('em sup').text
    assert_equal '3 more authors', text(authors.at_css('.more-authors'))
  end

  def test_an_unset_limit_still_shows_every_author
    authors = render_authors(limit: nil)
    assert_equal 'Wongi Park, Jordan A. James, Myeongseok Nam, Soomok Lee, Sang-Hyun Lee, William J. Beksi, and Alex Kim', text(authors)
    assert_nil authors.at_css('.more-authors')
  end
end
