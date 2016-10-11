using UnityEngine;
using System.Collections;
using System.IO;

public class PathUtil {

    public static void DeleteFolder(string path)
    {
        if (Directory.Exists(path))
        {
            string[] paths = Directory.GetFiles(path);
            for (int i = 0; i < paths.Length; ++i)
            {
                File.Delete(paths[i]);
            }
            paths = Directory.GetDirectories(path);
            for (int i = 0; i < paths.Length; ++i)
            {
                DeleteFolder(paths[i]);
            }
            Directory.Delete(path);
        }
    }
    

    public static void ClearPersistentDataPath()
    {
        if (Directory.Exists(Application.persistentDataPath)) {
            string[] paths = Directory.GetFiles(Application.persistentDataPath);
            for (int i = 0; i < paths.Length; ++i) {
                File.Delete(paths[i]);
            }
            paths = Directory.GetDirectories(Application.persistentDataPath);
            for (int i = 0; i < paths.Length; ++i) {
                DeleteFolder(paths[i]);
            }
        }
    }

    // "a/b/c/xxx.yyy" -> "a/b/c"
    public static string GetFolderPath(string path) {
        int index = path.LastIndexOf("/");
        if (index > 0) {
            return path.Substring(0, index);
        }
        return string.Empty;
    }

    public static void EnsureUnityFolder(string path) {
        EnsureFolder(Application.dataPath + path);
    }
    
    // just like the name
    public static void EnsureFolder(string path)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
    }

    //  "/abc.xxx" -> "E:/LearnYouSomeUnity/Assets/abc.xxx"
    public static string GetSysPath(string path)
    {
        return Application.dataPath + path;
    }

    //  "/abc.xxx" -> "Assets/abc.xxx"
    public static string GetUnityPath(string path)
    {
        return "Assets" + path;
    }

    public static string Sys2UnityPath(string path) { 
        path = path.Replace("\\", "/");
        int index = path.IndexOf("Assets");
        return path.Substring(index);
    }

    public static string Unity2SysPath(string path) {
        return GetSysPath(path.Replace("Assets", ""));
    }

    // get the asset's name by path
    public static string GetAssetName(string path)
    {
        int index = path.LastIndexOf("/");
        if (index >= 0)
        {
            int index2 = path.LastIndexOf(".");
            if (index2 > 0)
            {
                return path.Substring(index + 1, index2 - index - 1);
            }
            return path.Substring(index + 1);
        }
        return path;
    }
}
