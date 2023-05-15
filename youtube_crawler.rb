require 'google/apis/youtube_v3'
require 'googleauth'
require 'trollop'
require 'uri'

DEVELOPER_KEY = ENV['YOUTUBE_DEVELOPER_KEY']

def get_service
  service = Google::Apis::YoutubeV3::YouTubeService.new
  service.key = DEVELOPER_KEY
  service
end

def main
  # For instance, ruby youtube_crawler.rb --q="<your query>" --max-results=<your number>
  opts = Trollop::options do
    opt :q, 'Search term', type: String, default: 'Google'
    opt :max_results, 'Max results', type: :int, default: 25
  end

  service = get_service

  begin
    channels = {}
    next_page_token = nil

    # Loop until we reach the maximum number of results or we run out of pages
    while channels.size < opts[:max_results] do
      opt = {
        q: opts[:q],
        max_results: [opts[:max_results] - channels.size, 50].min,  # 50 is the maximum allowed by the API
        type: 'channel,video,playlist',
        page_token: next_page_token
      }

      search_response = service.list_searches('snippet', **opt)

      search_response.items.each do |search_result|
        channels[search_result.snippet.channel_id] = {}
      end

      # Break the loop if there are no more pages
      break if search_response.next_page_token.nil?

      # Otherwise, prepare for the next iteration
      next_page_token = search_response.next_page_token
    end

    channels.each do |id, _|
      channel_response = service.list_channels('snippet,statistics', id: id)
      channel = channel_response.items.first

      channels[id][:name] = channel.snippet.title
      channels[id][:subscribers] = channel.statistics.subscriber_count
      channels[id][:video_count] = channel.statistics.video_count
      channels[id][:average_view_count] = channel.statistics.view_count.to_i / channel.statistics.video_count.to_i if channel.statistics.view_count.to_i.positive?
      channels[id][:description] = channel.snippet.description

      emails = channels[id][:description]&.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b/)
      channels[id][:emails] = emails

      urls = URI.extract(channels[id][:description], ['http', 'https'])
      channels[id][:social_links] = urls

      channel_url = "https://www.youtube.com/channel/#{channel.id}"
      channels[id][:url] = channel_url
    end

    channels.each do |id, info|
      puts "Channel ID: #{id}"
      info.each do |key, value|
        puts "#{key.capitalize}: #{value}"
      end
      puts "\n"
    end

    puts "Channels processed: #{channels.size}"
  rescue Google::Apis::TransmissionError => e
    puts e.message
  end
end

main
