using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;

public class AtlasPath {
    public string sysDir;
    public string dir;
    public string filePrefix;
    public string targetPath;
    public string texPath;
    public string alphaTexPath;

    public AtlasInfo _config;

    public AtlasInfo config {
        get {
            if (_config == null) {
                _config = AssetDatabase.LoadAssetAtPath<AtlasInfo>(PathConfig.atlasConfig);
            }
            return _config;
        }
    }

    public void FormatPath(string dir) {
        this.sysDir = dir;
        this.dir = dir.ReplaceESC();
        this.filePrefix = PathUtil.GetDirName(this.dir);
        this.targetPath = PathUtil.GetFullPath(config.targetPath.Combine(filePrefix));
        targetPath = PathUtil.GetAssetPath(targetPath);
        this.texPath = targetPath.Combine(filePrefix + ".png");
        alphaTexPath = targetPath.Combine(filePrefix + "_a.png");
    }
    
}

public class UGUIAtlasMaker {

    static AtlasInfo config;
    static void LoadConfig()
    {
        config = AssetDatabase.LoadAssetAtPath<AtlasInfo>(PathConfig.atlasConfig);
        if (config == null)
        {
            config = new AtlasInfo(PathConfig.spritePath, PathConfig.atlasTargetPath);
            AssetDatabase.CreateAsset(config, PathConfig.atlasConfig);
        }
    }

    static string FormatArg() {
        List<string> args = new List<string>();
        args.Add("--format unity-texture2d");
        args.Add("--max-size 2048");
        args.Add("--shape-padding 0");
        args.Add("--border-padding 0");
        args.Add("--algorithm MaxRects");
        args.Add("--disable-rotation");
        args.Add("--no-trim");
        args.Add("--force-publish"); 

        return string.Join(" ", args.ToArray());
    }

    public static void GenAtlasProcessor(AtlasPath path, UGUIAtlasWorker worker, object param) {
        worker.GenAtlas(path.dir, path.targetPath, path.filePrefix, (string)param);
    }

    public static void SplitAlphaProcessor(AtlasPath path, UGUIAtlasWorker worker, object param) {
        worker.SplitAlpha(path.texPath, path.alphaTexPath);
    }

    public static void GenMaterialProcessor(AtlasPath path, UGUIAtlasWorker worker, object param) {
        worker.GenMaterial(path.targetPath, path.texPath, path.alphaTexPath, (Shader)param, path.filePrefix);
    }

    public static void RemoveUnUsedProcessor(AtlasPath path, UGUIAtlasWorker worker, object param){
        PathUtil.DeleteFileOrFolder(path.sysDir); 
    }

    public static void UpdateSettingProcessor(AtlasPath path, UGUIAtlasWorker worker, object param) {
        worker.UpdateSetting(path.texPath, TextureImporterFormat.ETC_RGB4, TextureImporterFormat.PVRTC_RGB4);
        worker.UpdateSetting(path.alphaTexPath, TextureImporterFormat.ETC_RGB4, TextureImporterFormat.PVRTC_RGB4);
    }

    public static void UpdateBorderProcessor(AtlasPath path, UGUIAtlasWorker worker, object param) {
        worker.UpdateBorder(path.texPath);
    }

    public static void Process(Action<AtlasPath, UGUIAtlasWorker, object> processor, string[] dirs, UGUIAtlasWorker worker, object param = null) {
        AtlasPath path = new AtlasPath ();
        for (int i = 0; i < dirs.Length; ++i)
        {
            path.FormatPath(dirs[i]);
            processor(path, worker, param);
        }
        AssetDatabase.Refresh();
    }
    

    [MenuItem("UI/一键生成图集")]
    public static void GenAtlas() 
    {
       
        LoadConfig();
        string[] dirs = config.GetChangedDir();
        PathUtil.EnsuerFolder(PathUtil.GetFullPath("Atlas"));

        // 召唤一个工人 ㄟ( ▔ , ▔ )ㄏ
        UGUIAtlasWorker worker = new UGUIAtlasWorker ();
        Shader shader = AssetDatabase.LoadAssetAtPath<Shader>("Assets/Shader/UI-Default.shader");

        // work work  (╯‵□′)╯︵┻━┻(摔！)
        if(dirs.Length > 0)
        { 
            Process(GenAtlasProcessor, dirs, worker, FormatArg());
            Process(SplitAlphaProcessor, dirs, worker);  // mark readable
            Process(UpdateBorderProcessor, dirs, worker);
            Process(UpdateSettingProcessor, dirs, worker); // isReadable = false
            Process(GenMaterialProcessor, dirs, worker, shader);
            TTLoger.Log("哦！太感动了，居然成功了！");  
        }
        else
        {
            TTLoger.Log("无美术资源变化，不需生成！");
        }

        dirs = config.GetRemovedList();
        Process(RemoveUnUsedProcessor, dirs, worker);

        // 验收记录 Y(￣o￣)Y
        config.UpdateAndGetChangedAtlas();
        EditorUtility.SetDirty(config);
        shader = null;
        Resources.UnloadUnusedAssets();
        AssetDatabase.Refresh();
    }

    [MenuItem("UI/赋值材质")]
    public static void AssignTex2Mat() {
        string[] dirs = Directory.GetDirectories(PathUtil.GetFullPath(PathConfig.atlasTargetPath));
        UGUIAtlasWorker worker = new UGUIAtlasWorker();
        Shader shader = AssetDatabase.LoadAssetAtPath<Shader>("Assets/Shader/UI-Default.shader");
        Process(GenMaterialProcessor, dirs, worker, shader);
        shader = null;
        Resources.UnloadUnusedAssets();
        AssetDatabase.Refresh();
    }

    [MenuItem("UI/赋值Border")]
    public static void UpdateBorder()
    {
        string[] dirs = Directory.GetDirectories(PathUtil.GetFullPath(PathConfig.atlasTargetPath));
        UGUIAtlasWorker worker = new UGUIAtlasWorker();
        Process(UpdateBorderProcessor, dirs, worker);
        Resources.UnloadUnusedAssets();
        AssetDatabase.Refresh();
    }
}
