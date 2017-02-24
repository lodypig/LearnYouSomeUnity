using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;

namespace ABSystem {
    // 资源收集器，负责收集一个文件夹下制定类型资源，输出资源列表，根据给定GameResType, 更新GameTable
    public class AssetCollector
    {
        private List<BuildAssetInfo> buildAssetInfoList;

        public AssetCollector()
        {
            buildAssetInfoList = new List<BuildAssetInfo>();
        }

        public List<BuildAssetInfo> GetBuildAssetInfoList()
        {
            return buildAssetInfoList;
        }

        public void Add(string assetPath, GameResType type)
        {
            buildAssetInfoList.Add(new BuildAssetInfo(assetPath, type));
        }

        public void Reset()
        {
            buildAssetInfoList.Clear();
        }
        public static AssetCollector CreateAndCollect(string path, string pattern, GameResType type, SearchOption searchOption)
        {
            string systemFullPath = PathUtil.GetFullPath(path);
            AssetCollector collector = new AssetCollector();
            if (!Directory.Exists(systemFullPath))
                return collector;
            collector.CollectFolder(systemFullPath, pattern, type, searchOption);
            return collector;
        }

        public void CollectFolder(string systemFullPath, string pattern, GameResType type, SearchOption searchOption)
        {
            if (!Directory.Exists(systemFullPath))
                return;

            string[] fileList = Directory.GetFiles(systemFullPath, "*.*", searchOption);
            List<string> files = PathUtil.FilterPattern(fileList, pattern);

            for (int i = 0; i < files.Count; ++i)
            {
                string path = files[i];
                path = PathUtil.SystemPath2AssetPath(path);
                Add(path, type);
            }
        }

        public string[] ToAssetStringList()
        {
            string[] assetPathList = new string[buildAssetInfoList.Count];
            for (int i = 0; i < buildAssetInfoList.Count; ++i)
            {
                assetPathList[i] = buildAssetInfoList[i].resPath;
            }
            return assetPathList;
        }

        public void UpdateGameTable(string abName)
        {
            for (int i = 0; i < buildAssetInfoList.Count; ++i)
            {
                buildAssetInfoList[i].UpdateGameRes(abName);
            }
        }

        public bool IsEmpty() {
            return buildAssetInfoList.Count == 0;
        }
    }
}
