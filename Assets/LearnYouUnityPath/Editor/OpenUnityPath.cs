using UnityEngine;
using System.Collections;
using UnityEditor;

public class OpenUnityPath {

    private static void Open(string path) {
        System.Diagnostics.Process.Start("explorer.exe", @path.Replace('/', '\\'));
    }

    [MenuItem("AssetDataBase/打开StreamAssetDataPath",false, 0)]
    public static void OpenStreamingAssetDataPath() 
    {
        Open(Application.streamingAssetsPath);
    }

    [MenuItem("AssetDataBase/打开PersistantDataPath", false, 0)]
    public static void OpenPersistantDataPath() 
    {
        Open(Application.persistentDataPath);
    }
	
}
