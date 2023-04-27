PlayerCmd = function(REXtext, playerID, ucid)
  if REXtext[1] == "help" or REXtext[1] == "h" then
    local text = string.format("玩家命令\n                                    1.转增资源点\n  -donatePoint name pointNum \n         示例:              -donatePoint Admin 100")
    net.send_chat_to(text, playerID)
  elseif REXtext[1] == "-donatePoint" and REXtext[2] and REXtext[3] then
    net.log(ucid, SourceCall.PlayerName[REXtext[2]])
    if ucid == SourceCall.PlayerName[REXtext[2]] then
      local name = net.get_player_info(playerID, "name")
      net.dostring_in("mission", [[a_do_script('SourceObj.lessSourcePoint("]] .. ucid .. '",' .. 100 .. [[)')]])
      net.send_chat_to(name .. " 乱玩指令扣100资源点", playerID)
    else
      local fun_str = [[a_do_script('SourceObj.donatePoint("]] .. ucid .. '","' .. SourceCall.PlayerName[REXtext[2]] .. '",' .. REXtext[3] .. [[)')]]
      net.dostring_in("mission", fun_str)
    end
  end
end
