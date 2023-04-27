ServerData.onEvent.self_kill = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"self_kill", playerID
  -- ServerData.LogStats(arg1)
  local ucid = net.get_player_info(arg1, 'ucid')
  local name = net.get_player_info(arg1, 'name')

  ServerData.LogEvent(eventName, ucid, name, net.get_player_info(arg1, 'name') .. ' 自杀')
end
