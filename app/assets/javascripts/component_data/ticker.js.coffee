@TickerData = flight.component ->
  @refresh = ->
    $.ajax('api/v2/tickers.json').done (data) =>
      @.trigger("ticker:#{market}", {ticker: d.ticker}) for market, d of data
    
  @after 'initialize', ->
    refresh = =>
      @refresh()
    window.setInterval refresh, 5000
    refresh()
