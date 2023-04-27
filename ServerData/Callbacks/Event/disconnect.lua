ServerData.onEvent.disconnect = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"disconnect", playerID, name, playerSide, reason_code
  local ucid = net.get_player_info(arg1, 'ucid')
  ServerData.LogEvent(eventName, ucid, arg2, '玩家' .. arg2 .. ' 断开连接 (' .. arg4 .. ').')
end
