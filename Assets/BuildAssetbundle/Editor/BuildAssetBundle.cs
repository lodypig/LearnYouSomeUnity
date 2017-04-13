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
        AssetBundleBuild[] abb = new AssetBundleBuild[files.Length + 1];


        abb[0] = GetCommon();

        string assetName;
        for (int i = 1; i <= files.Length; ++i)
        {
            assetName = PathUtil.GetAssetName(files[i - 1].Replace("\\", "/"));
            List<string> assetNames = new List<string>();
            abb[i].assetBundleName = assetName + ".ab";
            assetNames.Add(unityFolderPath + "/" + assetName +".prefab"); 
            abb[i].assetNames = assetNames.ToArray();
        }
        BuildPipeline.BuildAssetBundles(outPath, abb, options, EditorUserBuildSettings.activeBuildTarget);
    }

    public static  AssetBundleBuild GetCommon() {
        AssetBundleBuild abb = new AssetBundleBuild();
        
        string[] files = Directory.GetFiles(Application.dataPath + "/LearnYouBuildAssetbundle/Sprite", "*.png");
        string[] assetnames = new string[files.Length];
        string assetName;
        for (int i = 0; i < files.Length; ++i) {
            assetName = PathUtil.GetAssetName(files[i].Replace("\\", "/"));
            assetnames[i] = "Assets/LearnYouBuildAssetbundle/Sprite/" + assetName + ".png";
        }
        abb.assetBundleName = "common.ab";
        abb.assetNames = assetnames;
        return abb;
    }

    [MenuItem("AssetBundle/打包UI")]
    public static void BuildUI() {
        PathUtil.EnsureUnityFolder("/StreamingAssets/UI/Compress");
        PathUtil.EnsureUnityFolder("/StreamingAssets/UI/UnCompress");
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/Compress", "*.prefab", BuildAssetBundleOptions.None);
        BuildFolder("/LearnYouBuildAssetbundle/Prefab/UI", "Assets/StreamingAssets/UI/UnCompress", "*.prefab", BuildAssetBundleOptions.UncompressedAssetBundle);
        AssetDatabase.Refresh();
    }

    [MenuItem("AssetBundle/打包全部")]
    public static void BuildAll()
    {
        PathUtil.EnsureUnityFolder("/StreamingAssets/UI");
        BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath + "/UI");
    }

    [MenuItem("Assets/打包")]
    public static void BuildSelect() {
        UnityEngine.Object target = Selection.activeObject;
        string path = AssetDatabase.GetAssetPath(target.GetInstanceID());
        string sysPath = PathUtil.Unity2SysPath(path);

        if (Directory.Exists(sysPath))
        {
            string[] files = Directory.GetFiles(sysPath);
            AssetBundleBuild abb = new AssetBundleBuild ();
            abb.assetBundleName = PathUtil.GetAssetName(sysPath);
            abb.assetNames= new string[files.Length];
            for (int i = 0; i < files.Length; ++i) {
                abb.assetNames[i] = PathUtil.Sys2UnityPath(files[i]);
            }

            BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath, new AssetBundleBuild[1] { abb }, BuildAssetBundleOptions.ChunkBasedCompression);

        }
        else {
            Debug.Log("请选择文件夹！");
        }



    }
}
