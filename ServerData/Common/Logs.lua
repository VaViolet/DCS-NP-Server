--################################ 辅助函数定义(Helper function definitions) ################################
-- Object.Category { UNIT = 1, WEAPON = 2,STATIC = 3, BASE = 4,SCENERY = 5, Cargo = 6}
-- Helper function returns object category basing on https://pastebin.com/GUAXrd2U

---获取阵营名称
---@param id number --side id
---@return any --  阵营名称
ServerData.SideID2Name = function(id)
  -- Helper function returns side name per side (coalition) id
  -- Helper函数按阵营返回每个阵营的名称(coalition) id
  local _sides = {
    [0] = '观众',
    [1] = '红方',
    [2] = '蓝方',
    [3] = '中立者' -- TBD check once this is released in DCS
  }
  if _sides[id] then
    return _sides[id]
  else
    return '神秘阵营'
  end
end

---生成唯一的模拟任务哈希
---@return string
ServerData.GenerateMissionHash = function()
  -- Generates unique simulation mission hash
  return DCS.getMissionName() .. '@' .. ServerData.Version .. '@' .. os.date('%Y%m%d_%H%M%S')
end

---获取所有多机组人员
---@param owner_playerID any 所有者玩家ID
---@return table 所有者玩家
ServerData.GetMulticrewCrew = function(owner_playerID)
  -- Get all multicrew crew
  -- 获取所有多机组人员
  local _master_type, _master_slot, _sub_slot = ServerData.GetMulticrewAllParameters(owner_playerID)
  local _crew = {}
  table.insert(_crew, owner_playerID)
  if
    _master_type == 'F-14B' or _master_type == 'Yak-52' or _master_type == 'L-39C' or _master_type == 'SA342M' or _master_type == 'SA342Minigun' or _master_type == 'SA342Mistral' or _master_type == 'SA342L' or _master_type == 'F-14A-135-GR' or _master_type == 'C-101EB' or _master_type == 'UH-1H' or
      _master_type == 'C-101CC'
   then
    -- TBD add additional multicrew model types
    -- TBD添加额外的多机组模型类型
    local _owner_side = net.get_player_info(owner_playerID, 'side')

    if _master_slot and _master_slot ~= '' then
      -- Search for all players from crew
      -- 从所有玩家搜索机组人员
      local _all_players = net.get_player_list()
      for PlayerIDIndex, _playerID in ipairs(_all_players) do
        local _playerDetails = net.get_player_info(_playerID)
        if
          _playerDetails.side == _owner_side and (_playerDetails.slot == _master_slot or _playerDetails.slot == _master_slot .. '_1' or _playerDetails.slot == _master_slot .. '_2' or _playerDetails.slot == _master_slot .. '_3' or _playerDetails.slot == _master_slot .. '_4') and
            _playerID ~= owner_playerID
         then
          -- Add to crew list
          -- 添加到机组人员列表
          table.insert(_crew, _playerID)
        else
          -- Do nothing
        end
      end
    end
  end
  return _crew
end
---获取所有机组人员名称并以字符串形式返回(用于记录目的)
---@param owner_playerID any --所有者玩家ID
---@return string 所有机组人员名称
ServerData.GetMulticrewCrewNames = function(owner_playerID)
  -- Get all crew names and return as string (needed for logging purposes)
  -- 获取所有机组人员名称并以字符串形式返回(用于记录目的)
  local _pilots_accounted = ServerData.GetMulticrewCrew(owner_playerID)
  local _result_text = ''
  for _, pilotID in ipairs(_pilots_accounted) do
    _result_text = _result_text .. net.get_player_info(pilotID, 'name') .. ', '
  end
  return _result_text
end
---获取起飞降落事件
---@param takeoff any
---@param location any --地点
---@return string 起飞或者降落的位置名称
ServerData.GetTakeOffLandingEvent = function(takeoff, location)
  -- Get correct event type for statistics basing on objecy which served as runway/farp
  -- 根据 served 和 runway/farp对象获取正确的事件类型以进行统计
  local _operation = ''
  if takeoff == true then
    _operation = 'tookoff_'
  else
    _operation = 'landing_'
  end

  local _temp_type = ''
  if string.find(location, 'FARP', 1, true) then
    _temp_type = 'FARP'
  elseif string.find(location, 'CVN-74 John C. Stennis', 1, true) or string.find(location, 'LHA-1 Tarawa', 1, true) or string.find(location, 'SHIP', 1, true) then
    _temp_type = 'SHIP'
  elseif location ~= '' then
    _temp_type = 'AIRFIELD'
  else
    _temp_type = 'OTHER'
  end

  return _operation .. _temp_type
end
-- ################################ 日志功能(Log functions) ################################

---聊天日志
---@param playerID any
---@param msg any
---@param all any
ServerData.LogChat = function(playerID, msg, all)
  if ServerData.testServer(playerID) then
    return
  end
  -- Logs chat messages
  local _TempData = {}
  _TempData['player'] = net.get_player_info(playerID, 'name')
  _TempData['msg'] = msg
  _TempData['all'] = all
  _TempData['ucid'] = net.get_player_info(playerID, 'ucid')
  _TempData['datetime'] = os.date('%Y-%m-%d %H:%M:%S')
  _TempData['missionhash'] = ServerData.MissionHash
  --TODO 这个网络传送关掉了
  ServerData.client_send_msg('LogChat', _TempData, false)
  Logger.AddLog(_TempData, 1)
