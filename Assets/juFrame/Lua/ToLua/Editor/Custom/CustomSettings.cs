using UnityEngine;
using System;
using System.Collections.Generic;
using LuaInterface;

using BindType = ToLuaMenu.BindType;
using System.Reflection;

public static class CustomSettings
{
    public static string saveDir = Application.dataPath + "/juFrame/Lua/Source/Generate/";    
    public static string toluaBaseType = Application.dataPath + "/juFrame/Lua/ToLua/BaseType/";    

    //导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
    //unity 有些类作为sealed class, 其实完全等价于静态类
    public static List<Type> staticClassTypes = new List<Type>
    {        
        typeof(UnityEngine.Application),
        typeof(UnityEngine.Time),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.Input),
        typeof(UnityEngine.Resources),
        typeof(UnityEngine.Physics),
        typeof(UnityEngine.RenderSettings),
        typeof(UnityEngine.QualitySettings),
        typeof(UnityEngine.GL),
    };

    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList = 
    {        
        _DT(typeof(Action)),                
        _DT(typeof(UnityEngine.Events.UnityAction)),
        _DT(typeof(System.Predicate<int>)),
        _DT(typeof(System.Action<int>)),
        _DT(typeof(System.Comparison<int>)),
    };

    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {                    
        _GT(typeof(Debugger)).SetNameSpace(null),       

        // ------------------------------------------------------------ ToLua 导出区域 ------------------------------------------------------
        //----------------Dotween------------------
        _GT(typeof(DG.Tweening.DOTween)),
        _GT(typeof(DG.Tweening.Tween)).SetBaseType(typeof(System.Object)).AddExtendType(typeof(DG.Tweening.TweenExtensions)),
        _GT(typeof(DG.Tweening.Sequence)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.Tweener)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.LoopType)),
        _GT(typeof(DG.Tweening.PathMode)),
        _GT(typeof(DG.Tweening.PathType)),
        _GT(typeof(DG.Tweening.RotateMode)),

        _GT(typeof(Component)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Transform)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Material)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Camera)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(UnityEngine.UI.Image)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
        _GT(typeof(UnityEngine.UI.Text)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
        _GT(typeof(UnityEngine.CanvasGroup)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),


        //_GT(typeof(Light)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        //_GT(typeof(Rigidbody)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        //_GT(typeof(AudioSource)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        //_GT(typeof(LineRenderer)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        //_GT(typeof(TrailRenderer)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),    

        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),        
        _GT(typeof(GameObject)),
        //_GT(typeof(TrackedReference)),
        _GT(typeof(Application)),
        //_GT(typeof(Physics)),
        //_GT(typeof(Collider)),
        _GT(typeof(Time)),        
        _GT(typeof(Texture)),
        _GT(typeof(Texture2D)),
        _GT(typeof(Shader)),        
        _GT(typeof(Renderer)),
        //_GT(typeof(WWW)),
        _GT(typeof(Screen)),        
        _GT(typeof(CameraClearFlags)),
        _GT(typeof(AudioClip)),        
        _GT(typeof(AssetBundle)),
        _GT(typeof(ParticleSystem)),
        _GT(typeof(AsyncOperation)).SetBaseType(typeof(System.Object)),        
        //_GT(typeof(LightType)),
        _GT(typeof(SleepTimeout)),
#if UNITY_5_3_OR_NEWER
        _GT(typeof(UnityEngine.Experimental.Director.DirectorPlayer)),
#endif
        _GT(typeof(Animator)),
        //_GT(typeof(Input)),
        //_GT(typeof(KeyCode)),
        //_GT(typeof(SkinnedMeshRenderer)),
        //_GT(typeof(Space)),      
       

        _GT(typeof(MeshRenderer)),
#if !UNITY_5_4_OR_NEWER
        //_GT(typeof(ParticleEmitter)),
        //_GT(typeof(ParticleRenderer)),
        //_GT(typeof(ParticleAnimator)), 
