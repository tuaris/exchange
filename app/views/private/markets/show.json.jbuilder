json.asks @asks
json.bids @bids
json.trades @trades
json.market_orders @markets_orders

json.config do 
  json.chat_port ENV['CHAT_PORT']
  json.chat_host ENV['CHAT_HOST']
end

if @member
  json.orders do
    json.wait *([@orders_wait] + Order::ATTRIBUTES)
    json.done @trades_done.map {|t|
      if t.self_trade?
        [t.for_notify('ask'), t.for_notify('bid')]
      else
        t.for_notify
      end
    }.flatten
    json.cancel *([@orders_cancel] + Order::ATTRIBUTES)
  end
end
