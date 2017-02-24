using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;



/*
 * AssetLoaderMobeil
 * assetbundle资源加载器
 * 在此处做资源检查，如果通过，后续不再检查输入输出，认为路径有效、资源一定存在
 * 提供同步和异步加载资源方式，全部使用不带路径、后缀资源名，如BagItem（区分大小写）
 * 
 */
public class AssetLoaderMobeil : AssetLoader {

    Dictionary<string, AssetBundleRef> abrDict = new Dictionary<string, AssetBundleRef>();
    Dictionary<string, AssetLoading<AssetBundleRef>> loadingDict = new Dictionary<string, AssetLoading<AssetBundleRef>>();  // 正在异步加载字典

    public void AddAssetBundleRef(string bundleName, AssetBundleRef abr) {
        abrDict.Add(bundleName, abr);
    }

    // 资源清单检查
    bool CheckRes(GameResType type, string name, out GameBundleInfo data) {
        data = GameTable.GetGameBundleRes(type, name);
        if (data == null)
        {
            TTLoger.LogError("资源清单未找到资源 : " + name + "，请检查resBundle");
            return false;
        }
        return true;
    }

    public override AssetBundleRef LoadAB(string assetbundleName)
    {
        AssetBundleRef abr;
        if (!abrDict.TryGetValue(assetbundleName, out abr))
        {
            string[] depends = AssetBundleManager.GetAllDependencies(assetbundleName);
            for (int i = 0; i < depends.Length; ++i)
            {
                LoadAB(depends[i]);
            }
            abr = AssetBundleManager.GetAB(assetbundleName);
            abrDict.Add(assetbundleName, abr);
        }
        return abr;
    }

    public override void LoadABAsync(string assetbundleName, Action<AssetBundleRef> callback = null)
    {
        AssetBundleRef abr;
        if (abrDict.TryGetValue(assetbundleName, out abr))
        {
            if (callback != null)
            {
                callback(abr);
            }
            return;
        }
        string[] depends = AssetBundleManager.GetAllDependencies(assetbundleName);

        Action loadSelf = () =>
        {
            AssetBundleManager.GetABAsync(assetbundleName, (assetbundleRef) =>
            {
                if (abrDict == null || loadingDict == null)
                {
                    assetbundleRef.Release();   //释放ab
                    callback(null);
                    return;
                }
                if (!abrDict.ContainsKey(assetbundleName))
                {
                    abrDict.Add(assetbundleName, assetbundleRef);
                }
                if (callback != null)
                {
                    callback(assetbundleRef);
                }
            });
        };

        if (depends.Length == 0)
        {
            loadSelf();
        }
        else { 
            int count = depends.Length;
            Action<AssetBundleRef> loadSelfC = (ab) =>
            {
                if (--count == 0 ) {
                    loadSelf();
                }
            };
            for (int i = 0; i < depends.Length; ++i)
            {
                LoadABAsync(depends[i], loadSelfC);
            }
        }
    }

    public override void RemoveAB(string assetbundleName)
    {
        AssetBundleRef abr;
        if (abrDict.TryGetValue(assetbundleName, out abr)) {
            abr.Release();
            abrDict.Remove(assetbundleName);
        }
    }

    public override UnityEngine.Object Load(GameResType type, string name, Type resType = null)
    {        
        GameBundleInfo data;
        // 检查资源清单是否有该资源
        if (CheckRes(type, name, out data)) {
            // 加载资源
            return LoadAB(data.assetbundle).Load(data.name, resType);
        }
        return null;
    }


