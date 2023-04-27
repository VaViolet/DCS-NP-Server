ServerData.callbacks.onPlayerStart = function(id)
  -- Player entered cocpit
  if not ServerData.testServer(id) then
    net.send_chat_to(ServerData.MOTD_L1, id)
    net.send_chat_to(ServerData.MOTD_L2, id)
  end
end

ServerData.callbacks.onPlayerTrySendChat = function(playerID, msg, all)
  -- Somebody tries to send chat message
  if msg ~= ServerData.MOTD_L1 and msg ~= ServerData.MOTD_L2 and msg ~= ServerData.ConnectionError then
    ServerData.LogChat(playerID, msg, all)
    if string.find(msg, 'qq ') == 1 then
      local data = net.get_player_info(playerID)
      if data ~= nil then
        ServerData.client_send_msg('updateQQ', {qq = msg, ucid = data.ucid})
      -- local cmd, err = UDP.udp:receive()
      -- print("------------接收UDP消息----------------")
      -- print(cmd)
      -- print("----------------------------")
      -- print(err)
      -- print(err == "timeout")
      -- if (err == "timeout" or cmd ~= nil) then
      --   net.send_chat_to("该账号已关联,可以在群进行查询", playerID)
      -- else
      --   net.send_chat_to("该账号关联失败!", playerID)
      -- end
      -- if err == "closed" then
      --   net.send_chat_to("数据库已关闭,暂时无法关联!", playerID)
      -- end
      end
    end
  end
  return msg
end
ServerData.callbacks.onPlayerDisconnect = function(id, err_code)
  -- Player disconnected
  -- ServerData.LogEvent('onPlayerDisconnect', 'Player ' .. id .. ' disconnected.', nil, nil)
end

ServerData.callbacks.onPlayerStop = function(id)
  -- Player left the simulation (happens right before a disconnect, if player exited by desire)
  -- ServerData.LogEvent('onPlayerStop', 'Player ' .. id .. ' quit the server.', nil, nil)
end
