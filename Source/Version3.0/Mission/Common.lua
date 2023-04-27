SourceObj = SourceObj or {}
SourceObj.playerInfo = {}
SourceObj.playerSource = {}
SourceObj.sourceInitPoint = 1500 --初始资源点
SourceObj.sourceMaxPoint = 3000 --资源点上限
SourceObj.recoverPoint = 500 --低保的阈值，以及低保指标
SourceObj.realRecoverTime = 300
SourceObj.autoAddID = {}
-- SourceObj.landRecoverTime = 60 -- 以秒为单位
-- SourceObj.skyRecoverTime = 30 -- 以秒为单位
-- SourceObj.timeHasRun = 0

-- SourceObj.lua setUserCallbacks
SourceObj.updatePlayerInfo = function(_name, _ucid)
    SourceObj.playerInfo[_name] = _ucid
    SourceObj.playerSource[_ucid] = SourceObj.playerSource[_ucid] or {}

    if SourceObj.playerSource[_ucid]["point"] == nil then
        SourceObj.playerSource[_ucid]["point"] = SourceObj.sourceInitPoint
        SourceObj.SaveSourcePoint()
    end

    if SourceObj.autoAddID[_ucid] == nil then
        SourceObj.playerSource[_ucid]["name"] = _name
        SourceObj.autoAddID[_ucid] = timer.scheduleFunction(SourceObj.autoAddSourcePoint, {_ucid,_name}, timer.getTime() + SourceObj.realRecoverTime)
        env.info("增加资源点自动任务，玩家:" .. _name .. ",  函数id:" .. SourceObj.autoAddID[_ucid])
    end

end
SourceObj.clearAutoAddSourcePoint = function(_ucid)
    env.info("取消资源点自动任务，id:"..SourceObj.autoAddID[_ucid])
    timer.removeFunction(tonumber(SourceObj.autoAddID[_ucid]))
    SourceObj.autoAddID[_ucid]=nil
end
SourceObj.autoAddSourcePoint = function(_args, time)
    local _ucid = _args[1]
    local _name = _args[2]

    local msg = ""
    if SourceObj.playerSource[_ucid]["point"] and SourceObj.playerSource[_ucid]["point"] < SourceObj.recoverPoint then
        SourceObj.playerSource[_ucid]["point"] = SourceObj.recoverPoint
        --SourceObj.SaveSourcePoint()
        msg = string.format("触发低保，恢复到%d资源点", SourceObj.recoverPoint)
    end
    if SourceObj.playerSource[_ucid]["point"] > SourceObj.sourceMaxPoint then
        SourceObj.playerSource[_ucid]["point"] = SourceObj.sourceMaxPoint
        --SourceObj.SaveSourcePoint()
        msg = string.format("资源点到达上限，恢复到%d资源点", SourceObj.sourceMaxPoint)
    end

    if SourceObj.playerGroup[_ucid] and msg ~= "" then
        trigger.action.outTextForGroup(SourceObj.playerGroup[_ucid], msg, 10)
    end
    env.info("执行资源点平衡,msg:"..msg..",name:".._name)
    SourceObj.autoAddID[_ucid] = timer.scheduleFunction(SourceObj.autoAddSourcePoint, {_ucid,_name}, timer.getTime() + SourceObj.realRecoverTime)
end

SourceObj.is_include = function(value, tab)
    if tab then
        for k, v in pairs(tab) do
            if v == value then
                return true
            end
        end
    end
    return false
end
SourceObj.is_includeTable = function(value, tab)
    if tab then
        for k1, v1 in pairs(tab) do
            if type(v1) == "table" then
                for k2, v2 in pairs(v1) do
                    if v2 == value then
                        return true
                    end
                end
            end
        end
    end
    return false
end

SourceObj.unitExplosion = function(_unit)
    if _unit ~= nil then
        local status, error = pcall(
                function(_unit)
                    _unit:getPoint()
                end,
                _unit
        )
        if status then
            trigger.action.explosion(_unit:getPoint(), 100)
        else
            env.error('资源点处理错误:unitExplosion->:' .. SourceObj.JSON:encode(_unit) .. ',' .. error)
        end
    end
