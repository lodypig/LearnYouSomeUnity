using UnityEngine;
using System.IO;
using System;
using System.Collections.Generic;

public class GameUpdater : Singleton<GameUpdater>
{
    public const string CurrentVersionPath = "config/version";
    public const string CacheVersionPath = "cache/version";
    public string UpdateServer = "http://120.27.139.129:27337";
    public static string AndroidServerUrl = "/update/android"; // 127.0.0.1
    public static string IOSServerUrl = "/update/ios"; // 127.0.0.1
    private VersionConfig OldCfg = null;
    private VersionConfig NewCfg = null;
    private List<string> files = null;

    public string[] serverName = new string[] { "外网", "内网", "小帅", "程辉", "唐弢", "林淮", "志鹏", "燕斌", "冠杰", "根煌", "天生"};
    private string[] serverIP = new string[] { "http://120.27.139.129:27337", "WAE01020131.woobest.com:27337" 
        ,"http://WAE01020218.woobest.com:27337", "http://WAE01020107.woobest.com:27337", "http://WAE01020214.woobest.com:27337"
    , "http://WAE01020227.woobest.com:27337", "http://WAE01020211.woobest.com:27337", "http://10.2.30.37:27337", "http://WAE01020208.woobest.com:27337"
    , "http://WAE01020326.woobest.com:27337", "http://WAE01020221.woobest.com:27337"};



    private long startTime = 0;
    
    public static event Action<WWW> OnStartDownload;
    public static event Action<WWW> OnEndDownload;
    public static event Action<WWW> OnDownloading;
    public static event Action OnFinished;
    public static event Action<float> UpdateInfoMsg;

    public static GameUpdater GetInstance()
    {
        return Instance;
    }

    public void SetUpdateServer(int index) {
        this.UpdateServer = this.serverIP[index];
    }

    private int totalDownloaded = 0;

    public int TotalDownloaded
    {
        get
        {
            return this.totalDownloaded;
        }
    }

    private int currentDownloaded = 0;

    public int CurrentDownloaded
    {
        get
        {
            return this.currentDownloaded;
        }
    }

    private float downloadSpeed = 0;
    public float DownloadSpeed
    {
        get
        {
            return this.downloadSpeed;
        }
    }

    public void AddDownloadingAction(Action<WWW> Func)
    {
        OnDownloading += Func;
    }

    public void RemoveDownloadingAction(Action<WWW> Func)
    {
        OnDownloading -= Func;
    }

    public void AddFinishedAction(Action Func)
    {
        OnFinished += Func;
    }

    public void RemoveFinishedAction(Action Func)
    {
        OnFinished -= Func;
    }

    public void OnUpdateDownloadStart(WWW www)
    {
        TTLoger.LogError("开始下载:" + www.url);

        this.startTime = TimeKit.GetMillisTime();

        if (OnStartDownload != null)
        {
            OnStartDownload(www);
        }
    }

    public void OnUpdateDownloadEnd(WWW www)
    {
        TTLoger.LogError("完成下载:" + www.url);

        ++currentDownloaded;

        if (OnEndDownload != null)
        {
            OnEndDownload(www);
        }
    }

    public void OnUpdateDownloading(WWW www)
    {
        TTLoger.LogError(string.Format("下载中({0}):{1}", www.bytesDownloaded, www.url));
        long nowTime = TimeKit.GetMillisTime();

        downloadSpeed = 1000.0f/1024/1024 * www.bytesDownloaded / (nowTime - startTime);

        if (OnDownloading != null)
        {
            OnDownloading(www);
        }
    }

    public void OnUpdateDownloadError(WWW www)
    {
        TTLoger.LogError("下载失败:" + www.url);
    }

    public void OnUpdateDownloadFinished()
    {
        if (OnFinished != null)
        {
            OnFinished();
        }
    }
    


    public bool CheckVersionNumber(VersionConfig oldCfg, VersionConfig newCfg)
    {
        return newCfg.version < oldCfg.version;
    }


    /// <summary>
    /// 网络是否可用
    /// </summary>
    /// <returns></returns>
    private bool IsNetworkAvailable()
    {
        return true;
    }

    private string getServerUrl() {

        if (Application.platform == RuntimePlatform.Android)
        {
            return UpdateServer+AndroidServerUrl;
        }
        else {
            return UpdateServer+IOSServerUrl;
        }
    }

