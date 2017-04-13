using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using UnityEngine.UI;

public class LearnYouLoadAssetBundle : MonoBehaviour
{


    private List<GameObject> createObjectList = new List<GameObject>();
    private AssetBundle ab;
    private Text text;
    private AssetBundle cab;

    void Start()
    {
        AssetBundleDownLoader.DownloadHttp("sprite1234.ab", "sprite1234.ab");
        text = GameObject.Find("Canvas/Text").GetComponent<Text>();
        cab = AssetLoader.LoadABFromStream("/UI/UnCompress/common.ab");
    }

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
       text.text = type + " cost time : " + time;
    }

    private void CreateAsset(AssetBundle ab, string assetName) {

        UnityEngine.Object asset = AssetLoader.LoadAsset(ab, assetName);
        Instantiate(asset);
    }

    private void CreateAssetAsync(AssetBundle ab, string assetName, Action callback) {
        AssetLoader.LoadAssetAsync(ab, assetName, (asset) => {
            Instantiate(asset);
            callback();
        });
    }



    private void Clear() {
        for (int i = 0; i < createObjectList.Count; ++i)
        {
            //Destroy(createObjectList[i]);
        }
        createObjectList.Clear();
        if (ab != null)
        {
            cab.Unload(true);
            cab = null;
            //Resources.UnloadUnusedAssets();
        }
        text.text = string.Empty;
    }   

    void OnGUI() {




        if (GUI.Button(new Rect(10, 10, 200, 50), "stream同步AB"))
        {
            Clear();
            float time = Time.realtimeSinceStartup;
            ab = AssetLoader.LoadABFromStream("/sprite");
            SetTime("load ab from streamingAssetDataPath", Time.realtimeSinceStartup - time);
        }

        if (GUI.Button(new Rect(10, 80, 200, 50), "stream异步AB"))
        {
            Clear();
            float time = Time.realtimeSinceStartup;
            AssetLoader.LoadABFromStreamAsync("/UI/UnCompress/sprite1234.ab", (assetBundle) =>
            {
                ab = assetBundle;
                SetTime("load ab sync", Time.realtimeSinceStartup - time);
            });
        }

        if (GUI.Button(new Rect(10, 150, 200, 50), "persistent同步AB"))
        {
            Clear();
            float time = Time.realtimeSinceStartup;
            ab = AssetLoader.LoadABFromPersistent("/sprite1234.ab");
            SetTime("load ab from persistantDataPath", Time.realtimeSinceStartup - time);
        }

        if (GUI.Button(new Rect(10, 220, 200, 50), "persistent异步AB"))
        {
            Clear();
            float time = Time.realtimeSinceStartup;
            AssetLoader.LoadABFromPersistentAsync("/sprite1234.ab", (assetBundle) =>
            {
                ab = assetBundle;
                SetTime("load ab sync", Time.realtimeSinceStartup - time);
            });
        }

        //CreateAsset(ab, "sprite1234.prefab");
        if (GUI.Button(new Rect(220, 10, 200, 50), "同步加载资源"))
        {
            if (ab == null) {
                text.text = "请先加载AB";
                return;
            }
            float time = Time.realtimeSinceStartup;
            ab.LoadAllAssets();
            //CreateAsset(ab, "sprite1234.prefab");
            SetTime("load asset", Time.realtimeSinceStartup - time);
        }

        if (GUI.Button(new Rect(220, 80, 200, 50), "异步加载资源")) 
        {
            if (ab == null)
            {
                text.text = "请先加载AB";
                return;
            }
            float time = Time.realtimeSinceStartup;
            CreateAssetAsync(ab, "sprite1234.prefab", () =>
            {
                SetTime("load asset async", Time.realtimeSinceStartup - time);
            });
        }


        if (GUI.Button(new Rect(600, 10, 120, 50), "清空场景")) {
            Clear();
        }

        if (GUI.Button(new Rect(750, 10, 120, 50), "检查StreamingAsset"))
        {
            string path = Application.streamingAssetsPath + "/UI/UnCompress/sprite1234.ab";
            text.text = path + " exists :" + File.Exists(path);
        }

        if (GUI.Button(new Rect(750, 80, 120, 50), "检查StreamingAsset2"))
        {
            string path = Application.dataPath + "!assets/UI/UnCompress/sprite1234.ab";
            text.text = path + " exists :" + File.Exists(path);
        }
        

        if (GUI.Button(new Rect(750, 150, 120, 50), "检查persistantDataPath"))
        {
            text.text = File.Exists(Application.persistentDataPath + "/sprite1234.ab").ToString();
        }


    }
}
