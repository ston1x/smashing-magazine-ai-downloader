# frozen_string_literal: true

require "anthropic"
require "pry"

# Matches wallpapers metadata with a given theme
class ThemeMatcher
  def initialize(wallpapers, theme)
    @wallpapers = wallpapers
    @theme = theme
    @client = Anthropic::Client.new(access_token: ENV["ANTHROPIC_API_KEY"])
  end

  attr_reader :wallpapers, :theme, :client

  def call
    find_matches
  end

  private

  # Call Anthropic API to match the wallpapers metadata with the given theme
  def find_matches
    response = client.messages(
      parameters: {
        model: "claude-3-haiku-20240307",
        max_tokens: 1024,
        temperature: 0,
        system: "You are a helpful assistant that matches themes to wallpapers. Always respond with just a JSON array.",
        messages: [{ role: "user", content: prompt }],
      },
    )
    matching_ids = JSON.parse(response["content"].first["text"])
    wallpapers.select { |w| matching_ids.include?(w.id) }
  rescue JSON::ParserError => e
    puts "Error parsing Anthropic response: #{e.message}"
  rescue StandardError => e
    puts "Error matching wallpapers with Anthropic: #{e.message}"
  end

  def prompt
    @prompt ||= <<~PROMPT
      You are helping to select wallpapers that match a given theme.

      Theme to match: #{theme}

      Please analyze each wallpaper and determine if it matches the theme "#{theme}".

      Return only a JSON array of matching wallpaper IDs, like this:
      ["wallpaper_id_1", "wallpaper_id_2", "wallpaper_id_3"]

      If none of the wallpapers match the theme, return an empty array: []

      Consider both direct matches and thematic connections. For example:
      - Theme "nature": landscapes, weather, plants, and animals would all match
      - Theme "architecture": buildings, cities, bridges, and structural patterns would match
      - Theme "animals": any wildlife, pets, or animal-related imagery would match
      - Theme "technology": computers, circuits, digital art
      - Theme "food": cooking, ingredients, meals, kitchen items
      and so on.

      Below are the wallpapers to analyze:
      #{wallpapers_data}
    PROMPT
  end

  def wallpapers_data
    @wallpapers_data ||= wallpapers.map do |wallpaper|
      "ID: #{wallpaper.id}; Description: #{wallpaper.description}"
    end.join("\n\n")
  end
end
