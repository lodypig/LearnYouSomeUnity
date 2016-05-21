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
        AssetBundleBuild[] buildMap = new AssetBundleBuild[3];
        string[] files = Directory.GetDirectories(Application.dataPath + "/Prefab", "*.prefab");


        BuildPipeline.BuildAssetBundles("Assets/AB/UI", buildMap);
    }
}
