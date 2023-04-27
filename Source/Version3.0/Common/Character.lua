DoString = function(s)
  local func, err = loadstring(s)
  if func then
    return true, func()
  else
    net.log("dostring error in string: " .. err)
    return false
  end
end
--去除尾部空白符
Cut_tail_spaces = function(str)
  local tail = string.find(str, "%s+$") -- find where trailing spaces start
  if tail then
    return string.sub(str, 1, tail - 1) -- cut if there are any
  else
    return str
  end
end
TrimStr = function(str)
  return string.format("%s", str:match("^%s*(.-)%s*$"))
end

--分割字符串
Split_by_space = function(str)
  local arr = {}
  for w in string.gmatch(str, "%S+") do
    table.insert(arr, w)
  end
  return arr
end
-- coalitionSide = {
--   [0] = "中立",
--   [1] = "红方 ",
--   [2] = "蓝方"
-- }
-- log = function(str)
--   local logFile
--   if logFile then
--     logFile:write(str .. "\n")
--     logFile:flush()
--   end
-- end
-- readFile = function(path)
--   local file = io.open(path, "rb") -- r read mode and b binary mode
--   if not file then
--     return nil
--   end
--   local content = file:read "*a" -- *a or *all reads the whole file
--   file:close()
--   return content
-- end
