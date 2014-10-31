@ToDaMoonUI = flight.component ->
  @after 'initialize', ->
    @.socket = new Phoenix.Socket("ws://#{gon.config.chat_host}:#{gon.config.chat_port}/ws")

    @.socket.join "rooms", "lobby", {}, (chan) ->
      chan.on "join", (message) ->
        console.log 'joined'

      chan.on "new:message", (message) ->
        console.log "message: #{message}"

      chan.on "user:entered", (msg) ->
        console.log "user: #{msg.username || "anonymous"}"
