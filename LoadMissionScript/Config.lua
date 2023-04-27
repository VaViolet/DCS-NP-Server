LoadMissionScript = LoadMissionScript or {}

net.log("加载任务脚本 初始化: 正在加载" .. "...")
do
  function LoadMissionScript.error(msg)
    msg = tostring(msg)
    local newMsg = "加载任务脚本 ERROR: " .. msg
    net.log(newMsg)
  end

  function LoadMissionScript.warning(msg)
    msg = tostring(msg)
    local newMsg = "加载任务脚本 WARNING: " .. msg
    net.log(newMsg)
  end

  function LoadMissionScript.info(msg)
    msg = tostring(msg)
    local newMsg = "加载任务脚本 INFO: " .. msg
    net.log(newMsg)
  end
  --加载任务环境脚本
  local curMSf, err = io.open("./Scripts/MissionScripting.lua", "r")
  if curMSf then
    local LoadMissionScriptMSf, err = io.open(lfs.writedir() .. "Scripts/LoadMissionScript/MissionScripting.lua", "r")
    if LoadMissionScriptMSf then
      local curMS = curMSf:read("*all")
      local LoadMissionScriptMS = LoadMissionScriptMSf:read("*all")
      curMSf:close()
      LoadMissionScriptMSf:close()
      local curMSfunc, err = loadstring(curMS)
      if curMSfunc then
        local LoadMissionScriptMSfunc, err = loadstring(LoadMissionScriptMS)
        if LoadMissionScriptMSfunc then
          if string.dump(curMSfunc) ~= string.dump(LoadMissionScriptMSfunc) and curMS ~= LoadMissionScriptMS then -- 尝试安装...第一个条件应该足以进行测试，但恐怕它可能取决于系统。
            LoadMissionScript.warning("./Scripts/MissionScripting.lua不是最新的。 正在安装新的./Scripts/MissionScripting.lua。")
            local newMSf, err = io.open("./Scripts/MissionScripting.lua", "w")
            if newMSf then
              newMSf:write(LoadMissionScriptMS)
              newMSf:close()
            else
              LoadMissionScript.error("无法打开./Scripts/MissionScripting.lua进行写作，原因如下:" .. tostring(err))
            end
          else -- 无需安装
            LoadMissionScript.info("./Scripts/MissionScripting.lua是最新的，无需安装.")
            return true
          end
        else
          LoadMissionScript.error("无法编译 " .. lfs.writedir() .. "Scripts/LoadMissionScript/MissionScripting.lua, 原因: " .. tostring(err))
        end
      else
        LoadMissionScript.error("无法编译./Scripts/MissionScripting.lua，原因: " .. tostring(err))
      end
    else
      LoadMissionScript.error("无法打开 " .. lfs.writedir() .. "Scripts/LoadMissionScript/MissionScripting.lua 用于读取, 原因: " .. tostring(err))
    end
  else
    LoadMissionScript.error("无法打开 ./Scripts/MissionScripting.lua 用于读取, 原因: " .. tostring(err))
  end
end
LoadMissionScript.info("LoadMissionScript/Config.lua 加载完成.")
