using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

public class TestAB  {


    public static void BuildForEachFolder(string path, string outPath, params string[] searchPatterns) {
        string[] dirs = Directory.GetDirectories(Application.dataPath + path);
        List<string> assetNames = new List<string>();
        for (int i = 0; i < dirs.Length; ++i) {
            for (int j = 0; j < searchPatterns.Length; ++j) { 
                string[] files = Directory.GetFiles(dirs[i], searchPatterns[j]);
                for (int k = 0; k < files.Length; ++i) {
                    assetNames.Add(files[k]);
                }
            }
        }
        uint crc;
        //BuildPipeline.BuildAssetBundle(null, assetNames.ToArray(), Application.streamingAssetsPath + "/" + outPath, out crc);
    }


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


    [MenuItem("AssetBundle/打包模型")]
    public static void BuildCube() {
        AssetBundleBuild[] buildMap = new AssetBundleBuild[2];
        string[] assetNames = new string[1];

        assetNames[0] = "Assets/Prefab/Model/Cube.prefab";
        buildMap[0].assetBundleName = "cube";
        buildMap[0].assetNames = assetNames;

        string[] assetNames2 = new string[1];
        assetNames2[0] = "Assets/Prefab/Model/Capsule.prefab";
        buildMap[1].assetBundleName = "capsule";
        buildMap[1].assetNames = assetNames2;

        BuildPipeline.BuildAssetBundles("Assets/AB/Model", buildMap);
    }
    [MenuItem("AssetBundle/打包UI")]
    public static void BuildUI() {
        BuildFolder("/Prefab/UI", "Assets/StreamingAssest/UI/Compress", "*.prefab", BuildAssetBundleOptions.None);
        BuildFolder("/Prefab/UI", "Assets/StreamingAssest/UI/UnCompress", "*.prefab", BuildAssetBundleOptions.UncompressedAssetBundle);
        AssetDatabase.Refresh();
    }
}
