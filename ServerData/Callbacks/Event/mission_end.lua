ServerData.onEvent.mission_end = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"mission_end", winner, msg
  ServerData.LogEvent(eventName, '任务结束, winner ' .. arg1 .. ' message: ' .. arg2)
end
