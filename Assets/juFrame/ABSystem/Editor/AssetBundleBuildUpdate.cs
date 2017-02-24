using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace ABSystem
{
    //打包ab包，并且与远端比较，确定更新包
    class AssetBundleBuildUpdate
    {
        private static string configPath ="E:/p27/client/Assets/StreamingAssets";
        private static string getServerUrl()
        {

            if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android)
            {
                return GameUpdater.Instance.UpdateServer + GameUpdater.AndroidServerUrl;
            }
            else
            {
                return GameUpdater.Instance.UpdateServer + GameUpdater.IOSServerUrl;
            }
        }

        private static VersionConfig getNewVersion()
        {
            AssetBundle streamAb = AssetBundleLoader.LoadFromStreamingAssetsPath(GameUpdater.CurrentVersionPath);
            VersionConfig streamVc = null;

            TextAsset text = streamAb.LoadAsset("version") as TextAsset;
            string content = text.text;
            streamVc = VersionUtil.ReadVersionConfig(content);
            streamAb.Unload(true);
            return streamVc;
        }


        private static void copyToUpdate(List<string> files)
        {
            Debug.LogError("拷贝ab包开始！");
            string tmpPath = PathUtil.GetFullPath(PathConfig.updateAb);
            FileUtil.DeleteFileOrDirectory(tmpPath);
            Directory.CreateDirectory(tmpPath);
            string fromPath, toPath;
            for (int i = 0; i <= files.Count; i++)
            {
                //version强制拷贝
                if (i == files.Count)
                {
                    fromPath = Application.streamingAssetsPath.Combine("config/version");
                    toPath = tmpPath.Combine("config/version");
                }
                else {
                    if (files[i] == "lua") {
                        int ll = 1;
                    }
                    fromPath = Application.streamingAssetsPath.Combine(files[i]);
                    toPath = tmpPath.Combine(files[i]);
                }
                PathUtil.EnsuerFolder(PathUtil.GetParentDir(toPath));
                FileUtil.CopyFileOrDirectory(fromPath, toPath);
            }
            Debug.LogError("拷贝ab包结束！");

        }

        [MenuItem("ABSystem/外网更新打包")]
        static void Buildupdate()
        {
            GameObject wwwMange = new GameObject();
            wwwMange.AddComponent<WWWManager>();

            AssetBundleBuildConfig config = AssetBundleBuildPanel.LoadConfig();
            AssetBundleBuilder.Build(config);

            VersionConfig newCfg = getNewVersion();
            string url = getServerUrl().Combine(GameUpdater.CurrentVersionPath);
            string cachePath = GameUpdater.CacheVersionPath;
            Debug.LogError("加载服务端version信息……");
            GameUpdater.Instance.DeleteCacheVersion();
            WWWManager.Instance.DownloadWWW(url, cachePath, (suc) =>
            {
                VersionConfig serverCfg = VersionUtil.ReadConfig(cachePath);
                List<string> files = GameUpdater.Instance.GetFileListNeedDownloaded(serverCfg, newCfg);
                Debug.LogError("需要更新的ab包个数：" + files.Count);
                FileUtil.DeleteFileOrDirectory(cachePath);
                copyToUpdate(files);
                GameObject.DestroyImmediate(wwwMange);
                Debug.LogError("外网更新打包结束！");
            });
        }

    }

}