    /// <summary>
    /// 从服务器下载所有文件
    /// </summary>
    private void DownloadAllFilesFromServer()
    {
        string url = getServerUrl().Combine(UrlUtil.UrlEncode(CurrentVersionPath));

        WWWManager.Instance.DownloadWWW(url, CacheVersionPath, (suc) =>
        {
            if (suc)
            {
                VersionConfig vc = VersionUtil.ReadConfig(CacheVersionPath);
                if (vc != null)
                {
                    NewCfg = vc;

                    files = new List<string>();
                    foreach(KeyValuePair<string, VersionFileConfig> kv in vc.fileDict)
                    {
                        files.Add(kv.Value.path);
                    }
                    gotoUpdate();
                }
                else
                {
                    ShowDialog_CanNotReadLastestVersionConfig();
                }
            }
            else
            {
                ShowDialog_CanNotUpdateToLatestVersion();
            }
        });
    }


    private void gotoUpdate()
    {
        int downloadSize = GetSizeByteNeedDownloaded(this.NewCfg, this.files);
        float sizeM = downloadSize / 1024 / 1024;
        //todo 检测是否为wifi环境
        if (sizeM < 1)
        {
            UpdateFiles();
        }
        else
        {
            if (UpdateInfoMsg != null) {
                UpdateInfoMsg(sizeM);
            }
        }
    }
    



    /// <summary>
    /// 显示网络不给力，重连界面
    /// </summary>
    private void ShowDialog_NetworkNotAvailable()
    {

    }


    /// <summary>
    /// 新的版本信息下载失败，无法更新到最新版本
    /// </summary>
    private void ShowDialog_CanNotUpdateToLatestVersion()
    {

    }


    /// <summary>
    /// 最新版本信息读取失败
    /// </summary>
    private void ShowDialog_CanNotReadLastestVersionConfig()
    {

    }


    public void DeleteCacheVersion()
    {
        string path = PathUtil.GetPersistentDataPath(CacheVersionPath);
        if (PathUtil.ExistsFile(path))
        {
            File.Delete(path);
        }

        string parentPath = PathUtil.GetParentDir(path);
        if (PathUtil.ExistsDir(parentPath))
        {
            PathUtil.DeleteFileOrFolder(parentPath);
        }
    }


    private void FinishUpdate()
    {
        string path = PathUtil.GetParentDir(PathUtil.GetPersistentDataPath(CurrentVersionPath));
        if (!Directory.Exists(path)) { 
            Directory.CreateDirectory(path);
        }

        File.Copy(PathUtil.GetPersistentDataPath(CacheVersionPath), PathUtil.GetPersistentDataPath(CurrentVersionPath), true);

        DeleteCacheVersion();

        StopUpdate();

        if (OnFinished != null)
        {
            OnFinished();
        }
    }

    /// <summary>
    /// 获取文件需要下载的文件列表
    /// </summary>
    /// <returns></returns>
    public List<string> GetFileListNeedDownloaded(VersionConfig oldCfg, VersionConfig newCfg)
    {
        Dictionary<string, VersionFileConfig> oldDict = oldCfg.fileDict;

        Dictionary<string, VersionFileConfig> newDict = newCfg.fileDict;

        List<string> files = new List<string>();
        foreach (KeyValuePair<string, VersionFileConfig> kv in newDict)
        {
            if (oldDict.ContainsKey(kv.Key))
            {
                VersionFileConfig oldVfc = oldDict[kv.Key];
                VersionFileConfig newVfc = kv.Value;

                if (oldVfc.md5 != newVfc.md5)
                {
                    files.Add(kv.Key);
                }

                oldDict.Remove(kv.Key);
            }
            else
            {
                files.Add(kv.Key);
            }
        }

        foreach (KeyValuePair<string, VersionFileConfig> kv in oldDict)
        {
            string path = PathUtil.GetPersistentDataPath(kv.Key);
            if (PathUtil.ExistsFile(path))
            {
                File.Delete(path);
            }
        }

        return files;
    }


    //获取需要下载的文件的总大小
    private int GetSizeByteNeedDownloaded(VersionConfig newCfg, List<string> files)
    {
        int size = 0;
        Dictionary<string, VersionFileConfig> newDict = newCfg.fileDict;
        for (int i = 0; i < files.Count; i++) {
            VersionFileConfig newVfc = newDict[files[i]];
            size += newVfc.sizeByte;
        }
        return size;
    }


