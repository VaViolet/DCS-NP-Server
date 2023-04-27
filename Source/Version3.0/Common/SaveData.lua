SaveData = {}

function SaveData.creatDir(path, name)
  lfs.mkdir(path .. name)
  return lfs.writedir() .. name
end

function SaveData.creatFile(path, name, data)
  local FilePath = path .. "\\" .. name
  local LogFile = io.open(FilePath, "a")
  if LogFile then
    LogFile:write(data .. "\n")
    LogFile:close()
  end
end
function SaveData.file_exists(path)
  local file = io.open(path, "rb")
  if file then
    file:close()
  end
  return file ~= nil
end
