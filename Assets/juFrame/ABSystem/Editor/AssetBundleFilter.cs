using UnityEngine;
using System.Collections;
using System.IO;
using System.Collections.Generic;
using UnityEditor;

namespace ABSystem {
    [System.Serializable]
    public class AssetBundleFilter
    {
        public AssetBundleFilter(UnityEngine.Object target)
        {
            this.target = target;
        }
        public BuildOption option = BuildOption.WholeFolder;
        public AssetBundleFilter()
        {

        }
        public bool isAppend = false;
        public string pattern = "*.prefab";
        public SearchOption searchOption = SearchOption.AllDirectories;
        public string path = string.Empty;
        public string assetbundleName = "default";
        public bool independent;
        public UnityEngine.Object target
        {
            get
            {
                if (_target == null)
                {
                    _target = AssetDatabase.LoadAssetAtPath(path, typeof(UnityEngine.Object));
                    if (_target == null) { 
                        _target = new UnityEngine.Object();
                    }
                }
                return _target;
            }
            set
            {
                _target = value;
                path = PathUtil.GetRelativePathToAsset(AssetDatabase.GetAssetPath(_target.GetInstanceID()));
            }
        }
        public UnityEngine.Object _target;
        public GameResType resType = GameResType.None;
    }
    [System.Serializable]
    public class AssetBundleFilterMain : AssetBundleFilter
    {
        public List<AssetBundleFilter> subFilterList;
        public bool valid = true;
        public bool showSub = true;

        public void AddSubFilter(AssetBundleFilter filter)
        {
            if (subFilterList == null)
            {
                subFilterList = new List<AssetBundleFilter>();
            }
            subFilterList.Add(filter);
        }

        public bool HasSub()
        {
            return subFilterList != null && subFilterList.Count > 0;
        }

        public bool IsShowSub()
        {
            return showSub && HasSub();
        }

        public AssetBundleFilterMain()
            : base()
        {
        }

        public AssetBundleFilterMain(UnityEngine.Object target)
            : base(target)
        {

        }

        public bool HasFilter(UnityEngine.Object target)
        {
            if (HasSub())
            {
                for (int i = 0; i < subFilterList.Count; ++i)
                {
                    if (subFilterList[i].target == target)
                    {
                        return true;
                    }
                }
            }
            if (this.target == target)
            {
                return true;
            }

            return false;
        }
    }
}
