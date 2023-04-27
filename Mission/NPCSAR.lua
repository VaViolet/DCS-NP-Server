npcsar = {}
npcsar.Id = "npcsar - "

npcsar.Version = "20220429"

net.log("LOAD - NP CSAR version "..npcsar.Version ..", script by VL")

npcsar.Debug = false
npcsar.Trace = true

npcsar.baseNum = 2 --基础奖励数量
npcsar.coalitionBonus = 3 --捞到敌方飞行员的奖励倍率
npcsar.dangerZoneBonus = 3 --危险区捞人的奖励倍率

npcsar.distance = 100 --捞人的距离
npcsar.AddDistance = 1000 --距离CC这个距离内不生成跳伞驾驶员
npcsar.cleanTime = 60*60 --清除驾驶员的时间

npcsar.EjectedPilots={}

npcsar.HeliRescueInfo={}

function npcsar.logError(message)
    env.info("[NPCSAR] Err: "  .. message)
end

function npcsar.logInfo(message)
    env.info("[NPCSAR] Info: "  .. message)
end

function npcsar.logDebug(message)
    if message and npcsar.Debug then
        env.info("[NPCSAR] Dbg: "  .. message)
    end
end

function npcsar.logTrace(message)
    if message and npcsar.Trace then
        env.info("[NPCSAR] Trace: "  .. message)
    end
end


npcsar.eventHandler = {}
function npcsar.eventHandler:onEvent(_event)
    local status, err = pcall(function(_event)
        if _event == nil or _event.initiator == nil then
            return false

        elseif _event.id == 9 then --pilot dead
            local _unit = _event.initiator
            if _unit == nil then
                npcsar.logError('事件的unit为空,eventID:'.._event.id)
                return
            end

            npcsar.HeliRescueInfo[_unit:getName()]=nil
            npcsar.logDebug(_unit:getName().."的直升机救援信息被重置")
        elseif _event.id == 5 then --aircraft  crashes
            local _unit = _event.initiator
            if _unit == nil then
                npcsar.logError('事件的unit为空,eventID:'.._event.id)
                return
            end

            npcsar.HeliRescueInfo[_unit:getName()]=nil
            npcsar.logDebug(_unit:getName().."的直升机救援信息被重置")
        elseif _event.id == 6 then --ejection
            local _unit = _event.initiator
            if _unit == nil then
                npcsar.logError('事件的unit为空,eventID:'.._event.id)
                return
            end

            for _, _name in pairs(ctld.logisticUnits) do
                local _logistic = StaticObject.getByName(_name)
                if _logistic ~= nil and _logistic:getCoalition() == _unit:getCoalition() then
                    local _dist = npcsar.getDistance(_unit:getPoint(), _logistic:getPoint())
                    if _dist <= npcsar.AddDistance then
                        ctld.displayMessageToGroup(_unit, "你离cc太近了，就不生成跳伞驾驶员了，自己走回去吧。", 10)
                        return
                    end
                end
            end


            npcsar.addCsar(_unit:getCoalition() , _unit:getCountry(), _unit:getPoint(), _unit:getTypeName(),  _unit:getName(), _unit:getPlayerName())

        elseif _event.id == 8 then --object  destroyed

        end
    end,_event)

    if (not status) then
        npcsar.logError(string.format("Error while handling event %s", err))
    end
end

function npcsar.addCsar(_coalition , _country, _point, _unitTypeName,_unitName, _playerName)
    local _spawnedGroup = npcsar.spawnPilotModel( _coalition, _country, _point)

    trigger.action.outTextForCoalition(_spawnedGroup:getCoalition(), "MAYDAY MAYDAY! " .. _playerName .."的" .._unitTypeName.. "跳伞了，够够我.", 10)
    local _text = "Pilot " .. _playerName .. " of " .. _unitName

    if _spawnedGroup ~= nil then
        local _setImmortal = {
            id = 'SetImmortal',
            params = {
                value = true
            }
        }
        local _controller = _spawnedGroup:getController();
        Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
        Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
        Controller.setCommand(_controller, _setImmortal)

        npcsar.EjectedPilots[_spawnedGroup:getName()] = { side = _spawnedGroup:getCoalition(), type=_unitTypeName, originalUnit = _unitName, desc = _text, player = _playerName, point = _point, spawnTime=timer.getTime()}

        npcsar.logInfo('生成待营救驾驶员:'.._spawnedGroup:getName())
    else
        npcsar.logError('生成待营救驾驶员错误，group为空')
    end

end



