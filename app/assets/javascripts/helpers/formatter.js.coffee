class Formatter
  round: (str, fixed) ->
    BigNumber(str).round(fixed, BigNumber.ROUND_HALF_UP).toF(fixed)

  fix: (type, str) ->
    str = '0' unless $.isNumeric(str)
    if type is 'ask'
      @.round(str, gon.market.ask.fixed)
    else if type is 'bid'
      @.round(str, gon.market.bid.fixed)

  fixAsk: (str) ->
    @.fix('ask', str)

  fixBid: (str) ->
    @.fix('bid', str)

  fixPriceGroup: (str) ->
    if gon.market.price_group_fixed
      str = '0' unless $.isNumeric(str)
      @.round(str, gon.market.price_group_fixed)
    else
      @fixBid(str)

  check_trend: (type) ->
    if type == 'up' or type == 'buy' or type == 'bid' or type == true
      true
    else if type == 'down' or type == "sell" or type = 'ask' or type == false
      false
    else
      throw "unknown trend smybol #{type}"

  market: (base, quote) ->
    "#{base.toUpperCase()}/#{quote.toUpperCase()}"

  market_url: (market, order_id) ->
    if order_id?
      "/markets/#{market}/orders/#{order_id}"
    else
      "/markets/#{market}"

  trade: (ask_or_bid) ->
    gon.i18n[ask_or_bid]

  short_trade: (type) ->
    if type == 'buy' or type == 'bid'
      gon.i18n['bid']
    else if type == "sell" or type = 'ask'
      gon.i18n['ask']
    else
      'n/a'

  trade_time: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("MM/DD")} #{m.format("HH:mm")}#{m.format(":ss")}"

  fulltime: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("MM/DD HH:mm")}"

  mask_fixed_price: (price) ->
    @.fixPriceGroup(price).replace(/\..*/, "<g>$&</g>")

  long_time: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("YYYY/MM/DD HH:mm")}"

  mask_fixed_volume: (volume) ->
    @.fixAsk(volume).replace(/\..*/, "<g>$&</g>")

  fix_ask: (volume) ->
    @.fixAsk volume

  fix_bid: (price) ->
    @.fixBid price

  amount: (amount, price) ->
    val = (new BigNumber(amount)).times(new BigNumber(price))
    @.fixAsk(val).replace(/\..*/, "<g>$&</g>")

  trend: (type) ->
    if @.check_trend(type)
      "text-up"
    else
      "text-down"

  trend_icon: (type) ->
    if @.check_trend(type)
      "<i class='fa fa-caret-up text-up'></i>"
    else
      "<i class='fa fa-caret-down text-down'></i>"

  volume: (origin, volume) ->
    if (origin is volume) or (BigNumber(volume).isZero())
      @.fixAsk origin
    else
      @.fixAsk volume

  t: (key) ->
    gon.i18n[key]

window.formatter = new Formatter()
