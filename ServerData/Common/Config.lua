-- 变量初始化(Variable init)
ServerData = {}
ServerData.onEvent = {}
ServerData.Version = '3.0.0'
ServerData.MissionHash = ''
ServerData.lastSentStatus = 0
ServerData.lastFrameStart = 0
ServerData.PlayersData = {}
ServerData.callbacks = {}
ServerData.SlotsData = {}
ServerData.StatusData = {}
ServerData.MissionData = {}

-- 连接(Connection)
-- (int) [default: 600] Base refresh rate in seconds to send status update
-- (int) [默认值: 600] 发送状态更新的基本刷新率(秒)
ServerData.RefreshStatus = 600
-- 任务配置(Mission Configuration)
-- (int) [default: 300] Number of secounds after mission start when death of the pilot will not go to statistics, shall avoid death penalty during spawning DCS bugs
---(int)[默认值：300]任务开始后的秒数内当飞行员的死亡不会去统计,避免在DCS产生错误时造成死亡
ServerData.MissionStartNoDeathWindow = 300
-- 本地化(Localisation)
-- (string) Message send to players connecting the server - Line 1
ServerData.MOTD_L1 = '欢迎来到我们的服务器!'
-- ServerData 与 DCS World集成统计和事件数据
-- (string) Message send to players connecting the server - Line 2
-- (string) 消息发送给连接服务器的玩家
ServerData.MOTD_L2 = '统计和事件数据已集成到DCS World.'
-- (string) Information to send to players when ServerData connection is broken
-- (string) 从服务器数据连接中断时发送给玩家的信息
ServerData.ConnectionError = 'ERROR: Connection broken - contact server admin!'
