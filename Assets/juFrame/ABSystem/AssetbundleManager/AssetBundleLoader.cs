using UnityEngine;
using System.Collections;
using System;

public class AssetBundleLoader : MonoBehaviour
{
    //-----------------私有部分-------------------------------
    #region STREAMING_ASSET_PATH
    public static readonly string STREAMING_ASSET_PATH =
#if UNITY_ANDROID &&!UNITY_EDITOR
    Application.dataPath + "!assets";  
#else
    Application.streamingAssetsPath;
#endif
    #endregion

    #region 从最终路径load方法
    static AssetBundle LoadAssetbundle(string finalPath)
    {
        return AssetBundle.LoadFromFile(finalPath);
    }

    static IEnumerator LoadAsyncCoroutine(string path, Action<AssetBundle> callback) {
        AssetBundleCreateRequest abcr = AssetBundle.LoadFromFileAsync(path);
        yield return abcr;        
        callback(abcr.assetBundle);
    }

    static void LoadAssetbundleAsync(string finalPath, Action<AssetBundle> callback)
    {
        GameMain.Instance.StartCoroutine(LoadAsyncCoroutine(finalPath, callback));
    }
    #endregion

    #region 同步load方法
    public static AssetBundle LoadFromStreamingAssetsPath(string path)
    {
        string finalPath = STREAMING_ASSET_PATH.Combine(path);
        return LoadAssetbundle(finalPath);
    }

    public static AssetBundle LoadFromPersistentDataPath(string path)
    {
        string finalPath = Application.persistentDataPath.Combine(path);
        if (PathUtil.ExistsFile(finalPath)) { 
            return LoadAssetbundle(finalPath);
        }
        return null;
    }
    #endregion

    #region 异步load方法
    static void LoadFromStreamAssetPathAsync(string path, Action<AssetBundle> callback) {
        string finalPath = STREAMING_ASSET_PATH.Combine(path);
        LoadAssetbundleAsync(finalPath, callback);
    }

    static bool LoadFromPersistentDataPathAsync(string path, Action<AssetBundle> callback) {
        //TTLoger.LogError(string.Format("找路径({0})", path));
        string finalPath = Application.persistentDataPath.Combine(path);
        if (PathUtil.ExistsFile(finalPath)) {
            LoadAssetbundleAsync(finalPath, callback);
            return true;
        }
        //TTLoger.LogError(string.Format("路径没找到({0})", finalPath));
        return false;
    }

    #endregion

    //------------------对外方法-------------------------------
    // 先从persistentDataPath加载，失败再去streamingAssetDataPath加载
    public static AssetBundle Load(string path) {
        AssetBundle ab = LoadFromPersistentDataPath(path);
        if (ab == null) { 
            ab = LoadFromStreamingAssetsPath(path);
        }
        return ab;
    }

    public static void LoadAsync(string path, Action<AssetBundle> callback) {
        if (!LoadFromPersistentDataPathAsync(path, callback)) {
            LoadFromStreamAssetPathAsync(path, callback);
        }
    }
}
