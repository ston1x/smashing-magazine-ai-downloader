# frozen_string_literal: true

require "date"
require "nokogiri"

# Scrapes the Smashing Magazine website, collecting wallpapers metadata
class Scraper
  BASE_URL = "https://www.smashingmagazine.com"

  def initialize(month_and_year, theme)
    @month = month_and_year[0..1]
    @year = month_and_year[2..-1]
    @theme = theme
  end

  attr_reader :month, :year, :theme

  def call
    response = fetch_page
    collect_wallpapers_metadata(response)
  end

  private

  def fetch_page

    HTTParty.get(url).body
  rescue StandardError => e
    puts "Failed to fetch page: #{e.message}"
  end

  def collect_wallpapers_metadata(response)
    doc = Nokogiri::HTML(response)
    container = doc.at_css(".c-garfield-the-cat")

    container.css("h2").map do |heading|
      # title = heading.text.gsub(/\s*#\s*$/, '').strip

      id = heading["id"]
      description = heading.next_element.text.strip

      # Find all download links in the following unordered list
      links_ul = heading
      links_ul = links_ul.next_element while links_ul && links_ul.name != "ul"
      urls = links_ul ? links_ul.css("a").map { |link| link["href"] } : []

      Wallpaper.new(id, description, urls)
    end.compact
  end

  def url
    @url ||= begin
      # Create a Date object for the first day of the target month
      target_date = Date.new(year.to_i, month.to_i, 1)
      # Subtract one month to get the publication date
      pub_date = target_date << 1 # << subtract 1 month

      month_word = Date::MONTHNAMES[month.to_i].downcase

      "#{BASE_URL}/#{pub_date.year}/%02d/desktop-wallpaper-calendars-#{month_word}-#{year}/" % pub_date.month
    end
  end
end
