net.log('INFO: 服务器数据Callbaks->正在加载...')
local status, error =
  pcall(
  function()
    ----------------------------------------Common-------------------------------------
    dofile(lfs.writedir() .. 'Scripts/ServerData/Common/Config.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Common/common.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Common/Logs.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Common/LogStats.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Common/Logger.lua')
    ----------------------------------------Event事件-------------------------------------
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/connect.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/change_slot.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/takeoff.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/kill.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/crash.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/eject.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/self_kill.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/pilot_death.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/friendly_fire.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/landing.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/mission_end.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/disconnect.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/onPlayer.lua')
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/Event/onSimulation.lua')
    ----------------------------------------Callbacks-------------------------------------
    dofile(lfs.writedir() .. 'Scripts/ServerData/Callbacks/ServerDataCall.lua')
  end
)
if (not status) then
  net.log(string.format('ERROR: 服务器数据Callbaks加载失败:%s', error))
else
  net.log('INFO: 服务器数据Callbaks->已全部加载')
end
