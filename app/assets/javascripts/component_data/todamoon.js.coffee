@ToDaMoonData = flight.component ->
  @after 'initialize', ->
    component = @

    join_room = (data) ->
      @.socket = new Phoenix.Socket(gon.config.chat_uri)

      @.socket.join "rooms", "lobby", data, (chan) =>

        chan.on 'notify:join', (d) ->
          if d.status == 'connected'
            component.trigger 'todamoon:notify:join', d
            component.off document, 'todamoon:cmd:send'
            component.on document, 'todamoon:cmd:send', (event, message) ->
              chan.send('cmd:send', body: message.body)
            component.on document, 'todamoon:cmd:set', (event, message) ->
              chan.send('cmd:set', message)
            component.on document, 'todamoon:cmd:set_excessively_send', (event, message) ->
              chan.send('cmd:set_excessively_send', message)
            component.on document, 'todamoon:cmd:set_freely_send', (event, message) ->
              chan.send('cmd:set_freely_send', message)
          else if d.status == 'reconnected'
            component.trigger 'todamoon:notify:rejoin'
            chan.socket.close()
            chan.socket = null

        chan.on "notify:freely_send", (d) ->
          component.trigger 'todamoon:notify:freely_send'

        chan.on "user:enter", (d) ->
          component.trigger 'todamoon:user:enter', d

        chan.on "user:leave", (d) ->
          component.trigger 'todamoon:user:leave', d

        chan.on "user:send", (d) ->
          component.trigger 'todamoon:user:send', d

        chan.on "user:limit_send", (d) ->
          component.trigger 'todamoon:user:limit_send', d
          
        chan.on "user:set", (d) ->
          component.trigger 'todamoon:user:set', d

        chan.on "room:info", (d) ->
          component.trigger 'todamoon:room:info', d

        chan.on "error:excessively_send", (d) ->
          component.trigger 'todamoon:error:excessively_send', d

        chan.on "error:limit_send", (d) ->
          component.trigger 'todamoon:error:limit_send', d

    if gon.current_user
      $.ajax
        type: "POST"
        url: "/todamoon/auth"
        success: (d) ->
          join_room(d)
    else
      join_room({})
