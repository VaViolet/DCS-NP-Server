local loadVersion = 'Version3.0'

--[[
启动测试器，不知道不要管
1.InitDebugger.lua相比InitNPGame.lua只是多了一个调试器
在聊天窗口输入`debug 文件完整路径`来调试
示例：`debug E:\\test.lua`
也可以下载https://github.com/zzjtnb/DCS_World_Debugger的代码
通过网页在线实时调试

2.通过菜单调试
首先把Scripts/Debug/Mission/Event.lua下面的注释,把DebugLua.path改成你的文件完整路径
然后在游戏中按“\”调出菜单选择“F11->其他->加载脚本”
]]
--local status, error =
--  pcall(
--  function()
--    net.log('[Debugger]开始加载Debugger')
--    dofile(lfs.writedir() .. 'Scripts/Debug/Tools/utils.lua')
--    dofile(lfs.writedir() .. 'Scripts/Debug/Init.lua')
--  end
--)
--if (not status) then
--  net.log(string.format('Hooks 加载出错:%s', error))
--else
--  net.log('Hooks 加载完成')
--end

----------以上为测试环境，不了解勿动--------------
----------以下为开服环境--------------

--网络环境的加载和脚本Callbacks
--dofile(lfs.writedir() .. 'Scripts/ServerData/init.lua') --去肥增瘦
dofile(lfs.writedir() .. 'Scripts/SlotAuth/SlotAuth.lua')
dofile(lfs.writedir() .. 'Scripts/Source/Version3.0/Callbacks/Init.lua')

--任务环境的加载和脚本
dofile(lfs.writedir() .. 'Scripts/LoadMissionScript/Config.lua')
