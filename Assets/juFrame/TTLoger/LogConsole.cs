using UnityEngine;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine.EventSystems;
using System.Runtime.InteropServices;


public class LogConsole : MonoBehaviour
{
    private bool isInit = false;

    #region -------------Singleton Setting------------------

    private static LogConsole _instance;
    private static object _lock = new object();
    public static LogConsole Instance
    {
        get
        {
            if (applicationIsQuitting)
            {
                return null;
            }

#if BUILD_TYPE_WAI && !UNITY_EDITOR
            return null;
#endif

            lock (_lock)
            {
                if (_instance == null)
                {
                    if (_instance == null)
                    {
                        GameObject singleton = new GameObject();
                        _instance = singleton.AddComponent<LogConsole>();
                        singleton.name = "(singleton) " + typeof(LogConsole).ToString();

                        //singleton.hideFlags = HideFlags.HideInHierarchy;
                        _instance.Init();
                    }
                    else
                    {
                        TTLoger.Log("[Singleton] Using instance already created: " +
                            _instance.gameObject.name);
                    }
                }

                return _instance;
            }
        }
    }

    private static bool applicationIsQuitting = false;

    public void OnDestroy()
    {
        if (isInit)
        {
            applicationIsQuitting = true;
            _lock = null;
            _instance = null;
        }
        StopAsyncWriteLog();
    }

    #endregion

    public static bool IsOpen
    {
        get { return m_isOpen; }
        set
        {
            // RESET THE CURRENT SHOW TYPE WHEN OPEN AGAIN.
            Instance.currentShowMessageCustom = string.Empty;

            // RESET THE NEW SHOW INDEX.
            Instance.maxMsgCount = Instance.CaculateCurrentMaxMsgCount();
            Instance.endMsgIndex = Instance.maxMsgCount - 1;
            Instance.beginMsgIndex = Instance.FindBeginMsgIndexFromEnd();
            Instance.isNeedRefreshContent = true;
            Instance.needAutoToMax = true;

            if (value == true) {
                if (Instance.ui_root_obj == null) {
                    Instance.DrawWindow(true);
                }
                Instance.input.text = string.Empty;
#if UNITY_EDITOR
                Instance.input.ActivateInputField();
                Instance.input.Select();
#endif
            }
            Instance.ui_root_obj.SetActive(value);
            m_isOpen = value;
        }
    }

    private static bool m_isOpen = false;

    //cached previous open time
    private float preOpenTime = 0f;

    ///Cant set event system outside.

    ///Can Set Others CMD outside.
    public System.Action<LogConsole> delegateInitCMD = null;

    ///UI Element
    GameObject ui_root_obj = null;
    UnityEngine.UI.Text text_content = null;
    UnityEngine.UI.ScrollRect sr_content = null;
    UnityEngine.UI.InputField input = null;
    UnityEngine.UI.Text text_pageCount = null;

    GameObject ui_fps_root = null;
    UnityEngine.UI.Text text_fps = null;

    ///use to control refresh the label text.
    ///input a cmd\new message
    internal bool isNeedRefreshContent = true;
    static int maxLinesForDisplay = 2000;
    static int maxLinesForAsyncRecord = 20000;

    int beginMsgIndex = 0; // current show msg index begin
    int endMsgIndex = 0;   // current show msg index end
    int maxMsgCount = 1;   // current max msg count

    bool needAutoToMax = true; // when select target page less than maxPage wont follow the newest.
    bool IsEditor = false;
    string dataPath = string.Empty;

    /// <summary>
    /// whitch type of message should show
    /// NOTE: -1=all
    /// </summary>
    private int currentShowMessageType = -1;

    /// <summary>
    /// show some spec custom type of messages.
    /// NOTE:default this kinds  of type wont show in console by default.
    /// </summary>
    private string currentShowMessageCustom = string.Empty;

    //fps & memory info
    bool fpsMode; 
    FPSCounter fps;
    MemoryCounter memoryCounter;

    Dictionary<string, Func<string[], object>> _cmdTable = new Dictionary<string, Func<string[], object>>();
    Dictionary<string, string> _cmdTableDiscribes = new Dictionary<string, string>();

    #region Message Struct

    //performance optimized
    static Queue<LogMessage> _messages = new Queue<LogMessage>();
    static Dictionary<string, Queue<LogMessage>> customQueueMessages = new Dictionary<string, Queue<LogMessage>>();
    static Queue<LogMessage> FindCustomQueue(string customType)

    {
        if (string.IsNullOrEmpty(customType))
        {
            return _messages;
        }

        customType = customType.ToLower();
        Queue<LogMessage> tempQueue = null;
        if (!customQueueMessages.TryGetValue(customType, out tempQueue))
        {
            tempQueue = new Queue<LogMessage>();
            customQueueMessages[customType] = tempQueue;
        }
        return tempQueue;
    }

    static LogMessage CreateNew(object messageObject, MessageType messageType, Color displayColor, string customType)
    {
        Queue<LogMessage> tempQueue = FindCustomQueue(customType);

        if (tempQueue.Count > maxLinesForDisplay)
        {
            LogMessage msg = tempQueue.Dequeue();
            msg.Set(messageObject, messageType, displayColor, customType);
            return msg;
        }
        else
        {
            LogMessage msg = new LogMessage(messageObject, messageType, displayColor, customType);

            // push into this queue.
            tempQueue.Enqueue(msg);

            return msg;
        }
    }

    /// <summary>
    /// This Enum holds the message types used to easily control the formatting and display of a message.
    /// </summary>
    public enum MessageType : int
    {
        NORMAL = 0,
        WARNING = 1,
        ERROR = 2,
        SYSTEM = 3,
        INPUT = 4,
        OUTPUT = 5,
        UNITY = 6,
    }

    /// <summary>
    /// Represents a single message, with formatting options.
    /// </summary>
    struct LogMessage
    {
        string text;
        string formatted;
        public string customType;
        public MessageType type;

        public Color color { get; private set; }

        public static Color defaultColor = Color.white;
        public static Color warningColor = Color.yellow;
        public static Color errorColor = Color.red;
        public static Color systemColor = Color.green;
        public static Color inputColor = Color.green;
        public static Color outputColor = Color.cyan;
        public static Color unityColor = new Color(0.3882f, 0.7725f, 1f, 1f);


        public LogMessage(object messageObject, MessageType messageType, Color displayColor, string customType) : this()
        {
            this.Set(messageObject, messageType, displayColor, customType);
        }

        public void Set(object messageObject, MessageType messageType, Color displayColor, string customType)
        {
            this.color = displayColor;

            if (messageObject == null)
                this.text = "<null>";
            else
            {
                if (messageType == MessageType.SYSTEM || messageType == MessageType.OUTPUT || messageType == MessageType.INPUT || messageType == MessageType.UNITY)
                    this.text = messageObject.ToString();
                else
                    this.text = "[" + DateTime.Now.ToLongTimeString() + "] " + messageObject.ToString();
            }

            this.formatted = string.Empty;
            this.type = messageType;
            this.customType = customType;
        }

        public static LogMessage Log(object message, string customType)
        {
            return CreateNew(message, MessageType.NORMAL, defaultColor, customType);
        }

