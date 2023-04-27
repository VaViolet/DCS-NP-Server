local sourceMissionEvent = {}
sourceMissionEvent.eventHandler = {}
function sourceMissionEvent.eventHandler:onEvent(event)
  local status, error =
    pcall(
    function(event)
      if event == nil or event.initiator == nil then
        return false
      elseif event.id == world.event.S_EVENT_PILOT_DEAD and event.initiator ~= nil then
        if event.initiator:getPlayerName() ~= nil then
          if SourceObj.playerInfo[event.initiator:getPlayerName()] then
            SourceObj.updateSourcePointsByEvent(event.initiator, SourceObj.playerInfo[event.initiator:getPlayerName()], "pilotDead")
          end
        end
      elseif event.id == world.event.S_EVENT_TAKEOFF and event.initiator ~= nil then
        if event.initiator:getPlayerName() ~= nil then
          if SourceObj.playerInfo[event.initiator:getPlayerName()] then
            SourceObj.updateSourcePointsByEvent(event.initiator, SourceObj.playerInfo[event.initiator:getPlayerName()], "takeoff")
			SourceObj.updateTeamSourcePointsByEvent(event.initiator, SourceObj.playerInfo[event.initiator:getPlayerName()], "takeoff")
          end
        end
      elseif event.id == world.event.S_EVENT_LAND and event.initiator ~= nil then
        if SourceObj.playerInfo[event.initiator:getPlayerName()] then
          SourceObj.updateSourcePointsByEvent(event.initiator, SourceObj.playerInfo[event.initiator:getPlayerName()], "landing")
		 SourceObj.updateTeamSourcePointsByEvent(event.initiator, SourceObj.playerInfo[event.initiator:getPlayerName()], "landing")
        end
      elseif event.id == world.event.S_EVENT_BIRTH and event.initiator ~= nil then
        SourceObj.onBirth(event.initiator)
		SourceObj.onTeamBirth(event.initiator)
      elseif event.id == world.event.S_EVENT_KILL or event.id == 29 and event.initiator ~= nil and event.target ~= nil then
        if event.initiator:getPlayerName() ~= nil then
          if SourceObj.playerInfo[event.initiator:getPlayerName()] then
            SourceObj.updateSourcePointsByEvent(event, SourceObj.playerInfo[event.initiator:getPlayerName()], "kill")
			SourceObj.updateTeamSourcePointsByEvent(event, SourceObj.playerInfo[event.initiator:getPlayerName()], "kill")
          end
        end
      else
      end
    end,
    event
  )
  if (not status) then
    env.error(string.format("资源系统任务事件处理时出错:%s", error), false)
  end
end

world.addEventHandler(sourceMissionEvent.eventHandler)

env.info("资源系统任务事件监听已添加")
