using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using LuaInterface;
using DG.Tweening;
public class UIWrapper : MonoLoader, IPointerDownHandler, IPointerClickHandler, IPointerUpHandler
{
    //算是一个控件，存储私有数据的地方
    private Dictionary<object, object> userData = new Dictionary<object, object>();

    public object GetUserData(object key) {
        if (userData.ContainsKey(key)) {
            object value = userData[key];
            return value;
        }
        return null;
    }

    public void SetUserData(object key,object value) {
        userData[key] = value;
    }

    public void RemoveUserData(object key)
    {
        if (userData.ContainsKey(key))
        {
            userData.Remove(key);
        }
    }
    
    private float deltaTime = 0;
    void Update()
    {
        if (isPressed)
        {
            float duration = Time.realtimeSinceStartup - pressedTime;
            if (duration > 0.5f)
            {
                deltaTime += Time.deltaTime;
                if (deltaTime > 0.2f && onButtonLongPressed != null)
                {
                    deltaTime = 0;
                    onButtonLongPressed(duration);
                }
            }
        }
    }
    public Material material
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return null;
            return image.material;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            image.material = value;
        }
    }




    #region EventTrigger事件

    public void CheckET()
    {
        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        if (et == null)
        {
            this.gameObject.AddComponent<UIEventTrigger>();
        }
    }

    public void RemoveEventTriggers()
    {
        EventTrigger[] ets = this.GetComponents<EventTrigger>();
        foreach(EventTrigger et in ets)
        {
            GameObject.Destroy(et);
        }
    }



    public void BindETBeginDrag(Action<GameObject> onBeginDrag)
    {
        if (onBeginDrag == null)
            return;

        CheckET();

        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindBeginDrag(onBeginDrag);
    }

    public void BindETEndDrag(Action<GameObject> onEndDrag)
    {
        if (onEndDrag == null)
            return;

        CheckET();

        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindEndDrag(onEndDrag);
    }

    public void BindETDrag(Action<GameObject, Vector2> onDrag)
    {
        if (onDrag == null)
            return;

        CheckET();

        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindDrag(onDrag);
    }

    public void BindETButtonDown(Action<GameObject,int> onButtonDown)
    {
        if (onButtonDown == null)
            return;

        CheckET();

        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindButtonDown(onButtonDown);
    }


    public void BindETButtonUp(Action<GameObject> onButtonUp)
    {
        if (onButtonUp == null)
            return;

        CheckET();

        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindButtonUp(onButtonUp);
    }

    public void BindETTouchEnter(Action<GameObject> onTouchEnter)
    {
        if (onTouchEnter == null) return;
        CheckET();
        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindTouchEnter(onTouchEnter);
    }

    public void BindETTouchExit(Action<GameObject> onTouchExit)
    {
        if (onTouchExit == null) return;
        CheckET();
        UIEventTrigger et = this.GetComponent<UIEventTrigger>();
        et.BindTouchExit(onTouchExit);
    }

    #endregion

    #region 按钮


    private bool mIsSoundDontDestroyOnLoad = false;

    public bool isSoundDontDestroyOnLoad
    {
        get
        {
            return this.mIsSoundDontDestroyOnLoad;
        }

        set
        {
            this.mIsSoundDontDestroyOnLoad = value;
        }
    }

    private bool mIsClickSoundEnable = true;

    public bool isClickSoundEnable
    {
        get
        {
            return this.mIsClickSoundEnable;
        }

        set
        {
            this.mIsClickSoundEnable = value;
        }
    }

    public string mClickSoundOverride = "common_button";

    public string clickSoundOverride
    {
        get
        {
            return this.mClickSoundOverride;
        }

        set
        {
            this.mClickSoundOverride = value;
        }
    }

    private event Action<GameObject> onClick;

    public void FireButtonClick()
    {
        if (this.onClick != null)
        {
            this.onClick(this.gameObject);
        }
    }

    public void UnbindAllButtonClick()
    {
        this.onClick = null;
    }

    //只绑定一个点击事件
    public void BindButtonClick(Action<GameObject> onClick)
    {
        if (onClick == null)
            return;
        this.onClick = onClick;
    }
    
    //绑定多个点击事件
    public void BindButtonMultipleClick(Action<GameObject> onClick)
    {
        if (onClick == null)
            return;
        this.onClick -= onClick;
        this.onClick += onClick;
    }

    //只有每个UI的根节点才能绑这个事件，其他子控件你绑了也不会有反应
    private event Action<GameObject> onLostFocus;

    public void BindLostFocus(Action<GameObject> onLostFocus)
    {
        if (onLostFocus == null)
            return;
        this.onLostFocus -= onLostFocus;
        this.onLostFocus += onLostFocus;
        UIManager.Instance.RegisterLostFocus(this.gameObject);
    }

    public void SetNaiveSize() {
        Image image = GetComponent<Image>();
        image.SetNativeSize();
    }
    public void UnbindAllLostFocus()
    {
        this.onLostFocus = null;
        UIManager.Instance.RemoveLostFocus(this.gameObject);
    }
    //通过UIManager中的UI列表被调用
    public void FireLostFocus()
    {
        if (this.onLostFocus != null)
        {
            this.onLostFocus(this.gameObject);
        }
    }


    public void OnPointerClick(PointerEventData eventData)
    {
        if (NativeManager.GetInstance().shouldForbideTouch()) {
            return;
        }
        this.lastPointerEventData = eventData;

        if (this.isClickSoundEnable)
        {
            if (this.mClickSoundOverride == string.Empty)
            {
                this.mClickSoundOverride = "common_button";
            }
            AudioManager.PlaySoundFromAssetBundle(this.mClickSoundOverride, this.mIsSoundDontDestroyOnLoad, AudioManager.SoundMute);
        }

        UIManager.Instance.FireLostFocusEvent(eventData.pointerEnter);
        FireButtonClick();
    }

    public void SimulateButtonClick(string state)
    {
        Button btn = this.GetComponent<Button>();
        if (btn == null)
            return;
        Animator animator = btn.animator;
        if (animator == null)
            return;
        animator.SetTrigger(state);
    }

    public void ClickButton()
    {
        Button btn = this.GetComponent<Button>();
        if (btn != null)
        {
            btn.onClick.Invoke();
        }
    }


    private event Action<GameObject> onButtonDown;

    private void FireButtonDown()
    {
        if (this.onButtonDown != null)
        {
            this.onButtonDown(this.gameObject);
        }
    }

    private PointerEventData lastPointerEventData = null;

    public Vector2 pointer_position
    {
        get
        {
            if (lastPointerEventData == null)
                return Vector2.zero;
            return lastPointerEventData.position;
        }
    }

    public Vector2 pointer_press_position
    {
        get
        {
            if (lastPointerEventData == null)
                return Vector2.zero;
            return lastPointerEventData.pressPosition;
        }
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        this.lastPointerEventData = eventData;

        FireButtonDown();
        isPressed = true;
        deltaTime = 0;
        pressedTime = Time.realtimeSinceStartup;
    }

    public void BindButtonDown(Action<GameObject> onButtonDown)
    {
        if (onButtonDown == null)
            return;
        this.onButtonDown += onButtonDown;
    }


    private event Action<GameObject> onButtonUp;

    private void FireButtonUp()
    {
        if (this.onButtonUp != null)
        {
            this.onButtonUp(this.gameObject);
        }
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        this.lastPointerEventData = eventData;

        FireButtonUp();
        isPressed = false;
    }

    public void BindButtonUp(Action<GameObject> onButtonUp)
    {
        if (onButtonUp == null)
            return;
        this.onButtonUp += onButtonUp;
    }

    private event Action<float> onButtonLongPressed;
    private float pressedTime;
    private bool isPressed;
    public void BindButtonLongPressed(Action<float> onButtonLongPressed)
    {
        this.onButtonLongPressed = onButtonLongPressed;
    }
    public bool buttonEnable
    {
        get
        {
            Button button = this.GetComponent<Button>();
            if (button == null)
                return false;
            return button.interactable;
        }

        set
        {
            Button button = this.GetComponent<Button>();
            if (button != null)
            {
                button.interactable = value;
            }
        }
    }

    public bool buttonImageEnable
    {
        set
        {
            Button button = this.GetComponent<Button>();
            if (button != null)
            {
                Image ima = button.GetComponent<Image>();
                if (ima != null)
                {
                    ima.enabled = value;
                }
            }
        }
    }

    #endregion

    #region 检索


    public UIWrapper Parent
    {
        get
        {
            if (this.transform.parent == null)
                return null;
            Transform parent = this.transform.parent;
            UIWrapper wrapper = parent.GetComponent<UIWrapper>();
            if (wrapper == null)
                wrapper = parent.gameObject.AddComponent<UIWrapper>();
            return wrapper;
        }
    }

    public UIWrapper this[string name]
    {
        get
        {
            Transform t = this.transform.FindChild(name);
            if (t == null)
            {
                //TTLoger.LogError(string.Format("[错误] 节点<{0}>不存在子节点<{1}>", this.transform.name, name));
                return null;
            }
            UIWrapper wrapper = t.GetComponent<UIWrapper>();
            if (wrapper == null)
            {
                wrapper = t.gameObject.AddComponent<UIWrapper>();
            }
            return wrapper;
        }
    }

    public UIWrapper this[int index]
    {
        get
        {
            Transform t = this.transform.GetChild(index);
            if (t == null)
            {
                //TTLoger.LogError(string.Format("[错误] 节点<{0}>不存在子节点<{1}>", this.transform.name, name));
                return null;
            }
            UIWrapper wrapper = t.GetComponent<UIWrapper>();
            if (wrapper == null)
            {
                wrapper = t.gameObject.AddComponent<UIWrapper>();
            }
            return wrapper;
        }
    }

    public UIWrapper GOI(int index)
    {
        return this[index];
    }


    public UIWrapper GO(String path) {
        //String[] arr = path.Split('.');
        //UIWrapper obj = this;
        //for (int i = 0; i < arr.Length; i++) {
        //    obj = obj[arr[i]];
        //}
        Transform trans = GOT(path);
        if (trans != null)
        {
            GameObject obj = trans.gameObject;
            UIWrapper wrapper = obj.GetComponent<UIWrapper>();
            if (wrapper == null)
            {
                wrapper = obj.gameObject.AddComponent<UIWrapper>();
            }
            return wrapper;
        }
        return null;
    }

    public UnityEngine.Object LoadAsset(string name) {
        return AssetLoader.Load(GameResType.UI, name);
    }

    public Transform GOT(String path) {
        String[] arr = path.Split('.');
        Transform obj = this.transform;
        for (int i = 0; i < arr.Length; i++) {
            Transform t = obj.FindChild(arr[i]);
            if (t == null) {
                return null;
            }
            obj = t;
        }

        return obj;
    }




    #endregion

    #region 子节点

    public void Clean()
    {
        List<GameObject> children = new List<GameObject>();
        for (int i = 0; i < this.transform.childCount; ++i)
        {
            children.Add(this.transform.GetChild(i).gameObject);
        }

        this.transform.DetachChildren();
        foreach (GameObject child in children)
        {
            GameObject.Destroy(child);
        }
    }

    public int childCount
    {
        get
        {
            return this.transform.childCount;
        }
    }

    #endregion

    #region 显示/隐藏

    public bool IsShow()
    {
        return this.gameObject.activeSelf;
    }

    public void SetShow(bool show)
    {
        if (show)
        {
            if (!IsShow())
            {
                Show();
            }
        }
        else
        {
            if (IsShow())
            {
                Hide();
            }
        }
    }

    public virtual void Show()
    {
        this.gameObject.SetActive(true);
    }

    public virtual void Hide()
    {

        this.gameObject.SetActive(false);
    }


    public void ShowChild(string name)
    {
        UIWrapper child = this[name];
        if (child != null)
        {
            child.Show();
        }
    }

    public void HideChild(string name)
    {
        UIWrapper child = this[name];
        if (child != null)
        {
            child.Hide();
        }
    }

    public bool IsChildShow()
    {
        UIWrapper child = this[name];
        if (child == null)
            return false;
        return child.IsShow();
    }


    public void SetChildShow(bool show)
    {
        UIWrapper child = this[name];
        if (child != null)
        {
            child.SetShow(show);
        }
    }

    public void AddChild(GameObject child) {
        child.transform.SetParent(this.gameObject.transform);
    }

    public void DOFade(float from,float to,float time)
    {
        CanvasGroup cavansGroup = this.GetComponent<CanvasGroup>();
        if (cavansGroup == null)
        {
            cavansGroup = this.gameObject.AddComponent<CanvasGroup>();
        }
        cavansGroup.alpha = from;
        cavansGroup.DOFade(to, time);
    }

    public void SetAlpha(float alpha)
    {
        CanvasGroup cavansGroup = this.GetComponent<CanvasGroup>();
        if (cavansGroup == null)
        {
            cavansGroup = this.gameObject.AddComponent<CanvasGroup>();
        }
        cavansGroup.alpha = alpha;
    }

    #endregion

    #region 文本

    public float textWidth
    {
        get
        {
            Text text = this.GetComponent<Text>();
            if (text == null)
                return 0;
            return text.preferredWidth;
        }
    }
    public string text
    {
        get
        {
            Text text = this.GetComponent<Text>();
            if (text == null)
                return string.Empty;
            return text.text;
        }

        set
        {
            Text text = this.GetComponent<Text>();
            if (text != null)
            {
                text.text = value;
            }
        }
    }

    public string font 
    {
        get 
        {
            Text text = this.GetComponent<Text>();
            if (text == null)
                return string.Empty;
            return text.font.name;
        }
        set
        { 
            Text text = this.GetComponent<Text>();
            if (text == null)
                return;
            Font font = AssetLoader.Load(GameResType.Font, value, typeof(Font)) as Font;
            text.font = font;
        }
    }

    public string inputText
    {
        get
        {
            InputField iptFiled = this.GetComponent<InputField>();
            if (iptFiled == null)
                return string.Empty;
            return iptFiled.text;

        }
        set
        {
            InputField iptFiled = this.GetComponent<InputField>();
            if (iptFiled != null) {
                iptFiled.text = value;
            }
        }
    }

    public int inputIndex 
    {
        get {
            InputField iptFiled = this.GetComponent<InputField>();
            if (iptFiled == null)
                return 0;
            return iptFiled.caretPosition;
        }
    }

    public void MoveTextEnd(bool shift)
    {
        InputField iptFiled = this.GetComponent<InputField>();
        if (iptFiled != null)
        {
            iptFiled.MoveTextEnd(false);
        }
    }

    public void BindInputFiledValueChanged(UnityAction<string, int> onValueChanged)
    {
        if (onValueChanged == null)
            return;

        InputField input = this.GetComponent<InputField>();

        if (input == null)
            return;

#if UNITY_EDITOR
        input.onValueChanged.AddListener((text) => {
            int caret = input.caretPosition;
            onValueChanged(text, caret == 0 ? text.Length : caret);//光标为零，说明已经失去焦点，是从聊天表情那里添加的，默认加到结尾
        });
#else
        EditBox edb = this.GetComponent<EditBox>();
        if (edb != null) {
            edb.onTextChange = onValueChanged;
        }
#endif
    
    }



    public void SetTextColor(int r, int g, int b, int a)
    {
        this.textColor = new Color32((byte)r, (byte)g, (byte)b, (byte)a);
    }


    public Color textColor
    {
        get
        {
            Text text = this.GetComponent<Text>();
            if (text == null)
                return Color.white;
            return text.color;
        }

        set
        {
            Text text = this.GetComponent<Text>();
            if (text == null)
                return;
            text.color = value;
        }
    }

    #endregion

    #region 图片

    Image image;



    public string sprite
    {
        set
        {
            if (image == null)
            {
                image = this.GetComponent<Image>();
            }

            if (image == null)
            {
                //Debug.LogError(string.Format("=================== [Error] image is null: {0}", value));
                return;
            }

            if(string.IsNullOrEmpty(value))
            {
                image.sprite = null;
            }
            else
            {
#if UNITY_EDITOR
                if(AppConst.DevelopMode)
                {
                    Sprite sp;
                    if (GameTable.CheckRes(GameResType.Icon, value))
                    {
                        sp = LoadSprite(GameResType.Icon, value);
                    }
                    else {
                        sp = LoadSprite(GameResType.Sprite, value);
                    }
                    image.sprite = sp;
                    image.material = null;
                }
                else
                {
#endif
                    if (GameTable.CheckRes(GameResType.Icon, value))
                    {
                        image.sprite = LoadSprite(GameResType.Icon, value);
                        image.material = null;
                        return;
                    }
                    Atlas atlas = LoadAtlas(value);
                    if (atlas == null)
                    {
                        Debug.LogError(string.Format("=================== [Error] atlas is null: {0}", value));
                        return;
                    }
                    image.material = atlas.material;
                    image.sprite = atlas[value];
                }
#if UNITY_EDITOR
            }
#endif
        }
    }

    public int imageType
    {
        set
        {
            if (image == null)
            {
                image = this.GetComponent<Image>();
            }
            else
            {
                image.type = (Image.Type)value;
            }
        }
    }

    public Sprite LoadSprite(GameResType type, string spriteName)
    {
        return this.AssetLoader.Load(type, spriteName, typeof(Sprite)) as Sprite;

    }

    public Sprite Sprite {
        get {
            if (image == null)
            {
                image = this.GetComponent<Image>();
            }
            return image.sprite;
        }
        set {
            if (image == null)
            {
                image = this.GetComponent<Image>();
            }
            image.sprite = value;
        }
    }

    public Atlas LoadAtlas(string spriteName) {
       return AssetLoader.LoadAtlas(spriteName);
    }

    public void LoadAtlasAsync(string spriteName, Action<Atlas> callback)
    {
        AssetLoader.LoadAtlasAsync(spriteName, callback);
    }
    public Texture materialTexture
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return null;
            return image.material.mainTexture;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            image.material.mainTexture = value;
        }
    }

    public Image.FillMethod fillMethod
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return Image.FillMethod.Horizontal;
            return image.fillMethod;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            if (image != null)
            {
                image.fillMethod = value;
            }
        }
    }

    public bool fillClockwise
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return false;
            return image.fillClockwise;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            if (image != null)
            {
                image.fillClockwise = value;
            }
        }
    }


    public float fillAmount
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return 0;
            return image.fillAmount;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            if (image != null)
            {
                image.fillAmount = value;
            }
        }
    }

    public Color imageColor
    {
        get
        {
            Image image = this.GetComponent<Image>();
            if (image == null)
                return Color.white;
            return image.color;
        }

        set
        {
            Image image = this.GetComponent<Image>();
            if (image != null)
            {
                image.color = value;
            }
        }
    }

    public Color color
    {
        get
        {
            Graphic graphic = this.GetComponent<Graphic>();
            if (graphic == null)
                return Color.white;
            return graphic.color;
        }

        set
        {
            Graphic graphic = this.GetComponent<Graphic>();
            if (graphic != null)
            {
                graphic.color = value;
            }
        }
    }

    public void SetBlackWhiteMode(bool gray) 
    {
        Util.SetGray(gameObject, gray, false); 
    }

    //这个使用MW_RTT中的_BlackRate参数来控制图片是否压黑
    public void SetShadow(bool b)
    {
        Image image = this.GetComponent<Image>();
        if (image != null)
        {
            if (image.material != null) 
            {
                if (b == true)
                {
                    image.material.SetFloat("_BlackRate", 0.7f);
                }
                else
                {
                    image.material.SetFloat("_BlackRate", 0f);
                }                       
            }
        }
    }
    #endregion

    #region 关闭

    public void Close()
    {
        GameObject.Destroy(this.gameObject);
    }

    public void DelayClose(float time)
    {
        GameObject.Destroy(this.gameObject, time);
    }

    #endregion

    #region 跟随

    /// <summary>
    /// 跟随目标
    /// </summary>
    /// <param name="target"></param>
    public void FollowTarget(Transform target)
    {
        if (target == null)
            return;
        UIFollow follow = this.GetComponent<UIFollow>();
        if (follow == null)
        {
            follow = this.gameObject.AddComponent<UIFollow>();
        }
        follow.target = target;
        follow.Follow();
    }

    #endregion

    #region 层级


    public void AddLayerSortingOrder(int sortingOrder)
    {
        this.layerSortingOrder = this.layerSortingOrder + sortingOrder;
    }

    public int layerSortingOrder
    {
        get
        {
            UILayer layer = this.GetComponent<UILayer>();
            if (layer == null)
                return 0;
            return layer.sortingOrder;
        }

        set
        {
            UILayer layer = this.GetComponent<UILayer>();
            if (layer != null)
            {
                layer.sortingOrder = value;
            }
        }

    }

    /// <summary>
    /// 排序顺序
    /// </summary>
    public int sortingOrder
    {
        get
        {
            Canvas canvas = this.GetComponent<Canvas>();
            if (canvas == null)
                return 0;
            return canvas.sortingOrder;
        }

        set
        {
            Canvas canvas = this.GetComponent<Canvas>();
            if (canvas != null)
            {
                canvas.sortingOrder = value;
            }
        }
    }

    #endregion

    #region Toggle

    private event Action<bool> onToggleValueChanged;

    public bool ToggleValue
    {
        get
        {
            Toggle toggle = this.GetComponent<Toggle>();
            if (toggle == null)
                return false;
            return toggle.isOn;
        }

        set
        {
            Toggle toggle = this.GetComponent<Toggle>();
            if (toggle != null)
            {
                toggle.isOn = value;
            }
        }
    }

    public void FireToggleValueChanged(bool value) {
        if (onToggleValueChanged != null) {
            onToggleValueChanged(value);
        }
    }

    public void BindToggleValueChanged(Action<bool> onToggleValueChanged) {
        if (onToggleValueChanged == null)
            return;
        Toggle toggle = this.GetComponent<Toggle>();
        if (toggle == null)
            return;
        this.onToggleValueChanged += onToggleValueChanged;
        toggle.onValueChanged.AddListener((value) =>
        {
            FireToggleValueChanged(value);
        });
    }

    #endregion

    #region Scrollview

    public void BindScrollRectValueChanged(UnityAction<Vector2> onValueChanged)
    {
        if (onValueChanged == null)
            return;

        ScrollRect sr = this.GetComponent<ScrollRect>();
        if (sr == null)
            return;

        sr.onValueChanged.AddListener(onValueChanged);
    }

    public bool Horizontal
    {
        get
        {
            ScrollRect sr = this.GetComponent<ScrollRect>();
            if (sr != null)
            {
                return sr.horizontal;
            }
            return false;
        }

        set
        {
            ScrollRect sr = this.GetComponent<ScrollRect>();
            if (sr != null)
            {
                sr.horizontal = value;
            }
        }
    }


    public bool Vertical
    {
        get
        {
            ScrollRect sr = this.GetComponent<ScrollRect>();
            if (sr != null)
            {
                return sr.vertical;
            }
            return false;
        }

        set
        {
            ScrollRect sr = this.GetComponent<ScrollRect>();
            if (sr != null)
            {
                sr.vertical = value;
            }
        }
    }

    public int itemCount
    {
        get
        {
            return this.transform.childCount;
        }
    }

    private GridLayoutGroup AddGridLayoutGroup()
    {
        GridLayoutGroup glg = this.gameObject.AddComponent<GridLayoutGroup>();
        glg.childAlignment = TextAnchor.MiddleCenter;
        glg.constraint = GridLayoutGroup.Constraint.Flexible;
        glg.startCorner = GridLayoutGroup.Corner.UpperLeft;
        glg.startAxis = GridLayoutGroup.Axis.Horizontal;
        return glg;
    }


    public Vector2 cellSpacing
    {
        get
        {
            GridLayoutGroup glg = this.GetComponent<GridLayoutGroup>();
            if (glg == null)
                glg = AddGridLayoutGroup();
            return glg.spacing;
        }

        set
        {
            GridLayoutGroup glg = this.GetComponent<GridLayoutGroup>();
            if (glg != null)
            {
                glg.spacing = value;
            }
        }
    }


    public Vector2 cellSize
    {
        get
        {
            GridLayoutGroup glg = this.GetComponent<GridLayoutGroup>();
            if (glg == null)
                glg = AddGridLayoutGroup();
            return glg.cellSize;
        }

        set
        {
            GridLayoutGroup glg = this.GetComponent<GridLayoutGroup>();
            if (glg != null)
            {
                glg.cellSize = value;
            }
        }
    }


    /// <summary>
    /// 播放界面特效
    /// </summary>
    /// <param name="ui"></param>
    /// <param name="name"></param>
    /// <param name="callback"></param>
    /// 

    //新加入的和 已有的 之间的存在关系
    public enum UIEffectAddType
    {
        Keep,     //保持原有
        Replace,  //替换
        Overlying,//叠加 

    }
    public void PlayUIEffect(GameObject rootUI, string name)
    {
        PlayUIEffect(rootUI, name, 5.0f);
    }

    public void PlayUIEffectForever(GameObject rootUI, string name)
    {
        PlayUIEffect(rootUI, name, 1.0f, null, true, true);
    }


    public void PlayUIEffect(GameObject rootUI, string name, float elapsedTime)
    {
        PlayUIEffect(rootUI, name, elapsedTime, null, true, false);
    }


    public void PlayUIEffect(GameObject rootUI, string name, float elapsedTime, LuaFunction callback, bool isAbove)
    {
        PlayUIEffect(rootUI, name, elapsedTime, callback, isAbove, false);
    }

    public void PlayUIEffect(GameObject rootUI, string name, float elapsedTime, LuaFunction callback, bool isAbove, bool isForever, UIEffectAddType addType = UIEffectAddType.Keep)
    {
        switch(addType)
        {
            case UIEffectAddType.Keep:
                {
                    Transform child = this.transform.FindChild(name + "(Clone)");
                    if (child != null)
                    {
                        return;
                    }
                }break;
            case UIEffectAddType.Replace:
                {
                    StopUIEffect(name);
                }break;
            case UIEffectAddType.Overlying:
                {
                    
                }break;
            default:
                return;
        }

        AssetLoader loader = AssetBundleManager.CreateLoader();
        loader.LoadAsync(GameResType.Effect, name, (asset) =>
        {
            GameObject effect = GameObject.Instantiate(asset) as GameObject;
            effect.transform.SetParent(this.transform);
            effect.transform.localPosition = Vector3.zero;
            effect.transform.localEulerAngles = Vector3.zero;
            effect.transform.localScale = Vector3.one;
            EffectController ec = effect.AddComponent<EffectController>();
            ec.elapsedTime = elapsedTime;
            ec.forever = isForever;
            UILayer layer = effect.gameObject.AddComponent<UILayer>();
            layer.type = UILayerType.UIEffect;
            layer.canvas = rootUI.GetComponent<Canvas>();
            layer.AssetLoader = loader;
            if (layer.canvas != null)
            {
                layer.sortingOrder = layer.canvas.sortingOrder + (isAbove ? 1 : -1);
                layer.AdjustCanvasSortingOrder();
                
            }

            if (callback != null)
            {
                callback.Call(effect);
                callback.Dispose();
            }
        });
    }

    public void PlayUIEffect(GameObject rootUI, GameObject effectPrefab, float elapsedTime, LuaFunction callback, bool isAbove, bool isForever, UIEffectAddType addType = UIEffectAddType.Keep)
    {
        if (effectPrefab == null)
        {
            return;
        } 
        switch (addType)
        {
            case UIEffectAddType.Keep:
                {
                    Transform child = this.transform.FindChild(effectPrefab.transform.name + "(Clone)");
                    if (child)
                    {
                        return;
                    }
                } break;
            case UIEffectAddType.Replace:
                {                        
                   StopUIEffect(effectPrefab.transform.name);
                } break;
            case UIEffectAddType.Overlying:
                {

                } break;
            default:
                return;
        }
        GameObject effect = GameObject.Instantiate(effectPrefab) as GameObject;
        effect.transform.SetParent(this.transform);
        effect.transform.localPosition = Vector3.zero;
        effect.transform.localEulerAngles = Vector3.zero;
        effect.transform.localScale = Vector3.one;
        effect.SetActive(true);
        EffectController ec = effect.GetComponent<EffectController>();
        if (ec == null)
        {
            ec = effect.AddComponent<EffectController>();
        }
        ec.elapsedTime = elapsedTime;
        ec.forever = isForever;
        UILayer layer = effect.gameObject.GetComponent<UILayer>();
        if (layer == null)
        {
            layer = effect.gameObject.AddComponent<UILayer>();
        }
        layer.type = UILayerType.UIEffect;
        layer.canvas = rootUI.GetComponent<Canvas>();
        if (layer.canvas != null)
        {
            layer.sortingOrder = layer.canvas.sortingOrder + (isAbove ? 1 : -1);
            layer.AdjustCanvasSortingOrder();
        }

        if (callback != null)
        {
            callback.Call(effect);
            callback.Dispose();
        }
    }

    public GameObject LoadUIEffect(GameObject rootUI, string name, bool isAbove, bool dontDestory)
    {
        AssetLoader loader = dontDestory ? AssetBundleManager.godLoader : AssetBundleManager.CreateLoader();
        UnityEngine.Object asset = loader.Load(GameResType.Effect, name);
        GameObject effect = GameObject.Instantiate(asset) as GameObject;

        UILayer layer = effect.gameObject.AddComponent<UILayer>();
        layer.type = UILayerType.UIEffect;
        layer.canvas = rootUI.GetComponent<Canvas>();
        if(!dontDestory)
            layer.AssetLoader = loader;
        if (layer.canvas != null)
        {
            layer.sortingOrder = layer.canvas.sortingOrder + (isAbove ? 1 : -1);
        }

        return effect;
    }


    public void StopUIEffect(string name)
    {
        name += "(Clone)";    
        for (int i = 0; i < this.transform.childCount; ++i)
        {
            GameObject child = this.transform.GetChild(i).gameObject;
            if (child.name != name)
                continue;
            UILayer layer = child.GetComponent<UILayer>();
            if (layer == null)
                continue;
            if (layer.type != UILayerType.UIEffect)
                continue;
            GameObject.DestroyImmediate(layer.gameObject);
        }
    }

    /// <summary>
    /// 停止所有界面特效,要把回调给清掉
    /// </summary>
    public void StopAllUIEffects()
    {
        List<UILayer> layers = new List<UILayer>();
        for(int i = 0; i < this.transform.childCount; ++i)
        {
            GameObject child = this.transform.GetChild(i).gameObject;
            UILayer layer = child.GetComponent<UILayer>();
            EffectController effectCtrl = child.GetComponent<EffectController>();
            if (layer == null)
                continue;
            if (layer.type != UILayerType.UIEffect)
                continue;
            effectCtrl.onDestroy = null;
            layers.Add(layer);
        }
        foreach(UILayer layer in layers)
        {
            GameObject.Destroy(layer.gameObject);
        }
    }

    #endregion

    #region 移动


    public float alpha
    {
        get
        {
            Graphic graphic = this.GetComponent<Graphic>();
            if (graphic == null)
                return 0.0f;
            return graphic.color.a;
        }

        set
        {
            Graphic graphic = this.GetComponent<Graphic>();
            if (graphic != null)
            {
                Color color = graphic.color;
                color.a = Mathf.Clamp(value, 0, 1);
                graphic.color = color;
            }
        }
    }

    public void OnFadeOutFinished(object o)
    {
        if (o == null)
            return;
        LuaFunction callback = (LuaFunction)o;
        callback.Call(this);
    }

    public void setAlpha(float newAlpha)
    {
        this.alpha = newAlpha;

        if (userData.ContainsKey("setAlpha"))
        {
            object value = userData["setAlpha"];
            if (value is LuaFunction)
            {
                LuaFunction func = (LuaFunction)value;
                func.Call(this);
            }
        }
    }


    public void FadeOut(float flyTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);

        Hashtable args = new Hashtable();
        args.Add("from", 1.0f);
        args.Add("to", 0.0f);
        args.Add("time", flyTime);
        args.Add("delay", 0.0f);
        args.Add("onupdate", "setAlpha");
        args.Add("oncomplete", "OnFadeOutFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);
        iTween.ValueTo(go, args);
    }

    public void DelayFadeOut(float flyTime, float delayTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);
        this.alpha = 0;

        Hashtable args = new Hashtable();
        args.Add("from", 1.0f);
        args.Add("to", 0.0f);
        args.Add("time", flyTime);
        args.Add("delay", delayTime);
        args.Add("onupdate", "setAlpha");
        args.Add("oncomplete", "OnFadeInFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);
        iTween.ValueTo(go, args);
    }

    public void OnFadeInFinished(object o)
    {
        if (o == null)
            return;
        LuaFunction callback = (LuaFunction)o;
        callback.Call(this);
    }

    public void OnMoveFadeInFinished(object o)
    {
        if (o == null)
            return;
        LuaFunction callback = (LuaFunction)o;
        callback.Call(this);
    }

    public void FadeIn(float flyTime, LuaFunction callback)
    {
        DelayFadeIn(flyTime, 0.0f, callback);
    }

    public void DelayFadeIn(float flyTime, float delayTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);
        this.alpha = 0;

        Hashtable args = new Hashtable();
        args.Add("from", 0.0f);
        args.Add("to", 1.0f);
        args.Add("time", flyTime);
        args.Add("delay", delayTime);
        args.Add("onupdate", "setAlpha");
        args.Add("oncomplete", "OnFadeInFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);
        iTween.ValueTo(go, args);
    }

    public void DelayMoveFadeIn(Vector3 position, float flyTime, float delayTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);
        this.alpha = 0;

        Hashtable args = new Hashtable();
        args.Add("position", position);
        args.Add("easetype", "linear");
        args.Add("time", flyTime);
        args.Add("delay", delayTime);
        args.Add("oncomplete", "OnMoveFadeOutFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);

        //iTween.FadeTo(go, 0f, distance /(100 * velocity));
        iTween.MoveTo(go, args);

        iTween.ValueTo(go, iTween.Hash(
            "from", 0.0f, "to", 1.0f,
            "time", flyTime,
            "delay", delayTime,
            "onupdate", "setAlpha"));
    }


    public void OnMoveFinished(object o)
    {
        if (o == null)
            return;
        LuaFunction callback = (LuaFunction)o;
        callback.Call(this);
    }

    /// <summary>
    /// 移动
    /// </summary>
    /// <param name="position"></param>
    /// <param name="flyTime"></param>
    public void MoveTo(Vector3 position, float flyTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        Hashtable args = new Hashtable();
        args.Add("position", position);
        args.Add("easetype", "linear");
        args.Add("time", flyTime);
        args.Add("oncomplete", "OnMoveFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);
        iTween.MoveTo(go, args);
    }


    /// <summary>
    /// 淡入
    /// </summary>
    /// <param name="position"></param>
    /// <param name="flyTime"></param>
    /// <param name="delayTime"></param>
    public void MoveFadeIn(Vector3 position, float flyTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);

        Hashtable args = new Hashtable();
        args.Add("position", position);
        args.Add("easetype", "linear");
        args.Add("time", flyTime);
        args.Add("oncomplete", "OnMoveFadeInFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);

        //iTween.FadeTo(go, 0f, distance /(100 * velocity));
        iTween.MoveTo(go, args);
        iTween.ValueTo(go, iTween.Hash(
            "from", 0.0f, "to", 1.0f,
            "time", flyTime,
            "delay", 0.0f,
            "onupdate", "setAlpha"));
    }


    public void OnMoveFadeOutFinished(object o)
    {
        if (o == null)
            return;
        LuaFunction callback = (LuaFunction)o;
        callback.Call(this);
    }

    /// <summary>
    /// 淡出
    /// </summary>
    /// <param name="position"></param>
    /// <param name="flyTime"></param>
    /// <param name="delayTime"></param>
    public void MoveFadeOut(Vector3 position, float flyTime, LuaFunction callback)
    {
        GameObject go = this.gameObject;
        go.SetActive(true);

        Hashtable args = new Hashtable();
        args.Add("position", position);
        args.Add("easetype", "linear");
        args.Add("time", flyTime);
        args.Add("oncomplete", "OnMoveFadeOutFinished");
        args.Add("oncompleteparams", callback);
        args.Add("oncompletetarget", go);

        //iTween.FadeTo(go, 0f, distance /(100 * velocity));
        iTween.MoveTo(go, args);
        iTween.ValueTo(go, iTween.Hash(
            "from", 1.0f, "to", 0.0f,
            "time", flyTime,
            "delay", 0.0f,
            "onupdate", "setAlpha"));
    }

    public void StopAllITweens()
    {
        iTween.Stop(this.gameObject);
    }


    #endregion

    #region Slider

    private event Action<float> onSliderValueChanged;


    public float SliderValue
    {
        get
        {
            Slider slider = this.GetComponent<Slider>();
            if (slider == null)
                return 0.0f;
            return slider.value;
        }

        set
        {
            Slider slider = this.GetComponent<Slider>();
            if (slider != null)
            {
                slider.value = value;
            }
        }
    }

    public void FireSliderValueChanged(float value) {

        if (onSliderValueChanged != null)
        {
            onSliderValueChanged(value);
        }
    }

    public void BindSliderValueChanged(Action<float> onSliderValueChanged) {
        if (onSliderValueChanged == null)
            return;
        Slider slider = this.GetComponent<Slider>();
        if (slider == null)
            return;
        this.onSliderValueChanged = onSliderValueChanged;
        slider.onValueChanged.AddListener((value) =>
        {
            FireSliderValueChanged(value);
        });
    }

    #endregion

    #region iTweenCallBack

    public event Action<object> tweenCallBack;
    
    public void OnTweenComplete(object go)
    {
        if (tweenCallBack != null) {
            Action<object> act = tweenCallBack;
            tweenCallBack = null;
            act(go);            
        }
    }

    #endregion
 


    #region RectTransform


    public Vector2 rectSize
    {
        get
        {
            RectTransform rect = this.GetComponent<RectTransform>();
            if (rect == null)
                return Vector2.zero;
            return rect.rect.size;
        }
    }


    public Vector3 scale
    {
        get
        {
            RectTransform rect = this.GetComponent<RectTransform>();
            if (rect == null)
                return Vector3.zero;
            return rect.localScale;
        }

        set
        {
            RectTransform rect = this.GetComponent<RectTransform>();
            if (rect != null)
            {
                rect.localScale = value;
            }
        }
    }

    #endregion

    #region 用于引导文字显示效果


    public override void OnDestroy()
    {
        base.OnDestroy();
        this.sprite = null;
        StopAllCoroutines();
    }

    private bool mIsDoingCrack = false;

    public bool IsDoingCrack()
    {
        return this.mIsDoingCrack;
    }

    public void DoCrack(string message, float crackTime, float stretchTime, float keepTime, float fadeOutTime, LuaFunction callback)
    {
        StartCoroutine(DoCrackImpl(message, crackTime, stretchTime, keepTime, fadeOutTime, callback));
    }

    private IEnumerator DoCrackImpl(string message, float crackTime, float stretchTime, float keepTime, float fadeOutTime, LuaFunction callback)
    {
        if (mIsDoingCrack)
        {
            yield break;
        }

        mIsDoingCrack = true;

        UIWrapper text = this["_Text"];
        UIWrapper line = this["_Line"];
        // 文本初始化
        text.text = message;
        text.alpha = 1;
        text.scale = new Vector3(1, 0, 1);
        // 线条初始化
        line.fillAmount = 0;
        line.alpha = 1;

        // 裂开一条缝隙
        float startTime = Time.realtimeSinceStartup;
		while(true)
        {
            float now = Time.realtimeSinceStartup;
			if (now >= startTime + crackTime)
            {
				line.fillAmount = 1.0f;
				break;
            }
			else
            {
			    float percent = 0.08f + (now - startTime) / crackTime * (0.92f - 0.08f);
			    line.fillAmount = percent;
                yield return null;
            }
        }


		// 展开文字
        startTime = Time.realtimeSinceStartup;
		while(true)
        {
            float now = Time.realtimeSinceStartup;
            if (now >= startTime + stretchTime)
            {
				text.scale = Vector3.one;
				break;
            }
            else
            {
			    Vector3 scale = text.scale;
			    scale.y = (now - startTime) / stretchTime;
                text.scale = scale;
                yield return null;
            }
		}

		// 停留文字
        startTime = Time.realtimeSinceStartup;
		while(true)
        {
            float now = Time.realtimeSinceStartup;
            if (now >= startTime + keepTime)
            {
				break;
            }
            yield return null;
        }

		// 淡出文字
        startTime = Time.realtimeSinceStartup;
		while(true)
        {
            float now = Time.realtimeSinceStartup;
            if (now >= startTime + fadeOutTime)
            {
                line.alpha = 0;
                text.alpha = 0;
                break;
            }
			float t = 1.0f - (now - startTime) / fadeOutTime;
			line.alpha = t;
			text.alpha = t;
            yield return null;
        }

        mIsDoingCrack = false;

        if (callback != null)
        {
            callback.Call();
        }
    }

    #endregion
}
