using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEditor;


namespace ABSystem {
   
    public class AssetBundleBuildConfig : ScriptableObject
    {
        public List<AssetBundleFilterMain> filters = new List<AssetBundleFilterMain>();

        public bool NotHasFilter(UnityEngine.Object target) {
            for (int i = 0; i < filters.Count; ++i) {
                if (filters[i].HasFilter(target)) {
                    return false;
                }
            }
            return true;
        }
    }

  
}