        public static LogMessage Log(object message, string customType, Color col)
        {
            return CreateNew(message, MessageType.NORMAL, col, customType);
        }

        public static LogMessage Log(object message, MessageType messageType)
        {
            return CreateNew(message, messageType, defaultColor, string.Empty);
        }

        public static LogMessage System(object message)
        {
            return CreateNew(message, MessageType.SYSTEM, systemColor, string.Empty);
        }

        public static LogMessage Warning(object message, string customType)
        {
            return CreateNew(message, MessageType.WARNING, warningColor, customType);
        }

        public static LogMessage Error(object message, string customType)
        {
            return CreateNew(message, MessageType.ERROR, errorColor, customType);
        }

        public static LogMessage Output(object message)
        {
            return CreateNew(message, MessageType.OUTPUT, outputColor, string.Empty);
        }

        public static LogMessage Input(object message)
        {
            return CreateNew(message, MessageType.INPUT, inputColor, string.Empty);
        }

        public override string ToString()
        {
            return text;
        }

        public bool isNotEmpty() {
            return text.Length != 0;
        }

        ///need color
        public string ToGUIString()
        {
            if (!string.IsNullOrEmpty(formatted))
                return formatted;

            switch (type)
            {
                case MessageType.INPUT:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + ">>> " + text + "</color>\n";
                    break;
                case MessageType.OUTPUT:
                    var lines = text.Trim('\n').Split('\n');
                    var output = new StringBuilder();

                    //foreach (var line in lines)
                    for (int i = 0; lines != null && i < lines.Length; i++)
                    {
                        output.AppendLine("= " + lines[i]);
                    }

                    formatted = "<color=#" + ColorToHex(this.color) + ">" + output.ToString() + "</color>";
                    break;
                case MessageType.SYSTEM:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + "# " + text + "</color>\n";
                    break;
                case MessageType.WARNING:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + "* " + text + "</color>\n";
                    break;
                case MessageType.ERROR:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + "** " + text + "</color>\n";
                    break;
                case MessageType.UNITY:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + "*** " + text + "</color>";
                    break;
                default:
                    formatted = "<color=#" + ColorToHex(this.color) + ">" + text + "</color>\n";
                    break;
            }

            return formatted;
        }
    }

    #endregion

    #region History CMD struct

    class History
    {
        List<string> history = new List<string>();
        int index = 0;

        public void Add(string item)
        {
            history.Add(item);
            index = 0;
            current = item;
        }

        string current = string.Empty;

        public string Fetch(string cur, bool next)
        {
            if (index == 0) this.current = cur;

            if (history.Count == 0) return current;

            index += next ? -1 : 1;

            if (history.Count + index < 0 || history.Count + index > history.Count - 1)
            {
                index = 0;
                return this.current;
            }

            current = history[history.Count + index];

            return current;
        }
    }

    History _history = new History();

    #endregion

    #region Mono & base

    // Use this for initialization
    void Init()
    {
        IsEditor = Application.isEditor;
        if (IsEditor)
        {
            dataPath = Application.dataPath;
        }
        else
        {
            dataPath = Application.persistentDataPath;
        }

        isInit = true;
        gameObject.hideFlags = HideFlags.HideInHierarchy;

        fps = new FPSCounter();
        memoryCounter = new MemoryCounter();

        LogMessages(LogMessage.System("TTConsole\nEnter '?' For Help"));

        //this.RegisterCommandCallback("close", CMDClose, "关闭调试窗口");
        this.RegisterCommandCallback("clear", CMDClear, "清除调试信息");
        this.RegisterCommandCallback("sys", CMDSystemInfo, "显示系统信息");
        this.RegisterCommandCallback("?", CMDHelp, "显示可用命令");
        this.RegisterCommandCallback(":", CMDShowMessageType, "控制显示的消息类型(-1(无):all,0:normal,1:warn,2:error,3:system,4:input,5:output,6:unitylog)");
        this.RegisterCommandCallback("show", CMDShowCustomMessage, "控制显示自定义消息，默认不显示");
        this.RegisterCommandCallback("fps", CMDShowFPS, "控制显示FPS，0表示不显示,1表示显示fps,2表示也显示fps&内存");
        this.RegisterCommandCallback("mem", CMDShowMemory, "打印当前内存占用列表");
        this.RegisterCommandCallback("log", CMDStartAsyncLoging, "开启异步写入Log文件");
        this.RegisterCommandCallback("additem", GM.AddItem, "gm增加物品(id, 数量): additem 10086 50");
        this.RegisterCommandCallback("addgem", GM.AddGem, "gm增加宝石(id, 数量): addgem 4380101 50");
        this.RegisterCommandCallback("addcurrency", GM.AddCurrency, "gm增加货币(数量): addcurrency money/diamond/jingtie -1000");
        this.RegisterCommandCallback("addequip", GM.AddEquip, "gm增加装备(id, 品质, 数量, 繁荣度): addequip 11110001 1 1 10");
        this.RegisterCommandCallback("addexp", GM.AddExp, "增加经验:addexp 500(不填表示增加到本级满经验)");
        this.RegisterCommandCallback("addlevel", GM.AddLevel, "增加等级:addlevel 1");
        this.RegisterCommandCallback("showAllPlayerPos", GM.ShowAllPlayerPos, "获取当前场景所有的玩家ID以及其位置");
        this.RegisterCommandCallback("showPlayerPos", GM.ShowPlayerPos, "获取当前玩家的位置: showPlayerPos");
        this.RegisterCommandCallback("showPlayerAttr", GM.showPlayerAttr, "在服务器打印当前玩家的所有属性");
        this.RegisterCommandCallback("getObjPos", GM.getObjPos, "获取指定id的目标在后台的即时位置   getObjPos 11");
        this.RegisterCommandCallback("re", GM.RefreshUIScript, "刷新UI有关的Lua脚本");
        this.RegisterCommandCallback("clearAllLogFiles", ClearAllLogFiles, "清空log");
        this.RegisterCommandCallback("uplog", uploadLog, "上传log  uplog 1 10  1表示MessageType.Warning 10表示上传距离当前时间最近的10个log文件");
        this.RegisterCommandCallback("dumpab", GM.DumpAB, "查看ab信息");
        this.RegisterCommandCallback("testFuben", GM.testFuben, "副本测试");
        this.RegisterCommandCallback("addheart", GM.addHeart, "gm增加魔龙之心(数量): addheart 999");
        //this.RegisterCommandCallback("sendmail", GM.SendEmail, "gm给自己发邮件测试用: sendmail 0");
        this.RegisterCommandCallback("setAttr", GM.setAttr, "gm设置玩家的属性为配置的标准属性: setAttr 30");
        this.RegisterCommandCallback("transmit", GM.transmit, "传送 : transmit 1009"); 
        this.RegisterCommandCallback("addOT", GM.addOfflineTime, "添加离线挂机时间(分钟) : addOT 60");
        this.RegisterCommandCallback("getAiInfo", GM.getAiInfo, "获取角色对应的AI信息（在服务端打印） : getAiInfo 10017");
        this.RegisterCommandCallback("setZhuanjin", GM.setZhuanJin, "获取角色技能专精（玩家必须先有对应的主技能）: setZhuanjin 10000 1");
        this.RegisterCommandCallback("challenge_zhuxian", GM.challenge_zhuxian, "挑战主线副本（测试GM，传入章节ID）: challenge_zhuxian 1");
		this.RegisterCommandCallback("tn", GM.testNotificator, "测试本地提醒 : testnoti 1001 10 提醒标题 这是一条本地提醒消息 0");
        this.RegisterCommandCallback("gc", GM.gc, "GC: gc");
        this.RegisterCommandCallback("addskill", GM.allSkill, "解锁所有技能");
        this.RegisterCommandCallback("sn", GM.showAllNotification, "显示所有已注册提醒");
//#if UNITY_ANDROID
        Application.logMessageReceived += HandleUnityLog;        
// #else
//         //BuglyAgent.RegisterLogCallback(HandleUnityLog);
// #endif

        

        //Start Async Writing Log
        //only in editor auto start.
        //mobile should use log...
        if (true/*!applicationIsQuitting && Application.isMobilePlatform == false && Application.isEditor*/)
        {
            StartAsyncWriteLog();
        }

        DataAccess.GetInstance().Ports.SetPort("gmc_get_log", (connect, msg) =>
            {
                string[] str = new string[3];
                str[1] = msg.GetInt("type").ToString();
                str[2] = msg.GetInt("count").ToString();
                uploadLog(str);
            });
    }

