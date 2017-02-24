using UnityEngine;
using System.Collections;
using System;

public class TTLoger
{
#if BUILD_TYPE_WAI
    static public bool EnableLog = false;
#else 
    static public bool EnableLog = true;
#endif

    //一般调试Log  只打印
    static public void Log(object message)
    {
        if (EnableLog)
        { 
            Debug.Log(message,null);
        }
    }

    //自定义Log DevelopMode只打印；日志必须记录
    static public void Log(object message, string customType)
    {
        if (EnableLog)
        {
            Debug.Log(string.Format("message:{0} customType:{1}", message, customType));
        }
        LogConsole.Log(message, customType);
    }
    static public void Log(object message, string customType, Color col)
    {
        if (EnableLog)
        {
            Debug.Log(string.Format("message:{0} customType:{1}", message, customType));
        }
        LogConsole.Log(message, customType, col);
    }

    //Error   DevelopMode只打印；日志必须记录 error严重的错误
    static public void LogError(object message)
    {
        if (EnableLog)
        {
            Debug.LogError(message);
        }
        LogError(message,null);
    }
    //自定义Error  
    static public void LogError(object message, string customType)
    {
        if (EnableLog)
        {
            //TTLoger.LogError(string.Format("message:{0} customType:{1}", message, customType));
        }
        LogConsole.LogError(message, customType);
    }

    //Warning  DevelopMode 只记录日志
    static public void LogWarning(object message)
    {
        LogWarning(message,null);
    }
    static public void LogWarning(object message, string customType)
    {
        if (EnableLog)
        {
            LogConsole.LogWarning(message, customType);
            //Debug.LogWarning(string.Format("message:{0} customType:{1}", message, customType));
        }
    }

    public static void RegisterCommand(string commandString, Func<string[], object> commandCallback, string CMD_Discribes)
    {
        LogConsole.RegisterCommand(commandString, commandCallback, CMD_Discribes);
    }

    public static void UnRegisterCommand(string commandString)
    {
        LogConsole.UnRegisterCommand(commandString);
    }

}