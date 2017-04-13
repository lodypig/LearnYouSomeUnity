using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using DG.Tweening;

/// <summary>
/// 系统信息类型
/// </summary>
public enum SysInfoType
{
    None,       // None
    Text,       // 文本
    Money,      // 金币
    Diamond,    // 钻石
    Exp,    // 经验
    Item,       // 物品
}


/// <summary>
/// 系统信息数据
/// </summary>
public struct SysInfoData
{
    public SysInfoType type;            // 类型
    public string text;                 // 文本
    public int itemId;                  // 物品id
    public int itemCount;               // 物品数量
    public int itemQuality;             //品质
    public int money;                   // 金币
    public int diamond;                 // 钻石
    public int exp;                     // 经验
    public static SysInfoData Init()
    {
        SysInfoData data;
        data.type = SysInfoType.None;
        data.text = string.Empty;
        data.itemId = 0;
        data.itemCount = 0;
        data.itemQuality = 0;
        data.money = 0;
        data.diamond = 0;
        data.exp = 0;
        return data;
    }

    public bool Equals(SysInfoData other)
    {
        if (this.type != other.type)
            return false;
        if (this.text != other.text)
            return false;
        if (this.itemId != other.itemId)
            return false;
        if (this.itemCount != other.itemCount)
            return false;
        if (this.money != other.money)
            return false;
        if (this.exp != other.exp)
            return false;
        if (this.diamond != other.diamond)
            return false;
        return true;
    }
}

public class SysInfoLayer : MonoSingleton<SysInfoLayer>
{


    //public void OnGUI()
    //{
    //    if (GUI.Button(new Rect((Screen.width - 200) * 0.5f, (Screen.height + 200 - 60) * 0.5f, 200, 60), "飘信息"))
    //    {
    //        int value = UnityEngine.Random.Range(1, 5);
    //        switch(value)
    //        {
    //            case 1:
    //                ShowMsg("hahaha");
    //                break;

    //            case 2:
    //                ShowMoneyMsg(1000);
    //                break;

    //            case 3:
    //                ShowDiamondMsg(500);
    //                break;

    //            case 4:
    //                ShowItemMsg(1, 10);
    //                break;

    //            default:
    //                break;
    //        }
            
            
            
            
    //    }
    //}

    // Use this for initialization

    public GameObject msgObj;
    public GameObject pickPanel;
    public GameObject pickMsg;
    public GameObject moneyMsg;
    public GameObject diamondMsg;
    public GameObject expMsg;
    public GameObject itemMsg;

    public List<GameObject> list = new List<GameObject>();
    public List<GameObject> pickList = new List<GameObject>();

    public Queue<SysInfoData> msgList = new Queue<SysInfoData>();       // 系统消息列表

    private SysInfoData lastMsgData;

    private string lastmsg = null;
    private int pointer = 0;
    private bool showingMsg;
    public int aliveCount = 0;
    public string msg;
    public float delayShowTime = 0;
    private float lastMsgShowTime = 0;
    public float msgY = 200;

    string[] QualityColorStr = 
    {
        "#f1f1f1",
	    "#4BA918",
	    "#1D97F5",
	    "#B940FF", 
	    "#E68829",
	    "#f1f1f1",
	    "#E68829",
    };

    public float GetTimeOfLastMsgShowUtilNow()
    {
        return Time.time - lastMsgShowTime;
    }

    /// <summary>
    /// 移动距离
    /// </summary>
    public float distance = 0f;
    /// <summary>
    /// 飞行时间
    /// </summary>
    public float flyTime = 0.2f;
    /// <summary>
    /// 延迟消失时间
    /// </summary>
    public float fadeTime =  2f;
    //
    //连续出现多个非纯文本时的间隔
    public float intervalTime = 0.5f;

    /// <summary>
    /// 最大拾取信息个数
    /// </summary>
    public int maxPickMsg = 3;

    public static SysInfoLayer GetInstance()
    {
        return Instance;
    }

/*    void Start()
    {

        lastMsgShowTime = Time.time;

        //for (int i = 0; i < maxPickMsg; ++i)
        //{
        //    GameObject go = GameObject.Instantiate(msgObj, Vector3.zero, Quaternion.identity) as GameObject;
        //    go.SetActive(false);
        //    go.transform.SetParent(this.transform);
        //    go.transform.localScale = new Vector3(1, 1, 1);
        //    list.Add(go);
        //}
    }*/


    #region 显示信息



    /* 显示消息文本
     * SysInfoData msgData = SysInfoData.Init();
     * msgData.type = SysInfoType.Text;
     * msgData.text = msg;
     * msgList.Enqueue(msgData);
     * 
    */
    public void ShowMsg(string msg)
    {
        
        Lua.Call<string>("ui.showMsg", msg);
    }

    #endregion

    #region 执行信息


    /// <summary>
    /// 执行文本信息
    /// </summary>
    /// <param name="msgData"></param>
    public GameObject DoTextMsg(SysInfoData msgData)
    {
        GameObject go = GameObject.Instantiate(msgObj) as GameObject;
        TextFly adpation = go.GetComponent<TextFly>();
        Text text = go.GetComponentInChildren<Text>();
        text.text = msgData.text;
        return go;
    }


