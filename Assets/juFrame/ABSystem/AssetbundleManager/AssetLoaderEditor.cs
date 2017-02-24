using UnityEngine;
using UnityEditor;
using System.Collections;
using System;


/*
 * 编辑器下资源加载器
 * 根据resEditor，查找资源路径，使用AssetDataBase.LoadAssetAtPath加载
 * 实际无异步load方法
 */
#if UNITY_EDITOR
public class AssetLoaderEditor : AssetLoader {

    bool CheckRes(GameResType type, string name, out GameResInfo data)
    {
        data = GameTable.GetGameRes(type, name);
        if (data == null)
        {
            TTLoger.LogError("资源清单未找到资源 : " + name + "，请检查resEditor");
            return false;
        }
        return true;
    }

     // 同步load方法
     public override UnityEngine.Object Load(GameResType type, string name, Type resType = null) {
         GameResInfo data;
         if (CheckRes(type, name, out data)) {
             return LoadAssetAtPath(data.resPath, resType);
         }
         return null;
     }

     public static UnityEngine.Object LoadFromResource(string path) {
         return LoadAssetAtPath(AppConst.RawResPath.Combine(path));
     }

     // 统一接口，实际直接同步加载并回调
     public override void LoadAsync(GameResType type, string name, Action<UnityEngine.Object> callback, Type resType = null)
     {
         UnityEngine.Object go = Load(type, name, resType);
         callback(go);
     }

     
     public static UnityEngine.Object LoadAssetAtPath(string path, Type resType = null)
     {
         return AssetDatabase.LoadAssetAtPath(path, resType == null ? typeof(UnityEngine.Object) : resType);
     }



     public override Atlas LoadAtlas(string spriteName) {
         GameResInfo data;
         if (CheckRes(GameResType.Sprite, spriteName, out data))
         {
             Atlas atlas = new Atlas("");
             Sprite sp = LoadAssetAtPath(data.resPath, typeof(Sprite)) as Sprite;
             atlas.Add(spriteName, sp);
             return atlas;
         }
         return null;
     }

     public override void LoadAtlasAsync(string spriteName, Action<Atlas> callback)
     {
         Atlas atlas = LoadAtlas(spriteName);
         callback(atlas);
     }
}
#endif