    public void Start()
    {        
        if (!isInit)
        {
            Destroy(this.gameObject);
            return;
        }
        else
        {
            DontDestroyOnLoad(gameObject);
        }
    }

    void OnLevelWasLoaded(int level)
    {
        InitEventSystem();
    }

    ///listen the base unity log
    void HandleUnityLog(string condition, string stackTrace, LogType type)
    {
        if (type == LogType.Error || type == LogType.Exception)
        {
            LogError(condition + "\n" + "<i>" + "<color=#" + ColorToHex(Color.grey) + ">" + stackTrace + "</color>" + "</i>", String.Empty);
        } else if (type == LogType.Warning) {
            LogWarning(condition + "\n" + "<i>" + "<color=#" + ColorToHex(Color.grey) + ">" + stackTrace + "</color>" + "</i>", String.Empty);
        }
        else {
            Log(condition + "\n", MessageType.OUTPUT);
        }
    }

    ///check KeyCode & Touch
    ///control the Console
    void UpdateKeyCode()
    {
        // Toggle key shows the console in non-iOS dev builds
        //if (Event.current != null && Event.current.keyCode == KeyCode.BackQuote && Event.current.type == EventType.KeyUp)
        if (Input.GetKeyUp(KeyCode.BackQuote))
        {
            IsOpen = !IsOpen;
        }

       
        if (Input.touchCount == 3 && Time.realtimeSinceStartup - preOpenTime >= 1.0f)
        {
            
            for (int i = 0; i < Input.touchCount; i++)
            {
                Touch touch = Input.GetTouch(i);
                if (touch.position.y >= Screen.height * 0.5)
                {

                }
                else
                {
                    return;
                }
            }
            preOpenTime = Time.realtimeSinceStartup;
            IsOpen = !IsOpen;
        }

        if (IsOpen && input.isFocused)
        {
            if (Input.GetKeyUp(KeyCode.Return))
            {
                EvalInputString(input.text);
                input.text = string.Empty;
            }
            //else if (evt.keyCode == KeyCode.UpArrow)
            else if (Input.GetKeyUp(KeyCode.UpArrow))
            {
                input.text = _history.Fetch(input.text, true);
            }
            //else if (evt.keyCode == KeyCode.DownArrow)
            else if (Input.GetKeyUp(KeyCode.DownArrow))
            {
                input.text = _history.Fetch(input.text, false);
            }
        }
        else
        {
            //check auto page move.
            if (IsOpen)
            {
                //keycode work
                if (Input.GetKeyUp(KeyCode.LeftBracket))
                {
                    AddPage(-1);
                }
                else if (Input.GetKeyUp(KeyCode.RightBracket))
                {
                    AddPage(1);
                }

                //touch work
                if (Input.touchCount == 1)
                {
                    Touch touch = Input.GetTouch(0);
                    if (touch.phase == TouchPhase.Began)
                    {
                        if (touch.position.x <= Screen.width * 0.5f && touch.position.y >= Screen.height * 0.9f)
                        {
                            AddPage(-1);
                        }
                        else if (touch.position.x > Screen.width * 0.5f && touch.position.y >= Screen.height * 0.9f)
                        {
                            AddPage(1);
                        }
                    }
                }

            }
        }
    }

    // Update is called once per frame
    public void Update()
    {
        UpdateKeyCode();

        if (ui_fps_root != null)
        {
            if (fps.Update())
            {
                memoryCounter.Update(1);
                text_fps.text = fps.current.ToString("F0") + "\n" + memoryCounter.ToString();
            }
        }

        if (!IsOpen) return;

        if (isNeedRefreshContent)
        {
            isNeedRefreshContent = false;
            DrawingContent();
        }
    }

    // Note that Color32 and Color implictly convert to each other. You may pass a Color object to this method without first casting it.
    public static string ColorToHex(Color32 color)
    {
        string hex = color.r.ToString("X2") + color.g.ToString("X2") + color.b.ToString("X2");
        return hex;
    }

