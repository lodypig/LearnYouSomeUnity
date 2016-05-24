using UnityEngine;
using System.Collections;
using UnityEditor;

public class AssetDataBase  {

    [MenuItem("AssetDataBase/创建Asset")]
    public static void CreateAsset() {
        Material material = AssetDatabase.LoadAssetAtPath<Material>("Assets/LearnYouAssetDataBase/Material/LearnYouAssetDataBase.mat");
        Material newMaterial = new Material(material);
        AssetDatabase.CreateAsset(newMaterial, "Assets/I'm create from LearnYouAssetDataBase.mat");
        AssetDatabase.Refresh();
    }

    [MenuItem("AssetDataBase/复制Materal")]
    public static void CopyMateral() {
        AssetDatabase.CopyAsset("Assets/LearnYouAssetDataBase/Material/LearnYouAssetDataBase.mat", "Assets/I'm a copy of LearnYouAssetDataBase.mat");
        AssetDatabase.Refresh();
    }




    
}
