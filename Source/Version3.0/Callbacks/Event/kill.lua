SourceCall = SourceCall or {}

SourceCall.kill = function(eventName, killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName)
  local kdata = net.get_player_info(killerPlayerID)
  local vdata = net.get_player_info(victimPlayerID)
  if kdata == nil then
    kdata = {}
    kdata.ucid = "00000000000000000000000000000000"
    kdata.name = "AI"
  end
  if vdata == nil then
    vdata = {}
    vdata.ucid = "00000000000000000000000000000000"
    vdata.name = "AI"
  end
end
