ServerData.callbacks.onSimulationFrame = function()
  -- Repeat for each simulator frame
  -- 重复每个模拟器帧
  local _now = DCS.getRealTime()
  ServerData.lastFrameStart = _now
  -- Send mission update - First run or update required (set on connection errors)
  -- 发送任务更新-首次运行或需要更新（针对连接错误进行设置）
  if ServerData.lastSentMission == 0 and _now > 0 then
    ServerData.lastSentMission = _now
    ServerData.UpdateMission()
    ServerData.UpdateSlots()
  end
  -- Send status update - update required
  -- 发送状态更新-需要更新
  if _now > ServerData.lastSentStatus + ServerData.RefreshStatus then
    ServerData.lastSentStatus = _now
    if not ServerData.isEmptytb(ServerData.PlayersData) then
      ServerData.UpdateStatus()
    end
  end
end

ServerData.callbacks.onSimulationStop = function()
  -- 游戏界面已停止
  -- Simulation was stopped
  ServerData.MissionHash = ServerData.GenerateMissionHash()
  ServerData.UpdateStatus()
  ServerData.MissionData = {}
  ServerData.PlayersTableCache = {}
  ServerData.SlotsData = {}
end
