# frozen_string_literal: true

# Parses command line options passed to the script
class OptionsParser
  attr_reader :options

  def initialize
    @options = {}
  end

  def call
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby options_parser.rb --month MMYYYY --theme THEME_KEYWORD"

      opts.on("-m MMYYYY", "--month MMYYYY", "Month and year to search for") { |v| options[:month] = v }
      opts.on("-t THEME_KEYWORD", "--theme THEME_KEYWORD", "Theme keyword to search for") { |v| options[:theme] = v }
      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end.parse!

    # TODO: Also validate month format
    validate_options_presence!(options)
    options
  end

  private

  def validate_options_presence!(options)
    raise ArgumentError, "Arguments `month` and `theme` are required" unless options[:month] && options[:theme]
  end
end