    static Color HexToColor(string hex)
    {
        byte r = byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber);
        byte g = byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
        byte b = byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber);
        return new Color32(r, g, b, 255);
    }

    #endregion

    #region DrawWindows

    ///Init the event system if not exist.
    private void InitEventSystem()
    {
        UnityEngine.EventSystems.EventSystem es = FindObjectOfType<UnityEngine.EventSystems.EventSystem>();
        if (es == null)
        {
            GameObject eventsystem = new GameObject("EventSystem");
            es = eventsystem.AddComponent<UnityEngine.EventSystems.EventSystem>();
            eventsystem.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
        }
    }

    private void DrawWindow(bool isHide)
    {
        transform.position = Vector3.zero;

        //canvas
        GameObject windows = new GameObject("LogConsole_UI");
        ui_root_obj = windows;
        windows.transform.parent = transform;

        Canvas canvas = windows.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.pixelPerfect = false;
        canvas.sortingOrder = 10086;

        UnityEngine.UI.CanvasScaler cs = windows.AddComponent<UnityEngine.UI.CanvasScaler>();

        //only mobile platform should use screen size.
        if (!Application.isEditor)
        {
            cs.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
            cs.screenMatchMode = UnityEngine.UI.CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            cs.referenceResolution = new Vector2(960f, 640f);
            cs.matchWidthOrHeight = 1.0f;
        }


        UnityEngine.UI.GraphicRaycaster gr = windows.AddComponent<UnityEngine.UI.GraphicRaycaster>();
        gr.blockingObjects = UnityEngine.UI.GraphicRaycaster.BlockingObjects.All;
        //gr.

        InitEventSystem();
        InitBlackground(windows);
        InitScrollView(windows);
        InitScrollContent(sr_content.gameObject);
        InitInput(windows);
#if UNITY_EDITOR
        input.ActivateInputField();
        input.Select();
#endif
    }

    void InitBlackground(GameObject windows)
    {
        //background
        GameObject background = new GameObject("blackground");
        background.transform.parent = windows.transform;
        UnityEngine.UI.Image img_bgm = background.AddComponent<UnityEngine.UI.Image>();
        img_bgm.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        img_bgm.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 0);
        img_bgm.rectTransform.anchorMin = new Vector2(0, 0.3f);
        img_bgm.rectTransform.anchorMax = new Vector2(1, 1);
        img_bgm.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        img_bgm.color = new Color(0, 0, 0, 0.8f);
    }

    void InitScrollView(GameObject windows)
    {
        //content_scroll_view
        GameObject scrollView = new GameObject("scrollview");
        scrollView.transform.parent = windows.transform;
        sr_content = scrollView.AddComponent<UnityEngine.UI.ScrollRect>();
        sr_content.horizontal = false;
        

        UnityEngine.UI.Image img_sr = scrollView.AddComponent<UnityEngine.UI.Image>();
        img_sr.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        img_sr.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, -30);
        img_sr.rectTransform.anchorMin = new Vector2(0, 0.3f);
        img_sr.rectTransform.anchorMax = new Vector2(1, 1);
        img_sr.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        img_sr.color = new Color(0, 0, 0, 1f);
        UnityEngine.UI.Mask mask = scrollView.AddComponent<UnityEngine.UI.Mask>();
        mask.showMaskGraphic = false;
    }

    void InitScrollContent(GameObject scrollView)
    {
        //content_text
        GameObject scroll_content = new GameObject("content");
        scroll_content.transform.parent = scrollView.transform;
        text_content = scroll_content.AddComponent<UnityEngine.UI.Text>();
        text_content.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        text_content.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 0);
        text_content.rectTransform.anchorMin = new Vector2(0, 0);
        text_content.rectTransform.anchorMax = new Vector2(1, 1);
        text_content.rectTransform.pivot = new Vector2(0f, 0f);
        text_content.color = new Color(1, 1, 1, 1f);
        text_content.font = Resources.GetBuiltinResource(typeof(Font), "Arial.ttf") as Font;
        text_content.fontSize = 16;
        text_content.alignment = TextAnchor.LowerLeft;

        text_content.gameObject.AddComponent<UnityEngine.UI.ContentSizeFitter>().verticalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize;
        scrollView.GetComponent<UnityEngine.UI.ScrollRect>().content = text_content.rectTransform;
    }

    void InitInput(GameObject windows)
    {
        GameObject input_obj = new GameObject("input");
        input_obj.transform.parent = windows.transform;
        UnityEngine.UI.Image img_input = input_obj.AddComponent<UnityEngine.UI.Image>();
        img_input.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        img_input.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Bottom, -15, 30);
        img_input.rectTransform.anchorMin = new Vector2(0, 0.3f);
        img_input.rectTransform.anchorMax = new Vector2(1, 0.3f);
        img_input.rectTransform.pivot = new Vector2(0f, 0f);
        img_input.color = new Color(0, 0, 0, 1);

        GameObject input_placeholder = new GameObject("placeHolder");
        input_placeholder.transform.parent = input_obj.transform;
        UnityEngine.UI.Text text_holder = input_placeholder.AddComponent<UnityEngine.UI.Text>();
        text_holder.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        text_holder.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 5, -10);
        text_holder.rectTransform.anchorMin = new Vector2(0, 0);
        text_holder.rectTransform.anchorMax = new Vector2(1, 1);
        text_holder.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        text_holder.font = Resources.GetBuiltinResource(typeof(Font), "Arial.ttf") as Font;
        text_holder.color = Color.grey;
        text_holder.text = ">";

        GameObject input_page = new GameObject("pageamount");
        input_page.transform.parent = input_obj.transform;
        text_pageCount = input_page.AddComponent<UnityEngine.UI.Text>();
        text_pageCount.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
        text_pageCount.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 5, -10);
        text_pageCount.rectTransform.anchorMin = new Vector2(0, 0);
        text_pageCount.rectTransform.anchorMax = new Vector2(1, 1);
        text_pageCount.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        text_pageCount.font = Resources.GetBuiltinResource(typeof(Font), "Arial.ttf") as Font;
        text_pageCount.color = Color.grey;
        text_pageCount.text = currentPersent + "%";
        text_pageCount.alignment = TextAnchor.MiddleRight;

        GameObject input_text_obj = new GameObject("inputText");
        input_text_obj.transform.parent = input_obj.transform;
        UnityEngine.UI.Text text_input = input_text_obj.AddComponent<UnityEngine.UI.Text>();
        text_input.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 10, -20);
        text_input.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 5, -10);
        text_input.rectTransform.anchorMin = new Vector2(0, 0);
        text_input.rectTransform.anchorMax = new Vector2(1, 1);
        text_input.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        text_input.font = Resources.GetBuiltinResource(typeof(Font), "Arial.ttf") as Font;
        text_input.color = Color.white;
        text_input.supportRichText = false;

        input = input_obj.AddComponent<UnityEngine.UI.InputField>();
        input.textComponent = text_input;

        ///Init event
        input.onEndEdit.AddListener(ProcessInput);

    }

    /// <summary>
    /// draw the cosole windows
    /// dynamic 
    /// NOTE:only show current page.
    /// </summary>
    void DrawingContent()
    {
        string val = string.Empty;
        LogMessage[] msgs = GetAllCurrentTypeMessages().ToArray();

        for (int i = beginMsgIndex; i <= endMsgIndex; i++)
        {
            val += msgs[i].ToGUIString();
        }
        text_content.text = val;
        text_pageCount.text = currentPersent + "%";
    }

    int currentPersent
    {
        get
        {
            LogMessage[] msgs = GetAllCurrentTypeMessages().ToArray();

            if (maxMsgCount == -1 || maxMsgCount == 0 || msgs.Length == 0)
            {
                return 0;
            }
            else if (endMsgIndex == msgs.Length - 1)
            {
                return 100;
            }
            return (int)((endMsgIndex * 1.0f / (msgs.Length - 1)) * 100);
        }
    }

    private void DrawFPS()
    {
        if (ui_fps_root != null)
        {
            return;
        }

        //canvas
        GameObject fpsRoot = new GameObject("fps");
        ui_fps_root = fpsRoot;
        fpsRoot.transform.parent = transform;
        Canvas canvas = fpsRoot.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.pixelPerfect = true;
        canvas.sortingOrder = 10000;
        fpsRoot.transform.localPosition = fpsRoot.transform.localPosition + new Vector3(-100, -20, 0);
        fpsRoot.AddComponent<UnityEngine.UI.CanvasScaler>();

        //text
        //content_text
        GameObject fps_content = new GameObject("text");
        fps_content.transform.parent = ui_fps_root.transform;
        text_fps = fps_content.AddComponent<UnityEngine.UI.Text>();
        text_fps.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Right, 0, 0);
        text_fps.rectTransform.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 0);
        text_fps.rectTransform.anchorMin = new Vector2(0, 0);
        text_fps.rectTransform.anchorMax = new Vector2(1, 1);
        text_fps.rectTransform.pivot = new Vector2(0f, 0f);
        text_fps.color = new Color(1, 1, 1, 1f);
        text_fps.font = Resources.GetBuiltinResource(typeof(Font), "Arial.ttf") as Font;
        text_fps.fontSize = 16;
        text_fps.alignment = TextAnchor.UpperRight;
        text_fps.text = "fps";
    }

    #endregion

    #region Console commands

    //==== Built-in example DebugCommand handlers ====
    object CMDClose(string[] args)
    {
        IsOpen = false;
        return "closed";
    }

    object CMDClear(string[] args)
    {
        this.ClearLog();

        return "clear";
    }

    object CMDHelp(string[] args)
    {
        var output = new StringBuilder();

        output.AppendLine("可用命令列表: ");
        output.AppendLine("--------------------------");
        foreach (string key in _cmdTable.Keys)
        {
            output.AppendLine("[" + key + "] -> " + _cmdTableDiscribes[key]);
        }

        output.Append("--------------------------");
        if (Application.isMobilePlatform)
        {
            output.AppendLine("移动端：半屏幕以上3只手指开关、底部左边1只手指←翻页，相反→翻页");
        }
        else
        {
            output.AppendLine("PC端：数字键左边~键开关、[键←翻页，]键→翻页");
        }
        return output.ToString();
    }

    object CMDSystemInfo(string[] args)
    {
        Log("Unity Ver: " + Application.unityVersion, MessageType.OUTPUT);
        Log("Platform: " + Application.platform, MessageType.OUTPUT);
        Log("Language: " + Application.systemLanguage, MessageType.OUTPUT);
        //Log(string.Format("Level: {0} [{1}]", UnityEngine.SceneManagement.SceneManager.GetActiveScene().name, UnityEngine.SceneManagement.SceneManager.GetActiveScene().buildIndex), MessageType.OUTPUT);
        Log("Data Path: " + Application.dataPath, MessageType.OUTPUT);
        Log("Persistent Path: " + Application.persistentDataPath, MessageType.OUTPUT);
        Log("deviceModel " + SystemInfo.deviceModel, MessageType.OUTPUT);
        Log("deviceName " + SystemInfo.deviceName, MessageType.OUTPUT);
        Log("deviceType " + SystemInfo.deviceType, MessageType.OUTPUT);
        Log("deviceUniqueIdentifier " + SystemInfo.deviceUniqueIdentifier, MessageType.OUTPUT);
        Log("graphicsDeviceID " + SystemInfo.graphicsDeviceID, MessageType.OUTPUT);
        Log("graphicsDeviceName " + SystemInfo.graphicsDeviceName, MessageType.OUTPUT);
        Log("graphicsDeviceVendor " + SystemInfo.graphicsDeviceVendor, MessageType.OUTPUT);
        Log("graphicsDeviceVendorID " + SystemInfo.graphicsDeviceVendorID, MessageType.OUTPUT);
        Log("graphicsDeviceVersion " + SystemInfo.graphicsDeviceVersion, MessageType.OUTPUT);
        Log("graphicsMemorySize " + SystemInfo.graphicsMemorySize, MessageType.OUTPUT);
        Log("graphicsShaderLevel " + SystemInfo.graphicsShaderLevel, MessageType.OUTPUT);
        Log("operatingSystem " + SystemInfo.operatingSystem, MessageType.OUTPUT);
        Log("processorCount " + SystemInfo.processorCount, MessageType.OUTPUT);
        Log("processorType " + SystemInfo.processorType, MessageType.OUTPUT);
        Log("supportedRenderTargetCount " + SystemInfo.supportedRenderTargetCount, MessageType.OUTPUT);
        Log("supports3DTextures " + SystemInfo.supports3DTextures, MessageType.OUTPUT);
        Log("supportsAccelerometer " + SystemInfo.supportsAccelerometer, MessageType.OUTPUT);
        Log("supportsComputeShaders " + SystemInfo.supportsComputeShaders, MessageType.OUTPUT);
        Log("supportsGyroscope " + SystemInfo.supportsGyroscope, MessageType.OUTPUT);
        Log("supportsImageEffects " + SystemInfo.supportsImageEffects, MessageType.OUTPUT);
        Log("supportsInstancing " + SystemInfo.supportsInstancing, MessageType.OUTPUT);
        Log("supportsLocationService " + SystemInfo.supportsLocationService, MessageType.OUTPUT);
        Log("supportsRenderTextures " + SystemInfo.supportsRenderTextures, MessageType.OUTPUT);
        Log("supportsShadows " + SystemInfo.supportsShadows, MessageType.OUTPUT);
        Log("supportsVibration " + SystemInfo.supportsVibration, MessageType.OUTPUT);
        Log("systemMemorySize " + SystemInfo.systemMemorySize, MessageType.OUTPUT);
        Log("CurrentResolution: " + Screen.currentResolution.width + " * " + Screen.currentResolution.height, MessageType.OUTPUT);
        Log("Dpi: " + Screen.dpi, MessageType.OUTPUT);
        Log("Profiler.enabled = : " + Profiler.enabled.ToString(), MessageType.OUTPUT);

        System.GC.Collect();
        Log(string.Format("Total memory: {0:###,###,###,##0} kb", (System.GC.GetTotalMemory(true)) / 1024f), MessageType.OUTPUT);

        return "end.";
    }

    ///control whitch type message should show.
    ///@param = message index
    object CMDShowMessageType(string[] args)
    {
        //special when show new type should follow the newest
        needAutoToMax = true;

        int id = 0;
        if (args == null || args.Length == 1 || int.TryParse(args[1], out id) == false)
        {
            currentShowMessageType = -1;
            return "ALL";
        }
        else
        {
            currentShowMessageType = id;
        }
        return id == -1 ? "ALL" : Enum.Parse(typeof(MessageType), id.ToString()).ToString();
    }

    object CMDShowCustomMessage(string[] args)
    {
        //special when show new type should follow the newest
        needAutoToMax = true;

        if (args == null || args.Length == 1)
        {
            currentShowMessageCustom = string.Empty;
            return String.Empty;
        }
        else
        {
            currentShowMessageCustom = args[1];

            //use tt instead of ttloader
            if (currentShowMessageCustom.Equals("tt"))
            {
                currentShowMessageCustom = "TTLoader";
            }
        }
        return currentShowMessageCustom;
    }


    object CMDShowFPS(string[] args)
    {
        if (!fpsMode)
        {
            DrawFPS();
            fpsMode = true;
        }
        else
        {
            if (ui_fps_root != null)
            {
                Destroy(ui_fps_root.gameObject);
            }
            fpsMode = false;
        }
        return "";
    }

    object CMDShowMemory(string[] args)
    {
        double mbseed = 1.0f / (1024 * 1024);

        //get all textures
        //Resources.FindObjectsOfTypeAll is only show active.
        List<Texture> textures = new List<Texture>(Resources.FindObjectsOfTypeAll(typeof(Texture)) as Texture[]);
        Log("----------TEXTURE-----------", MessageType.OUTPUT);
        Log("Texture Count:" + textures.Count, MessageType.OUTPUT);
        textures.Sort((a, b) =>
        {
            int sa = Profiler.GetRuntimeMemorySize(a);
            int sb = Profiler.GetRuntimeMemorySize(b);
            if (sa > sb) return -1;
            else if (sa < sb) return 1;
            else return 0;
        });
        for (int i = 0; i < textures.Count && i < 100; i++)
        {
            Log(textures[i].name + " : " + (Profiler.GetRuntimeMemorySize(textures[i]) * mbseed).ToString("#0.##") + "mb", MessageType.OUTPUT);
        }


        //sounds
        List<AudioClip> clips = new List<AudioClip>(Resources.FindObjectsOfTypeAll(typeof(AudioClip)) as AudioClip[]);
        Log("----------Sound-----------", MessageType.OUTPUT);
        Log("Sound Count:" + clips.Count, MessageType.OUTPUT);
        clips.Sort((a, b) =>
        {
            int sa = Profiler.GetRuntimeMemorySize(a);
            int sb = Profiler.GetRuntimeMemorySize(b);
            if (sa > sb) return -1;
            else if (sa < sb) return 1;
            else return 0;
        });
        for (int i = 0; i < clips.Count; i++)
        {
            Log(clips[i].name + " : " + (Profiler.GetRuntimeMemorySize(clips[i]) * mbseed).ToString("#0.##") + "mb", MessageType.OUTPUT);
        }


        return "end.";
    }

    object CMDStartAsyncLoging(string[] args)
    {
        if (!isAsyncWritingLog)
        {
            StartAsyncWriteLog();
            return "开始异步写入Log";
        }
        else
        {
            return "已经开始异步写入Log了";
        }
    }

    #endregion

    #region InternalFunctionality

    void LogMessages(LogMessage msg)
    {
        if (IsOpen)
        {
            ///calculate current page amount.
            maxMsgCount = CaculateCurrentMaxMsgCount();

            if (needAutoToMax)
            {
                isNeedRefreshContent = true;
                endMsgIndex = maxMsgCount - 1;
                beginMsgIndex = FindBeginMsgIndexFromEnd();
            }
        }

        ///add into async writer
        if (isAsyncWritingLog)
        {
           // Loginfo info = new Loginfo(msg.type, msg.ToGUIString());
            AddToAsyncWriteBuff(msg.type, msg.ToGUIString());
        }
    }

    //--- Local version. Use the static version above instead.
    void ClearLog()
    {
        _messages.Clear();
        customQueueMessages.Clear();
        isNeedRefreshContent = true;
    }

    // calculate the maxPage of current msg type.
    int CaculateCurrentMaxMsgCount()
    {
        return GetAllCurrentTypeMessages().Count;
    }

    //--- Local version. Use the static version above instead.
    void RegisterCommandCallback(string commandString, Func<string[], object> commandCallback, string CMD_Discribes)
    {
        try
        {
            ///wont add again.
            if (_cmdTable.ContainsKey(commandString)) return;

            _cmdTable[commandString] = commandCallback;
            _cmdTableDiscribes.Add(commandString, CMD_Discribes);
        }
        catch (Exception e)
        {
            TTLoger.LogError(e.Message);
        }
    }

    //--- Local version. Use the static version above instead.
    void UnRegisterCommandCallback(string commandString)
    {
        try
        {
            _cmdTable.Remove(commandString);
            _cmdTableDiscribes.Remove(commandString);
        }
        catch (Exception e)
        {
            TTLoger.LogError(e.Message);
        }
    }

    void EvalInputString(string inputString)
    {
        var multInput = inputString.Split(new char[] { ';'}, StringSplitOptions.RemoveEmptyEntries);
        if (multInput.Length == 0) {
            return;
        }

        for (int i = 0; i < multInput.Length; ++i) {
            var input = multInput[i].Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (input.Length == 0)
            {
                continue;
            }
            LogMessages(LogMessage.Input(inputString));
            var cmd = input[0];
            if (_cmdTable.ContainsKey(cmd))
            {
                LogMessage output = LogMessage.Output(_cmdTable[cmd](input));
                if (output.isNotEmpty())
                {
                    LogMessages(output);
                }
            }
            else
            {
                object[] luaRet = Lua.state.DoString(string.Format("(function () {0} end)()", inputString));
                if (luaRet != null && luaRet.Length != 0)
                {
                    string output = String.Join(",", (string[])luaRet);
                    LogMessages(LogMessage.Output(output));
                }
            }

            _history.Add(inputString);
        }
        
    }

    #endregion

    #region internal Static Api

    internal static object Log(object message, string customType)
    {
        if (LogConsole.Instance == null)
            return null;

        LogConsole.Instance.LogMessages(LogMessage.Log(message, customType));

        return message;
    }

    internal static object Log(object message, string customType, Color col)
    {
        if (LogConsole.Instance == null)
            return null;

        LogConsole.Instance.LogMessages(LogMessage.Log(message, customType, col));

        return message;
    }

    internal static object Log(object message, MessageType messageType)
    {
        if (LogConsole.Instance == null)
            return null;
        LogConsole.Instance.LogMessages(LogMessage.Log(message, messageType));

        return message;
    }

    internal static object LogWarning(object message, string customType)
    {
        if (LogConsole.Instance == null)
            return null;
        LogConsole.Instance.LogMessages(LogMessage.Warning(message, customType));

        return message;
    }

    internal static object LogError(object message, string customType)
    {
        if (LogConsole.Instance == null)
            return null;
        LogConsole.Instance.LogMessages(LogMessage.Error(message, customType));

        return message;
    }

    /// <summary>
    /// Clears all console output.
    /// </summary>
    public static void Clear()
    {
        if (LogConsole.Instance != null)
        {
            LogConsole.Instance.ClearLog();
        }
    }

    public void SortAsFileName(ref FileInfo[] arrFi)
    {
        Array.Sort(arrFi, delegate(FileInfo x, FileInfo y) { return y.Name.CompareTo(x.Name); });
    }

    public  IEnumerator PostData(WWW www)
    {
        yield return www;
    }
    public object uploadLog(string[] arg)
    {
        LogConsole.MessageType type = (LogConsole.MessageType)Enum.Parse(typeof(LogConsole.MessageType), arg[1]);
        int num = int.Parse(arg[2]);

        string path = LogConsole.Instance.FormatLogFolder(type);
        DirectoryInfo di = new DirectoryInfo(path);
        FileInfo[] tempFiles = di.GetFiles("*.log");
        int FileNum = Math.Min(num, tempFiles.Length);
        if (FileNum <= 0)
        {
            return path + "没有log文件";
        }
        SortAsFileName(ref tempFiles);
        FileInfo[] files = new FileInfo[FileNum];
        Array.Copy(tempFiles, 0, files, 0, FileNum);

        StartCoroutine(OnUploadLog(files,type.ToString()));

        return "上传Log";
    }
    public IEnumerator OnUploadLog(FileInfo[] arrFi,string type)
    {
        foreach (FileInfo file in arrFi)
        {
            string str = file.FullName;
            string content = string.Empty;
            if(IsFileInUse(str))
            {
                continue;
            }
            StreamReader reader = new StreamReader(str, Encoding.UTF8, true);
            content = reader.ReadToEnd();
            reader.Close();
            byte[] bytes = System.Text.Encoding.ASCII.GetBytes(content);

            yield return new WaitForEndOfFrame();

            WWWForm form = new WWWForm();
            form.AddField("FileName", file.Name);
            form.AddField("PlayerName", uPlayerController.Instance.id);
            form.AddField("ServerName", Net.serverName);
            form.AddField("LogType", type);
               
            form.AddBinaryData("post", bytes);
            WWW www = new WWW("http://120.27.139.129/UnityUpload.php", form);
            StartCoroutine(PostData(www));
        }
    }


    public bool IsFileInUse(string fileName)
    { 
        bool inUse = true;
        FileStream fs = null;
        try
        {
            fs = new FileStream(fileName, FileMode.Open, FileAccess.Read,FileShare.None);
            inUse = false;
        }
        catch
        {}
        finally
        {
            if (fs != null)
                fs.Close();
        }
        return inUse;//true表示正在使用,false没有使用  
    }  
    public object ClearAllLogFiles(string[] arg)
    {
        foreach (string str in Enum.GetNames(typeof(LogConsole.MessageType)))
        {
            string strpath = LogConsole.Instance.FormatLogFolder((LogConsole.MessageType)Enum.Parse(typeof(LogConsole.MessageType),str));
            if (!Directory.Exists(strpath))
            {
                continue;
            }
            string[] files = Directory.GetFiles(strpath);
            foreach(string file in files)            
            {
                if(!IsFileInUse(file))
                {
                    File.Delete(file);
                }                
            }
        }
        return "清空所有Log";
    }
    public static void RegisterCommand(string commandString, Func<string[], object> commandCallback, string CMD_Discribes)
    {
        if (LogConsole.Instance != null)
        {
            LogConsole.Instance.RegisterCommandCallback(commandString, commandCallback, CMD_Discribes);
        }
    }

    public static void UnRegisterCommand(string commandString)
    {
        if (LogConsole.Instance != null)
        {
            LogConsole.Instance.UnRegisterCommandCallback(commandString);
        }
    }

    #endregion

    #region Event UI Process

    private void ProcessInput(string cmd)
    {
        //fixed:Only Submit
        if (Application.isMobilePlatform || Input.GetButtonDown("Submit"))
        {
#if UNITY_EDITOR            
                input.ActivateInputField();
                input.Select();
#endif
            

            EvalInputString(cmd);

            //if submit new should reset the current page index
            maxMsgCount = CaculateCurrentMaxMsgCount();

            if (needAutoToMax)
            {
                endMsgIndex = maxMsgCount - 1;
                beginMsgIndex = FindBeginMsgIndexFromEnd();
                isNeedRefreshContent = true;
            }
        }

        input.text = string.Empty;
    }

    /// <summary>
    /// val : 1 , -1 mean left or right.
    /// </summary>
    private void AddPage(int val)
    {
        // begin - end
        if (val == 1)
        {
            if (endMsgIndex < maxMsgCount - 1)
            {
                beginMsgIndex = endMsgIndex;
                endMsgIndex = FindEndMsgIndexFromBegin();

                // if end is max
                // need get the begin
                if (endMsgIndex == maxMsgCount - 1)
                {
                    needAutoToMax = true;
                    beginMsgIndex = FindBeginMsgIndexFromEnd();
                }
                else
                {
                    needAutoToMax = false;
                }
            }
        }
        else
        {
            if (beginMsgIndex > 0)
            {
                endMsgIndex = beginMsgIndex;
                beginMsgIndex = FindBeginMsgIndexFromEnd();

                if (beginMsgIndex == 0)
                {
                    endMsgIndex = FindEndMsgIndexFromBegin();
                }

                needAutoToMax = false;
            }
        }

        isNeedRefreshContent = true;
    }

    private List<LogMessage> GetAllCurrentTypeMessages()
    {
        List<LogMessage> curs = new List<LogMessage>();

        LogMessage[] msgs;
        lock (_lock)
        {
            //msgs = _messages.ToArray();
            msgs = FindCustomQueue(currentShowMessageCustom).ToArray();
        }
        for (int i = 0; i < msgs.Length; i++)
        {
            LogMessage msg = msgs[i];

            //check if right with current type
            if (currentShowMessageType != -1 && (int)msg.type != currentShowMessageType)
            {
                continue;
            }

            ///when show custom mess type empty 
            ///only show empty type msg.
            if (string.IsNullOrEmpty(currentShowMessageCustom) && string.IsNullOrEmpty(msg.customType))
            {
                curs.Add(msg);
            }
            ///else if show custom type not empty
            ///only show equals type
            else if (string.IsNullOrEmpty(currentShowMessageCustom) == false && currentShowMessageCustom.Equals(msg.customType, StringComparison.OrdinalIgnoreCase))
            {
                curs.Add(msg);
            }
        }

        return curs;
    }

    // found the begin index from end 
    // need less than 65000 chars.
    private int FindBeginMsgIndexFromEnd()
    {
        List<LogMessage> curs = GetAllCurrentTypeMessages();
        string text = string.Empty;

        for (int i = endMsgIndex; i >= 0; i--)
        {
            text += curs[i].ToGUIString();
            if (text.Length >= 10000)
            {
                return i;
            }
        }
        return 0;
    }

    private int FindEndMsgIndexFromBegin()
    {
        List<LogMessage> curs = GetAllCurrentTypeMessages();
        string text = string.Empty;
        for (int i = beginMsgIndex; i < curs.Count; i++)
        {
            text += curs[i].ToGUIString();
            if (text.Length >= 10000)
            {
                return i;
            }
        }
        return curs.Count - 1;
    }

    #endregion

    #region Thread Writing Log

    /// <summary>
    /// 日志buffer队列
    /// </summary>
    //Queue<string> LogQueue = new Queue<string>();
    class Loginfo
    {
        public Loginfo(MessageType t,string s)
        {
            _type = t;
            _str = s;
        }
        public MessageType _type = MessageType.NORMAL;
        public MessageType type
        {
            get
            {
                return _type;
            }
        }
        public string _str = string.Empty;
        public string str
        {
            get
            {
                return _str;
            }
            set{
                _str = value;
            }
        }
    }
    Queue<Loginfo> LogQueue = new Queue<Loginfo>();

    

    /// <summary>
    /// 日志进程临界区
    /// </summary>
    System.Object thisLock = new System.Object();

    /// <summary>
    /// 日志文件写入流对象
    /// </summary>
    class WriterConnectData
    {
        public WriterConnectData(System.IO.StreamWriter w)
        {
            _Write = w;
            _asyncWriteCounter = 0;
        }
        public int _asyncWriteCounter = 0;
        public int asyncWriteCounter
        {
            set
            {
                _asyncWriteCounter = value;
            }
            get
            {
                return _asyncWriteCounter;
            }
        }
        public System.IO.StreamWriter _Write = null;
        public System.IO.StreamWriter Write
        {
            set
            {
                _Write = value;
            }
            get
            {
                return _Write;
            }
        }
    }
    Dictionary<MessageType, WriterConnectData> streamWrite = new Dictionary<MessageType, WriterConnectData>();

    /// <summary>
    /// 日志线程
    /// </summary>
    System.Threading.Thread logThread;

    int asyncWriteCounter = 0;
    bool isAsyncWritingLog = false;

