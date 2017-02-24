using UnityEngine;
using System.Collections;
using System;
using System.IO;
using System.Collections.Generic;
using UnityEditor;


namespace ABSystem {

    public class AssetBundleCollector
    {

        List<AssetBundleBuild> buildList;

        public AssetBundleCollector()
        {
            buildList = new List<AssetBundleBuild>();
        }

        public List<AssetBundleBuild> GetBuildList()
        {
            return buildList;
        }

        public bool IsEmpty()
        {
            return buildList == null || buildList.Count <= 0;
        }

        public void AddBuilder(string assetbundleName, string[] assetList)
        {
            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = assetbundleName;
            build.assetNames = assetList;
            buildList.Add(build);
        }

        public void AddBuilder(string assetbundleName, AssetCollector collector)
        {
            if (collector.IsEmpty())
            {
                return;
            }
            AddBuilder(assetbundleName, collector.ToAssetStringList());
            collector.UpdateGameTable(assetbundleName);
            collector.Reset();
        }

        public void AddBuilderList(string nameFormat, AssetCollector collector)
        {
            List<BuildAssetInfo> list = collector.GetBuildAssetInfoList();
            for (int i = 0; i < list.Count; ++i)
            {

                string[] s = PathUtil.splitePath(list[i].resPath);              
                string assetbundleName = string.Format(nameFormat, s);
                AddBuilder(assetbundleName, new string[1] { list[i].resPath });
                list[i].UpdateGameRes(assetbundleName);
            }
            collector.Reset();
        }

        public void CollectFolder(GameResType type, string path, string pattern, string assetbundleName, SearchOption searchOption = SearchOption.AllDirectories)
        {
            AssetBundleCollector abcollector = CollectAssetBundlesForFolder(type, path, pattern, assetbundleName, searchOption);
            this.Mearge(abcollector);
        }

        public void CollectEachSubFolder(GameResType type, string path, string pattern, string format = "{0}", SearchOption searchOption = SearchOption.AllDirectories)
        {
            AssetBundleCollector abcollector = CollectAssetbundlesForEachSubFolder(type, path, pattern, format, searchOption);
            this.Mearge(abcollector);
        }

        public void CollectEachFile(GameResType type, string path, string pattern, string assetbundleName, SearchOption searchOption = SearchOption.AllDirectories)
        {
            AssetBundleCollector abcollector = CollectAssetbundlesForEachFile(type, path, pattern, assetbundleName, searchOption);
            this.Mearge(abcollector);
        }

        public void Mearge(AssetBundleCollector bundleCollector)
        {
            if (bundleCollector == null || bundleCollector.IsEmpty())
            {
                return;
            }
            List<AssetBundleBuild> list = bundleCollector.GetBuildList();
            this.buildList.AddRange(list);
        }

        public void Collect(BuildOption option, GameResType resType, string path, string pattern, string assetbundleName)
        {
            switch (option)
            {
                case BuildOption.EachFile:
                    CollectEachFile(resType, path, pattern, assetbundleName);
                    break;
                case BuildOption.EachFolder:
                    CollectEachSubFolder(resType, path, pattern, assetbundleName);
                    break;
                case BuildOption.WholeFolder:
                    CollectFolder(resType, path, pattern, assetbundleName);
                    break;
            }
        }

        public void CollectAppend(AssetBundleCollector mainCollector, BuildOption option, GameResType resType, string path, string pattern, string assetbundleName, bool independent, SearchOption searchOption = SearchOption.AllDirectories)
        {
            for (int i = 0; i < mainCollector.buildList.Count; ++i)
            {
                AssetBundleBuild bd = mainCollector.buildList[i];
                string name = PathUtil.GetFileNameWithoutExtension(bd.assetBundleName);
                string formatPath = string.Format(path, name);
                if (independent)
                {
                    Collect(option, resType, formatPath, pattern, assetbundleName);
                }
                else {
                    AssetCollector collector = AssetCollector.CreateAndCollect(formatPath, pattern, resType, searchOption);
                    List<string> assetList = new List<string>(bd.assetNames);
                    List<string> assetList2 = new List<string>(collector.ToAssetStringList());
                    assetList.AddRange(assetList2);
                    bd.assetNames = assetList.ToArray();
                    mainCollector.buildList[i] = bd;
                    collector.UpdateGameTable(bd.assetBundleName);
                }
            }
        }

        public static AssetBundleCollector CollectAssetbundlesForEachFile(GameResType type, string path, string pattern, string format = "{0}", SearchOption searchOption = SearchOption.AllDirectories)
        {
            AssetCollector collector = AssetCollector.CreateAndCollect(path, pattern, type, searchOption);
            AssetBundleCollector assetbundleCollector = new AssetBundleCollector();
            if (collector == null)
            {
                return assetbundleCollector;
            }
            assetbundleCollector.AddBuilderList(format, collector);
            return assetbundleCollector;
        }

        public static AssetBundleCollector CollectAssetBundlesForFolder(GameResType type, string path, string pattern, string assetbundlename, SearchOption searchOption = SearchOption.AllDirectories)
        {
            AssetCollector collector = AssetCollector.CreateAndCollect(path, pattern, type, searchOption);
            List<AssetBundleBuild> buildList = new List<AssetBundleBuild>();
            AssetBundleCollector assetbundleCollector = new AssetBundleCollector();
            assetbundleCollector.AddBuilder(assetbundlename, collector);
            return assetbundleCollector;
        }

        public static AssetBundleCollector CollectAssetbundlesForEachSubFolder(GameResType type, string path, string pattern, string format = "{0}", SearchOption searchOption = SearchOption.AllDirectories)
        {
            string fullpath = PathUtil.GetFullPath(path);
            AssetBundleCollector assetBundleCollector = new AssetBundleCollector();
            if (!Directory.Exists(fullpath))
                return assetBundleCollector;

            string[] dirList = Directory.GetDirectories(fullpath);
            List<AssetBundleBuild> bulldList = new List<AssetBundleBuild>();
            foreach (string dir in dirList)
            {
                string fullPath = dir.Replace("\\", "/");
                string[] splitName = PathUtil.splitePath(fullPath);
                string name = string.Format(format, splitName);
                AssetBundleCollector abc = CollectAssetBundlesForFolder(type, PathUtil.GetRelativePathToDataPath(fullPath), pattern, name, searchOption);
                assetBundleCollector.Mearge(abc);
            }
            return assetBundleCollector;
        }

        public void Build(string targetPath) {
            AssetBundleBuild[] buildList = this.buildList.ToArray();

            if (!PathUtil.ExistsDir(Application.streamingAssetsPath)) {
                PathUtil.EnsuerFolder(Application.streamingAssetsPath);
            }

            for (int i = 0; i < buildList.Length; ++i) {
                if (buildList[i].assetBundleName.IndexOf("/") > 0)
                {
                    PathUtil.EnsuerStreamingAssetFolder(PathUtil.GetParentDir(buildList[i].assetBundleName));
                }
            }

            BuildPipeline.BuildAssetBundles(targetPath, buildList, BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.DisableWriteTypeTree, EditorUserBuildSettings.activeBuildTarget);
        }
    }     
} 


