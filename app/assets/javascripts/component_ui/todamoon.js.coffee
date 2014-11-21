@ToDaMoonUI = flight.component ->
  @attributes
    'send': '.btn-send'
    'box': '#chat-textarea'
    'chatroom': '.chat-body'
    'switcher': '#btn-todamoon'

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
      @select('box').val('')

    # 当前用户加入聊天室
    @on document, 'todamoon:notify:join', ->
      html = JST["templates/todamoon/join"]
      @select('chatroom').append(html)

    # 当前用户重复加入聊天室（连接已经断开）
    @on document, 'todamoon:notify:rejoin', ->
      html = JST["templates/todamoon/join"]({'type':'rejoin'})
      @select('chatroom').append(html)

    # 某用户进入聊天室
    # uid, at, nickname
    @on document, 'todamoon:user:enter', (e, d) ->
      html = JST["templates/todamoon/user_enter"](d)
      @select('chatroom').append(html)

    # 某用户在聊天室中发言
    # body, at, nickname
    @on document, 'todamoon:user:send', (e, d) ->
      d['is_me'] = d['uid'] == gon.current_user['id']
      html = JST["templates/todamoon/receive"](d)
      @select('chatroom').append(html)

    # 某用户被管理员限制发言
    # limit_at, uid, at, nickname
    @on document, 'todamoon:user:limit_send', (e, d) ->
      d['type'] = 'limit_send'
      html = JST["templates/todamoon/announcement"](d)
      @select('chatroom').append(html)

    # 当前用户发言过快（未到达发言时限，默认间隔1秒）
    # limit_at
    @on document, 'todamoon:error:excessively_send', (e, d) ->
      d['type'] = 'excessively_send'
      html = JST["templates/todamoon/announcement"](d)
      @select('chatroom').append(html)

    # 当前用户被管理员禁言
    # limit_at 禁言解除时间戳
    @on document, 'todamoon:error:limit_send', (e, d) ->
      d['type'] = 'forbidden_send'
      html = JST["templates/todamoon/announcement"](d)
      @select('chatroom').append(html)

    @on @select('switcher'), 'click', =>
      if @$node.hasClass('expanded')
        @$node.removeClass('expanded')
      else
        @$node.addClass('expanded')
