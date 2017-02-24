using UnityEngine;
using System;
using System.IO;
using System.Collections;
using System.Xml;
using System.Text;
//using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Collections.Generic;

/// <summary>
/// 版本配置
/// </summary>
public class VersionConfig
{
    public int version = 0;                                                     // 版本号
    public Dictionary<string, VersionFileConfig> fileDict = new Dictionary<string, VersionFileConfig>(); // 文件信息
}

/// <summary>
/// 版本文件配置
/// </summary>
public class VersionFileConfig
{
    public string path = string.Empty;  // 路径
    public string md5 = string.Empty;   // md5
    public int sizeByte = 0;
}


/// <summary>
/// 版本工具
/// </summary>
public class VersionUtil
{
    /// <summary>
    /// 生成版本配置
    /// </summary>
    /// <param name="path">路径</param>
    /// <param name="version">版本号</param>
    /// <returns></returns>
 

    /// <summary>
    /// 解析版本配置信息
    /// </summary>
    /// <param name="content"></param>
    /// <returns></returns>
    public static VersionConfig ReadVersionConfig(string content)
    {
        VersionConfig vc = new VersionConfig();

        XmlDocument doc = new XmlDocument();
        doc.LoadXml(content);

        XmlElement root = null;
        root = doc.DocumentElement;
        XmlElement version = root.GetElementsByTagName("Version").Item(0) as XmlElement;
        string sVersion = version.InnerText;
        int.TryParse(sVersion, out vc.version);

        XmlElement files = root.GetElementsByTagName("Files").Item(0) as XmlElement;

        XmlNodeList fileList = files.GetElementsByTagName("File");

        for (int i = 0; i < fileList.Count; ++i)
        {
            XmlElement file = fileList.Item(i) as XmlElement;

            XmlElement path = file.GetElementsByTagName("Path").Item(0) as XmlElement;
            string sPath = path.InnerText;
            
            XmlElement md5 = file.GetElementsByTagName("MD5").Item(0) as XmlElement;
            string sMD5 = md5.InnerText;

            XmlElement sizeByte = file.GetElementsByTagName("SizeByte").Item(0) as XmlElement;
            int iSizeByte = Int32.Parse(sizeByte.InnerText);

            VersionFileConfig vfc = new VersionFileConfig();
            vfc.path = sPath;
            vfc.md5 = sMD5;
            vfc.sizeByte = iSizeByte;
            if (vc.fileDict.ContainsKey(vfc.path))
            {
                vc.fileDict.Remove(vfc.path);
            }
            vc.fileDict.Add(vfc.path, vfc);
        }

        return vc;
    }
    
    // 从StreamingAsset读取version.jz
    // 从StreamingAsset读取缓存的最新的version.jz
    public static VersionConfig ReadConfig(string versionPath)
    {
        AssetBundle ab = AssetBundleLoader.Load(versionPath);
        if (ab != null)
        {
            TextAsset text = ab.LoadAsset("version") as TextAsset;
            if (text == null) {
                return null;
            }
            string content = text.text;
            VersionConfig vc = ReadVersionConfig(content);
            ab.Unload(true);
            // 读取成功
            return vc;
        }
        else
        {
            // 读取失败
            return null;
        }
    }

    //如果persistent路径下面的version信息新于streaming路径下面的version信息，说明persistent下面都是老的资源，删除掉
    public static VersionConfig handleOldAb(string versionPath)
    {
        AssetBundle preAb = AssetBundleLoader.LoadFromPersistentDataPath(versionPath);
        VersionConfig preVc = null;
        if (preAb != null)
        {
            TextAsset text = preAb.LoadAsset("version") as TextAsset;
            string content = text.text;
            preVc = ReadVersionConfig(content);
            preAb.Unload(true);
        }
        AssetBundle streamAb = AssetBundleLoader.LoadFromStreamingAssetsPath(versionPath);
        VersionConfig streamVc = null;
        if (streamAb != null)
        {
            TextAsset text = streamAb.LoadAsset("version") as TextAsset;
            string content = text.text;
            streamVc = ReadVersionConfig(content);
            streamAb.Unload(true);
        }
        if (preVc == null)
        {
            return streamVc;
        }
        if (preVc.version < streamVc.version)
        {
            Directory.Delete(Application.persistentDataPath, true);
            return streamVc;
        }
        return preVc;
    }

}
