using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using System.Text;

namespace ABSystem
{
    public class VersionGenerator
    {
        public static VersionConfig GenerateVersionConfig(AssetBundleCollector collector)
        {
            VersionConfig vc = VersionUtil.ReadConfig("config/version") ?? new VersionConfig();

            VersionConfig newVC = new VersionConfig();
            newVC.version = vc.version + 1;

            List<AssetBundleBuild> buildList = collector.GetBuildList();
            for (int i = 0; i < buildList.Count; ++i) {
                AssetBundleBuild build = buildList[i];
                string file = Application.streamingAssetsPath.Combine(build.assetBundleName);
                if (PathUtil.ExistsFile(file))
                {
                    FileStream fs = new FileStream(file, FileMode.Open);
                    byte[] bytes = new byte[fs.Length];
                    fs.Read(bytes, 0, bytes.Length);
                    string md5 = CryptUtil.GetMD5(bytes);
                    fs.Close();
                    VersionFileConfig vfc = new VersionFileConfig();
                    vfc.path = build.assetBundleName;
                    vfc.md5 = md5;
                    vfc.sizeByte = bytes.Length;
                    if (!newVC.fileDict.ContainsKey(vfc.path))
                        newVC.fileDict.Add(vfc.path, vfc);
                    else
                        Debug.LogError("重复资源:" + vfc.path);
                }
            }
            return newVC;
        }

        /// <summary>
        /// 写版本配置
        /// </summary>
        /// <param name="vc"></param>
        /// <returns></returns>
        public static void WriteVersionConfig(VersionConfig vc)
        {
            var versionFile = new System.IO.StreamWriter(PathUtil.GetFullPath(PathUtil.GetRelativePathToDataPath(PathConfig.version)), false, Encoding.UTF8);
            StringBuilder sb = new StringBuilder();
            versionFile.WriteLine("<Config>");
            versionFile.Write("\t<Version>"); versionFile.Write(vc.version.ToString()); versionFile.WriteLine("</Version>");
            versionFile.WriteLine("\t<Files>");
            foreach (KeyValuePair<string, VersionFileConfig> kv in vc.fileDict) {
                VersionFileConfig vfc = kv.Value;
                versionFile.WriteLine("\t\t<File>");
                versionFile.Write("\t\t\t<Path>"); versionFile.Write(vfc.path.ToLower()); versionFile.WriteLine("</Path>");
                versionFile.Write("\t\t\t<MD5>"); versionFile.Write(vfc.md5); versionFile.WriteLine("</MD5>");
                versionFile.Write("\t\t\t<SizeByte>"); versionFile.Write(vfc.sizeByte); versionFile.WriteLine("</SizeByte>");
                versionFile.WriteLine("\t\t</File>");
            }
            versionFile.WriteLine("\t</Files>");
            versionFile.WriteLine("</Config>");
            versionFile.Flush();
            versionFile.Close();
        }
        
    }
}