//     string logFolder
//     {
//         get
//         {
//             string logFolder = string.Empty;
//             if (Application.isEditor)
//                 logFolder = System.IO.Path.Combine(Application.dataPath, "../Log");
//             else
//                 logFolder = System.IO.Path.Combine(Application.persistentDataPath, "Log");
// 
//             if (!Directory.Exists(logFolder))
//             {
//                 System.IO.Directory.CreateDirectory(logFolder);
//             }
// 
//             return logFolder;
//         }
//     }
    public string FormatLogFolder(MessageType type)
    {
        string logFolder = string.Empty;
        string path = string.Empty;
        if (IsEditor)
        {
            path = "../Log/" + type.ToString();
            logFolder = System.IO.Path.Combine(dataPath, path);
        }
        else
        {
            path = "Log/" + type.ToString();
            logFolder = System.IO.Path.Combine(dataPath, path);
        }
        LogMessages(LogMessage.System(dataPath));
        if (!Directory.Exists(logFolder))
        {
            System.IO.Directory.CreateDirectory(logFolder);
        }

        return logFolder;
    }
    public string FormatLogPath(MessageType type)
    {
        var ss = System.DateTime.Now;
        var log = ss.ToString("yyyy-MM-dd-HH-mm-ss") + ".log";
        return System.IO.Path.Combine(FormatLogFolder(type), log);
    }
