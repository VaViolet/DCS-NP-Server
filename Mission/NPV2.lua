--[[
    NP占点脚本 By 紫花
    依赖ctld和mist

 ]]
--TODO 选边限制
--TODO fob的击杀更新
--阵营级大杀器
--箱子

NP = {}

NP.Id = "NP - "

NP.Version = "20220417"

net.log("LOAD - NP core script version "..NP.Version ..", script by VL")

NP.RefreshTime = 10

NP.CaptureDistance = 100

-- debug level, specific to this module
NP.Debug = true
-- trace level, specific to this module
NP.Trace = true
 
NP.AWACSList = {
    "blueAWACS",
    "blueAWACS2",
    "redAWACS",
    "redAWACS2"
}

function NP.logError(message)
    env.info("[NP] Err: "  .. message)
end

function NP.logInfo(message)
    env.info("[NP] Info: "  .. message)
end

function NP.logDebug(message)
    if message and ctld.Debug then
        env.info("[NP] Dbg: "  .. message)
    end
end

function NP.logTrace(message)
    if message and ctld.Trace then
        env.info("[NP] Trace: "  .. message)
    end
end

function NP.findUnitControlByPlayer(_groupTable)
    local _playerUnits = {}
    for _, _unitsTable in pairs(_groupTable.units) do
        local _unit = ctld.getAddGroupUnit(_unitsTable.unitName)
        if _unit ~= nil then
            local playerName = _unit:getPlayerName()
            if playerName~=nil then
                _playerUnits[playerName]=_unit
            end
        end
    end
    return _playerUnits
end


function NP.capture(_args)
    NP.logDebug('进入cap函数')
    local _playerUnits = NP.findUnitControlByPlayer(_args)
    NP.logDebug('开始找最近的cc')
    local _hasCloseEnough, _targetLogistic,_capturedPlayerName
    for _playerName,_unit in pairs(_playerUnits) do
        local _closeEnough,_logistic=NP.closeEnoughFromEnemyLogisticZone(_unit)
        if _closeEnough then
            _hasCloseEnough=true
            _targetLogistic=_logistic
            _capturedPlayerName=_playerName
        end
    end

    if _hasCloseEnough == nil then
        NP.logInfo('占点不够近')
        trigger.action.outText('操作地面单位的指挥官，在靠近敌方cc后再占领。如果你乱按这个按钮，整个服务器都会被这个消息吵到',10)
        return
    end

    NP.logDebug('开始从mist获取数据')
    local _logisticData = NP.getLogisticData(_targetLogistic)
    local _side = _targetLogistic:getCoalition()
    local oppsiteCountryID
    local oppsiteSide
    local oppsiteCountry
    local oppsiteCountrySide
    --TODO 抽象这里
    if _side==2 then
        oppsiteCountryID =country.id.AGGRESSORS
        oppsiteCountrySide="red"
        oppsiteSide=1
        oppsiteCountry=country.name[oppsiteCountryID]
    else
        oppsiteCountryID =country.id.USA
        oppsiteCountrySide="blue"
        oppsiteSide=2
        oppsiteCountry=country.name[oppsiteCountryID]
    end

    _logisticData.groupName=_logisticData.groupName.. ' '
    _logisticData.name=_logisticData.groupName
    _logisticData.groupId=ctld.getNextGroupId()
    --_logisticData.groupId=nil

    _logisticData.countryId= oppsiteCountryID
    _logisticData.country= oppsiteCountry
    _logisticData.coalitionId= oppsiteSide
    _logisticData.coalition= oppsiteCountrySide

    _logisticData.units[1].groupName=_logisticData.groupName
    _logisticData.units[1].unitName=_logisticData.units[1].unitName..' '
    _logisticData.units[1].unitId= ctld.getNextUnitId()
    --_logisticData.units[1].unitId= nil
    _logisticData.units[1].groupId= _logisticData.groupId

    _logisticData.units[1].countryId= oppsiteCountryID
    _logisticData.units[1].country= oppsiteCountry
    _logisticData.units[1].coalition= oppsiteCountrySide
    _logisticData.units[1].coalitionId= oppsiteSide

    --_logisticData.units[1].alt=_logisticData.units[1].alt-5 --TODO cc浮空
    NP.logDebug('_logistic:'..ctld.p(_targetLogistic))
    NP.logDebug('_logisticData:'..ctld.formatTable(_logisticData))
    NP.logDebug('_unit:'..ctld.p(_unit))

    _targetLogistic:destroy()--把老一边的cc做掉
    for index=#ctld.logisticUnits,1,-1 do
        if ctld.logisticUnits[index] == _targetLogistic:getName() then
            table.remove(ctld.logisticUnits,index)
        end
    end


    mist.dynAddStatic(_logisticData)--生成另一阵营的新cc，同一位置
    timer.scheduleFunction(dsave.recordAllCCsElements, nil, timer.getTime() + 20)
    table.insert(ctld.logisticUnits, _logisticData.units[1].unitName)--新的单位加到cc的白名单


    NP.setRelatedZone(_logisticData.groupName,_logisticData.units[1].coalition)
    NP.logInfo("战区".._logisticData.groupName.."被"..oppsiteCountrySide.."占领。操作者是".._capturedPlayerName)
    trigger.action.outText("战区".._logisticData.groupName.."被"..oppsiteCountrySide.."占领。操作者是".._capturedPlayerName, 20)
