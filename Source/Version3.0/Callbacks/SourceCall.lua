SourceCall = SourceCall or {}
SourceCall.PlayerName = SourceCall.PlayerName or {}

-------------------------------------------------------游戏事件开始--------------------------------------------------

function SourceCall.onPlayerTryConnect(ipaddr, name, ucid, playerID)
  if Utils.is_includeTable(ucid, SourceCall.BannedClients) or Utils.is_includeTable(ipaddr, SourceCall.BannedClients) then
    return false, "你被封禁了，加QQ群联系管理员了解详细情况！"
  end
end

function SourceCall.onPlayerConnect(id)
  SourceCall.clients = SourceCall.clients or {}
  SourceCall.clients[id] = {id = id, ipaddr = net.get_player_info(id, "ipaddr"), name = net.get_player_info(id, "name"), ucid = net.get_player_info(id, "ucid"), ip = net.get_player_info(id, "ipaddr")}
  if not SourceCall.num_clients then
    SourceCall.num_clients = 1
  else
    SourceCall.num_clients = SourceCall.num_clients + 1
  end

  local name = net.get_player_info(id, "name")
  local ucid = net.get_player_info(id, "ucid")
  SourceCall.PlayerName[name] = ucid
  if DCS.isServer() and DCS.isMultiplayer() and name and ucid and id ~= net.get_my_player_id() then
    net.dostring_in("mission", 'a_do_script(\'SourceObj.updatePlayerInfo("' .. name .. '", "' .. ucid .. '")\')')
    --保存玩家详细信息
    if SourceCall.PlayerInfo[ucid] == nil then
      SourceCall.PlayerInfo[ucid] = {}
    end
    local tempQuitTime = SourceCall.PlayerInfo[ucid]["quitTime"] or 0
    local tempKillFriend = SourceCall.PlayerInfo[ucid]["KillFriend"] or 0
    SourceCall.PlayerInfo[ucid] = net.get_player_info(id)
    SourceCall.PlayerInfo[ucid]["loginTime"] = os.time()
    if tempQuitTime == 0 or tempQuitTime == nil then
      SourceCall.PlayerInfo[ucid]["quitTime"] = os.time()
    else
      SourceCall.PlayerInfo[ucid]["quitTime"] = tempQuitTime
    end
    SourceCall.PlayerInfo[ucid]["KillFriend"] = tempKillFriend
    FileData.SaveData(SourceCall.PlayerInfoFile, net.lua2json(SourceCall.PlayerInfo))
  end
end

function SourceCall.onPlayerStart(id)

end

function SourceCall.onPlayerTrySendChat(id, msg, all)
  local ucid = net.get_player_info(id, "ucid")
  local name = net.get_player_info(id, "name")
  local realString = Cut_tail_spaces(msg)
  local REXtext = Split_by_space(realString)
  AdminCmd(REXtext, id, ucid, name)
  PlayerCmd(REXtext, id, ucid, name)
  ChatFile(id, realString, all)
end

function SourceCall.onPlayerDisconnect(id)

  SourceCall.clients = SourceCall.clients or {} --should not be necessary.
  local ucid
  if SourceCall.clients[id] then
    ucid = SourceCall.clients[id].ucid
    SourceCall.clients[id] = nil
    SourceCall.num_clients = SourceCall.num_clients - 1
  end

  if DCS.isServer() and DCS.isMultiplayer() and ucid and id ~= net.get_my_player_id() then
    net.dostring_in("mission", 'a_do_script(\'SourceObj.clearAutoAddSourcePoint("' .. ucid .. '")\')')
  end
end

function SourceCall.onGameEvent(eventName, playerID, ...)
  -- net.log("onGameEvent事件详情: --> " .. eventName .. " : " .. net.lua2json({playerID = playerID, ...}))
  local calls = {}
  calls.change_slot = SourceCall.change_slot
  calls.takeoff = SourceCall.takeoff
  calls.friendly_fire = SourceCall.friendly_fire
  calls.self_kill = SourceCall.self_kill
  calls.kill = SourceCall.kill
  calls.pilot_death = SourceCall.pilot_death
  calls.eject = SourceCall.eject
  calls.crash = SourceCall.crash
  calls.landing = SourceCall.landing
  local call = calls[eventName]
  if call and not Utils.checkServer(playerID) then
    call(eventName, playerID, ...)
  end
end
function SourceCall.onMissionLoadEnd()
  if DCS.getRealTime() > 0 then
    SourceCall.mission_start_time = DCS.getRealTime() --需要防止CTD引起的C Lua的API上net.pause和net.resume
  end
end
function SourceCall.onSimulationFrame()
  if SourceCall.mission_start_time then
    if SourceCall.pause_when_empty and (DCS.getRealTime() > SourceCall.mission_start_time + 8) then -- 8秒窗口以希望总是避免CTD
      if DCS.getPause() == false then
        SourceCall.pause_forced = false -- 如果服务器由于任何原因未暂停，请关闭强制暂停。
      end
      if not SourceCall.pause_override then --暂停覆盖不是false
        if (SourceCall.num_clients and SourceCall.num_clients == 1 or not SourceCall.num_clients) and DCS.getPause() == false then
          DCS.setPause(true)
        elseif SourceCall.num_clients and SourceCall.num_clients > 1 and DCS.getPause() == true and (not SourceCall.pause_forced) then
          DCS.setPause(false)
        end
      end
    end
  end
end
function SourceCall.onSimulationStop()
end
-------------------------------------------------------游戏事件结束--------------------------------------------------
DCS.setUserCallbacks(SourceCall)
