ServerData.onEvent.pilot_death = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"pilot_death", playerID, unit_missionID
  ServerData.LogStatsCountCrew(arg1, 'pilot_death') -- TBD crew or initiator only?

  local ucid = net.get_player_info(arg1, 'ucid')
  local name = net.get_player_info(arg1, 'name')

  ServerData.LogEvent(eventName, ucid, name, ServerData.SideID2Name(net.get_player_info(arg1, 'side')) .. ' 玩家 ' .. ServerData.GetMulticrewCrewNames(arg1) .. ' 驾驶 ' .. DCS.getUnitType(arg2) .. ' 阵亡')
end
