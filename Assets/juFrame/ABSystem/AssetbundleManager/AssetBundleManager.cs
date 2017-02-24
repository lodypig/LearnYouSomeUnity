using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;


/* AssetbundleRef 和 AssetLoader 管理器，缓存所有AssetLoader和 AssetBundleRef
 * 向外部提供创建和获取 AssetbundleRef 和 AssetLoader 相关接口
 * 仅释放该类，不能销毁所有相关资源，不用单例而使用静态
 * 类中 assetBundleName为assetbundle相对StreamingAssetPath路径及名字，如ui/bagitem(一律小写)
 */
public class AssetBundleManager{

    private static Dictionary<string, AssetBundleRef> abDict = new Dictionary<string, AssetBundleRef>();   // Dict assetbundleName - AssetBundleRef 
    private static Dictionary<GameObject, AssetLoader> loaderDict = new Dictionary<GameObject, AssetLoader>();  // Dict key -> AssetLoader
    private static Dictionary<string, AssetLoading<AssetBundleRef>> loadingDict = new Dictionary<string, AssetLoading<AssetBundleRef>>();  // 正在异步加载字典
    
    public static AssetLoader godLoader = AssetLoader.Create();
    static AssetBundleManifest manifest;
    static AssetBundle mainfestAB;

    public static string[] GetAllDependencies(string assetbundleName)
    {
        return manifest.GetAllDependencies(assetbundleName);
    }


    ~AssetBundleManager()
    {
        godLoader.Release();
    }


    public static void InitAssetBundleManifest() {
        mainfestAB = AssetBundleLoader.Load("StreamingAssets");
        manifest = mainfestAB.LoadAsset("AssetBundleManifest") as AssetBundleManifest;
    }


    #region loader

    
    public static AssetLoader GetLoader(GameObject key) {
        if (loaderDict.ContainsKey(key))
        {
            // 缓存获取
            return loaderDict[key];
        }

        // 创建新的并缓存
        AssetLoader assetLoader = AssetLoader.Create();
        loaderDict.Add(key, assetLoader);
        return assetLoader;
    }
    public static AssetLoader CreateLoader() {
        return AssetLoader.Create();
    }
    public static void CacheLoader(GameObject key, AssetLoader assetLoader) {     
        loaderDict.Add(key, assetLoader);
    }
    public static void RemoveLoader(GameObject key) {
        loaderDict.Remove(key);
    }
    #endregion

    #region assetbundle

    // 缓存AssetBundle
    public static AssetBundleRef CacheAB(string assetBundleName, AssetBundle ab)
    {
        AssetBundleRef abRef = new AssetBundleRef(assetBundleName, ab);
        abDict[assetBundleName] = abRef;
        return abRef;
    }

    public static void CacheAB(AssetBundleRef abr)
    {
        abDict[abr.Name] = abr;
    }

    public static void CheckShouldCacheSprite(AssetBundleRef abr) {
        if (abr.Name.Contains("atlas"))
        {
            SpriteManager.CacheSprite(abr);
        }
    }

    public static void CheckShouldCacheSpriteAsync(AssetBundleRef abr, Action callback) {
        if (abr.Name.Contains("atlas"))
        {
            SpriteManager.CacheSpriteAsync(abr, callback);
        }
        else {
            callback();
        }
        
    }



    // 从缓存中查找AssetBundle，没有则同步加载并缓存
    public static AssetBundleRef GetAB(string assetbundleName)
    {
        AssetBundleRef abr;
        if (abDict.TryGetValue(assetbundleName, out abr))
        {
            // 缓存命中
            abr.Retain();
            return abr;
        }
        AssetBundle ab = AssetBundleLoader.Load(assetbundleName); // 同步加载
        abr = AssetBundleManager.CacheAB(assetbundleName, ab);
        CheckShouldCacheSprite(abr);
        return abr;
    }


    // 异步GatAB，允许回调为空
    public static void GetABAsync(string assetbundleName, Action<AssetBundleRef> callback = null) {
        AssetBundleRef abRef;
        if (abDict.TryGetValue(assetbundleName, out abRef))
        {
            // 缓存命中
            abRef.Retain();
            if (callback != null) { 
                callback(abRef);
            }
        }
        else {
            AssetLoading<AssetBundleRef> loading;
            // 检查是否已在loading
            if (loadingDict.TryGetValue(assetbundleName, out loading))
            {
                //将本次回调添加到load回调就完事了
                if (callback != null) { 
                    loading.callback.Add(callback);
                }
                loading.refCount++;
                return;
            }

            loading = new AssetLoading<AssetBundleRef>();
            loadingDict.Add(assetbundleName, loading);
            if (callback != null) { 
                loading.callback.Add(callback);
            }
            // 异步加载
            AssetBundleLoader.LoadAsync(assetbundleName, (assetbundle) =>
            {
                abRef = new AssetBundleRef(assetbundleName, assetbundle);
                CheckShouldCacheSpriteAsync(abRef, () =>
                {
                    CacheAB(abRef);
                    loadingDict.Remove(assetbundleName);
                    abRef.Retain(loading.refCount - 1);  // ref默认是1,所以只需retain refCount - 1
                    loading.FireCallBack(abRef);
                });
                
            });
        }
    }

    // AssetbundleRef释放时调用，移除其自身
    public static void UnloadAB(string assetbundleName) {
        abDict.Remove(assetbundleName);
    }

    // 清理所有loader，返回登录时调用
    public static void ReleaseAllLoaders() 
    {
        if (mainfestAB != null)
        {
            mainfestAB.Unload(true);
            manifest = null;
        }

        foreach (KeyValuePair<UnityEngine.GameObject, AssetLoader> kv in loaderDict) {
            kv.Value.Release();
        }
        loaderDict.Clear();
    }

    // 检查资源表中是否有某个资源
    public static bool HasGameRes(GameResType type, string name)
    {
        if (AppConst.DevelopMode)
        {
            GameResInfo info = GameTable.GetGameRes(type, name);
            return info != null;
        }
        else
        {
            GameBundleInfo info = GameTable.GetGameBundleRes(type, name);
            return info  != null;
        }
    }
    #endregion

    // 调试接口
    public static void DumpAB()
    {
        UnityEngine.MonoBehaviour.print("-------------- loader count : " + loaderDict.Count + " --------------");
        foreach (KeyValuePair<UnityEngine.GameObject, AssetLoader> kv in loaderDict)
        {
            UnityEngine.MonoBehaviour.print(kv.Key.name);
        }
        UnityEngine.MonoBehaviour.print("-------------- assetbundle count : " + abDict.Count + " --------------");
    }

    
}
