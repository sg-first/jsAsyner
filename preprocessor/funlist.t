var funName
var parNum
var isOptional

var asynlibList
var sourceList

function getasynlibList(content)
    var ary
    strsplit(content,"\r\n",ary)
    asynlibList=array()
    var i=0
    for(i = 0; i < arraysize(ary); i++) //找开头
        if(ary[i]=="-asynlib-")
            break
        end
    end
    for(i = i+1; i < arraysize(ary); i++)
        if(ary[i]=="-end-")
            break
        end
        arraypush(asynlibList,ary[i])
    end
end


function getsourceList(content)
    var ary
    strsplit(content,"\r\n",ary)
    sourceList=array()
    var i=0
    for(i = 0; i < arraysize(ary); i++) //找开头
        if(ary[i]=="-source-")
            break
        end
    end
    for(i = i+1; i < arraysize(ary); i++)
        if(ary[i]=="-end-")
            break
        end
        arraypush(sourceList,ary[i])
    end
end


function indexAsynFun()
    funName=array()
    parNum=array()
    isOptional=array()
    
    for(var i = 0; i < arraysize(asynlibList); i++) //遍历所有异步库文件
        var code=filereadex(strcat(path,asynlibList[i]))
        var ary
        strsplit(code,"\r\n",ary)
        for(var j = 0; j < arraysize(ary); j++) //遍历所有行
            if(strright(ary[j],strlen(",SynchronousAWIT)"))==",SynchronousAWIT)"&&strleft(ary[j],strlen("function "))=="function ") //两边不能有空格
                var funDecl
                if(strleft(ary[j],strlen("function optional "))=="function optional ")
                    arraypush(isOptional,true) //找到异步类型
                    funDecl="function optional "
                else
                    arraypush(isOptional,false) //找到异步类型
                    funDecl="function "
                end
                var name=strright(ary[j],strlen(ary[j])-strlen(funDecl)) //截取函数定义标识右边的字符
                name=strleft(name,strfind(name,"(")-1)
                arraypush(funName,name) //找到函数名
                //找参数个数
                var arytemp
                strsplit(ary[j],",",arytemp)
                arraypush(parNum,arraysize(arytemp)) //找到参数个数
            end
        end
    end
end


function PCsourceList()
    for(var i = 0; i < arraysize(sourceList); i++) //遍历处理所有用户项目源文件
        var newcode=PCcodeFile(sourceList[i])
        writeCode(newcode,strcat(makepath,sourceList[i]))
        if(isError)
            return
        end
    end
end


function PCcodeFile(codepath)
    output(strcat("预处理文件",codepath))
    var newcode=""
    var code=filereadex(strcat(path,codepath))
    var ary
    
    code=deleteMulComment(code)
    code=deleteSpace(code)    
    
    strsplit(code,"\r\n",ary)
    for(var i = 0; i < arraysize(ary); i++)
        newcode=prepro(ary[i],newcode)
        if(isError)
            return
        end
    end
    
    output(strcat(codepath,"预处理完成"))
    return newcode
end


function prepro(str,newcode)
    str=findAndDelete(str,"//") //处理单行注释
    var codepath
    
    if (strfind(str,"#define ")!=-1) //确认这句是define语句
        strsplit(str,"#define ",codepath)
        if(codepath[0]!="")
            mistake("无法识别的#define语句")
        end
        strsplit(codepath[1]," ",codepath)
        var defineName=codepath[0]
        var defineVal=codepath[1]
        output("展开宏")
        return strreplace(newcode,defineName,defineVal)
    end
    //在此处判断是否使用异步库函数,给本行添加回调,在下一行添加回调函数,函数嵌套计数器+1(注意optional函数有SynchronousStart标签再变)
    
    //不是define语句,直接接入即可
    str=retplus(str)
    return strcat(newcode,str)
end