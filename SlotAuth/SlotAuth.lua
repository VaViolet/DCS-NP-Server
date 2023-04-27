SLOT = SLOT or {}
SLOT.callbacks = SLOT.callbacks or {}

SLOT.FilePath = lfs.writedir() .. [[SourceData/]] .. '动态槽位限制.json'
SLOT.AuthDataCache = {}
SLOT.teamBalenceCoefficient = 0.25
SLOT.UseNewDynamicSystem = true

function SLOT.callbacks.onPlayerTryChangeSlot(playerID, side, slotID)
    local _side = side
    local _slotID = slotID


    if SLOT.backDoor(playerID) == true then
        return true
    end

    local result = SLOT.teamBalance(_side,playerID)
    if result == nil or result == false then
        return false
    end

    local result = SLOT.allowEnterSlotDynamic(playerID, _side, _slotID)
    if result == nil or result == false then
        return false
    end
end

function SLOT.callbacks.onPlayerTryConnect(addr, name, ucid, playerId)
    --net.log('addr'..addr.."ucid"..ucid.."name"..name.."playerId"..playerId)
    if string.find(name, " ") ~= nil or string.find(name, "　") ~= nil then
        return false, "ID不允许带空格"
    end

    return true
end

function SLOT.callbacks.onPlayerDisconnect(playerId)
end

function SLOT.callbacks.onPlayerTrySendChat(id, msg, all)
    if msg == 'refreshadmin' then
        net.log('SLOTAUTH 动态管理员信息加载完成')
        net.send_chat_to('SLOTAUTH 动态管理员信息加载完成', id)
        SLOT.AuthDataCache = SLOT.LoadFile(SLOT.FilePath)

        net.log('SLOTAUTH 管理员信息')
        for _role, _roleTable in pairs(SLOT.AuthDataCache) do
            net.log('------------载入角色' .. _role .. '-----------------------')
            for _ucid, extra in pairs(_roleTable) do
                net.log('载入ucid:' .. _ucid .. '| 玩家:' .. extra.ID)
            end
        end
    end
end

function SLOT.getFlagValue(_flag)
    local _status, _error = net.dostring_in('server', ' return trigger.misc.getUserFlag("' .. _flag .. '"); ')
    if not _status and _error then
        return tonumber(0)
    else
        --disabled
        return tonumber(_status)
    end
end

function SLOT.teamBalance(_side,_playerID)
    local Players = net.get_player_list()
    local _teamMap = {}
    _teamMap[1] = 0
    _teamMap[2] = 0

    for PlayerIDIndex, playerID in pairs(Players) do
        -- is player still in a valid slot
        local _playerDetails = net.get_player_info(playerID)
        if _playerDetails ~= nil and _playerDetails.side ~= 0 and _playerDetails.slot ~= "" and _playerDetails.slot ~= nil then
            _teamMap[_playerDetails.side] = _teamMap[_playerDetails.side] + 1
        end
    end

    local space = (_teamMap[1] + _teamMap[2]) * SLOT.teamBalenceCoefficient

    if _side == 1 then
        if _teamMap[1] - _teamMap[2]  > space then
            net.send_chat_to('人数不平衡', _playerID)
            return false
        end
    elseif _side == 2 then
        if _teamMap[2] - _teamMap[1]  > space then
            net.send_chat_to('人数不平衡', _playerID)
            return false
        end
    end

    if _teamMap[1] + _teamMap[2]<5 then
        net.send_chat_to('总人数少，允许不平衡', _playerID)
        return true
    end

    return true
end

function SLOT.backDoor(_playerID)
    return SLOT.findIDInTableDynamic(_playerID, net.get_player_info(_playerID, 'ucid'), SLOT.AuthDataCache.admin, 'instructor')
end

function SLOT.allowEnterSlotDynamic(_playerID, _side, _slotID)
    local _unitRole = DCS.getUnitType(_slotID)
    local _category = DCS.getUnitProperty(_slotID, DCS.UNIT_GROUPCATEGORY)
    local _groupName = DCS.getUnitProperty(_slotID, DCS.UNIT_GROUPNAME)
    local _unitName = DCS.getUnitProperty(_slotID, DCS.UNIT_NAME)
    local _ucid = net.get_player_info(_playerID, 'ucid')

    --TODO 检查教练机的flag
    if _category ~= nil and (_category == 'helicopter' or _category == 'airplane' or _category == 'plane') then
        if SLOT.getFlagValue(_groupName) == 0 then
            return true
        else
            net.send_chat_to('该机位不可选', _playerID)
            return false
        end
    end

    if _unitRole ~= nil and _unitRole == 'instructor' then
        --游戏管理员
        return SLOT.findIDInTableDynamic(_playerID, _ucid, SLOT.AuthDataCache.admin, 'instructor')
    end
    if _unitRole ~= nil and _unitRole == 'observer' then
        --观察员
        return SLOT.findIDInTableDynamic(_playerID, _ucid, SLOT.AuthDataCache.observer, 'observer')
    end
    if _unitRole ~= nil and _unitRole == 'artillery_commander' then
        --CA
        return SLOT.findIDInTableDynamic(_playerID, _ucid, SLOT.AuthDataCache.commander, 'artillery_commander')
    end

    return true
end

function SLOT.findIDInTableDynamic(_playerID, _inputUcid, table, commander)
    local allowed = false
    local info
    for _ucidValue, _extra in pairs(table) do
        if _ucidValue == _inputUcid then
            allowed = true
            info = _extra.comment
            break
        end
    end

    if allowed then
        return true
    else
        net.send_chat_to('你没有选择这个位置的权限', _playerID)
        if commander == 'artillery_commander' then
            net.send_chat_to('如果对CA和地面指挥感兴趣，可以向群管理提出申请', _playerID)
        end
        return false
    end
end

function SLOT.SaveData(FilePath, data)
    local File = io.open(FilePath, 'w')
    if File then
        File:write(data)
        File:close()
    else
        net.log(FilePath .. '保存失败')
    end
end

function SLOT.CreatFile(FilePath)
    local File = io.open(FilePath, 'w')
    if File then
        local json = {}
        File:write(net.lua2json({}))
        File:close()
        File = nil
        net.log(FilePath .. '创建成功')
    else
        net.log(FilePath .. '创建失败')
    end
end

function SLOT.LoadFile(FilePath)
    local File = io.open(FilePath, 'r')
    if File then
        local FileText = File:read('*all')
        File:close()
        local status, retval = pcall(
                function()
                    return net.json2lua(FileText)
                end
        )
        if status then
            net.log(FilePath .. '加载成功')
            return retval
        else
            net.log('数据格式错误,文件内容不是JSON格式')
        end
    else
        net.log(FilePath .. '未找到,正在创建...')
        SLOT.CreatFile(FilePath) -- creates the file.
    end
end

--设置用户callbacs,使用上面定义的功能映射DCS事件处理程序
DCS.setUserCallbacks(SLOT.callbacks)
net.log('SLOTAUTH 回调设置完成')
SLOT.AuthDataCache = SLOT.LoadFile(SLOT.FilePath)
net.log('SLOTAUTH 动态槽位限制信息加载完成')
net.log('SLOTAUTH 权限脚本 加载完成')
