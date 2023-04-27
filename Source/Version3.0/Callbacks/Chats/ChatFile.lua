ChatFile = function(id, realString, all)
  if SourceCall.chatLogFile and SourceCall.clients[id] then -- 客户端最好存在于SourceCall客户端中！
    -- local clientInfo = table.concat({"{name=", tostring(SourceCall.clients[id].name), ",ucid=", tostring(SourceCall.clients[id].ucid), "}"})
    local clientInfo = string.format("{name=%s,ucid=%s} ", tostring(SourceCall.clients[id].name), tostring(SourceCall.clients[id].ucid))
    local logline
    local writeLog = true
    if realString ~= "/mybad" then
      local chartType = {[-1] = "全体消息", [-2] = "友军消息"}
      if all == -1 or all == -2 then
        logline = os.date("%Y-%m-%d %H:%M:%S ") .. clientInfo .. chartType[all] .. ':"' .. realString .. '"'
        logline = logline .. "\n"
      else
        logline = os.date("%Y-%m-%d %H:%M:%S ") .. clientInfo .. all .. ':"' .. realString .. '"'
        logline = logline .. "\n"
      end
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
