@ToDaMoonUI = flight.component ->
  @attributes
    'send': 'a.send'
    'box': 'input.box'

  @after 'initialize', ->
    @on @select('send'), 'click', =>
      @trigger document, 'todamoon:send', body: @select('box').val()

    @on document, 'todamoon:user:enter', (e, d) ->
      console.log 'user:enter', d
      @$node.append(JST['templates/todamoon/user_enter'](d))

    @on document, 'todamoon:receive', (e, d) ->
      console.log 'receive', d
      @$node.append(JST['templates/todamoon/receive'](d))

    @on document, 'todamoon:rejoin', (e, d) ->
      console.log 'rejoin', d
      @$node.append(JST['templates/todamoon/rejoin'](d))

    @on document, 'todamoon:excessively:send', (e, d) ->
      console.log 'excessively:send', d

