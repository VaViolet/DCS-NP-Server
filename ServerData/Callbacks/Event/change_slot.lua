ServerData.onEvent.change_slot = function(eventName, playerID, arg2, arg3, arg4, arg5, arg6, arg7)
  local _master_type, _master_slot, _sub_slot = ServerData.GetMulticrewAllParameters(playerID)
  if _sub_slot == nil then
    _sub_slot = ''
  else
    _sub_slot = ' (' .. _sub_slot .. ')  '
  end
  local ucid = net.get_player_info(playerID, 'ucid')
  local name = net.get_player_info(playerID, 'name')
  ServerData.LogStatsCount(playerID, 'init')
  ServerData.PlayersTableCache['p' .. playerID] = net.get_player_info(playerID)
  local content = ServerData.SideID2Name(net.get_player_info(playerID, 'side')) .. '玩家' .. name .. '更换' .. _master_type .. _sub_slot

  ServerData.LogEvent(eventName, ucid, name, content)
end