    private void UpdateSingleFile(string url, string file, Action<bool> callback)
    {   
        WWWManager.Instance.DownloadWWW(url, file, (suc) =>
        {
            if (callback != null)
            {
                callback(suc);
            }
        });
    }


    private Queue<string> queue = new Queue<string>();


    private void UpdateFilesImpl()
    {
        if (queue.Count == 0)
        {
            FinishUpdate();
            return;
        }

        string file = queue.Peek();
        string url = getServerUrl().Combine(file.Replace(" ", "%20"));

        UpdateSingleFile(url, file, (www) =>
        { 
            if (www != null)
            {
                queue.Dequeue();
            }
            
            UpdateFilesImpl();
        });
    }

    public void UpdateFiles()
    {
        queue.Clear();
        foreach(string file in this.files)
        {
            queue.Enqueue(file);
        }

        totalDownloaded = queue.Count;
        UpdateFilesImpl();
    }



    public void StopUpdate()
    {
        WWWManager.Instance.StopAllWWW();

        NewCfg = null;
        OldCfg = null;

        files = null;

        totalDownloaded = 0;
        currentDownloaded = 0;

        WWWManager.OnStartDownload -= OnUpdateDownloadStart;
        WWWManager.OnEndDownload -= OnUpdateDownloadEnd;
        WWWManager.OnDownloading -= OnUpdateDownloading;
        WWWManager.OnDownloadError -= OnUpdateDownloadError;
    }


    public void HasNewVersion(Action<bool> callback)
    {
        if (IsNetworkAvailable())
        {
            //OldCfg = VersionUtil.ReadConfig(CurrentVersionPath);
            OldCfg = VersionUtil.handleOldAb(CurrentVersionPath);
            if (OldCfg == null) {
                if (callback != null)
                {
                    callback(true);
                }
                return;
            }
            string url = getServerUrl().Combine(CurrentVersionPath);
            DeleteCacheVersion();
            // 读取当前版本信息成功
            WWWManager.Instance.DownloadWWW(url, CacheVersionPath, (suc) =>
            {
                if (suc)
                {
                    NewCfg = VersionUtil.ReadConfig(CacheVersionPath);
                    if (NewCfg != null)
                    {
                        if (CheckVersionNumber(OldCfg, NewCfg))
                        {
                            DeleteCacheVersion();

                            if (callback != null)
                            {
                                callback(false);
                            }
                        }
                        else
                        {
                            files = GetFileListNeedDownloaded(OldCfg, NewCfg);

                                if (files.Count > 0)
                                {
                                    if (callback != null)
                                    {
                                        callback(true);
                                    }
                                }
                                else
                                {
                                    DeleteCacheVersion();

                                    if (callback != null)
                                    {
                                        callback(false);
                                    }
                                }
                        }
                    }
                    else
                    {
                        //当前没有找到version，
                        DeleteCacheVersion();

                        if (callback != null)
                        {
                            callback(false);
                        }
                    }
                }
                else
                {
                    if (callback != null)
                    {
                        callback(false);
                    }
                }
            });
            
        }
        else
        {
            if (callback != null)
            {
                callback(false);
            }
        }
    }

    public void UpdateVersion()
    {
        totalDownloaded = 0;
        currentDownloaded = 0;

        WWWManager.OnStartDownload -= OnUpdateDownloadStart;
        WWWManager.OnEndDownload -= OnUpdateDownloadEnd;
        WWWManager.OnDownloading -= OnUpdateDownloading;
        WWWManager.OnDownloadError -= OnUpdateDownloadError;

        WWWManager.OnStartDownload += OnUpdateDownloadStart;
        WWWManager.OnEndDownload += OnUpdateDownloadEnd;
        WWWManager.OnDownloading += OnUpdateDownloading;
        WWWManager.OnDownloadError += OnUpdateDownloadError;

        if (IsNetworkAvailable())
        {
            if (OldCfg != null)
            {
                gotoUpdate();
            }
            else
            {
                // 网络可用，完全更新服务器最新版本到设备(不可能出现这种情况，除非安装包上不带任何资源)
                DownloadAllFilesFromServer();
            }

        }
        else
        {
            // 网络不可用，提示玩家网络不给力
            ShowDialog_NetworkNotAvailable();
        }
    }
}
