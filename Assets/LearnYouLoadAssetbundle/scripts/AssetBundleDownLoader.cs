using UnityEngine;
using System.Collections;
using System.IO;
using System.Net;
using System;
internal class WebReqState
{
    public byte[] Buffer;

    public FileStream fs;

    public const int BufferSize = 1024;

    public Stream OrginalStream;


    public HttpWebResponse WebResponse;

    // 构造函数
    public WebReqState(string path)
    {
        Buffer = new byte[1024];
        fs = new FileStream(path, FileMode.Create);
    }

}

public class AssetBundleDownLoader {

    public static string ServerUrl = 
    #if UNITY_ANDOIRD 
        "http://10.2.30.100/new/android/"; // 127.0.0.1
    #else
        "http://10.2.30.100/new/ios/"; // 127.0.0.1
    #endif

    public static string PERSISITANT_DATA_PATH = Application.persistentDataPath;

    public static void SaveAssetBundle(string saveName, byte[] bytes, int length)
    {
        string filepath = Application.persistentDataPath + "/UI/Compress/";
        PathUtil.EnsureFolder(filepath);
        FileStream fs = File.Create(filepath + saveName);
        fs.Write(bytes, 0, length);
        fs.Flush();
        fs.Close();
    }

    public static void DownloadWWW(string assetBundleName, string saveName) {
        CoroutineProvider.Instance.StartCoroutine(DownloadAssetBundleCoroutine(ServerUrl + assetBundleName, saveName));
    }

    public static void DownloadHttp(string assetBundleName, string saveName) {
        string url = ServerUrl + assetBundleName;
        HttpWebRequest httpRequest = WebRequest.Create(url) as HttpWebRequest;
        httpRequest.BeginGetResponse(new AsyncCallback(HttpDownLoadCallback), httpRequest);
    }


    private static void HttpDownLoadCallback(IAsyncResult ar) {
        HttpWebRequest req = ar.AsyncState as HttpWebRequest;
        if (req == null) return;
        HttpWebResponse response = req.EndGetResponse(ar) as HttpWebResponse;
        if (response.StatusCode != HttpStatusCode.OK)
        {
            response.Close();
            return;
        }
        WebReqState state = new WebReqState(PERSISITANT_DATA_PATH + "/sprite1234.ab");
        state.WebResponse = response;
        Stream responseStream = response.GetResponseStream();
        state.OrginalStream = responseStream;
        responseStream.BeginRead(state.Buffer, 0, WebReqState.BufferSize, new AsyncCallback(ReadDataCallback), state);
    }

    private static void ReadDataCallback(IAsyncResult ar)
    {
        WebReqState state = ar.AsyncState as WebReqState;
        int read = state.OrginalStream.EndRead(ar);
        if (read > 0)
        {
            state.fs.Write(state.Buffer, 0, read);
            state.fs.Flush();
            state.OrginalStream.BeginRead(state.Buffer, 0, WebReqState.BufferSize, new AsyncCallback(ReadDataCallback), state);
        }
        else
        {
            state.fs.Close();
            state.OrginalStream.Close();
            state.WebResponse.Close();
//             Debug.Log(assetName + ":::: success");
//             if (func != null)
//             {
//                 func();
//             }
        }
    }

    public static IEnumerator DownloadAssetBundleCoroutine(string url, string saveName) {
        WWW www = new WWW(url);
        while (!www.isDone) {
            yield return www;
        }
        SaveAssetBundle(saveName, www.bytes, www.bytesDownloaded);
    }

}
