using UnityEngine;
using System.Collections;


/// <summary>
/// 游戏资源类型
/// </summary>
public enum GameResType
{
    Audio,
    Clip,
    Cloth,
    DropItem,
    Effect,
    Emote,
    FloatText,
    Font,
    Hair,
    HeadText,
    Atlas,
    Item,
    Lua,
    Material,
    Model,
    None,
    Scene,
    SceneElement,
    StateMachine,
    Table,
    Texture,
    UI,
    Weapon,
    Shader,
    Sprite,
    EffectElement,
    Icon
}



/// <summary>
/// 游戏AssetBundle资源数据
/// </summary>
public class GameBundleInfo {
    public int id = 0;
    public GameResType type = GameResType.Cloth;
    public string name = string.Empty;
    public string assetbundle = string.Empty;
}

public class GameResInfo {
    public int id = 0;
    public GameResType type = GameResType.Cloth;
    public string name = string.Empty;
    public string resPath = string.Empty;
}

