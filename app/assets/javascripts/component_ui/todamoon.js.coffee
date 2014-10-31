@ToDaMoonUI = flight.component ->
  @after 'initialize', ->
    @.socket = new Phoenix.Socket("ws://#{gon.config.chat_host}:#{gon.config.chat_port}/ws")
