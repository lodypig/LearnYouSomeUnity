using UnityEngine;
using System.Collections;
using System;


// 资源加载基类，向上层提供统一接口和根据不同平台创建接口
public abstract class AssetLoader {


    private static AssetLoader gLoader = null;

    public static AssetLoader GetLoader()
    {
        if (gLoader == null)
        {
            gLoader = Create();
        }
        return gLoader;
    }

    public static AssetLoader Create() { 
        // 编辑器下DevelopMode使用AssetLoaderEditor，其余使用AssetLoaderMobeil        
#if UNITY_EDITOR
        if (AppConst.DevelopMode) {
            return new AssetLoaderEditor();
        }
        return new AssetLoaderMobeil();
#else
        return new AssetLoaderMobeil();
#endif
    }

    public virtual AssetBundleRef LoadAB(string assetbundleName) { return null; }

    public virtual void LoadABAsync(string assetbundleName, Action<AssetBundleRef> callback = null) { callback(null);}

    public virtual void RemoveAB(string assetbundleName) { }

    // 同步加载资源
    public abstract UnityEngine.Object Load(GameResType type, string name, Type resType = null);

    // 异步加载资源
    public abstract void LoadAsync(GameResType type, string name, Action<UnityEngine.Object> callback, Type resType = null);

    // 统一叫Release吧，释放接口
    public virtual void Release() {}


    // 同步加载图片方法
    public virtual Atlas LoadAtlas(string spriteName) { return null; }

    // 异步加载图片方法
    public virtual void LoadAtlasAsync(string spriteName, Action<Atlas> callback) { callback(null); }

}
