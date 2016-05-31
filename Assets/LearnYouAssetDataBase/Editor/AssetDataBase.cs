using UnityEngine;
using System.Collections;
using UnityEditor;


public class AssetDataBase  {

    [MenuItem("AssetDataBase/创建Asset")]
    public static UnityEngine.Object CreateAsset() {
        PathUtil.EnsureUnityFolder("/LearnYouAssetDataBase/Material");
        Material material = new Material(Shader.Find("Specular"));
        AssetDatabase.CreateAsset(material, "Assets/LearnYouAssetDataBase/Material/I'm create from LearnYouAssetDataBase.mat");
        AssetDatabase.Refresh();
        return material;
    }

    [MenuItem("AssetDataBase/复制Materal")]
    public static void CopyMateral() {
        AssetDatabase.CopyAsset("Assets/LearnYouAssetDataBase/Material/I'm create from LearnYouAssetDataBase.mat", "Assets/LearnYouAssetDataBase/Material/I'm a copy of LearnYouAssetDataBase.mat");
        AssetDatabase.Refresh();
    }

    [MenuItem("Assets/移动到PersistentDataPath")]
    public static void MoveToPersistentDataPath() {
        if (Selection.objects.Length > 0) {
            string sourceFile, toFile;
            foreach (Object go in Selection.objects)
            {
                // unity path : like Assets/LearnYouAssetDataBase/Material/LearnYouAssetDataBase.mat
                string unityPath = AssetDatabase.GetAssetPath(go.GetInstanceID());

                // Application.dataPath :like "E:/LearnYouSomeUnity/Assets"
                // systemPath : like "E:/LearnYouSomeUnity/Assets/LearnYouAssetDataBase/Material/LearnYouAssetDataBase.mat"
                sourceFile = Application.dataPath + unityPath.Replace("Assets", "");
                toFile = Application.persistentDataPath + unityPath.Replace("Assets", "");
                PathUtil.EnsureFolder(PathUtil.GetFolderPath(toFile));
                FileUtil.CopyFileOrDirectory(sourceFile, toFile);
            }
            AssetDatabase.Refresh();
        }
    }

    [MenuItem("AssetDataBase/清空PersistentDataPath")]
    public static void ClearPersistentDataPath() {
        PathUtil.ClearPersistentDataPath();
    }
    
}
