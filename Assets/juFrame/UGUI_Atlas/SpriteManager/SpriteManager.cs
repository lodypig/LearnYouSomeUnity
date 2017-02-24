using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;


/**
 * 合图后，SpriteMode 使用 Multiple，导致无法直接加载指定的某一个Sprite对象。
 * 
 * ---- Mobiel ----
 * 使用AssetBundle.LoadAllAssets可以加载到所有的AssetBundle中包含的所有资源，即包括所有的Sprite
 * 所以对于图集类的AssetBundle，加载完毕后立即调用LoadAllAssets或LoadAllAssetsAsync，并生成对应的Atlas类，由SpriteManager缓存sprite -> Atlas
 * ----------------
 * 
 * ---- Editor ----
 * 使用AssetDataBase.LoadAllAssetsAtPath()加载到所有Sprite，并由SpriteManager缓存。
 * ----------------
 * 
 */
public class SpriteManager {

    
    static Dictionary<string, Atlas> _atlasDict = new Dictionary<string, Atlas>();


    public static void Clear() {
        _atlasDict.Clear();
    }

    public static Atlas GetAtlas(string key) {
        return _atlasDict[key];
    }

    public static bool TryGetAtlas(string key, out Atlas Atlas) {
        return _atlasDict.TryGetValue(key, out Atlas);
    }

    public static void CacheSpriteWorker(UnityEngine.Object[] assets, Atlas atlas) {
        string assetName;
        for (int i = 0; i < assets.Length; ++i)
        {
            if (assets[i] is Sprite)
            {
                assetName = PathUtil.LastTrim(assets[i].name, '-');
                if (!_atlasDict.ContainsKey(assetName)) {
                    _atlasDict.Add(assetName, atlas);
                    atlas.Add(assetName, assets[i] as Sprite);
                }
				#if UNITY_EDITOR
                else {
					Debug.LogWarning("duplicate sprite name : " + assetName + " oldAtlas : " + _atlasDict[assetName].name + " newAtlas : " + atlas.name);
                }
				#endif 
            }

            if (assets[i] is Material) {
                atlas.material = assets[i] as Material;
                atlas.material.shader = Shader.Find("UI/Default(MW)");
            }
        }
    }

    public static Atlas CacheSprite(string atlasName, UnityEngine.Object[] assets, Material material = null)
    {
        Atlas atlas = new Atlas(atlasName);
        atlas.material = material;
        CacheSpriteWorker(assets, atlas);
        return atlas;
    }

    

    public static void CacheSprite(AssetBundleRef abr, UnityEngine.Object[] assets)
    {
        Atlas atlas = new Atlas (abr.Name);
        abr.atlas = atlas;
        CacheSpriteWorker(assets, atlas);
        
    }
    
     public static void CacheSprite(AssetBundleRef abr) {
         UnityEngine.Object[] assets = abr.LoadAllAssets();
         CacheSprite(abr, assets);
    }

     public static void CacheSpriteAsync(AssetBundleRef abr, Action callback) {
         abr.LoadAllAssetsAsync((assets) =>
         {
             CacheSprite(abr, assets);
             callback();
         });
     }


    public static void UnCacheAtlas(string atlasName) {
        _atlasDict.Remove(atlasName);
    }
}
