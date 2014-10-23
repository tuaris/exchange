require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module Worker
  class SlackNotification

    def initialize
      @uri = URI.parse ENV['SLACK_URI'] rescue nil
    end

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      Thread.new do
        notify! payload[:channel], payload[:message]
      end
    end

    def notify!(channel, message)
      https = Net::HTTP.new(@uri.host, @uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(@uri.request_uri)
      req.content_type = 'application/json'
      req.body = JSON.dump({
        'icon_emoji' => ':yunbi:',
        'username'   => 'Yunbi',
        'channel'    => channel,
        'text'       => message
      })
      https.request(req)
    rescue
      puts "Failed to notify slack: #{$!}"
      puts "Message: #{message}"
      puts $!.backtrace[0,20].join("\n")
    end
  end
end
