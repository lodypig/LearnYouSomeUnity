using UnityEngine;
using LuaInterface;
using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;

public class LuaBridge 
{

    public static LuaFunction onPingBack_TimeManager;
    public static LuaFunction onDestroyGO;
    static LuaFunction onCreateUI;

    //需要自己来调用 这个注册函数，等价手写wrap文件
    public static void Register()
    {
        LuaState L = Lua.state;
        L.BeginModule(null);
        L.RegFunction("Send", SendLua);
        L.RegFunction("BlackSend", BlackSend);
        L.RegFunction("SetPort", SetPort);
        L.EndModule();
    }

    // Lua虚拟机启动完毕，加载所有lua文件后，会来调用，用于缓存C#所需lua内容
    public static void RegisterLuaFunc() {
        onPingBack_TimeManager = Lua.GetFunction("TimerManager.PingBack");
        onCreateUI = Lua.GetFunction("EventManager.onCreateUI");
        GameMain.Instance.onUpdate_SingletonManager = Lua.GetFunction("client.singleton.Update");
        GameMain.Instance.onUpdate_TimeManager = Lua.GetFunction("TimerManager.Update");
        GameMain.Instance.onCreateFinished_InstanceManager = Lua.GetFunction("InstanceManager.OnCreateFinished");
        GameMain.Instance.onDropItemManager_OnDestroy = Lua.GetFunction("DropItemManager.OnDestroy");
        GameMain.Instance.onDropItemManager_OnAnimatorMove = Lua.GetFunction("DropItemManager.OnAnimatorMove");
        GameMain.Instance.onDropItemManager_OnUpdate = Lua.GetFunction("DropItemManager.OnUpdate");
        onDestroyGO = Lua.GetFunction("EventManager.removeGO");

        Net.Instance.onRelogin = Lua.GetFunction("LoginManager.OnRelogin");
        Net.Instance.onConnectLost = Lua.GetFunction("LoginManager.ConnectLost");
        Net.Instance.onShowConnectUI = Lua.GetFunction("LoginManager.ShowConnectUI");
        Net.Instance.onShowReconnectFailed = Lua.GetFunction("LoginManager.ShowReconnectFailed");
    }

    // 重登和返回时，调用，游戏重开后虚拟机会重启。
    public static void Dispose() {
        if (onPingBack_TimeManager != null) {
            onPingBack_TimeManager.Dispose();
            onPingBack_TimeManager = null;
        }

        if (onCreateUI != null){
            onCreateUI.Dispose();
            onCreateUI = null;
        }

        if (Net.Instance != null)
        {
            if (Net.Instance.onRelogin != null)
            {
                Net.Instance.onRelogin.Dispose();
                Net.Instance.onRelogin = null;
            }

            if (Net.Instance.onShowConnectUI != null)
            {
                Net.Instance.onShowConnectUI.Dispose();
                Net.Instance.onShowConnectUI = null;
            }

            if (Net.Instance.onConnectLost != null)
            {
                Net.Instance.onConnectLost.Dispose();
                Net.Instance.onConnectLost = null;
            }

            if (Net.Instance.onShowReconnectFailed != null)
            {
                Net.Instance.onShowReconnectFailed.Dispose();
                Net.Instance.onShowReconnectFailed = null;
            }
        }

        for (int i = 0; i < funcList.Count; ++i){
            funcList[i].Dispose();
        }
    }

    static int SendLua(IntPtr L, bool isBlack) {
        int count = LuaDLL.lua_gettop(L);
        if (count == 1){
            ErlKVMessage msg = NetConverter.lua2msg(L, 1);
            Net.Send(msg, isBlack);            
            count = LuaDLL.lua_gettop(L);            
            return 0;
        } else if (count == 2){
            ErlKVMessage msg = NetConverter.lua2msg(L, 1);            
            LuaFunction func = ToLua.CheckLuaFunction(L, 2);
            Net.SendLua(msg, func, isBlack);            
            count = LuaDLL.lua_gettop(L);
            return 0;
        } else {
            LuaDLL.toluaL_exception(L, null, "invalid arguments to method: SendLua");
        }

        return 0;
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SendLua(IntPtr L){
        return SendLua(L, false);
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int BlackSend(IntPtr L){
        return SendLua(L, true);
    }

    static List<LuaFunction> funcList = new List<LuaFunction>();


    public static void Destroy()
    {
        Dispose();
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int SetPort(IntPtr L) {
        int count = LuaDLL.lua_gettop(L);
        if (count != 2 && count != 3) {
            LuaDLL.toluaL_exception(L, null, "invalid arguments to method: SetPort");
            return 0;
        }
        string port = ToLua.CheckString(L, 1);
        LuaFunction func = ToLua.CheckLuaFunction(L, 2);
        funcList.Add(func);
        bool isKV = true;
        if (count == 3) {
            isKV = ToLua.CheckBoolean(L, 3);
        }
        DataAccess.GetInstance().Ports.SetPort(port, (con, msg) =>
        {
            func.BeginPCall();
            if (isKV) {
                NetConverter.KVPushLua(msg, L);
            } else {
                NetConverter.PushLua(msg, L);
            }
            func.PCall(1);
            func.EndPCall();
        });
        return 0;
    }

    public static void onUI(string uiName) {
        uFacadeUtility.CallLuaFunctionArgStr(onCreateUI, uiName);
    }

    public static LuaFunction GetLuaFunction(LuaTable t, string fullname)
    {
        IntPtr L = Lua.state.L;
        // 保留栈顶
        int oldTop = LuaDLL.lua_gettop(L);
        // 分割名称
        int startIndex = 0;
        // push 表
        Lua.state.Push(t);
        // 获取表
        StringBuilder sb = new StringBuilder();
        LuaTypes type = LuaTypes.LUA_TNONE;
        while(true)
        {
            int index = fullname.IndexOf('.', startIndex);
            if (index == -1)
            {
                sb.Remove(0, sb.Length);
                sb.Append(fullname, startIndex, fullname.Length - startIndex);
                LuaDLL.lua_pushstring(L, sb.ToString());
                LuaDLL.lua_rawget(L, -2);
                type = LuaDLL.lua_type(L, -1);
                if (type != LuaTypes.LUA_TFUNCTION)
                {
                    LuaDLL.lua_settop(L, oldTop);
                    return null;
                }
                break;
            }
            else
            {
                sb.Remove(0, sb.Length);
                sb.Append(fullname, startIndex, index - startIndex);
                startIndex = index + 1;
                LuaDLL.lua_pushstring(L, sb.ToString());
                LuaDLL.lua_rawget(L, -2);
                type = LuaDLL.lua_type(L, -1);
                if (type != LuaTypes.LUA_TTABLE)
                {
                    LuaDLL.lua_settop(L, oldTop);
                    return null;
                }
            }
        }
        
        // 获取函数
        int reference = LuaDLL.luaL_ref(L, LuaIndexes.LUA_REGISTRYINDEX);                
        LuaFunction func = new LuaFunction(reference, Lua.state);
        LuaDLL.lua_settop(L, oldTop);
        return func;
    }
}

    