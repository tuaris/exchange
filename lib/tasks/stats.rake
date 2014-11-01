namespace :stats do

  def asset_value(ts, currency, amount)
    if currency.code != 'cny'
      redis = KlineDB.redis

      market = Market.find "#{currency.code}cny" rescue nil
      return [] unless market

      key = "peatio:#{market.id}:k:60"
      last_hour = 23.hours.since(Time.at ts)

      if redis.llen(key) > 0
        from = JSON.parse(redis.lindex(key, 0)).first
        offset = (last_hour.to_i - from) / 60.minutes
        point = JSON.parse redis.lindex(key, offset)
        last_hour_close_price = point[4]

        [amount*last_hour_close_price, amount, last_hour_close_price]
      else
        []
      end
    else
      [amount, amount, 1]
    end
  end

  def collect_stats(ts)
    trade_users = {}
    Market.all.each do |market|
      trade_users[market.id] = Worker::TradeStats.new(market).get_point(ts, 1440)
    end

    asset_stats = {}
    Currency.all.each do |currency|
      stat = Worker::WalletStats.new(currency).get_point(ts, 1440)
      asset_stats[currency.code] = asset_value(ts, currency, stat[3])
    end

    member_stats = Worker::MemberStats.new.get_point(ts, 1440)

    { trade_users:  trade_users,
      asset_stats:  asset_stats,
      member_stats: member_stats }
  end

  desc "send stats summary email"
  task email: :environment do
    yesterday = 1.day.ago(Time.now.beginning_of_day)
    base      = 1.day.ago(yesterday)

    yesterday_stats = collect_stats yesterday.to_i
    base_stats      = collect_stats base.to_i

    SystemMailer.daily_stats(yesterday.to_i, yesterday_stats, base_stats).deliver
  end

  def accounts_on_date(date)
    AccountVersion.where('created_at < ?', date).group('account_id').select('max(id) as id, member_id, account_id, currency, amount, created_at')
  end

  desc "user rank by daily average asset value"
  task user_rank: :environment do
    prices = {}
    Currency.all.each do |currency|
      case currency.code
      when 'cny'
        prices['cny'] = 1
      when 'yun'
        prices['yun'] = 0
      else
        prices[currency.code] = Global["#{currency.code}cny"].ticker[:last]
      end
    end

    from = Time.new(2014, 9, 20).end_of_day
    to   = Time.now.end_of_day

    total_user_value = Hash.new {|h, k| h[k] = 0 }
    count = 0

    date = from
    while date <= to
      count += 1

      versions = accounts_on_date(date).to_a
      puts "#{date}, found #{versions.size} versions, processing"

      versions.each do |version|
        if version.currency != 'yun'
          total_user_value[version.member_id] += prices[version.currency]*version.amount
        end
      end

      date += 1.day
    end

    File.open('user_rank.csv', 'w') do |f|
      total_user_value.each do |(id, total)|
        m = Member.find id
        f.puts "#{m.name},#{m.email},#{total/count}"
      end
    end
  end

end