end
SourceObj.getGroupId = function(_unit)
    local clientGroupId = _unit.getGroup(_unit):getID()
    if clientGroupId ~= nil then
        return clientGroupId
    end
    return nil
end
SourceObj.AIM_54 = function(_unit, text)
    local _groupId = SourceObj.getGroupId(_unit)
    trigger.action.outTextForGroup(_groupId, text, 10)
    timer.scheduleFunction(SourceObj.unitExplosion, _unit, timer.getTime() + 10)
end
SourceObj.getSourceKillChange = function(_unit)
    local sourcePointChange = 0
    if _unit:getDesc().category == 0 then
        sourcePointChange = Category.AIRPLANE
    elseif _unit:getDesc().category == 1 then
        sourcePointChange = Category.HELICOPTER
    elseif _unit:getDesc().category == 2 then
        sourcePointChange = Category.GROUND_UNIT
    elseif _unit:getDesc().category == 3 then
        sourcePointChange = Category.SHIP
    end
    return sourcePointChange
end
SourceObj.getSourceObjChange = function(_unit)
    local countInfo = {}
    local sourcePointChange = 0
    local _unitType = _unit:getTypeName()
    local planePoint = 0

    -------------------------------------------机型点数----------------------------------------
    if SourceObj.is_include(_unitType, Aircraft.superiorityFighter) then
        planePoint = Aircraft.superiorityFighterPoint
    elseif SourceObj.is_include(_unitType, Aircraft.lightFighter) then
        planePoint = Aircraft.lightFighterPoint
    elseif SourceObj.is_include(_unitType, Aircraft.attacker) then
        planePoint = Aircraft.attackerPoint
    elseif SourceObj.is_include(_unitType, Aircraft.helicopter) then
        planePoint = Aircraft.helicopterPoint
    end
    sourcePointChange = sourcePointChange + planePoint
    countInfo[1] = { ["飞机花费"] = planePoint }

    -------------------------------------------武器点数----------------------------------------
    local AmmoInfo = _unit:getAmmo()
    if AmmoInfo ~= nil then
        for i = 1, #AmmoInfo do
            local ammo = AmmoInfo[i]
            if ammo.desc and ammo.desc.typeName then
                local displayName = ammo.desc.displayName
                local ammoPoint = 0

                if SourceObj.is_include(displayName, Weapon.ATA_Zero) then
                    ammoPoint = Weapon.ATA_ZeroPoint
                elseif SourceObj.is_include(displayName, Weapon.ATA_One) then
                    ammoPoint = Weapon.ATA_OnePoint
                elseif SourceObj.is_include(displayName, Weapon.ATA_Two) then
                    ammoPoint = Weapon.ATA_TwoPoint
                elseif SourceObj.is_include(displayName, Weapon.ATA_Three) then
                    ammoPoint = Weapon.ATA_ThreePoint
                elseif SourceObj.is_include(displayName, Weapon.ATA_Four) then
                    ammoPoint = Weapon.ATA_FourPoint
                end

                if SourceObj.is_include(displayName, Weapon.ATG_One) then
                    ammoPoint = Weapon.ATG_OnePoint
                elseif SourceObj.is_include(displayName, Weapon.ATG_Two) then
                    ammoPoint = Weapon.ATG_TwoPoint
                elseif SourceObj.is_include(displayName, Weapon.ATG_Three) then
                    ammoPoint = Weapon.ATG_ThreePoint
                end

                if SourceObj.is_include(displayName, Weapon.ATGPod) then
                    ammoPoint = Weapon.ATGPodPoint
                elseif SourceObj.is_include(displayName, Weapon.mailbox) then
                    ammoPoint = Weapon.mailboxPoint
                end

                if SourceObj.is_includeTable(displayName, Weapon) then
                    sourcePointChange = sourcePointChange + ammoPoint * ammo.count
                    countInfo[i + 1] = { ["挂载"] = ammo.desc.displayName, ["单价"] = ammoPoint, ["数量"] = ammo.count }
                end
            end
        end
        -- SaveData.WeaponData(SourceObj.JSON:encode(countInfo) .. '\n')
    end

    return sourcePointChange, SourceObj.JSON:encode(countInfo)
end

env.info("公用工具已添加")



