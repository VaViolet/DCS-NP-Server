---Initialization script for the Mission lua Environment (SSE)
dofile('Scripts/ScriptingSystem.lua')

--启动测试环境，不知道的话勿动lse)
--dofile(lfs.writedir() .. 'Scripts/Debug/Mission/Init.lua')

--不要随意切换顺序
dofile(lfs.writedir() .. 'Scripts/Mission/mist.lua')
dofile(lfs.writedir() .. 'Scripts/Mission/CTLD.lua')
dofile(lfs.writedir() .. 'Scripts/Mission/DynamicSave.lua')
dofile(lfs.writedir() .. 'Scripts/StaticDataBase/UnitsList.lua')
dofile(lfs.writedir() .. 'Scripts/Mission/NPV2.lua')
dofile(lfs.writedir() .. 'Scripts/Mission/NPCSAR.lua')
dofile(lfs.writedir() .. 'Scripts/Source/Version3.0/Mission/SourceInit.lua')