//     string logPath
//     {
//         get
//         {
//             var ss = System.DateTime.Now;
//             var log = ss.ToString("yyyy-MM-dd-HH-mm-ss") + ".log";
//             return System.IO.Path.Combine(logFolder, log);
//         }
//     }

    /// <summary>
    /// Start A asyncWriteLog Server.
    /// </summary>
    public void StartAsyncWriteLog()
    {
        //new file.
        for (MessageType type = MessageType.NORMAL; type <= MessageType.UNITY; type++)
        {
            CreateNewLogFile(type);;
        }
        logThread = new System.Threading.Thread(RunningAsyncWritingLog);
        logThread.Priority = System.Threading.ThreadPriority.Lowest;
        logThread.Name = "LogThread";
        logThread.Start(logThread);

        isAsyncWritingLog = true;
    }

    public void StopAsyncWriteLog()
    {
        //for (MessageType type = MessageType.NORMAL; type <= MessageType.UNITY; type++)
        foreach (MessageType type in new List<MessageType>(streamWrite.Keys))   
        {
            if(streamWrite[type].Write != null)
            {
                streamWrite[type].Write.Flush();
                streamWrite[type].Write.Close();
            }
        }
        streamWrite.Clear();

        if (logThread != null)
        {
            logThread.Abort();
            logThread = null;
        }

        LogQueue.Clear();

        isAsyncWritingLog = false;
    }

    ///save current log and new file.
    public void CreateNewLogFile(MessageType type)
    {
        try
        {
            if (streamWrite.ContainsKey(type))
            {
                WriterConnectData data = streamWrite[type];
                if (data != null && data.Write != null)
                {
                    data.Write.Flush();
                    data.Write.Close();
                    data.Write = null;
                    data.asyncWriteCounter = 0;
                    data = null;
                }
            }
            streamWrite[type] = new WriterConnectData(new StreamWriter(FormatLogPath(type), true,Encoding.UTF8));
        }
        catch (Exception e)
        {
            TTLoger.LogWarning("CreateNewLogFile exception:" + e.Message);
        }
    }

    /// <summary>
    /// 写入到文本缓冲区
    /// </summary>
    /// <param name="text"></param>
    void AddToAsyncWriteBuff(MessageType type, string str)
    {
        str += "\n";
        Loginfo info = new Loginfo(type, str);
        MessageType t = info.type;
        lock (thisLock)
        {
            LogQueue.Enqueue(info);
        }
    }

    /// <summary>
    /// 从文本缓冲区日志读取到日志缓冲区
    /// </summary>
    Queue<Loginfo> _logBuff = new Queue<Loginfo>();
    Queue<Loginfo> logBuff
    {
        get
        {
            lock (thisLock)
            {
                int boundary = Mathf.Min(10, LogQueue.Count);
                
                for (int i = 0; i < boundary; i++)
                {
                    Loginfo info = LogQueue.Dequeue();
                    _logBuff.Enqueue(info);
                    if (streamWrite.ContainsKey(info.type))
                    {
                        WriterConnectData writeData = streamWrite[info.type];
                        if (writeData != null)
                        {
                            writeData.asyncWriteCounter += 1;
                        };
                    }                                 
                }
                return _logBuff;
            }
        }
    }

    ///writing
    void RunningAsyncWritingLog()
    { 
        while (true)
        { 
            try
            {
                Queue<Loginfo> Buff = logBuff;
                foreach (Loginfo info in Buff)
                {
                    MessageType type = info.type;
                    if (!streamWrite.ContainsKey(type))
                    {
                        continue;
                    }
                    WriterConnectData writeData = streamWrite[type];
                    if (writeData == null || writeData.Write == null)
                    {
                        continue;
                    }
                    writeData.Write.Write(info.str);
                    writeData.Write.Flush();

                    if(writeData.asyncWriteCounter >= maxLinesForAsyncRecord)
                    {
                        CreateNewLogFile(type);
                    }
                }
                Buff.Clear();
            }
            catch(Exception e)
            {
                TTLoger.LogError(e.ToString());
            }


            System.Threading.Thread.Sleep(150);
        }
    }

    #endregion
}

