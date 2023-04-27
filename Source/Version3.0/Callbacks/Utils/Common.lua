Utils = {}
function Utils.admin_caveat(ucid, point, playerID)
  net.dostring_in("mission", [[a_do_script('SourceObj.lessSourcePoint("]] .. ucid .. '",' .. point .. [[)')]])
  local name = net.get_player_info(playerID, "name")
  net.send_chat_to(name .. " 乱玩管理员指令扣100资源点", playerID)
end
Utils.checkServer = function(id)
  if id == net.get_server_id() then
    return true
  else
    return false
  end
end
Utils.sendMessage = function(GroupID, msg, showTime)
  if GroupID then
    local str = "trigger.action.outTextForGroup(" .. GroupID .. ",'" .. msg .. "'," .. showTime .. "); return true;"
    local _status, _error = net.dostring_in("server", str)
    if not _status and _error then
      net.log("Error! " .. _error)
    end
  else
    local str = "trigger.action.outText('" .. msg .. "'," .. showTime .. ",true); return true;"
    local _status, _error = net.dostring_in("server", str)
    if not _status and _error then
      net.log("Error! " .. _error)
    end
  end
end
Utils.Is_include = function(value, tab)
  if tab then
    for k, v in pairs(tab) do
      if v == value then
        return k
      end
    end
  end
  return false
end

Utils.is_includeTable = function(value, tab)
  if tab then
    for k1, v1 in pairs(tab) do
      if type(v1) == "table" then
        for k2, v2 in pairs(v1) do
          if v2 == value then
            return true
          end
        end
      end
    end
  end
  return false
end
Utils.get_stat = function(id)
  net.log(SourceCall.JSON:encode(net.get_stat(id)))
end
