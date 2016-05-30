using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

public class TestAB  {

    public static void BuildFolder(string path, string outPath, string searchPatterns, BuildAssetBundleOptions options) {

        string sysFolderPath = PathUtil.GetSysPath(path);
        string unityFolderPath = PathUtil.GetUnityPath(path);

        string[] files = Directory.GetFiles(sysFolderPath, searchPatterns);
        AssetBundleBuild[] abb = new AssetBundleBuild[files.Length];
        for (int i = 0; i < files.Length; ++i)
        {
            string assetName = PathUtil.GetAssetName(files[i].Replace("\\", "/"));
            List<string> assetNames = new List<string>();
            abb[i].assetBundleName = assetName + ".ab";
            assetNames.Add(unityFolderPath + "/" + assetName +".prefab"); 
            abb[i].assetNames = assetNames.ToArray();
        }
        BuildPipeline.BuildAssetBundles(outPath, abb, options, EditorUserBuildSettings.activeBuildTarget);
    }

    [MenuItem("AssetBundle/打包UI")]
    public static void BuildUI() {
        PathUtil.EnsureUnityFolder("/StreamingAssets/UI/Compress");
        PathUtil.EnsureUnityFolder("/StreamingAssets/UI/UnCompress");
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/Compress", "*.prefab", BuildAssetBundleOptions.None);
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/UnCompress", "*.prefab", BuildAssetBundleOptions.UncompressedAssetBundle);
        AssetDatabase.Refresh();
    }
}
