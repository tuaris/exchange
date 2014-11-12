module KlineDB
  class << self

    def redis
      @redis ||= Redis.new url: ENV["REDIS_URL"], db: 1
    end

    def kline(market, period)
      key = "peatio:#{market}:k:#{period}"
      length = redis.llen(key)
      data = redis.lrange(key, length - 1000, -1).map{|str| JSON.parse(str)}
    end

    def weibo(size)
      key = "peatio:weibo:statuses"
      redis.lrange(key, 0, size - 1).collect{|str| JSON.parse(str)}
    end

  end
end
