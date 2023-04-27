ServerData.onEvent.landing = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"landing", playerID, unit_missionID, airdromeName
  local _temp_airfield = ''

  if arg3 ~= '' then
    _temp_airfield = arg3
  end

  ServerData.LogStatsCountCrew(arg1, ServerData.GetTakeOffLandingEvent(false, arg3))

  local ucid = net.get_player_info(arg1, 'ucid')
  local name = net.get_player_info(arg1, 'name')
  ServerData.LogEvent(eventName, ucid, name, ServerData.SideID2Name(net.get_player_info(arg1, 'side')) .. ' 玩家 ' .. ServerData.GetMulticrewCrewNames(arg1) .. ' 驾驶 ' .. DCS.getUnitType(arg2) .. '降落在' .. _temp_airfield)
end
