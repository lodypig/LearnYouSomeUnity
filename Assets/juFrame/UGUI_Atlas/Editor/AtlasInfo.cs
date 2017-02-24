using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System;

[System.Serializable]
public class AtlasInfo : ScriptableObject{    

    [SerializeField]
    public strdirDict spriteDirInfoDict = new strdirDict();

    [SerializeField]
    public strdirDict atlasDirInfoDict = new strdirDict();

    public string spritePath;
    public string targetPath;
    

    public AtlasInfo(string path, string targetPath) {
        this.spritePath = path;
        this.targetPath = targetPath;
    }

    public List<string> UpdateAndGetChangedSprites() {

        // 获取现在目录下的所有文件夹
        string[] dirs = Directory.GetDirectories(PathUtil.GetFullPath(spritePath));
        List<string> changedDirs = new List<string>();
        for (int i = 0; i < dirs.Length; ++i)
        {
            // 如果已经在记录中
            if (spriteDirInfoDict.ContainsKey(dirs[i]))
            {
                if (spriteDirInfoDict[dirs[i]].UpdateAndCheckChange())
                {
                    changedDirs.Add(dirs[i]);
                }
            }
            else {
                // 记录新增文件，并添加到需要生成atlas列表
                changedDirs.Add(dirs[i]);
                spriteDirInfoDict.Add(dirs[i], new TDirInfo(dirs[i], "*.png"));              
            }
        }
        return changedDirs;
    }

    public List<string> UpdateAndGetChangedAtlas() {
        List<string> changedDirs = new List<string>();

        // 检查原有的
        foreach (var kv in atlasDirInfoDict)
        {
            string spritePath = Atlas2SpritePath(kv.Key);
            if (Directory.Exists(spritePath))
            {
                if (kv.Value.UpdateAndCheckChange()) {
                    changedDirs.Add(spritePath);
                }
            }
        }

        // 检查新增
        string targetFullPath = PathUtil.GetFullPath(targetPath);
        if (Directory.Exists(targetFullPath)) {
            string[] dirs = Directory.GetDirectories(targetFullPath);
            for (int i = 0; i < dirs.Length; ++i)
            {
                if (!atlasDirInfoDict.ContainsKey(dirs[i]))
                {
                    atlasDirInfoDict.Add(dirs[i], new TDirInfo(dirs[i], "*.png"));
                    changedDirs.Add(Atlas2SpritePath(dirs[i]));
                }
            }
        }   
      
        return changedDirs;
    }

    public string[] GetChangedDir() {
        List<string> changeList= UpdateAndGetChangedSprites();
        HashSet<string> hash = new HashSet<string>();
        for (int i = 0; i < changeList.Count; ++i)
        {
            hash.Add(changeList[i]);
        }
        List<string> changedAtlas = UpdateAndGetChangedAtlas();

        for (int i = 0; i < changedAtlas.Count; ++i)
        {
            if (!hash.Contains(changedAtlas[i])) {
                changeList.Add(changedAtlas[i]);
            }
        }

        return changeList.ToArray();
    }

    string Sprite2AtlasPath(string path) {
        return PathUtil.GetFullPath(PathUtil.GetNewParentPath(path, PathUtil.GetFullPath(this.spritePath), this.targetPath));
    }

    string Atlas2SpritePath(string path) {
        return PathUtil.GetFullPath(PathUtil.GetNewParentPath(path, PathUtil.GetFullPath(this.targetPath), this.spritePath));
    }

    public string[] GetRemovedList() {
        List<string> removeList = new List<string> ();
        string[] dirs = Directory.GetDirectories(PathUtil.GetFullPath(targetPath));
        for (int i = 0; i < dirs.Length; i++ )
        {
            string atlasPath = dirs[i];
            string spritePath = Atlas2SpritePath(atlasPath);
            if (!Directory.Exists(spritePath))
            {
                removeList.Add(atlasPath);
                spriteDirInfoDict.Remove(spritePath);
                atlasDirInfoDict.Remove(atlasPath);
            }
        }

        return removeList.ToArray();
    }

}


