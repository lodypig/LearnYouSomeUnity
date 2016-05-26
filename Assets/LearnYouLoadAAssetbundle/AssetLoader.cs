using UnityEngine;
using System.Collections;
using System;

public class AssetLoader {


    #region STREAMING_ASSET_PATH
    public static readonly string STREAMING_ASSET_PATH =
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
 Application.streamingAssetsPath;
#elif UNITY_IPHONE  
        Application.dataPath + "/Raw";  
#elif UNITY_ANDROID
    Application.dataPath + "!assets";  
#else  
        string.Empty;  
#endif
    #endregion

    #region WWW_STREAM_ASSET_PATH
    public static readonly string WWW_STREAM_ASSET_PATH =
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
 "file://" + Application.streamingAssetsPath;
#elif UNITY_IPHONE
	Application.dataPath + "/Raw";
#elif UNITY_ANDROID
	"jar:file://" + Application.dataPath + "!/assets";
#else
        string.Empty;
#endif

    #endregion

    #region load ab
    public static AssetBundle LoadFromFile(string path)
    {
        return AssetBundle.LoadFromFile(STREAMING_ASSET_PATH + path);
    }

    public static void LoadFromWWW(string path, Action<AssetBundle> callback)
    {
        CoroutineProvider.Instance.StartCoroutine(LoadFromWWWCoroutine(path, callback));

    }

    static IEnumerator LoadFromWWWCoroutine(string path, Action<AssetBundle> callback)
    {
        WWW www = new WWW(WWW_STREAM_ASSET_PATH + path);
        yield return www;
        callback(www.assetBundle);
        www.Dispose();
        www = null;
    }

    #endregion

    #region load asset
    public static UnityEngine.Object LoadAsset(AssetBundle ab, string assetName)
    {
        ab.LoadAsset(assetName);
        return ab.LoadAsset(assetName);
    }

    public static void LoadAssetAsync(AssetBundle ab, string assetName, Action<UnityEngine.Object> callback)
    {
        CoroutineProvider.Instance.StartCoroutine(LoadAssetAsyncCoroutine(ab, assetName, callback));
    }

    static IEnumerator LoadAssetAsyncCoroutine(AssetBundle ab, string assetName, Action<UnityEngine.Object> callback)
    {
        AssetBundleRequest request = ab.LoadAssetAsync(assetName);
        while (!request.isDone)
        {
            yield return false;
        }
        callback(request.asset);
    }
    #endregion
}
