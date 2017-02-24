using System;
using System.IO;
using UnityEngine;
using System.Text;
using System.Collections.Generic;

/// <summary>
/// 路径工具
/// </summary>
public static class PathUtil
{

    /// <summary>
    /// 存在文件
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
    public static bool ExistsFile(string path)
    {
        return File.Exists(path);
    }


    /// <summary>
    /// 存在目录
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
    public static bool ExistsDir(string path)
    {
        return Directory.Exists(path);
    }


    /// <summary>
    /// 获取父目录
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
	public static string GetParentDir(string path)
    {
        path = path.Replace("\\", "/");
        int pos = path.LastIndexOf('/');
        if (pos == -1)
        {
             DirectoryInfo dirInfo = new DirectoryInfo(path);
             return dirInfo.Parent.ToString();
        }
        return path.Substring(0, pos).Trim();
    }


  


    /// <summary>
    /// 获取全名（带后缀的名字）
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
    public static string GetFileName(string path)
    {
        return Path.GetFileName(path);
    }


    // 获取文件夹名字
    public static string GetDirName(string path) 
    {
        int index = path.LastIndexOf("/");
        if (index > 0) {
            return path.Substring(index + 1);
        }
        return path;
    }

    
    


    /// <summary>
    /// 获取主干名（不带后缀的名字）
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
    public static string GetFileNameWithoutExtension(string path)
    {
        return Path.GetFileNameWithoutExtension(path);
    }


    /// <summary>
    /// 获取后缀名
    /// </summary>
    /// <param name="path">路径</param>
    /// <returns></returns>
    public static string GetExtension(string path)
    {
        return Path.GetExtension(path);
    }


    /// <summary>
    /// 获取 PersistentDataPath
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static string GetPersistentDataPath(string path)
    {
        return Application.persistentDataPath.Combine(path);
    }


    /// <summary>
    /// 获取 StreamingAssetsDataPath
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static string GetStreamingAssetsDataPath(string path)
    {
        return Application.streamingAssetsPath.Combine(path);
    }


    public static string GetAssetPath(string path)
    {
        if (path.StartsWith(Application.dataPath.Replace("\\", "/")))
        {
            path = path.Substring(Application.dataPath.Length + 1);
        }
        return string.Format("Assets/{0}", path);
    }

    public static string GetNewParentPath(string path, string parent, string target) {
        return target.Combine(PathUtil.GetRelativePath(parent, path));
    }

    public static string GetFullPath(string path)
    {
        int index = path.IndexOf("Assets");
        string assetsPath = path;
        if (index != -1) {
            assetsPath = path.Substring(index + "Assets/".Length);
        }
        return Path.GetFullPath(Application.dataPath.Combine(assetsPath)).ReplaceESC();
    }

    // 获取Path相对于parent路径
    public static string GetRelativePath(string parent, string path)
    {
        if (!path.StartsWith(parent))
            return path;
        string relativePath = path.Substring(parent.Length).Replace("\\", "/");
        if (relativePath.StartsWith("/"))
            relativePath = relativePath.Substring(1);
        return relativePath;
    }

    public static string GetRelativePathToDataPath(string path)
    {
        return GetRelativePath(Application.dataPath, path);
    }

    public static string GetRelativePathToAsset(string path) {
        return GetRelativePath("Assets/", path);
    }

    public static string SystemPath2AssetPath(string path)
    {
        return "Assets/" + GetRelativePathToDataPath(path);
    }

    public static void EnsuerFolder(string systemPath) { 
        if (!ExistsDir(systemPath)) {
            Directory.CreateDirectory(systemPath);
        }
    }

    public static void EnsuerStreamingAssetFolder(string path) {
        EnsuerFolder(Application.streamingAssetsPath.Combine(path));
    }

    public static void DeleteFileOrFolder(string path) 
    {
        string[] files;
        if (Directory.Exists(path))
        {
            files = Directory.GetFiles(path);
            for (int i = 0; i < files.Length; ++i)
            {
                File.Delete(files[i]);
            }

            files = Directory.GetDirectories(path);
            for (int i = 0; i < files.Length; ++i)
            {
                DeleteFileOrFolder(files[i]);
            }

            Directory.Delete(path);
        }
        else if (File.Exists(path)) { 
                File.Delete(path);
            }
     }

    public static bool FilterPattern(string file, string pattern) {
        string[] patternList = pattern.Split(new char[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
        string ext = "*" + PathUtil.GetExtension(file);
        string ext2 = PathUtil.GetFileName(file);
        if (ext2.StartsWith("_"))
        {
            return false;
        }
        for (int i = 0; i < patternList.Length; ++i) {
            if (!patternList[i].Contains(ext)
              && !patternList[i].Contains(ext2))
                continue;
            return true;
        }
        return false;
      
    }

    public static List<string> FilterPattern(string[] fileList, string pattern)
    {
        if (string.IsNullOrEmpty(pattern)) {
            return new List<string>(fileList);
        }
        string[] patternList = pattern.Split(new char[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
        HashSet<string> patternSet = new HashSet<string>();
        for (int i = 0; i < patternList.Length; ++i )
        {
            patternSet.Add(patternList[i]);
        }
        List<string> files = new List<string>();
        foreach (string f in fileList)
        {
            // ext = *.ext
            // ext2 = name.ext
            string ext = "*" + PathUtil.GetExtension(f);
            string ext2 = PathUtil.GetFileName(f);

            if (ext2.StartsWith("_"))
            {
                continue;
            }

            if (!patternSet.Contains(ext)
                && !patternSet.Contains(ext2))
                continue;
            files.Add(f);
        }
        return files;
    }

    public static string ReplaceExtentsion(string path, string ext) {
        int index = path.LastIndexOf('.');
        if (index > 0) {
            return path.Substring(0, index) + ext;
        }
        return path + ext;
    }

    public static string LastTrim(string path, char separator) {
        int index = path.LastIndexOf(separator);
        if (index > 0) {
            return path.Substring(index + 1);
        }
        return path;
    }

    public static string[] splitePath(string path) {
        string[] s = path.Split('/');
        s[s.Length - 1] = GetFileNameWithoutExtension(s[s.Length - 1]);
        string tmp;
        if (s.Length > 2)
        {
            for (int j = 0; j < Math.Floor(s.Length / 2.0); ++j)
            {
                //需要转换成小写
                tmp = s[j].ToLower();
                s[j] = s[s.Length - j - 1].ToLower();
                s[s.Length - j - 1] = tmp;
            }
        }
        return s;
    }

    // -------------------------------- string extend --------------------------------
    public static string ReplaceESC(this string path)
    {
        return path.Replace("\\", "/");
    }

    /// <summary>
    /// 连接路径
    /// </summary>
    /// <param name="path1">路径1</param>
    /// <param name="path2">路径2</param>
    /// <returns></returns>
    public static string Combine(this string path, params string[] paths)
    {
        int capcity = path.Length;
        for (int i = 0; i < paths.Length; ++i) { 
            paths[i] = paths[i].ReplaceESC();
            capcity += paths[i].Length;
        }
        capcity = capcity + paths.Length + 1;
        StringBuilder sb = new StringBuilder(capcity);
        sb.Append(path);
        for (int i = 0; i < paths.Length; ++i) {
            sb.Append("/");
            sb.Append(paths[i]);
        }
        return sb.ToString();
    }


}
