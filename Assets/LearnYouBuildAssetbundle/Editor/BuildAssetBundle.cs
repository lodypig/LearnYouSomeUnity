using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

public class TestAB  {
    public static string GetSysPath(string path) {
        return Application.dataPath + path;
    }

    public static string GetUnityPath(string path) {
        return "Assets" + path;
    }

    public static string GetAssetName(string path)
    {
        int index = path.LastIndexOf("/");
        if (index >= 0) {
            int index2 = path.LastIndexOf(".");
            if (index2 > 0) {
                return path.Substring(index + 1, index2 - index - 1);
            }
            return path.Substring(index + 1);
        }
        return path;
    }

    public static void EnsuerDir(string path) { 
          if (!Directory.Exists(Application.dataPath + path)) {
            Directory.CreateDirectory(Application.dataPath + path);
        }
    }

    public static void BuildFolder(string path, string outPath, string searchPatterns, BuildAssetBundleOptions options) {

        string sysFolderPath = GetSysPath(path);
        string unityFolderPath = GetUnityPath(path);

        string[] files = Directory.GetFiles(sysFolderPath, searchPatterns);
        AssetBundleBuild[] abb = new AssetBundleBuild[files.Length];
        for (int i = 0; i < files.Length; ++i)
        {
            string assetName = GetAssetName(files[i].Replace("\\", "/"));
            List<string> assetNames = new List<string>();
            abb[i].assetBundleName = assetName + ".ab";
            assetNames.Add(unityFolderPath + "/" + assetName +".prefab"); 
            abb[i].assetNames = assetNames.ToArray();
        }
        BuildPipeline.BuildAssetBundles(outPath, abb, options, EditorUserBuildSettings.activeBuildTarget);
    }

    [MenuItem("AssetBundle/打包UI")]
    public static void BuildUI() {
        EnsuerDir("/StreamingAssets/UI/Compress");
        EnsuerDir("/StreamingAssets/UI/UnCompress");
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/Compress", "*.prefab", BuildAssetBundleOptions.None);
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/UnCompress", "*.prefab", BuildAssetBundleOptions.UncompressedAssetBundle);
        AssetDatabase.Refresh();
    }
}