function npcsar.spawnPilotModel(_coalition, _country, _point)
    local _id = mist.getNextGroupId()
    local _groupName = "Downed Pilot #" .. _id
    local _side = _coalition
    local _pos = _point

    local _group = {
        ["visible"] = true,
        ["groupId"] = _id,
        ["hidden"] = false,
        ["units"] = {},
        ["name"] = _groupName,
        ["task"] = {},
    }

    if _side == 2 then
        _group.units[1] = npcsar.createUnit(_pos.x , _pos.z , 120, "Soldier M4")
    else
        _group.units[1] = npcsar.createUnit(_pos.x , _pos.z , 120, "Infantry AK")
    end

    _group.category = Group.Category.GROUND;
    _group.country = _country;

    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)
    trigger.action.setGroupAIOff(_spawnedGroup)

    return _spawnedGroup
end

function npcsar.createUnit(_x, _y, _heading, _type)
    local _id = mist.getNextUnitId();
    local _name = string.format("Wounded Pilot #%s", _id)

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _type,
        ["name"] = _name,
        ["unitId"] = _id,
        ["heading"] = _heading,
        ["playerCanDrive"] = false,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end


function npcsar.loadPilots(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    if _heli == nil then
        npcsar.logError('[loadPilots]找不到heli')
        return
    end

   local pilotsInfo = npcsar.findNearPilots(_heli)

    if #pilotsInfo==0 then
        ctld.displayMessageToGroup(_heli,'你周围找不到任何跳伞飞行员',10)
        return
    end

    ctld.displayMessageToGroup(_heli,'捞跳伞飞行员中。。。。。',10)

    timer.scheduleFunction(function(_args)
        local _pilotsInfo=_args[1]
        local _heli=_args[2]

        if npcsar.HeliRescueInfo[_heli:getName()]==nil then
            npcsar.HeliRescueInfo[_heli:getName()] = {}
        end

        for _,pilotInfo in pairs(_pilotsInfo) do
            npcsar.EjectedPilots[pilotInfo.pilot]=nil
            Group.destroy(Group.getByName(pilotInfo.pilot))
            table.insert(npcsar.HeliRescueInfo[_heli:getName()], pilotInfo)
            --{ pilot = _pilotGroupName, coalition = detail.side, dangerZone = npcsar.isInDangerZone(detail)}
            ctld.displayMessageToGroup(_heli,'捞起跳伞飞行员:'..ctld.formatTable(pilotInfo),10)
        end
    end,{pilotsInfo,_heli}, timer.getTime() + 10)

end

function npcsar.findNearPilots(_heli)
    local pilotsDetail = {}
    for _pilotGroupName,detail in pairs(npcsar.EjectedPilots) do
        if npcsar.getDistance(_heli:getPoint(), detail.point) < npcsar.distance then
            npcsar.logDebug('发现能捞的飞行员:'.._pilotGroupName)
            local pilot={ pilot = _pilotGroupName, coalition = detail.side, dangerZone = npcsar.isInDangerZone(detail,_heli)}
            table.insert(pilotsDetail,pilot)
        end
    end

    return pilotsDetail
end

function npcsar.isInDangerZone(detail,_heli)
    local friendMinDist = 999999
    local enemyMinDist = 999999

    for _, _name in pairs(ctld.logisticUnits) do
        local _logistic = StaticObject.getByName(_name)
        if _logistic ~= nil then
            local _dist = npcsar.getDistance(detail.point, _logistic:getPoint())
            if _logistic:getCoalition() == _heli:getCoalition() then
                friendMinDist=npcsar.getMinNum(friendMinDist,_dist)
            else
                enemyMinDist=npcsar.getMinNum(enemyMinDist,_dist)
            end
        end
    end

    if friendMinDist<enemyMinDist then
        return false
    else
        return true
    end
end

function npcsar.getMinNum(num1,num2)
    if num1>num2 then
        return num2
    else
        return num1
    end
end
function npcsar.loadedPilotInfo(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    if _heli == nil then
        npcsar.logError('[loadedPilotInfo]找不到heli')
        return
    end

    ctld.displayMessageToGroup(_heli, "你现在转载的飞行员:".. ctld.formatTable(npcsar.HeliRescueInfo[_heli:getName()]), 10)
end
function npcsar.unpackPilots(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    if _heli == nil then
        npcsar.logError('[unpackPilots]找不到heli')
        return
    end

    if ctld.inLogisticsZone(_heli) == false then
        ctld.displayMessageToGroup(_heli, "附近没有己方cc，不能放下捞回的飞行员", 10)
        return
    end

    if npcsar.HeliRescueInfo[_heli:getName()] == nil or #npcsar.HeliRescueInfo[_heli:getName()]==0 then
        ctld.displayMessageToGroup(_heli, "你机舱里一个飞行员都没有", 10)
        return
    end

    local totalBonus = 0
    for _,pilotInfo in pairs(npcsar.HeliRescueInfo[_heli:getName()]) do
        local num = npcsar.baseNum

        if pilotInfo.coalition ~= _heli:getCoalition()then
            num = num *npcsar.coalitionBonus
        end

        if pilotInfo.dangerZone ==true then
            num = num *npcsar.dangerZoneBonus
        end

        totalBonus=totalBonus+ num
        ctld.displayMessageToGroup(_heli, ctld.formatTable(pilotInfo).."为你带来了".. num .. "点奖励", 10)
    end

    ctld.displayMessageToGroup(_heli, "总奖励为: "..totalBonus..",为你阵营生成对应数量的坦克", 10)
    npcsar.SpawnBonusUnits(totalBonus, _heli)
    npcsar.HeliRescueInfo[_heli:getName()]=nil
end

function npcsar.SpawnBonusUnits(totalBonus, _heli)
    for i=1,totalBonus do
        local template = ctld.getGroupTemplate(ctld.RandomTankPool[math.random(#ctld.RandomTankPool)])
        local _systemParts = {}
        for _, _part in pairs(template.parts) do
            _systemParts[_part.name] = { name = _part.name, desc = _part.desc }
        end

        local _point = _heli:getPoint()
        local num = 1
        local _positions = {}
        local _types = {}
        for _name, _systemPart in pairs(_systemParts) do
            local _launcherPart = ctld.getLauncherUnitFromAATemplate(template)
            if _launcherPart == _name and template.aaLaunchers > 1 then
                --add multiple launcher
                local _launchers = template.aaLaunchers
                for _i = 1, _launchers do
                    -- spawn in a circle around the crate
                    local _angle = math.pi * 2 * (_i - 1) / _launchers
                    local _xOffset = math.cos(_angle) * 12+math.random(0, totalBonus*10)
                    local _yOffset = math.sin(_angle) * 12+math.random(0, totalBonus*10)
                    num = num + 1
                    _point = { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset }
                    table.insert(_positions, _point)
                    table.insert(_types, _name)
                end
            else
                local _angle = math.pi * 2 * (num - 1)
                local _xOffset = math.cos(_angle) * 15 +math.random(0, totalBonus*10)
                local _yOffset = math.sin(_angle) * 15 +math.random(0, totalBonus*10)
                _point = { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset }
                table.insert(_positions, _point)
                table.insert(_types, _name)
            end
        end


        local _id = ctld.getNextGroupId()
        local _groupName = _heli:getPlayerName() .. " " .. _types[1] .. " #" .. _id
        local _side = _heli:getCoalition()

        local _group = {
            --["PlayerName"] = tostring(initName),
            ["visible"] = false,
            -- ["groupId"] = _id,
            ["hidden"] = false,
            ["units"] = {},
            --        ["y"] = _positions[1].z,
            --        ["x"] = _positions[1].x,
            ["name"] = _groupName,
            ["task"] = {},
            ["playerCanDrive"] = true,
        }
        if #_positions == 1 then
            local _unitId = ctld.getNextUnitId()
            local _details = { type = _types[1], unitId = _unitId, name = string.format("Unpacked %s #%i", _types[1], _unitId) }
            _group.units[1] = ctld.createUnit(_positions[1].x + 5, _positions[1].z + 5, 120, _details)
        else
            for _i, _pos in ipairs(_positions) do
                local _unitId = ctld.getNextUnitId()
                local _details = { type = _types[_i], unitId = _unitId, name = string.format("Unpacked %s #%i", _types[_i], _unitId) }
                _group.units[_i] = ctld.createUnit(_pos.x + 5, _pos.z + 5, 120, _details)
            end
        end
        local _spawnedGroup
        _group.country = _heli:getCountry()
        _group.category = Group.Category.GROUND
        _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)
        local _dest = _spawnedGroup:getUnit(1):getPoint()
        _dest = { x = _dest.x + 0.5, _y = _dest.y + 0.5, z = _dest.z + 0.5 }
        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _dest)
    end
end

function npcsar.getDistance(_point1, _point2)

    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end


function npcsar.cleanPilots()
    npcsar.logInfo('开始清除时间过长的跳伞驾驶员')
    local hasClean = false
    for groupName,detail in pairs(npcsar.EjectedPilots) do
        if timer.getTime()-detail.spawnTime>npcsar.cleanTime then
            Group.destroy(Group.getByName(groupName))
            npcsar.EjectedPilots[groupName]=nil
            hasClean = true
            npcsar.logInfo('跳伞驾驶员'..groupName..'被清除')
        end
    end
    if hasClean == true then
        trigger.action.outText('清除了一些好长时间都没人捞的跳伞驾驶员，RIP',10)
    end
    timer.scheduleFunction(npcsar.cleanPilots, nil, timer.getTime() + npcsar.cleanTime)
end

world.addEventHandler(npcsar.eventHandler)
timer.scheduleFunction(npcsar.cleanPilots, nil, timer.getTime()+5)
net.log("LOAD SUCCESS - NPCSAR version "..NP.Version ..", script by VL")