    //TODO 这个方法有些复杂，说明需要简化逻辑
    public override void LoadAsync(GameResType type, string name, Action<UnityEngine.Object> callback, Type resType = null)
    {
        GameBundleInfo data;

        // 检查资源
        if (CheckRes(type, name, out data))
        {
            AssetBundleRef abRef;

            /*
             *  测试发现，异步从ab包加载资源时，即使该assetbundle已被unload(true)，仍可以载到奇怪的资源，且能被添加到场景上
             *  而loader被释放可能引起assetbundle被unload            
             */
            Action<UnityEngine.Object> checkCallBack = (asset) =>                            //检查异步加载资源结束时，是否该loader已被释放
            {
                if (abrDict == null || loadingDict == null)    // 为null视为已释放
                {
                    callback(null);             // 直接回调null
                }
                else
                {
                    callback(asset);   // 正常回调上层
                }
            };

            if (abrDict.TryGetValue(data.assetbundle, out abRef))
            {
                abRef.LoadAsync(name, checkCallBack);        // 缓存命中
            }
            else {
                // 缓存未命中，则要去加载ab，先声明ab载完回调
                Action<AssetBundleRef> loadABCallback = (assetbundleRef) =>
                {
                    if (assetbundleRef == null)
                    {
                        checkCallBack(null);
                    }
                    else
                    {
                        assetbundleRef.LoadAsync(name, checkCallBack);
                    }
                };

                /*
                 * loadAssetbundle 可以考虑在继承monoLoader的情况下，自己startCoroutine，就不必处理协程结束，而自己已经被销毁的情况
                 */

                AssetLoading<AssetBundleRef> loading;

                // 如果已经在异步load assetbundle
                if (loadingDict.TryGetValue(data.assetbundle, out loading))
                {
                    //将本次回调添加到load回调就完事了
                    loading.callback.Add(loadABCallback);
                    return;
                }

                // 创建一个loading
                loading = new AssetLoading<AssetBundleRef>();
                loadingDict.Add(data.assetbundle, loading);
                loading.callback.Add(loadABCallback);

                // 异步load Assetbundle
                LoadABAsync(data.assetbundle, (assetbundleRef) =>    // 本地缓存未命中，向AssetManager异步请求AssetBundle
                {
                    // 如果loader自身已被释放
                    if (abrDict == null || loadingDict == null)
                    {
                        loading.FireCallBack(null);  // 回调null
                    }
                    // 正常添加到缓存，并回调
                    loadingDict.Remove(data.assetbundle);
                    loading.FireCallBack(assetbundleRef);
                });
            }
        }
        else {
            // 没找到这资源
            callback(null);
        }
        
    }
    
    public override void Release()
    {
        if (abrDict == null) {
            return;
        }
        foreach (KeyValuePair<string, AssetBundleRef> kv in abrDict) {
            kv.Value.Release();
        }
        // 赋值为null，如果在Release后还有同步加载会产生error，异步则回调null
        abrDict = null;
        loadingDict = null;
    }



    public override Atlas LoadAtlas(string spriteName)
    {
        GameBundleInfo data;
        // 检查资源清单是否有该资源
        if (CheckRes(GameResType.Sprite, spriteName, out data))
        {
            Atlas atlas;
            if (!SpriteManager.TryGetAtlas(spriteName, out atlas)) {
                AssetBundleRef abRef = AssetBundleManager.GetAB(data.assetbundle);
                if (!abrDict.ContainsKey(data.assetbundle))
                {
                    abrDict.Add(data.assetbundle, abRef);
                }
                atlas = abRef.atlas;
            }
            return atlas;
        }
        return null;
    }

    public override void LoadAtlasAsync(string spriteName, Action<Atlas> callback)
    {
        GameBundleInfo data;
        // 检查资源清单是否有该资源
        if (CheckRes(GameResType.Sprite, spriteName, out data))
        {
            Atlas atlas;
            if (SpriteManager.TryGetAtlas(spriteName, out atlas))
            {
                callback(atlas);
            }
            else {
                AssetBundleManager.GetABAsync(data.assetbundle, (abr) =>
                {
                    abrDict.Add(data.assetbundle, abr);
                    callback(abr.atlas);
                });
            }
            return;
        }
        callback(null);
    }
}
