--[[
    动态保存脚本 By 紫花
    依赖ctld和mist

    原理:ctld每5分钟会全量存储一次所有地面单位的数据，存到ctld的缓存里，并写到json
    这个数据同时也会用来占点
    这里会读取json，用ctld的方法生成所有单位
 ]]

--Workshop A
--.Command Center
--Gas platform

dsave = {}

dsave.Id = "dsave - "

dsave.Version = "20220417"

net.log("LOAD - DYNAMIC SAVE version "..dsave.Version ..", script by VL")

dsave.CCTypes = { '.Command Center', 'outpost'}
dsave.blackList = { 'iso_container_small', 'Infantry AK','Soldier M4','LHA_Tarawa'}
dsave.RefreshTime = 300

-- debug level, specific to this module
dsave.Debug = true
-- trace level, specific to this module
dsave.Trace = true

dsave.DSaveCCsOutCache={}
dsave.DSaveGroupsCache={}
dsave.Config_Dir = lfs.writedir() .. [[SourceData/]]
dsave.DSaveGroupsFilePath = dsave.Config_Dir .. "动态保存单位.json"
dsave.DSaveCCsFilePath = dsave.Config_Dir .. "动态保存物体.json"

function dsave.logError(message)
    env.info("[DSAVE] Err: "  .. message)
end

function dsave.logInfo(message)
    env.info("[DSAVE] Info: "  .. message)
end

function dsave.logDebug(message)
    if message and ctld.Debug then
        env.info("[DSAVE] Dbg: "  .. message)
    end
end

function dsave.logTrace(message)
    if message and ctld.Trace then
        env.info("[DSAVE] Trace: "  .. message)
    end
end


function dsave.saveToCache(_inputTable)
    table.insert(dsave.DSaveGroupsCache,_inputTable)
end

function dsave.NotInVehicleBlackList(_group)
    local flag= true

    if _group.category == 'static' then
        flag = false
    end

    for _, _plane in pairs(NP.AWACSList) do
        if _plane == _group.groupName then
            flag = false
        end
    end

    return flag
end

function dsave.recordAllVehiclesElements(inputDB)
    if inputDB==nil then
        return
    end

    for _, _group in pairs(inputDB) do
        local needSave =false
        if dsave.NotInVehicleBlackList(_group) then
            for _key , _unitTable in pairs(_group.units) do
                if _unitTable.unitName ~= nil and dsave.typeBelongsToBlackList(_unitTable.type)==false then
                    local _unit=Unit.getByName(_unitTable.unitName)
                    if _unit~=nil then
                        if _unit:getLife()>1 then
                            needSave =true
                            local _point = _unit:getPoint()
                            _group.units[_key].point.x=_point.x
                            _group.units[_key].x=_point.x
                            _group.units[_key].point.y=_point.z
                            _group.units[_key].y=_point.z
                        else
                            _group.units[_key]=nil
                        end
                    end
                else
                    _group.units[_key]=nil
                end
            end

            if needSave then
                table.insert(dsave.DSaveGroupsCache,_group)
            end

        end
    end

    dsave.SaveData(dsave.DSaveGroupsFilePath, net.lua2json(dsave.DSaveGroupsCache))
    dsave.DSaveGroupsCache={}
    dsave.logInfo("地面目标已经写入 动态保存单位.json")
    timer.scheduleFunction(dsave.recordAllVehiclesElements, inputDB, timer.getTime() + dsave.RefreshTime)
end




function dsave.recordAllCCsElements()
    local checkRepeat = {}
    for _, _group in pairs(mist.DBs.groupsByName) do
        local needSave = false
        for _key , _unitTable in pairs(_group.units) do
            if _unitTable.type~=nil and _unitTable.unitName~=nil and dsave.typeBelongsToCC(_unitTable.type) then
                local _unitObject = StaticObject.getByName(_unitTable.unitName)
                --dsave.logDebug("_unitObject"..ctld.formatTable(_unitObject))
                if _unitObject ~= nil and _unitObject:getLife() > 0 and checkRepeat[_unitTable.unitName]==nil then
                    needSave = true
                    checkRepeat[_unitTable.unitName]=true
                    --dsave.logDebug("_unitObject:getLife()"..ctld.formatTable(_unitObject))
                end
            end
        end

        if needSave == true then
            --dsave.logDebug("_group"..ctld.formatTable(_group))
            --dsave.saveToCache(_group)
            table.insert(dsave.DSaveCCsOutCache,_group)
        end
    end
    dsave.SaveData(dsave.DSaveCCsFilePath, net.lua2json(dsave.DSaveCCsOutCache))
    dsave.DSaveCCsOutCache={}
    dsave.logInfo("CC目标已经写入 动态保存物体.json")
    --timer.scheduleFunction(dsave.recordAllCCsElements, nil, timer.getTime() + dsave.RefreshTime )
end