end

---事件日志
---@param eventName any 事件类型
---@param ucid any 玩家ucid
---@param name any 玩家name
---@param content any 日志内容
ServerData.LogEvent = function(eventName, ucid, name, content)
  -- Logs events messages
  -- 记录事件消息
  local _TempData = {}
  _TempData['eventName'] = eventName
  _TempData['ucid'] = ucid
  _TempData['name'] = name
  _TempData['content'] = content
  _TempData['createdAt'] = os.date('%Y-%m-%d %H:%M:%S')
  table.insert(ServerData.eventData, _TempData)
end

-- ################################ Data preparation ################################

---状态更新的主要功能
ServerData.UpdateStatus = function()
  -- Update clients data - count connected players
  local _playerlist = net.get_player_list()
  -- Mission data
  local _MissionData = {}
  _MissionData['count_players'] = #_playerlist
  _MissionData['missionhash'] = ServerData.MissionHash
  _MissionData['theatre'] = ServerData.MissionData['theatre']
  ServerData.StatusData = _MissionData
  ServerData.StatusData['PlayerData'] = ServerData.PlayersData
  ServerData.StatusData['eventData'] = ServerData.eventData
  ServerData.client_send_msg('UpdatePlayersData', ServerData.StatusData)
  ServerData.PlayersData = {}
  ServerData.eventData = {}
  ServerData.StatusData = {}
end
---更新并发送插槽数据
ServerData.UpdateSlots = function()
  -- Update and send slots data
  local _now = DCS.getRealTime()
  -- Check if we need to pull the data or we can use the stored one
  -- 检查是否需要提取数据，或者我们可以使用存储的数据
  if ServerData.SlotsData['coalitions'] == nil then
    ServerData.SlotsData['coalitions'] = DCS.getAvailableCoalitions()
    ServerData.SlotsData['slots'] = {}
    -- Build up slot table
    -- 建立插槽表
    for _j, _i in pairs(ServerData.SlotsData['coalitions']) do
      ServerData.SlotsData['slots'][_j] = DCS.getAvailableSlots(_j)
      for _sj, _si in pairs(ServerData.SlotsData['slots'][_j]) do
        ServerData.SlotsData['slots'][_j][_sj]['countryName'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['onboard_num'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['groupSize'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['groupName'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['callsign'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['task'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['airdromeId'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['helipadName'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['multicrew_place'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['role'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['helipadUnitType'] = nil
        ServerData.SlotsData['slots'][_j][_sj]['action'] = nil
      end
    end
  end

  local _delay = (DCS.getRealTime() - _now) * 1000000
  Logger.AddLog('Updated slots data; sending (' .. _delay .. 'us)', 2)
  ServerData.client_send_msg('UpdateSlots', ServerData.SlotsData, false)
end
---任务信息更新的主要功能
ServerData.UpdateMission = function()
  -- Main function for mission information updates
  local _now = DCS.getRealTime()
  -- Check if we need to get mission data
  -- 检查我们是否需要获取任务数据
  if ServerData.isEmptytb(ServerData.MissionData) then
    local mission = DCS.getCurrentMission()['mission']
    local date = os.time {year = mission['date'].Year, month = mission['date'].Month, day = mission['date'].Day}
    ServerData.MissionData = {
      name = DCS.getMissionName(), --返回当前任务的名称
      filename = DCS.getMissionFilename(), --返回当前任务的文件名
      description = DCS.getMissionDescription(), --任务描述
      theatre = mission['theatre'],
      map = mission['map'],
      coalition = mission['coalition'],
      result_red = DCS.getMissionResult('red'),
      result_blue = DCS.getMissionResult('blue'),
      missionhash = ServerData.MissionHash,
      date = os.date('%Y-%m-%d', date)
    }
  --[[
      --返回阵营可用插槽列表。
      DCS.getAvailableCoalitions()
      --获取指定阵营的可用插槽(注意:返回的unitID实际上是一个slotID,对于多座单位它是
      DCS.getAvailableSlots(coalitionID) 'unitID_seatID')
      --获取单位属性
      DCS.getUnitProperty(missionId, propertyId)
      --从配置状态读取一个值。
      DCS.getConfigValue(cfg_path_string)
      -> {{abstime,级别,子系统,消息},...},last_index 返回从给定索引开始的最新日志消息。
      DCS.getLogHistory(from)
      Usage:
      local result = {}
      local id_from = 0
      local logHistory = {}
      local logIndex = 0
      logHistory, logIndex = DCS.getLogHistory(id_from)
      result = {
        logHistory = logHistory,
        new_last_id = logIndex
      }
      return result
     --log.write('WebGUI', log.DEBUG, string.format('%s returned %s!', requestString, net.lua2json(result)))
  --]]
  end
  local _delay = (DCS.getRealTime() - _now) * 1000000
  Logger.AddLog('Updated mission data; sending (' .. _delay .. 'us)', 2)
  ServerData.client_send_msg('UpdateMission', ServerData.MissionData, false)
end
