AdminCmd = function(REXtext, playerID, ucid, name)
  if REXtext[1] == "-admin" and REXtext[2] == "h" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local text =
        string.format(
        "管理员命令\n                               1.增加管理员\n  -admin addAdmin name\n                    2.删除管理员\n  -admin removeAdmin name\n              3.给玩家增加资源点\n  -admin addPoint name point\n   4.给玩家减少资源点\n  -admin lessPoint name point\n  5.封禁玩家\n   -admin ban name 备注(可不填)\n            6.解封玩家\n   -admin unban name\n                            7.暂停游戏\n   -admin pause\n                                     8.解除暂停\n   -admin unpause\n                                9. 启用空服务器自动暂停\n    -admin emptyPause\n        10.禁用空服务器自动暂停\n   -admin unEmptyPause\n   11.移动玩家到观众席   -admin forcePlayerSlot name"
      )
      net.send_chat_to(text, playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "addAdmin" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] then
        SourceCall.add_admins({name = REXtext[3], ucid = SourceCall.PlayerName[REXtext[3]]}, playerID)
      else
        net.send_chat_to("addAdmin:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "removeAdmin" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local id = Utils.Is_include(REXtext[3], SourceCall.Admins)
      if id then
        SourceCall.less_admins({name = REXtext[3], ucid = id}, playerID)
      else
        net.send_chat_to("removeAdmin:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "addPoint" and REXtext[3] and REXtext[4] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      -- -admin addPoint Admin 1000
      if SourceCall.PlayerName[REXtext[3]] then
        local fun_str = [[a_do_script('SourceObj.addSourcePoint("]] .. SourceCall.PlayerName[REXtext[3]] .. '",' .. REXtext[4] .. [[)')]]
        net.dostring_in("mission", fun_str)
        net.send_chat_to(string.format("%s资源点已增加%d点", REXtext[3], REXtext[4]), playerID)
      else
        net.send_chat_to("addPoint:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "lessPoint" and REXtext[3] and REXtext[4] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] then
        local fun_str = [[a_do_script('SourceObj.lessSourcePoint("]] .. SourceCall.PlayerName[REXtext[3]] .. '",' .. REXtext[4] .. [[)')]]
        net.dostring_in("mission", fun_str)
        net.send_chat_to(string.format("%s资源点已减少%d点", REXtext[3], REXtext[4]), playerID)
      else
        net.send_chat_to("lessPoint:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "ban" and REXtext[3] then
    net.log("满足条件: ", REXtext[1] == "-admin" and REXtext[2] == "ban" and REXtext[3] or REXtext[4])
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] then
        SourceCall.BannedClients[REXtext[3]] = {
          ipaddr = SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["ipaddr"],
          ucid = SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["ucid"]
        }
        if REXtext[4] then
          SourceCall.BannedClients[REXtext[3]].reason = REXtext[4]
          FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
          net.kick(SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["id"], REXtext[4])
        else
          FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
          net.kick(SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["id"])
        end
        net.send_chat_to("玩家:" .. REXtext[3] .. "已被封禁", playerID)
      else
        net.send_chat_to("ban:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "unban" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.BannedClients[REXtext[3]] then
        SourceCall.BannedClients[REXtext[3]] = nil
        FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
        net.send_chat_to("玩家:" .. REXtext[3] .. "已解封", playerID)
      else
        net.send_chat_to("unban:未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "pause" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      SourceCall.pause_override = true
      if not DCS.getPause() then
        DCS.setPause(true)
      end
      net.send_chat_to("已暂停", playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "unpause" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      SourceCall.pause_override = false
      SourceCall.pause_forced = false
      if DCS.getPause() then
        DCS.setPause(false)
      end
      net.send_chat_to("暂停已解除", playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "emptyPause" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      SourceCall.pause_when_empty = true
      net.send_chat_to("已启用空时服务器将自动暂停.", playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "unEmptyPause" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      SourceCall.pause_when_empty = false
      net.send_chat_to("已禁用空时服务器将自动暂停.", playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "forcePlayerSlot" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["id"] then
        net.force_player_slot(SourceCall.PlayerInfo[SourceCall.PlayerName[REXtext[3]]]["id"], 0, "")
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
	  elseif REXtext[1] == "-admin" and REXtext[2] == "addTeamPoint" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local fun_str = [[a_do_script('SourceObj.addSourceTeamPoint("]] .. REXtext[3] .. '",' .. REXtext[4] .. [[)')]]
      net.dostring_in("mission", fun_str)
      net.send_chat_to(string.format("红方资源点已增加%d点", REXtext[4]), playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "lessTeamPoint" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local fun_str = [[a_do_script('SourceObj.lessSourceTeamPoint("]] .. REXtext[3] .. '",' .. REXtext[4] .. [[)')]]
      net.dostring_in("mission", fun_str)
      net.send_chat_to(string.format("蓝方资源点已减少%d点", REXtext[4]), playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  end
end
