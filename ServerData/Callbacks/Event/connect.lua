ServerData.onEvent.connect = function(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
  --"connect", playerID, name
  local ucid = net.get_player_info(arg1, 'ucid')
  local name = net.get_player_info(arg1, 'name')
  ServerData.LogEvent(eventName, ucid, name, '玩家' .. name .. ' 已连接到服务器')
  ServerData.PlayersTableCache['p' .. arg1] = net.get_player_info(arg1)
end

---记录玩家登录数据
---@param playerID any
ServerData.LogLogin = function(playerID)
  -- Player logged in
  local ucid = net.get_player_info(playerID, 'ucid')
  local _TempData = {}
  _TempData['name'] = net.get_player_info(playerID, 'name')
  _TempData['ucid'] = ucid
  _TempData['lang'] = net.get_player_info(playerID, 'lang')
  _TempData['ping'] = net.get_player_info(playerID, 'ping')
  _TempData['ipaddr'] = net.get_player_info(playerID, 'ipaddr')
  _TempData['loginTime'] = os.date('%Y-%m-%d %H:%M:%S')

  ServerData.PlayersData[ucid] = _TempData
end
