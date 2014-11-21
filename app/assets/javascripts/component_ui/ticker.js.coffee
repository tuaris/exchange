@TickerUI = flight.component ->
  @attributes
    ticker: 'tr.value'

  @after 'initialize', ->
    @on document, "ticker:#{@$node.data('market')}", (event, data) =>
      template = JST['templates/homepage_ticker'](data.ticker)
      $ticker = @select('ticker')
      $ticker.empty().append(template)
    @on 'click', =>
      window.location.href = formatter.market_url(@$node.data('market'))
