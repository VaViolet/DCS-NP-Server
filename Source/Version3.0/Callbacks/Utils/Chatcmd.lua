Is_include = function(value, tab)
  if tab then
    for k, v in pairs(tab) do
      net.log(k, v)
      if v == value then
        return k
      end
    end
  end
  return false
end

Chatcmd = function(REXtext, playerID, ucid)
  if REXtext[1] == "-admin" and REXtext[2] == "help" or REXtext[2] == "h" then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local text = string.format("管理员命令\n                               1.增加管理员\n  -admin addAdmin name\n                    2.删除管理员\n  -admin removeAdmin name\n              3.给玩家增加资源点\n  -admin addPoint name point\n   4.给玩家减少资源点\n  -admin lessPoint name point\n  5.封禁玩家\n   -admin ban name\n                                6.解封玩家\n   -admin unban name\n")
      net.send_chat_to(text, playerID)
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "addAdmin" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] then
        SourceCall.add_admins({name = REXtext[3], ucid = SourceCall.PlayerName[REXtext[3]]}, playerID)
      else
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "removeAdmin" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      local id = Is_include(REXtext[3], SourceCall.Admins)
      if id then
        SourceCall.less_admins({name = REXtext[3], ucid = id}, playerID)
      else
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
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
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
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
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "ban" and REXtext[3] or REXtext[4] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] then
        local _ucid = SourceCall.PlayerName[REXtext[3]]
        SourceCall.BannedClients[ucid] = {IP = SourceCall.PlayerInfo[_ucid]["ipaddr"], ucid = SourceCall.PlayerInfo[_ucid]["ucid"], name = SourceCall.PlayerInfo[_ucid]["name"]}
        FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
        if REXtext[4] then
          net.kick(SourceCall.PlayerInfo[_ucid]["id"], REXtext[4])
        else
          net.kick(SourceCall.PlayerInfo[_ucid]["id"])
        end
        net.send_chat_to("玩家:" .. REXtext[3] .. "已被封禁", playerID)
      else
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  elseif REXtext[1] == "-admin" and REXtext[2] == "unban" and REXtext[3] then
    if playerID == 1 or SourceCall.Admins[ucid] then
      if SourceCall.PlayerName[REXtext[3]] and SourceCall.BannedClients[SourceCall.PlayerName[REXtext[3]]] then
        SourceCall.BannedClients[SourceCall.PlayerName[REXtext[3]]] = nil
        FileData.SaveData(SourceCall.BannedClientsFile, net.lua2json(SourceCall.BannedClients))
        net.send_chat_to("玩家:" .. REXtext[3] .. "已解封", playerID)
      else
        net.send_chat_to("未找到该用户名相关的玩家", playerID)
      end
    else
      Utils.admin_caveat(ucid, 100, playerID)
    end
  end
end

ChatFile = function(id, realString, all)
  if SourceCall.chatLogFile and SourceCall.clients[id] then -- 客户端最好存在于SourceCall客户端中！
    -- local clientInfo = table.concat({"{name=", tostring(SourceCall.clients[id].name), ",ucid=", tostring(SourceCall.clients[id].ucid), "}"})
    local clientInfo = string.format("{name=%s,ucid=%s}", tostring(SourceCall.clients[id].name), tostring(SourceCall.clients[id].ucid))
    local logline
    local writeLog = true
    if realString ~= "/mybad" then
      local chartType = {[-1] = " 全体消息", [-2] = " 友军消息", [all] = " net.send_chat_to"}
      logline = os.date("%Y-%m-%d %H:%M:%S ") .. clientInfo .. chartType[all] .. ':"' .. realString .. '"'
      logline = logline .. "\n"
    else
      logline = "SCREENSHOT: " .. os.date("%Y-%m-%d %H:%M:%S ") .. clientInfo .. " 截屏\n"
    end
    --有用的SourceCall消息以SourcePoint：或SourcePoint-开头。 删除除主机以外的所有消息
    if id == 1 and SourceCall.log_only_important_server_messages then
      writeLog = false
      if (string.find(logline, "SourcePoint:") and string.find(logline, "SourcePoint:") < 2) or (string.find(logline, "SourcePoint%-") and string.find(logline, "SourcePoint%-") < 2) then
        writeLog = true
      end
    end
    if writeLog == true then
      SourceCall.chatLogFile:write(logline)
      SourceCall.chatLogFile:flush()
    end
  elseif not SourceCall.clients[id] then
    SourceCall.error("来自SourceCall.clients中不存在的客户端的聊天消息！")
  end
end
