SourceCall = SourceCall or {}
SourceCall.add_admins = function(client_info, playerID)
  SourceCall.Admins = SourceCall.Admins or {}
  if client_info then
    SourceCall.Admins[client_info.ucid] = client_info.name
  end
  local file_str = net.lua2json(SourceCall.Admins)
  local Admins_File = io.open(SourceCall.AdminFile, "w")
  if Admins_File then
    Admins_File:write(file_str)
    Admins_File:close()
    Admins_File = nil
    net.send_chat_to("添加成功", playerID)
  else
    net.send_chat_to("添加失败,请查看日志", playerID)
    net.log("无法打开或写入" .. SourceCall.AdminFile)
  end
end
SourceCall.less_admins = function(client_info, playerID)
  if client_info then
    SourceCall.Admins[client_info.ucid] = nil
  end
  local file_str = net.lua2json(SourceCall.Admins)
  local Admins_File = io.open(SourceCall.AdminFile, "w")
  if Admins_File then
    Admins_File:write(file_str)
    Admins_File:close()
    Admins_File = nil
    net.send_chat_to("删除成功", playerID)
  else
    net.send_chat_to("添加失败,请查看日志", playerID)
    net.log("无法打开或写入" .. SourceCall.AdminFile)
  end
end