function dsave.destoryMissionEditorCCs() --在任务一开始把所有任务编辑器默认的cc全部删除，再通过动态保存来生成新的cc
    for _, _group in pairs(mist.DBs.groupsByName) do
        local _needDestory = false
        for _key , _unitTable in pairs(_group.units) do
            if _unitTable.type~=nil and dsave.typeBelongsToCC(_unitTable.type) then
                _needDestory = true
            end
        end

        if _needDestory == true then
            local _groupObject = StaticObject.getByName(_group.groupName)
            if _groupObject ~= nil then
                dsave.logInfo("CC已被摧毁:".._group.groupName)
                _groupObject:destroy()
            end
        end
    end
    dsave.logInfo("所有默认出生的cc都已经摧毁")
end



dsave.SaveData = function(FilePath, data)
    local File = io.open(FilePath, "w")
    if File then
        File:write(data)
        io.close(File)
    else
        dsave.logError(FilePath .. "保存失败")
    end
end

--TODO
function dsave.typeBelongsToBlackList(_typename)
    if _typename ==nil then
        return false
    end
    for _, ccType in pairs(dsave.blackList) do
        if ccType == _typename then
            return true
        end
    end

    return false
end


function dsave.typeBelongsToCC(_typename)
    if _typename ==nil then
        return false
    end
    for _, ccType in pairs(dsave.CCTypes) do
        if ccType == _typename then
            return true
        end
    end

    return false
end


function dsave.loadDsaveUnitsData()
    local File,err=io.open(dsave.DSaveGroupsFilePath,"r");

    local tableData
    if err == nil then
        dsave.logInfo('单位动态保存文件读取成功')
        local _data = File:read("*a"); -- 读取所有内容
        io.close(File)
        tableData =net.json2lua(_data)
    else
        dsave.logError(err)
        dsave.logError('如果没有单位动态保存文件，请忽略这条')
        if File~=nil then
            io.close(File)
        end
        return
    end
        dsave.logInfo('extract data from json file 单位')
        dsave.logInfo(ctld.formatTable(tableData))

    for _, _group in pairs(tableData) do
        local _spawnedGroup
        if _group.units[1]~=nil and _group.units[1].type == "RQ-1A Predator"then
            _group = ctld.groupToPlanes(_group)
            coalition.addGroup(_group.countryId, Group.Category.AIRPLANE, _group)
            _spawnedGroup = Group.getByName(_group.groupName)
        else
            _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)
        end

        if ctld.isJTACUnitType(_group.units[1].type) and ctld.JTAC_dropEnabled  and _spawnedGroup~=nil then --为jtac激活
            local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
            table.insert(ctld.jtacGeneratedLaserCodes, _code)
            ctld.JTACAutoLase(_spawnedGroup:getName(), _code) --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
        end

        dsave.logInfo('_group:'.._group.groupName ..' generated!')
    end
    dsave.logInfo('地面单位载入完成')
end

function dsave.loadDsaveCCsData()

    local File2,err2=io.open(dsave.DSaveCCsFilePath,"r");
    local tableData2
    if err2 == nil then
        dsave.logInfo('cc动态保存文件读取成功')
        dsave.destoryMissionEditorCCs()--马上要动态保存了，赶紧把任务编辑器已有的cc都做掉
        local _data = File2:read("*a") -- 读取所有内容
        io.close(File2)

        tableData2 =net.json2lua(_data)
    else
        dsave.logError(err2)
        dsave.logError('如果没有cc动态保存文件，请忽略这条')
        dsave.recordAllCCsElements()
        if File~=nil then
            io.close(File2)
        end
        timer.scheduleFunction(dsave.loadDsaveCCsData, nil, timer.getTime() + 4)
        return
    end
    dsave.logInfo('extract data from json file cc')
    dsave.logInfo(ctld.formatTable(tableData2))

    for _, _group in pairs(tableData2) do
        mist.dynAddStatic(_group)
        table.insert(ctld.logisticUnits, _group.units[1].unitName)
        dsave.logInfo('CC:|'.._group.groupName ..'|generated!'.. ' 阵营:' .._group.country)
    end
    dsave.logInfo('CC载入完成')
--[[
    trigger.action.outText("动态保存载入完成", 10)
    dsave.logInfo('Load records from saved data success! ')]]
end

function dsave.refreshFlagsAtMissionStart()
    for _, _name in pairs(ctld.logisticUnits) do
        local _logistic = StaticObject.getByName(_name)
        if _logistic ~= nil and _logistic:getLife() > 0 then
            NP.setRelatedZone(_logistic:getName(),dsave.coalitionToString(_logistic:getCoalition()))
        end
    end
    dsave.logInfo("Refresh userFlags complete!")
end

function dsave.coalitionToString(_coalition)
    if _coalition==1 then
        return "red"
    else
        return "blue"
    end
end

timer.scheduleFunction(dsave.loadDsaveUnitsData, nil, timer.getTime() + 20)
timer.scheduleFunction(dsave.loadDsaveCCsData, nil, timer.getTime() + 2+10)
timer.scheduleFunction(dsave.refreshFlagsAtMissionStart, nil, timer.getTime() + 12+10)

timer.scheduleFunction(dsave.recordAllVehiclesElements, mist.DBs.dynGroupsAdded, timer.getTime() + 50)

net.log("LOAD SUCCESS - DYNAMIC SAVE version "..dsave.Version ..", script by VL")