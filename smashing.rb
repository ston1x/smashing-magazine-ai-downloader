# frozen_string_literal: true

require "dotenv/load"
require "httparty"
require "optparse"

require_relative "lib/downloader"
require_relative "lib/options_parser"
require_relative "lib/scraper"
require_relative "lib/theme_matcher"
require_relative "lib/models/wallpaper"

options = OptionsParser.new.call
wallpapers = Scraper.new(options[:month], options[:theme]).call
matching_wallpapers = ThemeMatcher.new(wallpapers, options[:theme]).call
Downloader.new(matching_wallpapers).call
