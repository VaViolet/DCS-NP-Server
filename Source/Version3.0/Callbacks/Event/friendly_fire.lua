SourceCall = SourceCall or {}

SourceCall.friendly_fire = function(eventName, playerID, weaponName, victimPlayerID)
  local ucid = net.get_player_info(playerID, "ucid")
  local name = net.get_player_info(playerID, "name")
  local ipaddr = net.get_player_info(playerID, "ipaddr")
  SourceCall.PlayerInfo[ucid]["KillFriend"] = SourceCall.PlayerInfo[ucid]["KillFriend"] + 1
  -- net.log("次数:", SourceCall.PlayerInfo[ucid]["KillFriend"])
  -- net.log("第1个条件:", os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["loginTime"]) < 1800, SourceCall.PlayerInfo[ucid]["KillFriend"] >= 2)
  -- net.log("第2个条件:", os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["quitTime"]) > 1800, SourceCall.PlayerInfo[ucid]["KillFriend"] < 3)
  -- net.log("第3个条件:", os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["loginTime"]) > 1800, SourceCall.PlayerInfo[ucid]["KillFriend"] > 3)
  if os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["loginTime"]) < 1800 and SourceCall.PlayerInfo[ucid]["KillFriend"] == 2 then
    SourceCall.PlayerInfo[ucid]["quitTime"] = os.time()
    FileData.SaveData(SourceCall.PlayerInfoFile, net.lua2json(SourceCall.PlayerInfo))
    net.kick(playerID, "30分钟内击杀友军" .. tostring(SourceCall.PlayerInfo[ucid]["KillFriend"]) .. "次")
  elseif os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["loginTime"]) < 1800 and SourceCall.PlayerInfo[ucid]["KillFriend"] >= 3 then
    -- SourceCall.BannedClients[name] = {ipaddr = ipaddr, ucid = ucid, reason = "击杀友军"}
    -- FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
    net.kick(playerID, "30分钟内击杀友军" .. tostring(SourceCall.PlayerInfo[ucid]["KillFriend"]) .. "次")
    SourceCall.PlayerInfo[ucid]["KillFriend"] = 0
    FileData.SaveData(SourceCall.PlayerInfoFile, net.lua2json(SourceCall.PlayerInfo))
  elseif os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["quitTime"]) > 1800 and SourceCall.PlayerInfo[ucid]["KillFriend"] < 2 then
    SourceCall.PlayerInfo[ucid]["KillFriend"] = 0
    FileData.SaveData(SourceCall.PlayerInfoFile, net.lua2json(SourceCall.PlayerInfo))
  elseif os.difftime(os.time(), SourceCall.PlayerInfo[ucid]["quitTime"]) > 1800 and SourceCall.PlayerInfo[ucid]["KillFriend"] > 2 then
    -- SourceCall.BannedClients[name] = {ipaddr = ipaddr, ucid = ucid, reason = "击杀友军"}
    -- FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
    -- net.kick(playerID, "60分钟内击杀友军" .. tostring(SourceCall.PlayerInfo[ucid]["KillFriend"]) .. "次,你已被永久封禁")
    net.kick(playerID, "60分钟内击杀友军" .. tostring(SourceCall.PlayerInfo[ucid]["KillFriend"]) .. "次")
  end
end
