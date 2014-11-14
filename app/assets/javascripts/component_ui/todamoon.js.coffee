@ToDaMoonUI = flight.component ->
  @attributes
    'send': 'a.send'
    'box': 'input.box'

  @after 'initialize', ->

    # at          通知消息时间戳
    # uid         用户唯一标识
    # nickname    用户昵称
    # limit_at    禁言到达时间戳
    # body        消息内容
    # sec         秒数

    # 支持命令事件
    # todamoon:cmd:send(body) 发送消息
    # todamoon:cmd:set_excessively_send(uid, sec) 禁言某用户

    @on @select('send'), 'click', =>
      @trigger document, 'todamoon:cmd:send', body: @select('box').val()

    # 当前用户加入聊天室
    @on document, 'todamoon:notify:join', ->
      console.log 'todamoon:notify:join'

    # 当前用户重复加入聊天室（连接已经断开）
    @on document, 'todamoon:notify:rejoin', ->
      console.log 'todamoon:notify:rejoin'

    # 某用户进入聊天室
    # uid, at, nickname
    @on document, 'todamoon:user:enter', (e, d) ->
      console.log 'todamoon:user:enter', d

    # 某用户在聊天室中发言
    # body, at, nickname
    @on document, 'todamoon:user:send', (e, d) ->
      console.log 'todamoon:user:send', d

    # 某用户被管理员限制发言
    # limit_at, uid, at, nickname
    @on document, 'todamoon:user:limit_send', (e, d) ->
      console.log 'todamoon:user:limit_send', d

    # 当前用户发言过快（未到达发言时限，默认间隔1秒）
    # limit_at
    @on document, 'todamoon:error:excessively_send', (e, d) ->
      console.log 'todamoon:error:excessively_send', d

    # 当前用户被管理员禁言
    # limit_at 禁言解除时间戳
    @on document, 'todamoon:error:limit_send', (e, d) ->
      console.log 'todamoon:error:limit_send', d
