namespace :yun do
  def accounts_value(m, prices)
    m.accounts.map {|a| a.amount*prices[a.currency] }.sum
  end

  def changes_today(m, prices)
    from = Time.now.beginning_of_day
    v = 0
    m.deposits.where('created_at >= ?', from).each do |d|
      v += d.amount*prices[d.currency]
    end
    m.withdraws.where('created_at >= ?', from).each do |w|
      v -= w.amount*prices[w.currency]
    end
    v
  end

  desc "deliver interest"
  task interest: :environment do
    blacklist = ["forex@peatio.com", "forex-deep@peatio.com", "btsx-forex@peatio.com"]
    prices = Currency.market_values
    from = Time.now.beginning_of_day

    Member.find_each do |m|
      next if blacklist.include?(m.email)

      a = m.get_account('yun')
      unless a.versions.with_reason(Account::INTEREST).where('created_at >= ?', from).exists?
        amount = (accounts_value(m, prices) - changes_today(m, prices)) / 10
        if amount >= 1
          a.plus_funds amount, reason: Account::INTEREST
          puts "Member##{m.id} >> deliver interest #{amount} YUN."
        else
          puts "Member##{m.id} >> not enough assets, skip."
        end
      else
        puts "Member##{m.id} >> interest already delivered, skip."
      end
    end
  end
end
