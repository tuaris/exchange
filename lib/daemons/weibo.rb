#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = @logger = Logger.new STDOUT

@r ||= KlineDB.redis

$running = true
Signal.trap("TERM") do
  $running = false
end


def client
  unless @client
    @client = WeiboOAuth2::Client.new '', ''
    @client.get_token_from_hash(access_token: ENV["WEIBO_YUNBI_TOKEN"])
  end

  @client
end

def last_id
  @r.get('peatio:weibo:last_id').to_i || 0
end

def refresh
  @statuses = client.statuses
  resp = @statuses.user_timeline(since_id: last_id, trim_user: 1).statuses

  if resp.first
    resp.each do |status|
      @r.lpush('peatio:weibo:statuses', status.to_json) if status.id > last_id
    end
    max_id = (resp.map(&:id) << last_id).max
    @r.set 'peatio:weibo:last_id', max_id
  end
rescue => e
  @logger.error e
end

while($running) do
  refresh

  sleep 90
end
