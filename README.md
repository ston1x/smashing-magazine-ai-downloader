# Smashing AI Downloader

A script for downloading wallpapers from Smashing Magazine by month and theme. It accepts month of a year and theme as command line arguments. It then matches the corresponding post on Smashing Magazine, parses its pages and determines via Anthropic API whether wallpapers match the given keyword (theme).

## Installation

1. Make sure you have ruby >=3.1.0 installed
2. Clone the repo
3. Run `bundle`
4. Set your ANTHROPIC_API_KEY in `.env`

## Usage

Run the script with a specific theme and month of a year:

`ruby smashing.rb --month 052024 --theme animals`

For help, check:

`ruby smashing.rb --help`

## Design Decisions and Tradeoffs

- Theme matching: it might not be ideal in all situations, and additional prompt tuning might be needed, however it seems to serve its purpose fine at the moment
- Error handling: currently covers basic scenarios with informative messages for common scenarios, might be improved with retries and logging to error tracking tools

## Future improvements

- Add comprehensive test suite (preferrably with vcr or webmock)
- Implement caching for repetitive Anthropic API responses
- Implement concurrent downloads
- Implement output directory selection (CLI argument)
- Implement calendar/no calendar selection (CLI argument)
- Implement resolution selection (CLI argument)
- Implement debug mode (CLI argument)
