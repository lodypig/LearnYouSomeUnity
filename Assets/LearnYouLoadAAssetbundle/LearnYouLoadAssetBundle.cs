using UnityEngine;
using System.Collections;

public class LearnYouLoadAssetBundle : MonoBehaviour {


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

    private AssetBundle LoadFromFile(string path) {
        return AssetBundle.LoadFromFile(STREAMING_ASSET_PATH + "/UI/Compress/sprite1234.ab");
    }

    private void CreateAsset(AssetBundle ab, string assetName) {
        GameObject asset = ab.LoadAsset(assetName) as GameObject;
        if (asset != null) {
            GameObject go= GameObject.Instantiate(asset);
        }
        ab.Unload(false);
    }


	// Use this for initialization
	void Start () {
        AssetBundle ab = LoadFromFile("UI/Compress/sprite1234.ab");
        CreateAsset(ab, "sprite1234.prefab");
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