end

function NP.setRelatedZone(groupName,coalition)
    local originalCCname
    for k,v in pairs(ctld.logisticUnits) do
        if string.find(groupName, v) ~= nil then
            originalCCname = v
            break
        end
    end

    if originalCCname == nil then
        NP.logError('[setRelatedZone] 在ctld.logisticUnits数据表中找不到对应的cc: '..groupName ..'| 阵营:'..coalition)
        return
    end

    local ccname = string.gsub(originalCCname, "%s+", "")
    NP.logInfo('[setRelatedZone] 将cc后面的空格去掉，原cc名称: |'..originalCCname ..'| 参与翻转的cc名称:|'..ccname.."|")

    if  Unitlist[ccname] == nil then
        NP.logError('[setRelatedZone] 在Unitlist.list数据表中找不到对应cc的数据: '.. ccname..'| 阵营:'..coalition)
        return
    end

    local oppsitecoalition
    if coalition == 'red' then
       oppsitecoalition = 'blue'
    else
       oppsitecoalition = 'red'
    end

    for _,_Unit in pairs(Unitlist[ccname][oppsitecoalition]) do
        NP.logInfo('[setRelatedZone] 翻转直升机机位: |'.. _Unit..'| flag为100(false)')
        trigger.action.setUserFlag(_Unit, 100)
    end
    for _,_Unit in pairs(Unitlist[ccname][coalition]) do
        NP.logInfo('[setRelatedZone] 翻转直升机机位: |'.. _Unit..'| flag为0(true)')
        trigger.action.setUserFlag(_Unit, 0)
    end

    timer.scheduleFunction(function(_args)
        local _ccname, _coalition, _oppsitecoalition = _args[1],_args[2],_args[3]
        NP.logDebug('传进生成船的函数的值：'.._ccname.."|".._coalition.."|".._oppsitecoalition)

        if Unitlist[_ccname]['ships']~=nil then
            for _,_shipGroupName in pairs(Unitlist[_ccname]['ships'][_coalition]) do
                local myGroup = Group.getByName(_shipGroupName)
                if myGroup ~= nil then
                    NP.logInfo('[setRelatedZone] 补给船已存在，不进行生成:'.._shipGroupName.."|")
                else
                    mist.respawnGroup(_shipGroupName,true)
                    NP.logInfo('[setRelatedZone] 生成补给船:'.._shipGroupName.."|")
                end
            end
            for _,_shipGroupName in pairs(Unitlist[_ccname]['ships'][_oppsitecoalition]) do
                local myGroup = Group.getByName(_shipGroupName)
                if myGroup ~= nil then
                    Group.destroy(myGroup)
                    NP.logInfo('[setRelatedZone] 销毁补给船:'.._shipGroupName.."|")
                else
                    NP.logError('[setRelatedZone] 销毁补给船时找不到组:'.._shipGroupName.."|")
                end
            end
        end
    end, {ccname,coalition,oppsitecoalition} , timer.getTime()+10)

    NP.logInfo('[setRelatedZone] 占领CC的流程完成: '.. ccname..'| 阵营:'..coalition)
end


function NP.getLogisticData(_logistic)
    for _, _group in pairs(mist.DBs.groupsByName) do
        for _key , _unitTable in pairs(_group.units) do
            if _unitTable.unitName==_logistic:getName() then
                return _group
            end
        end
    end
    return nil
end

function NP.closeEnoughFromEnemyLogisticZone(_unitObject)
    local _unitPoint = _unitObject:getPoint()

    local _closeEnough = false

    local _logistic
    for _, _name in pairs(ctld.logisticUnits) do
        _logistic = StaticObject.getByName(_name)
        if _logistic ~= nil and _logistic:getCoalition() ~= _unitObject:getCoalition()  then
            local _dist = ctld.getDistance(_unitPoint, _logistic:getPoint())
            if _dist <= NP.CaptureDistance then
                _closeEnough = true
                return _closeEnough,_logistic
            end
        end
    end

    return _closeEnough,_logistic
end

function NP.RespawnAwacs()
    for _, _plane in pairs(NP.AWACSList) do
        local AWCAS = Group.getByName(_plane):getUnit(1)
        if AWCAS ~= nil then
            if Unit.getFuel(AWCAS) < 0.3 then
                mist.respawnGroup(_plane, true)
                NP.logInfo(_plane.."油量低，重生")
                trigger.action.outText("预警机梯队没油了，后续梯队正在交接！", 10)
            end
        else 
            NP.logError('[RespawnAwacs]检测预警机时找不到该预警机单位'.._plane.."|")
        end
    end
    timer.scheduleFunction(NP.RespawnAwacs, {}, timer.getTime() + 900)
end

timer.scheduleFunction(NP.RespawnAwacs, {}, timer.getTime() + 900)
net.log("LOAD SUCCESS - NP version "..NP.Version ..", script by VL")
