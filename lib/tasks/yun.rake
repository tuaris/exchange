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

  def deposit_interest(m, amount, ts)
    a = m.get_account('yun')
    ActiveRecord::Base.transaction do
      d = Deposits::Yun.new(
        payment_transaction_id: nil,
        blockid: ts,
        txid: "#{Deposit::PREFIXS[:yun][:interest]}-#{ts}-#{m.id}",
        amount: amount,
        member: m,
        account: a,
        currency: 'yun',
        memo: 101,
        aasm_state: :accepted
      )
      d.save!(validate: false)
      a.plus_funds amount, reason: Account::INTEREST
    end
  end

  desc "deliver interest"
  task interest: :environment do
    blacklist = ["forex@peatio.com", "forex-deep@peatio.com", "btsx-forex@peatio.com", 'lixiaolai@gmail.com']
    prices = Currency.market_values

    from = Time.now.beginning_of_day
    ts = Time.now.strftime "%Y%m%d"

    Member.find_each do |m|
      next if blacklist.include?(m.email)

      unless m.deposits.with_currency('yun').where(blockid: ts).exists?
        amount = ((accounts_value(m, prices) - changes_today(m, prices)) / 150).floor
        if amount >= 1
          deposit_interest m, amount, ts
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
