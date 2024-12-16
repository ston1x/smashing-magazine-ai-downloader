# frozen_string_literal: true

require "anthropic"

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
        messages: [{ role: "user", content: prompt }],
        system: "You are a reliable theme matcher that only returns exact, explicit matches. Always respond with just a JSON array.",
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

      Please analyze each wallpaper and determine if it explicitly matches the theme "#{theme}".
      Be strict - only return wallpapers that are related to the theme and/or mention it.

      For example, for theme "birds":
      - YES: wallpapers showing birds, nests, or bird-related imagery
      - YES: general nature scenes that have birds somewhere
      - NO: other flying creatures like insects
      - NO: thematically similar but not actually bird-related content

      Return only a JSON array of matching wallpaper IDs, like this:
      ["wallpaper_id_1", "wallpaper_id_2", "wallpaper_id_3"]

      If none of the wallpapers match the theme, return an empty array: []

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
