 using UnityEngine;
using System;
using System.Collections;
using LuaInterface;
using System.Collections.Generic;
using UnityEngine.UI;

//wugj 新的LuaBehaviour，现在一个UI对应的Lua文件会在Awake后将对应的controller保存在LuaController中
//     当GameObject被销毁时，这个LuaTable也会告知虚拟机加入GC列表
public class LuaBehaviour : UIWrapper {    
    private bool firstUpdate = true;
    private LuaFunction updateFunc;
    private object param;
    private int delayCount = 0;
    private Dictionary<int, LuaFunction> delayDict = new Dictionary<int, LuaFunction>();
    public string uiName;
    public bool isDestroyed = false;
    public LuaTable LuaController;
    public UILuaExporter exporter;


    public void OnApplicationQuit()
    {
        isDestroyed = true;
    }

    public object Param{
        set{
            param = value;
        }
    }

    public virtual void Start()
    {
        this.name = this.name.Replace("(Clone)", "");

        if (exporter == null)
        {
            string scriptName = name + "View";
            object[] obj = Lua.Call(scriptName, param);
            LuaController = obj[0] as LuaTable;
        }
        else {             
            LuaController = exporter.InitLuaController(param);
            LuaController["gameObject"] = this.gameObject;
            LuaController["transform"] = transform;
        }

        LuaController["this"] = this;

        UILayer layer = this.GetComponent<UILayer>();
        if (layer != null)
        {
            LuaController["layer"] = layer;
        }

        updateFunc = LuaController["Update"] as LuaFunction;
        CallLuaMethod("Start", this, gameObject);
    }

    public virtual void Update()
    {
        if (firstUpdate)
        {
            firstUpdate = false;
            LuaFunction fuc = LuaController["FirstUpdate"] as LuaFunction;
            if (fuc != null) {
                fuc.BeginPCall();
                fuc.Push(this.gameObject);
                fuc.PCall();
                fuc.EndPCall();
                fuc.Dispose();
            }
            LuaController["isFirstUpdate"] = true;
            LuaBridge.onUI(uiName);            
        }
        if (updateFunc != null)
        {
            updateFunc.Call();
        }
    }

    public object[] CallLuaMethod(string func, params object[] param)
    {
        if (isDestroyed || Lua.state == null || LuaController == null)
            return null;


        LuaFunction Luafunc = LuaController[func] as LuaFunction;
        if (Luafunc == null)
            return null;
        object[] result = Luafunc.Call(param);
        Luafunc.Dispose();
        return result;
    }
  
    public LuaFunction HaveLuaMethod(string func)
    {
        if (isDestroyed || Lua.state == null)
            return null;

        return LuaController[func] as LuaFunction;
    }


    public int Delay(float time, LuaFunction luaFunc)
    {
        int funcID = delayCount++;
        delayDict.Add(funcID, luaFunc);
        StartCoroutine(DelayCall(time, funcID));
        return funcID;
    }

    public void CancelDelay(int funcID)
    {
        if (delayDict.ContainsKey(funcID))
        {
            delayDict.Remove(funcID);
        }
    }

    IEnumerator DelayCall(float waitTime, int funcID)
    {
        yield return new WaitForSeconds(waitTime);
        if (delayDict.ContainsKey(funcID))
        {
            LuaFunction func = delayDict[funcID];
            delayDict[funcID].Call();
            delayDict.Remove(funcID);
            func.Dispose();
        }
    }

    //-----------------------------------------------------------------
    public override void OnDestroy()
    {
        base.OnDestroy();
        if (updateFunc != null)
        {
            updateFunc.Dispose();
            updateFunc = null;
        }
        
        CallLuaMethod("OnDestroy");
        UIManager.Instance.DestoryDlg(this.gameObject);
		Resources.UnloadUnusedAssets();

        //销毁Lua管理器
        if (LuaController != null)
        {
            LuaController.Dispose();
            LuaController = null;
            if (exporter != null) { 
                exporter.Release();            
            }
            isDestroyed = true;
        }
    }
}
