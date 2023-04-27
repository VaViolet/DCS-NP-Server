ServerData.onEvent.friendly_fire = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"friendly_fire", playerID, weaponName, victimPlayerID
  if arg2 == '' then
    arg2 = '未知武器'
  end

  local ucid = net.get_player_info(arg1, 'ucid')
  local name = net.get_player_info(arg1, 'name')
  ServerData.LogEvent(eventName, ucid, name, ServerData.SideID2Name(net.get_player_info(arg1, 'side')) .. '玩家' .. ServerData.GetMulticrewCrewNames(arg1) .. '击杀友军' .. ServerData.GetMulticrewCrewNames(arg3) .. '使用' .. arg2)
end