public class FPSCounter
{
    public float current = 0.0f;

    public float updateInterval = 0.5f;

    float accum = 0; // FPS accumulated over the interval
    int frames = 100; // Frames drawn over the interval
    float timeleft; // Left time for current interval

    float delta;

    public FPSCounter()
    {
        timeleft = updateInterval;
    }

    public bool Update()
    {
        delta = Time.deltaTime;

        timeleft -= delta;
        accum += Time.timeScale / delta;
        ++frames;

        // Interval ended - update GUI text and start new interval
        if (timeleft <= 0.0f)
        {
            // display two fractional digits (f2 format)
            current = accum / frames;
            timeleft = updateInterval;
            accum = 0.0f;
            frames = 0;
            return true;
        }
        return false;
    }
}

public class MemoryCounter
{
    //update interval
    public const float MEMORY_DIVIDER = 1.0f / 1048576; // 1024^2
    float preTime = -10f;
    float interval = 1f;

    public uint totalReserved = 0;
    public uint allocated = 0;
    public long monoMemory = 0;

    public bool Update(int updateInterval)
    {
        if (Time.realtimeSinceStartup - preTime < interval)
        {
            return false;
        }
        else
        {
            preTime = Time.realtimeSinceStartup;
        }

        totalReserved = Profiler.GetTotalReservedMemory();
        allocated = Profiler.GetTotalAllocatedMemory();
        monoMemory = GC.GetTotalMemory(false);
        return true;
    }

    public new string ToString()
    {
        return "Mem(Total):" + totalReserved * MEMORY_DIVIDER + "M" + "\n" +
               "Mem(Alloc):" + allocated * MEMORY_DIVIDER + "M" + "\n" +
               "Mem(Mono):" + monoMemory * MEMORY_DIVIDER + "M";
    }
}
