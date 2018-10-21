var path
var makepath
var inipath
var isExternal
var isHide
var useJsgo
var usePIO

var isError

function mainExit()
    exit()
end

function output(str)
    if(!isHide)
        str=strcat(str,"\r\n")
        editsettext("处理输出",strcat(editgettext("处理输出"),str))
    end
end

function mistake(str)
    if(!isHide)
        str=strcat("-----error: ",str)
        output(strcat(str,"-----"))
        isError=true
    end
end


function preprocessor_初始化()
    path=sysgetcurrentpath()
    inipath=strcat(path,"lib.ini")
end


function 运行热键_热键()
    output("-----start: 开始构建-----")
    isError=false
    output("创建构建文件夹")
    var projectName=filereadini("project","name",inipath)
    makepath=strcat(path,strcat("build-",projectName))
    folderdelete(makepath)
    foldercreate(makepath)
    makepath=strcat(makepath,"\\")
    output("索引asynlib中定义的异步函数")
    var asynContent=filereadex(strcat(path,"asyn.txt"))
    getasynlibList(asynContent)
    getsourceList(asynContent)
    indexAsynFun()
    output("开始预处理代码")
    PCsourceList()
    if(isError)
        return
    end
    output("拷贝库文件")
    copyLib()
    output("-----finish: 处理完成-----")
end


function 预处理运行_点击()
    运行热键_热键()
end
