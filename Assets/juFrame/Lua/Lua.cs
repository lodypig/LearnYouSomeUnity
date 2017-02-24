using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaInterface;


/*
 * 负责加载项目lua文件
 * 区分开发模式与非开发模式
 */
public static class DoLuaFileWorker {

    // 有些lua文件需要优先加载(后续考虑根据文件夹来做)
    static string[] firstLoadFiles = {
                                                "Math",
                                                "List",
                                                "define",                                                
                                                "EventManager",
                                                "gemTable",
                                                "equip_gem",
                                                "horseTable"
                                     };

    // 涉及到ToLua文件搜索路径，DoFile可以两种方式找到文件
    // 1. LuaState.AddSearchPath（lua文件所在目录）
    // 2. LuaState.DoFile(xxx.Module)，会在已有的SearchPath下，查找xxx/Module
    public static void AddP27SearchPath(string fullpath = null)
    {
        if (string.IsNullOrEmpty(fullpath))
        {
            fullpath = LuaConst.luaDir;
        }
        else
        {
            Lua.state.AddSearchPath(fullpath);
        }
        string[] dirs = Directory.GetDirectories(fullpath);
        for (int i = 0; i < dirs.Length; ++i)
        {
            AddP27SearchPath(dirs[i]);
        }
    }



    // AssetBundle中加载lua文件，运行时。
    public static void DoAllLuaFile(AssetBundleRef luaAbr)
    {
        
        UnityEngine.Object[] luaFiles = luaAbr.LoadAllAssets();

        HashSet<string> set = new HashSet<string>();
        for (int i = 0; i < firstLoadFiles.Length; ++i)
        {
            set.Add(firstLoadFiles[i].ToLower());
        }
        TextAsset t;

        // 先加载firstLoad
        for (int i = 0; i < luaFiles.Length; i++)
        {
            string pureName = PathUtil.GetFileNameWithoutExtension(luaFiles[i].name);
            if (set.Contains(pureName))
            {
                t = luaFiles[i] as TextAsset;
                Lua.state.DoString(t.text);
            }
        }

        // 加载非firstLoad
        for (int i = 0; i < luaFiles.Length; i++)
        {
            string pureName = PathUtil.GetFileNameWithoutExtension(luaFiles[i].name);
            if (!set.Contains(pureName))
            {
                t = luaFiles[i] as TextAsset;
                Lua.state.DoString(t.text);
            }
        }
        Lua.Call("Main.OnInitOK");   //初始化完成
    }


    // 开发模式，直接源文件DoFile
    public static void DoAllLuaFileDev()
    {
        HashSet<string> set = new HashSet<string>();
        for (int i = 0; i < firstLoadFiles.Length; ++i)
        {
            set.Add(firstLoadFiles[i]);
        }

        DirectoryInfo dir = new DirectoryInfo(LuaConst.luaDir);
        AddP27SearchPath(); // Add 之后 直接DoFile 名字(不带后缀)

        FileInfo[] files = dir.GetFiles("*.lua", SearchOption.AllDirectories);

        // 加载firstLoad
        for (int i = 0; i < firstLoadFiles.Length; ++i)
        {
            Lua.state.DoFile(firstLoadFiles[i]);
        }

        // 加载其他
        for (int i = 0; i < files.Length; ++i)
        {
            string luafileName = PathUtil.GetFileNameWithoutExtension(files[i].FullName);
            if (!set.Contains(luafileName))
            {
                Lua.state.DoFile(luafileName);
            }
        }

        Lua.Call("Main.OnInitOK");   //初始化完成
    }
    
}



public static class Lua {
    public static LuaState state = null;

    public static void Start() {        
        state = new LuaState();
        state.Start();
        LuaBinder.Bind(state);
        LuaBridge.Register();
    }

    public static void DoAllLuaFile(AssetBundleRef luaAbr) {
        DoLuaFileWorker.DoAllLuaFile(luaAbr);
    }

    public static void DoAllLuaFileDev() {
        DoLuaFileWorker.DoAllLuaFileDev();
    }

    // 重新加载UI文件夹下内容，控制台用
    public static bool DoUIFiles()
    {
        if (AppConst.DevelopMode)
        {
            string luaRoot = LuaConst.luaDir;
            DirectoryInfo dirRoot = new DirectoryInfo(luaRoot);
            string luaPath = LuaConst.luaDir + "/Logic/UI";
            DirectoryInfo dir = new DirectoryInfo(luaPath);
            FileInfo[] tmp = dir.GetFiles("*.lua", SearchOption.AllDirectories);
            foreach (FileInfo next in tmp)
            {
                string luafileName = next.FullName.Replace(dirRoot.FullName + "\\", "");
                luafileName = luafileName.Replace("\\", "/");                
                state.DoFile(luafileName);
            }
            return true;
        }
        return false;
    }

    public static LuaFunction GetFunction(string name) {        
        return state.GetFunction(name);
    }       

    // 慎用
    // 有GC, 来自参数和返回值的装箱和拆箱
    public static object[] Call(string funcName, params object[] args)
    {
        LuaFunction func = state.GetFunction(funcName);
        if (func != null)
        {
            return func.Call(args);
        }
        return null;
    }
    
    // 参数无GC，返回值有GC
    // 无返回值，图简单使用
    // 内含推荐的func调用方式
    public static object[] Call<T>(string funcName, params T[] args) {
        LuaFunction func = state.GetFunction(funcName);
        if (func == null) {
            return null;
        }
        func.BeginPCall();
        if (args != null) {
            for (int i = 0; i < args.Length; ++i) {
                func.Push(args[i]);
            }
        }
        func.PCall();
        object[] objs = func.CheckObjects();
        func.EndPCall();
        return objs;
    }

    public static LuaTable NewTable() {
        state.LuaNewTable();
        int oldTop = state.LuaGetTop();
        LuaTable table = state.CheckLuaTable(-1);
        state.LuaSetTop(oldTop);
        return table;
    }

    public static System.IntPtr L {
        get {
            return state.L;
        }
    }

}
