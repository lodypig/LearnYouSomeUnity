using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System;

public class UILuaExporter : MonoBehaviour{

    public List<string> exportNames;
    public List<UIWrapper> exportWrappers;
    public List<UILuaExporter> subCtrlList;
    
    public LuaTable luaController;

    public string scriptName;    
    public string name;
    public UILuaExporter next;

    public LuaTable InitLuaController(object param = null)
    {
        // 先执行lua脚本得到管理器
#if UNITY_EDITOR
        if (string.IsNullOrEmpty(this.scriptName)) {
            TTLoger.LogError("未指定界面管理器函数 : " + this.gameObject.name);
            return null;
        }
#endif
        LuaFunction func = Lua.GetFunction(scriptName);
#if UNITY_EDITOR
        if (func == null) {
            TTLoger.LogError("未找到界面管理器函数 ：" + scriptName);
            return null;
        }
#endif
        func.BeginPCall();
        func.Push(param);
        func.Push(this.gameObject);
        func.PCall();
        luaController = func.CheckLuaTable();
        func.EndPCall();
        

#if UNITY_EDITOR
        if (luaController == null) {
            TTLoger.LogError("无效的界面管理器函数 : " + scriptName + "(" + this.gameObject.name +")");
            return null;
        }
#endif         


        IntPtr L = Lua.state.L;

        // 赋个gameObject
        luaController["gameObject"] = this.gameObject;
        luaController["transform"] = this.transform;

        // 先导出子导出器
        InitSubController(L);

        // 如果没有导出控件就完事了
        if (exportNames == null || exportNames.Count == 0){
            return luaController;
        }

        // 准备导出控件
        int oldTop = LuaDLL.lua_gettop(L);
        Lua.state.Push(luaController);

        // 出现多个同名导出控件，转成table形式
        HashSet<string> tabled = new HashSet<string>();   // 转table标记
        
        for (int i = 0; i < exportNames.Count; ++i) {
            // 说明已经导出过了
            if (tabled.Contains(exportNames[i])) {
                continue;
            }
            // push 控件名
            LuaDLL.lua_pushstring(L, exportNames[i]);            

            // 检查如果后面有同名的就一起以table形式导出
            int n = 1;
            for (int j = i + 1; j < exportNames.Count; ++j) {
                if (exportNames[i].Equals(exportNames[j])) {
                    if (!tabled.Contains(exportNames[i])) {
                        LuaDLL.lua_newtable(L);
                        tabled.Add(exportNames[i]);
                        Lua.state.Push(exportWrappers[i]);
                        LuaDLL.lua_rawseti(L, -2, n++);
                    }

                    Lua.state.Push(exportWrappers[j]);
                    LuaDLL.lua_rawseti(L, -2, n++);
                }
            }
            if (!tabled.Contains(exportNames[i])) {
                Lua.state.Push(exportWrappers[i]);
            }                
            LuaDLL.lua_settable(L, -3);
        }

        LuaDLL.lua_settop(L, oldTop);
        return luaController;
    }

    public void InitSubController(IntPtr L) {
        if (subCtrlList == null || subCtrlList.Count == 0){
            return;
        }

        int oldTop = LuaDLL.lua_gettop(L);
        Lua.state.Push(luaController);

        for (int i = 0; i < subCtrlList.Count; ++i)
        {
            LuaDLL.lua_pushstring(L, subCtrlList[i].name);          
            if (subCtrlList[i].next)
            {
                UILuaExporter p = subCtrlList[i];
                LuaDLL.lua_newtable(L);
                int n = 1;
                while (p != null)
                {
                    p.InitLuaController(L);
                    Lua.state.Push(p.luaController);
                    LuaDLL.lua_rawseti(L, -2, n++);
                    p = p.next;
                }
            }
            else
            {
                subCtrlList[i].InitLuaController(L);
                Lua.state.Push(subCtrlList[i].luaController);
            }
            LuaDLL.lua_settable(L, -3);
        }

        LuaDLL.lua_settop(L, oldTop);
    }

    public void SetExport(List<string> exportNames, List<UIWrapper> exportWrappers)
    {
        if (exportNames.Count == 0)
        {
            this.exportNames = null;
        }
        else { 
            this.exportNames = exportNames;
        }

        if (exportWrappers.Count == 0)
        {
            this.exportWrappers = null;
        }
        else { 
            this.exportWrappers = exportWrappers;
        }
    }

    public void Release() {
        if (luaController != null) {
            luaController.Dispose();
            luaController = null;
        }
        if (subCtrlList != null) {
            for (int i = 0; i < subCtrlList.Count; ++i) {
                subCtrlList[i].Release();
            }
        }
    }

    
}
