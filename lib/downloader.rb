# frozen_string_literal: true

require 'fileutils'

# Downloads wallpapers from the provided wallpapers metadata
class Downloader
  WALLPAPERS_RELATIVE_PATH = "wallpapers"
  def initialize(wallpapers)
    @wallpapers = wallpapers
  end

  attr_reader :wallpapers

  def call
    FileUtils.mkdir_p(WALLPAPERS_RELATIVE_PATH)

    wallpapers.each do |wallpaper|
      print("Downloading #{wallpaper.id}...")
      wallpaper.urls.each do |url|
        download_wallpaper(wallpaper.id, url)
      end
      puts "DONE"
    end
  end

  private

  def download_wallpaper(id, url)
    # Some URLs have 301 status
    response = HTTParty.get(url, follow_redirects: true)
    raise "Failed to download wallpaper: #{response.status}" unless response.success?

    FileUtils.mkdir_p("#{WALLPAPERS_RELATIVE_PATH}/#{id}")
    File.open("wallpapers/#{id}/#{File.basename(url)}", "wb") { |file| file.write(response.body) }
  rescue StandardError => e
    puts "Failed to download wallpaper: #{e.message}"
  end
end
