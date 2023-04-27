do
  SourceCall = SourceCall or {}
  SourceCall.JSON = require("JSON")
  SourceCall.Config_Dir = lfs.writedir() .. [[SourceData/]]
  SourceCall.pause_when_empty = false --动态暂停(仅主机一人时)
  SourceCall.AdminFile = SourceCall.Config_Dir .. "管理员列表.json"
  SourceCall.PlayerInfoFile = SourceCall.Config_Dir .. "玩家信息.json"
  SourceCall.BannedClientsFile = SourceCall.Config_Dir .. "封禁列表.json"
  SourceCall.BannedClients = FileData.load_File(SourceCall.BannedClientsFile) or {}
  SourceCall.Admins = FileData.load_File(SourceCall.AdminFile) or {}
  SourceCall.PlayerInfo = FileData.load_File(SourceCall.PlayerInfoFile) or {}
  -------------------------------------------------聊天记录------------------------------------------------
  SourceCall.ChatLogDir = SourceCall.Config_Dir .. [[聊天记录/]]
  SourceCall.ChartLog = true
  SourceCall.log_only_important_server_messages = false --仅记录重要的服务器消息
  --创建聊天消息日志
  if SourceCall.ChartLog then
    local file, err = io.open(SourceCall.ChatLogDir .. os.date("%Y-%m-%d.txt"), "a")
    if err then
      net.log("聊天记录文件夹不存在,正在创建...")
      lfs.mkdir(SourceCall.ChatLogDir)
      SourceCall.chatLogFile = io.open(SourceCall.ChatLogDir .. os.date("%Y-%m-%d.txt"), "w")
      return
    end
    SourceCall.chatLogFile = file
  end
end