    /// <summary>
    /// 执行金币信息
    /// </summary>
    /// <param name="msgData"></param>
    public GameObject DoMoneyMsg(SysInfoData msgData)
    {
        GameObject go = GameObject.Instantiate(moneyMsg) as GameObject;
        TextFly adpation = go.GetComponent<TextFly>();
        Text text = go.GetComponentInChildren<Text>();
        text.text = string.Format("+{0}", msgData.money);
        go.SetActive(true);
        return go;
    }


    /// <summary>
    /// 执行钻石信息
    /// </summary>
    /// <param name="msgData"></param>
    public GameObject DoDiamondMsg(SysInfoData msgData)
    {
        GameObject go = GameObject.Instantiate(diamondMsg) as GameObject;
        TextFly adpation = go.GetComponent<TextFly>();
        Text text = go.GetComponentInChildren<Text>();
        text.text = string.Format("+{0}", msgData.diamond);
        go.SetActive(true);
        return go;
    }


    public GameObject DoExpMsg(SysInfoData msgData)
    {
        GameObject go = GameObject.Instantiate(expMsg) as GameObject;
        TextFly adpation = go.GetComponent<TextFly>();
        Text text = go.GetComponentInChildren<Text>();
        text.text = string.Format("+{0}", msgData.exp);
        go.SetActive(true);
        return go;
    }   
    #endregion

    public void HideMsg()
    {
        for (int i = 0; i < flys.Count; ++i)
        {
            flys[i].SetActive(false);
        }
    }


    private List<GameObject> flys = new List<GameObject>();


/*    void Update()
    {
        print("还是执行了");
        UpdateSysInfo();
    }*/

 
    public void ChangeWidth(GameObject go ,SysInfoData msgData)
    {
        RectTransform rt = go.GetComponent<RectTransform>();
        UIWrapper wrapper = go.GetComponent<UIWrapper>();
        UIWrapper text = wrapper.GO("Text");
        string str = wrapper.GO("Text").text;
        if (str.Contains("</color>"))
            str = getTextStr(msgData.text);

        int length = (int)text.textWidth;        

        switch (msgData.type)
        {
            case SysInfoType.Text:
            case SysInfoType.Item:
                rt.sizeDelta = new Vector2(length + 80, 40);
                break;
            case SysInfoType.Money:
            case SysInfoType.Diamond:
            case SysInfoType.Exp:    
                UIWrapper icon = wrapper.GO("Icon");
                rt.sizeDelta = new Vector2(40 + 28 + 10 + length + 40, 40);//前间隔、图标宽度、图标和文本间隔、文本宽度、后间隔
                icon.GetComponent<RectTransform>().anchoredPosition = new Vector3(40, 0, 0);
                text.GetComponent<RectTransform>().anchoredPosition = new Vector3(-40, 0, 0);
                break;
            default:
                 return;
        }
    }

    public string getTextStr(string str)
    {
        string text = null;
        text = str.Replace("</color>", ",");
        while (text.Contains("<color="))
        {
            int i = text.IndexOf("<color=");
            text = text.Remove(i, 15);
        }
        return string.Concat(text.Split(','));
    }

    public void Appear(GameObject go)
    {
        iTween.ValueTo(go, iTween.Hash(
             "from", 0.0f, "to", 1.0f,
             "time", 0.5f,
             //"delay", delayTime,
             "onupdate", "setAlpha"));
    }


    public void DisAppear(GameObject go)
    {
       /* iTween.ValueTo(go, iTween.Hash(
            "from", 1.0f, "to", 0.0f,
            "time", 0.5f,
            "delay", fadeTime,
            "oncomplete", "AnimationEnd",
            "oncompleteparams", go,
            "oncompletetarget", go,
            "onupdate", "setAlpha")); */

        iTween.FadeTo(go, iTween.Hash(
            "alpha", 0,
            "time", 0.5f,
            "delay", fadeTime,
            "oncomplete", "AnimationEnd",
            "oncompleteparams", go,
            "oncompletetarget", go));
    }

    public void Upgo()
    {
        RectTransform rt = null;
        for(int i = 0; i < flys.Count; ++i)
        {
            GameObject go = flys[i];
            rt = go.GetComponent<RectTransform>();
            float position_y = rt.anchoredPosition.y + 45f;
            rt.anchoredPosition = new Vector2(rt.anchoredPosition.x, position_y);
        }
    }


    public void Remove(GameObject go)
    {
        flys.Remove(go);
    }


    public void Fly(GameObject go)
    {

        go.SetActive(true);
        Hashtable args = new Hashtable();
        float dis = go.transform.position.y + distance * this.transform.localScale.y;
        args.Add("position", new Vector3(go.transform.position.x, dis, go.transform.position.z));
        args.Add("easetype", "linear");
        args.Add("time", flyTime);
        args.Add("oncomplete", "AnimationEnd");
        args.Add("oncompleteparams", go);
        args.Add("oncompletetarget", go);

        //iTween.FadeTo(go, 0f, distance /(100 * velocity));
        iTween.MoveTo(go, args);
        iTween.ValueTo(go, iTween.Hash(
             "from", 1.0f, "to", 0.0f,
             "time", flyTime,
             "delay", fadeTime,
             "onupdate", "setAlpha"));
    }
}
