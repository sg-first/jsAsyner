function writeCode(code,filepath) //将源码写入到文件中
    var hand=filecreate(filepath,"rw")
    filewrite(hand,code)
    fileclose(hand)
end

function copyCodeFile(name) //将代码文件拷贝到构建目录
    filecopy(strcat(path,name),strcat(makepath,name))
end

function readFile(filePath)
    var pa=strreplace(filePath,"Relative:\\",path)
    var con=filereadex(pa)
    return con
end

function copyLib()
    var num=filereadini("project","num",inipath)
    for(var i = 1; i <= 转整型(num); i++)
        var filename=filereadini("project",num,inipath)
        filecopy(strcat(path,filename),strcat(makepath,filename))
    end
end