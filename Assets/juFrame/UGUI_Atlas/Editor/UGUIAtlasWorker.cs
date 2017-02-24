using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

public class UGUIAtlasWorker {

    public void GenAtlas(string folderName, string targetPath, string filePrefix, string args)
    {
        if (Directory.Exists(targetPath))
        {
            PathUtil.DeleteFileOrFolder(targetPath);
        }
        AssetDatabase.Refresh();
        PathUtil.EnsuerFolder(targetPath);
        string dataPathArg = "--data " + targetPath.Combine(filePrefix + ".tpsheet");
        string arg = string.Join(" ", new string[3] { folderName, args, dataPathArg });
        CMDProcesser.processCommand("TexturePacker.exe", arg);
    }

    static void MakeReadable(string path)
    {
        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;
        ti.isReadable = true;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
        AssetDatabase.Refresh();
    }

    public void UpdateBorder(string path) {
        TextureImporter ti, sti;

        ti = AssetImporter.GetAtPath(path) as TextureImporter;
        SpriteMetaData[] datas = ti.spritesheet;

        path = PathUtil.GetParentDir(path);
        path = path.Replace(PathConfig.atlasKey, PathConfig.spriteKey);
        
        for (int i = 0; i < datas.Length; ++i) {
            sti = AssetImporter.GetAtPath(path.Combine(datas[i].name.Split('-')) + ".png") as TextureImporter;
            if (sti == null)
            {
                Debug.LogError("查找资源 ; " + path.Combine(datas[i].name.Split('-')) + " 失败");
                continue;
            }
            datas[i].border = sti.spriteBorder;
        }
        ti.spritesheet = datas;
        EditorUtility.SetDirty(ti);
        ti.SaveAndReimport();
    }



    public void UpdateSetting(string path, TextureImporterFormat formatAndoird, TextureImporterFormat formatiOS)
    {
        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;
        ti.isReadable = false;
        ti.mipmapEnabled = false;
        ti.wrapMode = TextureWrapMode.Clamp;
        ti.textureType = TextureImporterType.Sprite;
        ti.spriteImportMode = SpriteImportMode.Multiple;
        ti.SetPlatformTextureSettings("Android", 2048, formatAndoird);
        ti.SetPlatformTextureSettings("iPhone", 2048, formatiOS);
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
    }

    public void GenMaterial(string targetPath, string texPath, string alphaTexPath, Shader shader, string filePrefix)
    {
        Material m;
        string materialPath = targetPath.Combine(filePrefix + "_m.mat");
        m = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
        if (m == null)
        {
            m = new Material(shader);
            AssetDatabase.CreateAsset(m, targetPath.Combine(filePrefix + "_m.mat"));
        }
        Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(texPath);
        m.SetTexture("_MainTex", tex);
        tex = AssetDatabase.LoadAssetAtPath<Texture2D>(alphaTexPath);
        m.SetTexture("_AlphaTex", tex);
        EditorUtility.SetDirty(m);
    }

    public void SplitAlpha(string texPath, string alphaTexPath)
    {
        MakeReadable(texPath);
        
        Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(texPath);
        Texture2D newTex = new Texture2D(tex.width, tex.height, TextureFormat.RGB24, false);
        Texture2D alphaTex = new Texture2D(tex.width, tex.height, TextureFormat.RGB24, false);

        Color newColor = new Color(0.0f, 0.0f, 0.0f);
        Color alphaColor = new Color(0.0f, 0.0f, 0.0f);

        for (int x = 0; x < tex.width; ++x)
        {
            for (int y = 0; y < tex.height; ++y)
            {
                Color c = tex.GetPixel(x, y);
                newColor.r = c.r;
                newColor.g = c.g;
                newColor.b = c.b;
                alphaColor.r = c.a;
                newTex.SetPixel(x, y, newColor);
                alphaTex.SetPixel(x, y, alphaColor);
            }
        }

        Resources.UnloadAsset(tex);
        byte[] bytes = alphaTex.EncodeToPNG();
        File.WriteAllBytes(alphaTexPath, bytes);


        bytes = newTex.EncodeToPNG();
        File.WriteAllBytes(texPath, bytes);
    }
}
