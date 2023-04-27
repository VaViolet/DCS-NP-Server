net.set_name('PVP动态战役')
local res = net.start_server(serverSettings)
if res ~= 0 then
  log.write('专用服务器', log.DEBUG, '无法以代码启动服务器:', res)
end