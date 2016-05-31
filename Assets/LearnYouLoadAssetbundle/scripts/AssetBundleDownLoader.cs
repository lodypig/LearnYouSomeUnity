using UnityEngine;
using System.Collections;
using System.IO;

public class AssetBundleDownLoader {

    public static string ServerUrl = 
    #if UNITY_ANDOIRD 
        "http://10.2.30.100/new/android/sprite1234.ab"; // 127.0.0.1
    #else
        "http://10.2.30.100/new/ios/sprite1234.ab"; // 127.0.0.1
    #endif

    public static void Download() {
        CoroutineProvider.Instance.StartCoroutine(DownloadAssetBundleCoroutine(ServerUrl));
    }

    public static IEnumerator DownloadAssetBundleCoroutine(string url) {
        WWW www = new WWW(url);
        while (!www.isDone) {
            yield return www;
        }
        
        string filepath = Application.persistentDataPath + "/UI/Compress";
        PathUtil.EnsureFolder(filepath);
        FileStream fs = File.Create(filepath + "/sprite1234.ab");
        fs.Write(www.bytes, 0, www.bytesDownloaded);
        fs.Flush();
        fs.Close();
    }

}
