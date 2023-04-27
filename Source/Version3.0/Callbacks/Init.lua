local loadVersion = "Version3.0"
local status, error =
  pcall(
  function()
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Common/Character.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Utils/FileData.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Utils/Common.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Chats/ChatFile.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Chats/AdminCmd.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Chats/PlayerCmd.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Config.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/AdminList.lua")
    ----------------------------------------Event事件处理开始-------------------------------------
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/change_slot.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/takeoff.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/friendly_fire.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/self_kill.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/kill.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/pilot_death.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/eject.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/crash.lua")
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/Event/landing.lua")
    ----------------------------------------Event事件处理结束-------------------------------------
    dofile(lfs.writedir() .. "Scripts/Source/" .. loadVersion .. "/Callbacks/SourceCall.lua")
  end
)
if (not status) then
  net.log(string.format("资源系统Callbaks加载失败:%s", error))
else
  net.log("资源系统Callbaks全部加载完毕")
end
