using UnityEngine;
using System.Collections;
using System;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

[System.Serializable]
public class TFileInfo
{
    [SerializeField]
    string path;

    [SerializeField]
    string md5;

    public TFileInfo(string path)
    {
        this.path = path;
        UpdateAndCheckChange();

    }

    public string getMd5() {
        FileStream fs = new FileStream(this.path, FileMode.Open);
        byte[] bytes = new byte[fs.Length];
        fs.Read(bytes, 0, bytes.Length);
        string md5 = CryptUtil.GetMD5(bytes);
        fs.Close();
        return md5;
    }

    // 检查是否改变,并更新md5
    public bool UpdateAndCheckChange()
    {
        if (!File.Exists(this.path)) {
            return true;
        }
        string md5 = getMd5();
        bool changed;
        changed = string.IsNullOrEmpty(this.md5) || this.md5 != md5;
        this.md5 = md5;
        return changed;
    }
}
