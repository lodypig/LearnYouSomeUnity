using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

namespace ABSystem 
{

    public class AssetBundleBuilder  {
        public static void OnBuildStart(AssetBundleBuildConfig config, bool isGen)
        {
            GameResGenerator.ReadGameRes();
            BuildBoy.ClearGameRes(config);
            BuildBoy.CopyLua();
            BuildBoy.GenSpriteRes();
            if (!isGen)
            {
#if UNITY_STANDALONE_WIN
                //UGUIAtlasMaker.GenAtlas();
#endif
                BuildBoy.ChangeUIToAtlas();
            }
            AssetDatabase.Refresh();
            //MyModelGenerater.BatchGenerateRolePrefabs();
            //MonsterPrefabGenerator.BatchGeneratePrefab();
        }

		public static void OnCollectFinish() {
			GameResGenerator.WriteGameRes();
			AssetDatabase.Refresh ();
		}


        public static void OnBuildEnd(AssetBundleCollector collector, bool isGen)
        {
            BuildBoy.ClearLua();
          
            if (!isGen) { 
                BuildBoy.ChangeUIToSprite();
                GenVersion(collector);
            }
            AssetDatabase.Refresh();
            Resources.UnloadUnusedAssets();
            Debug.Log("打包结束！");
        }

        public static void GenVersion(AssetBundleCollector collector)
        {
            AssetDatabase.Refresh();
            VersionConfig vc = VersionGenerator.GenerateVersionConfig(collector);
            VersionGenerator.WriteVersionConfig(vc);
            AssetDatabase.Refresh();
            BuildConfig(PathConfig.version, "version.txt", "version");
        }

        public static AssetBundleCollector BuildConfig(string path, string pattern, string abName) {
			PathUtil.EnsuerStreamingAssetFolder ("config");
            AssetBundleCollector collector = AssetBundleCollector.CollectAssetBundlesForFolder(GameResType.None, PathUtil.GetRelativePathToAsset(PathUtil.GetParentDir(path)), pattern, abName);
			collector.Build(Application.streamingAssetsPath.Combine("config"));
            return collector;
        }


        public static void CollectMainFilter(AssetBundleFilterMain filter, ref AssetBundleCollector collector) {
            AssetBundleCollector mainCollector = new AssetBundleCollector();
            AssetBundleCollector subCollector = new AssetBundleCollector();
            AssetBundleFilter tmpF;
            mainCollector.Collect(filter.option, filter.resType, filter.path, filter.pattern, filter.assetbundleName);
            if (filter.HasSub()) {
                for (int i = 0; i < filter.subFilterList.Count; ++i) {
                    tmpF = filter.subFilterList[i];
                    if (filter.subFilterList[i].isAppend) {
                        subCollector.CollectAppend(mainCollector, tmpF.option, tmpF.resType, tmpF.path, tmpF.pattern, tmpF.assetbundleName, tmpF.independent);
                    }else{
                        subCollector.Collect(tmpF.option, tmpF.resType, tmpF.path, tmpF.pattern, tmpF.assetbundleName);
                    }
                }               
            }
            collector.Mearge(mainCollector);
            collector.Mearge(subCollector);
        }

        public static AssetBundleCollector Collect(AssetBundleBuildConfig config) {
            AssetBundleCollector collector = new AssetBundleCollector();
            for (int i = 0; i < config.filters.Count; ++i)
            {
                AssetBundleFilterMain filter = config.filters[i];
                if (filter.valid)
                {
                    CollectMainFilter(filter, ref collector);
                }
            }
            return collector;
        }

        public static void Build(AssetBundleBuildConfig config, bool isGenRes = false) {
            OnBuildStart(config, isGenRes);
            AssetBundleCollector collector = Collect(config);
			OnCollectFinish ();
            if (!isGenRes) { 
                collector.Build(Application.streamingAssetsPath);
            }
            OnBuildEnd(collector, isGenRes);
        }
    }
}
    
