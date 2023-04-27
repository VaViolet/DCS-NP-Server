-- ServerData for DCS World https://github.com/szporwolik/ServerData -> DCS Hook component

ServerData.callbacks.onMissionLoadEnd = function()
  -- Simulation was started
  ServerData.MissionHash = ServerData.GenerateMissionHash()
  ServerData.PlayersData = {}
  ServerData.eventData = {}
  ServerData.PlayersTableCache = {}
  ServerData.SlotsData = {}
  ServerData.MissionData = {}
  -- reset so mission information will be send
  -- 重置,以便发送任务信息
  ServerData.lastSentMission = 0
end
ServerData.callbacks.onGameEvent = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --[[
      net.log('----------------测试结束-----------')
      net.log(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
      net.log('----------------测试开始-----------')
  --]]
  -- Game event has occured
  -- 发生了游戏事件
  local calls = {}
  calls.connect = ServerData.onEvent.connect
  calls.change_slot = ServerData.onEvent.change_slot
  calls.takeoff = ServerData.onEvent.takeoff --起飞
  calls.landing = ServerData.onEvent.landing
  calls.kill = ServerData.onEvent.kill
  calls.self_kill = ServerData.onEvent.self_kill
  calls.friendly_fire = ServerData.onEvent.friendly_fire
  calls.pilot_death = ServerData.onEvent.pilot_death
  calls.crash = ServerData.onEvent.crash
  calls.eject = ServerData.onEvent.eject
  calls.mission_end = ServerData.onEvent.mission_end
  calls.disconnect = ServerData.onEvent.disconnect
  local call = calls[eventName]
  if call ~= nil then
    if not ServerData.testServer(arg1) then
      call(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    end
  else
    ServerData.LogEvent(eventName, 'Unknown event type', nil, nil)
  end
end

if DCS.isServer() then
  ServerData.MissionHash = ServerData.GenerateMissionHash() -- Generate initial missionhash
  --Set user callbacs,map DCS event handlers with functions defined above
  --设置用户callbacs,使用上面定义的功能映射DCS事件处理程序
  DCS.setUserCallbacks(ServerData.callbacks)
end
