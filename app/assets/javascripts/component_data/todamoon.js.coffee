@ToDaMoonData = flight.component ->
  @after 'initialize', ->
    @.socket = new Phoenix.Socket("ws://#{gon.config.chat_host}:#{gon.config.chat_port}/ws")

    @.socket.join "rooms", "lobby", {}, (chan) =>
      component = @

      chan.on 'join', ->
        component.on document, 'todamoon:send', (event, message) ->
          chan.send('new:msg', message)

      chan.on "user:entered", (message) ->
        component.trigger 'todamoon:user:enter', (message.username || "anonymous")

      chan.on "new:msg", (message) ->
        component.trigger 'todamoon:receive', message
