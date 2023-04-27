--------------------------------    定义ServerData的方法  --------------------------------
---检测是不是空表
---@param tbl any
---@return boolean 空返回true,反之为false
ServerData.isEmptytb = function(tbl)
  -- Make next function local - this improves performance
  -- 将next函数设为本地-这样可以提高性能
  local next = next
  return next(tbl) == nil
end
ServerData.getPlayerID = function(data)
  data.playerID = data.id
  data.id = nil
  return data
end

ServerData.testServer = function(id)
  return id == net.get_server_id()
end
ServerData.getServerStamp = function()
  return {ucid = nil, alias = 'SERVER'}
end

---发送消息到TCP服务端
---@param event any 事件类型
---@param data any 消息数据
---@param displayMsg any 是否打印
ServerData.client_send_msg = function(event, data, displayMsg)

  --if data ~= nil then
  --  local result = {
  --    type = 'ServerData',
  --    event = event,
  --    data = data,
  --    executionTime = {
  --      dcs_current_frame_delay = ((DCS.getRealTime() - ServerData.lastFrameStart) * 1000000)
  --    }
  --  }
  --  local code = [[Tools.net.tcp_send_msg(]] .. Tools.table2tring(result) .. [[)]]
  --  result, status = Tools.dostring_api_env(code)
  --  net.log(result, status, code)
  --end
end
