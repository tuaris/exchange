@TickerUI = flight.component ->
  @after 'initialize', ->
    @on document, "ticker:#{@$node.data('market')}", (event, data) ->
      console.log data
