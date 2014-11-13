@ToDaMoonData = flight.component ->
  @after 'initialize', ->
    component = @

    join_room = (data) ->
      console.log 'join_room', data
      @.socket = new Phoenix.Socket("ws://#{gon.config.chat_host}:#{gon.config.chat_port}/ws")

      @.socket.join "rooms", "lobby", data, (chan) =>
        chan.on 'join', ->
          component.off document, 'todamoon:send'
          component.on document, 'todamoon:send', (event, message) ->
            chan.send('new:msg', body: message.body)

        chan.on 'rejoin', ->
          window.alert 'rejoin !!!!!!!!!!!!!!!!!!'

        chan.on "user:entered", (message) ->
          component.trigger 'todamoon:user:enter', message

        chan.on "new:msg", (message) ->
          component.trigger 'todamoon:receive', message

    if gon.current_user
      $.ajax
        type: "POST"
        url: "/todamoon/auth"
        success: (d) ->
          join_room(d)
    else
      join_room({})
