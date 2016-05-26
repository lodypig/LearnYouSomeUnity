using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

public class LearnYouLoadAssetBundle : MonoBehaviour
{


    private List<GameObject> createObjectList = new List<GameObject>();


    private void Instantiate(UnityEngine.Object asset) { 
        if (asset != null) {
            GameObject go= GameObject.Instantiate((GameObject)asset);
            RectTransform rt = go.transform as RectTransform;
            rt.localPosition = new Vector3(300, 20, 0);
            rt.localScale = Vector3.one;
            createObjectList.Add(go);
        }
    }

    private void SetTime(string type, float time) {
        GameObject.Find("Canvas/Text").GetComponent<Text>().text = type + " cost time : " + time;
    }

    private void CreateAsset(AssetBundle ab, string assetName) {

        UnityEngine.Object asset = AssetLoader.LoadAsset(ab, assetName);
        Instantiate(asset);
        ab.Unload(false);
    }

    private void CreateAssetAsync(AssetBundle ab, string assetName, Action callback) {
        AssetLoader.LoadAssetAsync(ab, assetName, (asset) => {
            Instantiate(asset);
            ab.Unload(false);
            callback();
        });
    }

    void OnGUI() { 
        if (GUI.Button(new Rect(10, 10, 120, 50), "同步AB同步资源")) {
            float time = Time.realtimeSinceStartup;
            AssetBundle ab = AssetLoader.LoadFromFile("/UI/Compress/sprite1234.ab");
            CreateAsset(ab, "sprite1234.prefab");
            SetTime("load asset sync", Time.realtimeSinceStartup - time);
            
        }

        if (GUI.Button(new Rect(10, 80, 120, 50), "同步AB异步资源")) 
        {
            float time = Time.realtimeSinceStartup;
            AssetBundle ab = AssetLoader.LoadFromFile("/UI/Compress/sprite1234.ab");
            CreateAssetAsync(ab, "sprite1234.prefab", () =>
            {
                SetTime("load asset async", Time.realtimeSinceStartup - time);
            });
        }

        if (GUI.Button(new Rect(10, 150, 120, 50), "异步AB同步资源"))
        {
            float time = Time.realtimeSinceStartup;
            AssetLoader.LoadFromWWW("/UI/Compress/sprite1234.ab", (ab) =>
            {
                CreateAsset(ab, "sprite1234.prefab");
                SetTime("load asset sync", Time.realtimeSinceStartup - time);
            });
        }

        if (GUI.Button(new Rect(10, 220, 120, 50), "异步AB异步资源"))
        {
            float time = Time.realtimeSinceStartup;
            AssetLoader.LoadFromWWW("/UI/Compress/sprite1234.ab", (ab) =>
            {
                CreateAssetAsync(ab, "sprite1234.prefab", () =>
                {
                    SetTime("load asset async", Time.realtimeSinceStartup - time);
                });
            });
        }

        if (GUI.Button(new Rect(600, 10, 120, 50), "清空场景")) {
            for (int i = 0; i < createObjectList.Count; ++i) {
                Destroy(createObjectList[i]);
            }
            createObjectList.Clear();
        }
    }
}
