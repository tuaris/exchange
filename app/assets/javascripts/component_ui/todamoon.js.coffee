@ToDaMoonUI = flight.component ->
  @attributes
    'send': 'a.send'
    'box': 'input.box'

  @after 'initialize', ->
    @on @select('send'), 'click', =>
      @trigger document, 'todamoon:send', body: @select('box').val()

    @on document, 'todamoon:user:enter', (e, d) ->
      console.log 'user:enter', e, d

    @on document, 'todamoon:receive', (e, d) ->
      console.log 'receive', e, d

    @on document, 'todamoon:rejoin', (e, d) ->
      console.log 'receive', e, d
