using UnityEngine;
using System.Collections;
using System;
using System.IO;
using System.Collections.Generic;


[System.Serializable]
public class TDirInfo
{
    [SerializeField]
    string path;

    [SerializeField]
    string pattern;

    [SerializeField]
    strfileDict filesInfoDict = new strfileDict();

    [SerializeField]
    strdirDict dirInfoDict = new strdirDict();

    public TDirInfo(string path, string pattern = null)
    {
        this.pattern = pattern;
        this.path = path;
        if (Directory.Exists(path))
        {
            AddNew();
        }
    }

    public bool AddNewFiles()
    {
        bool addedNew = false;
        string[] files = Directory.GetFiles(path);
        files = PathUtil.FilterPattern(files, this.pattern).ToArray();
        for (int i = 0; i < files.Length; ++i)
        {
            if (!filesInfoDict.ContainsKey(files[i]))
            {
                filesInfoDict.Add(files[i], new TFileInfo(files[i]));
                addedNew = true;
            }
        }
        return addedNew;
    }

    public bool AddNewDirs()
    {
        bool addedNew = false;
        string[] dirs = Directory.GetDirectories(path);
        for (int i = 0; i < dirs.Length; ++i)
        {
            if (!dirInfoDict.ContainsKey(dirs[i]))
            {
                dirInfoDict.Add(dirs[i], new TDirInfo(dirs[i], pattern));
                addedNew = true;
            }
        }
        return addedNew;
    }

    public bool AddNew()
    {
        bool changed = AddNewFiles();
        return AddNewDirs() || changed;
    }


    // 检查子文件、文件夹是否有更新
    public bool UpdateAndCheckChangeWorker()
    {
        bool changed = false;
        foreach (var kv in filesInfoDict)
        {
            // 本来写作 ： changed || kv.Value.UpdateAndCheckChange()，发现一旦changed为true，则后面UpdateAndCheckChange（）短路不执行
            changed = kv.Value.UpdateAndCheckChange() || changed;
        }

        foreach (var kv in dirInfoDict)
        {
            changed = kv.Value.UpdateAndCheckChange() || changed;
        }
        return changed;
    }

    public bool checkRemove()
    {
        bool changed = false;
        List<string> removeList = new List<string>();

        // 移除文件
        foreach (var kv in filesInfoDict)
        {
            if (!File.Exists(kv.Key))
            {
                removeList.Add(kv.Key);
                changed = true;
            }
        }
        for (int i = 0; i < removeList.Count; ++i)
        {
            filesInfoDict.Remove(removeList[i]);
        }

        // 移除文件夹
        foreach (var kv in dirInfoDict)
        {
            if (!Directory.Exists(kv.Key))
            {
                removeList.Add(kv.Key);
                changed = true;
            }
        }
        for (int i = 0; i < removeList.Count; ++i)
        {
            dirInfoDict.Remove(removeList[i]);
        }

        return changed;

    }

    // 更新文件夹时间，并检查是否改变
    public bool UpdateAndCheckChange()
    {
        if (!Directory.Exists(this.path))
        {
            return true;
        }

        bool changed = false;

        changed = UpdateAndCheckChangeWorker() || changed; // 更新
        changed = checkRemove() || changed;  // 移除不存在
        changed = AddNew() || changed; // 添加新

        return changed;
    }
}
