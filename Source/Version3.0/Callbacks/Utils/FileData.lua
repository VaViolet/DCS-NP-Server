if FileData == nil then
  FileData = {}
  FileData.load_File = function(FilePath)
    local File = io.open(FilePath, "r")
    if File then
      local FileText = File:read("*all")
      File:close()
      local status, retval =
        pcall(
        function()
          return net.json2lua(FileText)
        end
      )
      if status then
        net.log(FilePath .. "加载成功")
        return retval
      else
        net.log("数据格式错误,文件内容不是JSON格式")
      end
    else
      net.log(FilePath .. "未找到,正在创建...")
      FileData.CreatFile(FilePath) -- creates the file.
    end
  end
--TODO
  FileData.SaveData = function(FilePath, data)
    local File = io.open(FilePath, "w")
    if File then
      File:write(data)
      File:close()
    else
      net.log(FilePath .. "保存失败")
    end
  end
  FileData.CreatFile = function(FilePath)
    local File = io.open(FilePath, "w")
    if File then
      local json = {}
      File:write(net.lua2json({}))
      File:close()
      File = nil
      net.log(FilePath .. "创建成功")
    else
      net.log(FilePath .. "创建失败")
    end
  end
end