#endif
                              
        //_GT(typeof(BoxCollider)),
        //_GT(typeof(MeshCollider)),
        //_GT(typeof(SphereCollider)),        
        //_GT(typeof(CharacterController)),
        //_GT(typeof(CapsuleCollider)),
        
        _GT(typeof(Animation)),        
        _GT(typeof(AnimationClip)).SetBaseType(typeof(UnityEngine.Object)),        
        _GT(typeof(AnimationState)),
        _GT(typeof(AnimationBlendMode)),
        //_GT(typeof(QueueMode)),  
        //_GT(typeof(PlayMode)),
        //_GT(typeof(WrapMode)),

        //_GT(typeof(QualitySettings)),
        //_GT(typeof(RenderSettings)),                                                   
        _GT(typeof(BlendWeights)),           
        _GT(typeof(RenderTexture)),
        //_GT(typeof(Resources)),

       
        //------------------------------------------------------------  C# Unity导出区域（有些ToLua自带） --------------------------------------------        
        _GT(typeof(iTween)),                
        _GT(typeof(UnityEngine.UI.ScrollRect.MovementType)),
        _GT(typeof(NetworkReachability )),
        _GT(typeof(PlayerPrefs)),
        _GT(typeof(System.Collections.ArrayList)),

        //------------------------------------------------------------  自定义导出区域 --------------------------------------------        
        //  -- ui manager --
        _GT(typeof(UIManager)),
        _GT(typeof(UIWrapper)),
        _GT(typeof(PanelManager)),
        _GT(typeof(WindowLayer)),
        _GT(typeof(UIWrapper.UIEffectAddType)),
        _GT(typeof(RectTransform)),
        _GT(typeof(LuaBehaviour)),
        _GT(typeof(UIExtendType)),
        _GT(typeof(UIOpenType)),
        _GT(typeof(ChatState)),

        //  -- ui wigdet --
        _GT(typeof(LRichText)),
        _GT(typeof(LMovieClip)),
        _GT(typeof(UIWarpContent)),
        _GT(typeof(EditBox)),
        _GT(typeof(CustomToggle)),
        _GT(typeof(GuideMask)),
        _GT(typeof(SysInfoLayer)),

        // -- avatar logic --
        _GT(typeof(LookatCameraController)),
        _GT(typeof(AvatarUtil)),
        _GT(typeof(JoystickLogic)),
        _GT(typeof(uFacadeUtility)),
        _GT(typeof(MonoLoader)),
        _GT(typeof(ShakeCameraType)),       

        // -- logic manager --
        _GT(typeof(SceneLoader)),
        _GT(typeof(NativeManager)),
        _GT(typeof(Net)),
        _GT(typeof(GameUpdater)),
        _GT(typeof(EffectController)),
        _GT(typeof(StrFiltermanger)),
        _GT(typeof(AudioManager)),

        // -- base --
        _GT(typeof(Util)),
        _GT(typeof(AppConst)),
        _GT(typeof(TableConstant)),
        _GT(typeof(CircleTrigger)),
        _GT(typeof(RectTrigger)),
        _GT(typeof(AreaTriggerBase)),
        _GT(typeof(GameResType)),
    };

    // 动态载入的列表，添加到lua package.preload，第一次访问才会加载
    public static List<Type> dynamicList = new List<Type>()
    {
        typeof(MeshRenderer),
#if !UNITY_5_4_OR_NEWER
        //typeof(ParticleEmitter),
        //typeof(ParticleRenderer),
        //typeof(ParticleAnimator),
#endif

        //typeof(BoxCollider),
        //typeof(MeshCollider),
        //typeof(SphereCollider),
        //typeof(CharacterController),
        //typeof(CapsuleCollider),

        typeof(Animation),
        typeof(AnimationClip),
        typeof(AnimationState),

        typeof(BlendWeights),
        typeof(RenderTexture),
        //typeof(Rigidbody),
    };

    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {
        
    };

    public static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    public static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }    
}
