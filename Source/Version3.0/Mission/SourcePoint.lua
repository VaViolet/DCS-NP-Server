SourceObj = SourceObj or {}
function SourceObj.creatDir(path, name)
  lfs.mkdir(path .. name)
  return lfs.writedir() .. name
end
function SourceObj.creatFile(path, name, data)
  local FilePath = path .. "\\" .. name
  local LogFile = io.open(FilePath, "a")
  if LogFile then
    LogFile:write(data .. "\n")
    LogFile:close()
  end
end
---------------------加载---------------------------
SourceObj.SourceSavePointDataPath = SourceObj.Config_Dir .. [[\玩家资源点.json]]

SourceObj.SourceSavePoint = function(data)
  SourceObj.creatFile(SourceObj.Config_Dir, "玩家资源点.json", data)
end
SourceObj.LoadSavedSourcePoint = function(path)
  local LoadSourcePoint, error = io.open(path, "r")
  if LoadSourcePoint then
    local content = LoadSourcePoint:read("*all")
    LoadSourcePoint:close()
    if content then
      if next(SourceObj.JSON:decode(content)) == nil then
        env.info("不存在任何玩家的资源点信息")
      else
        SourceObj.playerSource = SourceObj.JSON:decode(content)
        env.info("读取保存的玩家资源点信息成功")
      end
    end
  else
    env.info("读取保存的资源点失败:" .. error)
    SourceObj.SourceSavePoint("{}")
  end
end
SourceObj.LoadSavedSourcePoint(SourceObj.SourceSavePointDataPath)

SourceObj.SaveSourcePoint = function()
  File = io.open(SourceObj.SourceSavePointDataPath, "w")
  File:write(SourceObj.JSON:encode(SourceObj.playerSource))
  File:close()
end
SourceObj.addSourcePoint = function(_ucid, point)
  if SourceObj.playerGroup[_ucid] then
    SourceObj.playerSource[_ucid]["point"] = SourceObj.playerSource[_ucid]["point"] + tonumber(point)
    SourceObj.SaveSourcePoint()
    trigger.action.outTextForGroup(SourceObj.playerGroup[_ucid], "管理员给你添加" .. tonumber(point) .. "点资源点", 10)
  else
    SourceObj.playerSource[_ucid]["point"] = SourceObj.playerSource[_ucid]["point"] + tonumber(point)
    SourceObj.SaveSourcePoint()
  end
end
SourceObj.lessSourcePoint = function(_ucid, point)
  SourceObj.playerSource[_ucid]["point"] = SourceObj.playerSource[_ucid]["point"] - point
  SourceObj.SaveSourcePoint()
end
SourceObj.donatePoint = function(DonorUcid, WinnerUcid, point)
  SourceObj.playerSource[DonorUcid]["point"] = SourceObj.playerSource[DonorUcid]["point"] - point
  SourceObj.playerSource[WinnerUcid]["point"] = SourceObj.playerSource[WinnerUcid]["point"] + point
  trigger.action.outTextForGroup(SourceObj.playerGroup[DonorUcid], "已转增给" .. SourceObj.playerSource[WinnerUcid]["name"] .. tonumber(point) .. "点资源点", 10)
  trigger.action.outTextForGroup(SourceObj.playerGroup[WinnerUcid], SourceObj.playerSource[DonorUcid]["name"] .. "给你转增" .. tonumber(point) .. "点资源点", 10)
  SourceObj.SaveSourcePoint()
end
