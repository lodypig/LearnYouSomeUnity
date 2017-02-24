using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;


/*
 * 缓存异步加载资源回调，防止多次异步加载同一资源，加载完成后统一回调
 */
public class AssetLoading<T> {
    public List<Action<T>> callback = new List<Action<T>>();
    public int refCount = 1;

    public void FireCallBack(T loadObj)
    {
        List<Action<T>> temp = new List<Action<T>>();
        while(callback.Count > 0)
        {
            temp.AddRange(callback);
            callback.Clear();
            for(int i = 0; i < temp.Count; ++i)
            {
                temp[i](loadObj);
            }
            temp.Clear();
        }
    }

}


/*
 * Assetbundle引用器，提供加载资源方法，assetbundle引用和引用计数相关
 * 处理同时异步载资源。
 * 多次加载同一资源，unity本身已处理。
 */
public class AssetBundleRef
{

    #region properties & constructor
    
    AssetBundle assetBundle = null;
    int refCount = 1;  // 引用计数默认为1

    Dictionary<string, AssetLoading<UnityEngine.Object>> loadingDict = new Dictionary<string, AssetLoading<UnityEngine.Object>>();  // 正在异步加载字典
    AssetLoading<UnityEngine.Object[]> loadingAll;
    public Atlas atlas;


    string _name = string.Empty;
    public string Name
    {
        get
        {
            return _name;
        }
    }
    public AssetBundleRef(string name)
    {
        this._name = name;
    }

    public AssetBundleRef(string name, AssetBundle ab)
    {
        this._name = name;
        this.assetBundle = ab;
    }



 
    #endregion

    #region load
    // 同步加载资源
    public UnityEngine.Object Load(string assetName, Type resType = null)
    {
        return assetBundle.LoadAsset(assetName, resType == null ? typeof(UnityEngine.Object) : resType);
    }


    // 异步加载资源
    public void LoadAsync(string assetName, Action<UnityEngine.Object> callback, Type resType = null)
    {
        AssetLoading<UnityEngine.Object> assetLoading;
        UnityEngine.Object obj;


        // 先判断该资源是否已经在loading字典中
        if (loadingDict.TryGetValue(assetName, out assetLoading))
        {
            // 已在loading，将回调添加上去
            assetLoading.callback.Add(callback);
            return;
        }

        // 创建一个loading
        assetLoading = new AssetLoading<UnityEngine.Object>();
        assetLoading.callback.Add(callback);
        loadingDict.Add(assetName, assetLoading);

        // 开始异步加载资源
        GameMain.Instance.StartCoroutine(LoadAssetCoroutine(assetBundle, assetName, resType == null ? typeof(UnityEngine.Object) : resType));
    }

    // 异步加载资源协程实现
    IEnumerator LoadAssetCoroutine(AssetBundle ab, string assetName, Type resType)
    {
        AssetBundleRequest request = ab.LoadAssetAsync(assetName, resType);
        // 等待加载完成
        while (!request.isDone)
        {
            if (loadingDict == null)
            {
                // 这里认为已被release掉。最好能直接终止协程，但这样每个AssetBundleRef需要一个MonoBehaviour，代价太大。
                break;
            }
            yield return false;
        }

        if (loadingDict != null)
        {
            loadingDict[assetName].FireCallBack(request.asset);
            loadingDict.Remove(assetName);
        }
    }

#endregion 

    #region loadAll

    // 同步LoadAll
    public UnityEngine.Object[] LoadAllAssets() {
        return assetBundle.LoadAllAssets();
    }

    // 异步LoadAllAssets方法
    public void LoadAllAssetsAsync(Action<UnityEngine.Object[]> callback) {
        if (loadingAll != null) {
            loadingAll.callback.Add(callback);
            return;
        }

        loadingAll = new AssetLoading<UnityEngine.Object[]>();
        loadingAll.callback.Add(callback);
        GameMain.Instance.StartCoroutine(LoadAllAssetsCoroutine());
    }

    // Load All 协程实现
    IEnumerator LoadAllAssetsCoroutine()
    {
        AssetBundleRequest request = this.assetBundle.LoadAllAssetsAsync();
        while (!request.isDone) {
            if (loadingAll == null)
            {
                break;
            }
            yield return false;
        }
        if (loadingAll != null) {
            loadingAll.FireCallBack(request.allAssets);
            loadingAll = null;
        }

    }
    #endregion

    #region other
    public string[] GetAllAssetNames()
    {
        return assetBundle.GetAllAssetNames();
    }

    // 引用
    public void Retain(int count = 1)
    {
        // 不允许在refCount <= 0后继续引用 ，该assetbundle视为已释放，防止上层混乱导致多次dealloc
        if (refCount > 0) { 
            refCount+= count;
        }
    }

    // 释放，命名与destroy区分开
    void dealloc() {
        foreach (KeyValuePair<string, AssetLoading<UnityEngine.Object>> kv in loadingDict)
        {
            kv.Value.FireCallBack(null);
        }
        loadingDict = null;      // 让协程知道该assetbundle已被release

        if (loadingAll != null) {
            loadingAll.FireCallBack(null);
            loadingAll = null;
        }
        Unload(true);
        AssetBundleManager.UnloadAB(this._name);
    }

    // 减少引用
    public void Release()
    {
        --refCount;  // 保持代码干净，不加判断，可减少到负数
        if (refCount == 0)
        {
            dealloc();
        }
    }
    // assetbundle unload 接口
    public void Unload(bool unloadAllLoadedObjects = false)
    {
        //TTLoger.Log("Unload assetbundle " + unloadAllLoadedObjects + " : " + _name);  // 调试用
        assetBundle.Unload(unloadAllLoadedObjects);
        if (atlas != null) {
            atlas.Unload();
        }
    }
    #endregion
}
