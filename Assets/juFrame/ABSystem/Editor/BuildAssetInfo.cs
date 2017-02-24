using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;


namespace ABSystem {
    public class BuildAssetInfo
    {
        public GameResType type;
        public string resPath;

        public BuildAssetInfo(string assetPath, GameResType type)
        {
            this.resPath = assetPath;
            this.type = type;
        }

        public void UpdateGameRes(string abName)
        {
            string fileName = PathUtil.GetFileNameWithoutExtension(resPath);
            BuildBoy.UpdateGameRes(type, fileName, abName, resPath);
        }
      
    }
}
