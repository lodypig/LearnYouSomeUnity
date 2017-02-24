using UnityEngine;
using System.Collections;

public class PathConfig  {
#if UNITY_EDITOR
    public const string atlasConfig = "Assets/juFrame/UGUI_Atlas/Config/atlasConfig.asset";
    public const string spritePath = "Assets/" + spriteKey;
    public const string atlasTargetPath = "Assets/" + atlasKey;
	public const string uiPrefabPath = "Assets/RawRes/UIPrefab/RunTimePrefab";

    public const string buildConfig = "Assets/juFrame/ABSystem/Config/buildConfig.asset";
    public const string lua = "Assets/RawRes/lua";
    public const string tempLua = "Assets/RawRes/LuaTmp";
    public const string updateAb = "Assets/RawRes/updateAB";
#endif
    public const string spriteKey = "Sprite";
    public const string atlasKey = "Atlas";
    public const string resEditor = "Assets/juFrame/ABSystem/Config/resEditor.txt";
    public const string resBundle = "Assets/juFrame/ABSystem/Config/resBundle.txt";
    public const string version = "Assets/juFrame/ABSystem/Config/version.txt";
}
