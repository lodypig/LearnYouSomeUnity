/****************************************************************************
Copyright (c) 2015 Lingjijian

Created by Lingjijian on 2015

342854406@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
using UnityEngine;
using System.Collections.Generic;
using System.Security;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Text.RegularExpressions;

//RichText元素的几种类型
public enum RichType
{
    TEXT,
    IMAGE,
    ANIM,
    NEWLINE,
}
//这个是RichText对象的锚点位置，而子对象锚点在左下角
public enum RichAlignType
{
    DESIGN_CENTER,
    LEFT_TOP,
}

//RichText元素基类
public class LRichElement : Object {

    public RichType type { get; protected set; }
    public Color color { get; protected set; }
    public string data { get; protected set; }
}
/// <summary>
/// 文本元素
/// </summary>
public class LRichElementText : LRichElement
{
    public string txt { get; protected set; }
    public bool isUnderLine { get; protected set; }
    public bool isOutLine { get; protected set; }
    public int fontSize { get; protected set; }

    public LRichElementText(Color color, string txt, int fontSize, bool isUnderLine, bool isOutLine, string data)
    {
        this.type = RichType.TEXT;
        this.color = color;
        this.txt = txt;
        this.fontSize = fontSize;
        this.isUnderLine = isUnderLine;
        this.isOutLine = isOutLine;
        this.data = data;
    }
}

/// <summary>
/// 图片元素
/// </summary>
public class LRichElementImage : LRichElement
{
    public string path { get; protected set; }
    public int width { get; protected set; }
    public int height { get; protected set; }

    public LRichElementImage( string path, int width,int height,string data)
    {
        this.type = RichType.IMAGE;
        this.path = path;
        this.width = width;
        this.height = height;
        this.data = data;
    }
}

/// <summary>
/// 动画元素
/// </summary>
public class LRichElementAnim : LRichElement
{
    public string path { get; protected set; }
    public int frameCount { get; protected set; }
    public int width { get; protected set; }
    public int height { get; protected set; }
    public float fs { get; protected set; }

    public LRichElementAnim(string path,int frameCount, int width,int height, float fs, string data)
    {
        this.type = RichType.ANIM;
        this.path = path;
        this.frameCount = frameCount; 
        this.width = width;
        this.height = height;
        this.data = data;
        this.fs = fs;
    }
}

/// <summary>
/// 换行元素
/// </summary>
public class LRichElementNewline : LRichElement
{
    public LRichElementNewline()
    {
        this.type = RichType.NEWLINE;
    }
}

/// <summary>
/// 缓存结构
/// </summary>
class LRichCacheElement : Object
{
    public bool isUse;
    public GameObject node;
    public LRichCacheElement(GameObject node)
    {
        this.node = node;
    }
}

/// <summary>
/// 渲染结构
/// </summary>
struct LRenderElement
{
    public RichType type;
    public string strChar;
    public int width;
    public int height;
    public bool isOutLine;
    public bool isUnderLine;
    public Font font;
    public int fontSize;
    public Color color;
    public string data;
    public string path;
    public int frameCount;
    public float fs;
    public bool isNewLine;
    public Vector2 pos;

    public LRenderElement Clone()
    {
        LRenderElement cloneOjb;
        cloneOjb.type = this.type;
        cloneOjb.strChar = this.strChar;
        cloneOjb.width = this.width;
        cloneOjb.height = this.height;
        cloneOjb.isOutLine = this.isOutLine;
        cloneOjb.isUnderLine = this.isUnderLine;
        cloneOjb.font = this.font;
        cloneOjb.fontSize = this.fontSize;
        cloneOjb.color = this.color;
        cloneOjb.data = this.data;
        cloneOjb.path = this.path;
        cloneOjb.fs = this.fs;
        cloneOjb.frameCount = this.frameCount;
        cloneOjb.isNewLine = this.isNewLine;
        cloneOjb.pos = this.pos;
        return cloneOjb;
    }
}

public enum InputType
{
    INPUT_FIELD,    //使用输入控件来输入要解析的字符（需要在LRichText创建时指定输入控件）
    CONST_STRING,   //内容不会发生变化，指定固定的字符串来初始化
    MANUAL_CONTROL, //用户手动进行调用，begin时不进行任何解析操作
}

// RichText富文本类，一般使用时只需要使用LRichText.text赋值就可以
[AddComponentMenu("UI/RichText")]
public class LRichText : MonoBehaviour, IPointerDownHandler, IPointerClickHandler, IPointerUpHandler
{
    //与字符解析相关的各项变量（临时）
    public Color normalTextColor = Color.white;
    public Color[] itemTextColor;
    public Color linkTextColor = Color.cyan;
    public bool RaycastTarget = true;
    public Font font;
    public int normalFontSize = 15;
    public bool textShadow = false;
    public InputType inputType;
    public InputField input;        //指定关联的InputField(INPUT_FIELD模式下使用)
    public string constStr;         //固定字符串(CONST_STRING模式下使用)
    private string currentStr;      //当前使用的字符串(CONST_STRING模式下使用)

    private static Regex s_RegexHead = new Regex(@"^([^\[]+?)\[", RegexOptions.Singleline); //解析第一个[之前的文字
    private static Regex s_RegexTail = new Regex(@"\]([^\]]+?)$", RegexOptions.Singleline); //解析最后一个]之后的文字
    private static Regex s_RegexNormal1 = new Regex(@"\](.*?)\[", RegexOptions.Singleline);  //匹配两个][之间的文字
    private static Regex s_RegexNormal2 = new Regex(@"^([^\[\]]+?)$", RegexOptions.Singleline);  //匹配一整段没有[]的文字
    private static Regex s_RegexLink = new Regex(@"\[(.*?)\]", RegexOptions.Singleline);  //匹配[]之间的文字
    private static Regex s_RegexNewLine = new Regex(@"\[n\]", RegexOptions.Singleline);  //<\n>表示人为切到下一行
    private static Regex s_RegexItem = new Regex(@"\[item:(.+?):(.+?):(.+?)\]", RegexOptions.Singleline);    //匹配一个物品，形如：[item:袖珍生命药剂:item:quality]
    private static Regex s_RegexString = new Regex(@"\[color:(\d+?),(\d+?),(\d+?),(.+?)\]", RegexOptions.Singleline);
    private static Regex s_RegexImage = new Regex(@"\[#(\d{3}):(.+?)\]", RegexOptions.Singleline); //匹配普通图片，给出图片名称(Emote表中),形如:[#001:data]
    private static Regex s_RegexEmote = new Regex(@"\[([\u4e00-\u9fa5:\d]+?)\]", RegexOptions.Singleline);//匹配表情，给出表情名称(Emote表中)，形如:[大将军]
    private static Regex s_RegexLocation = new Regex(@"\[([\u4e00-\u9fa5:\d]+?),(\d+?),(\d+?)\]", RegexOptions.Singleline);//[巨岩沙海,199,200]
    private static Regex s_RegexFenxianLocation = new Regex(@"\[([\u4e00-\u9fa5:\d]+?),(\d+?),(\d+?),(\d+?)\]", RegexOptions.Singleline);//带分线信息[巨岩沙海,1, 199,200]

	public RichAlignType alignType;
	public int verticalSpace;
	public int maxLineWidth;

    public System.Action<string> onClickHandler;
    public int realLineHeight { get; protected set; }
    public int realLineWidth { get; protected set; }

    List<LRichElement> _richElements;
    List<LRenderElement> _elemRenderArr;
    List<LRichCacheElement> _cacheLabElements;
    List<LRichCacheElement> _cacheImgElements;
	List<LRichCacheElement> _cacheFramAnimElements;
    Dictionary<GameObject, string> _objectDataMap;

    SortedDictionary<int, LRichElement> elementDic;

    void Start() 
    {
        if (inputType == InputType.CONST_STRING)
            StartPrase();     
    }

    //通过text直接改变currentStr的值并重新解析
    public string text
    {
        get
        {
            return this.currentStr;
        }
        set
        {
            this.currentStr = value;
            if (this.inputType == InputType.MANUAL_CONTROL)
                StartPrase();
        }
    }
    //===================================================================
    //解析输入字符串以及控制相关的方法
    //===================================================================
    //解析完整的字符串，并生成对应的gameObject
    //以下接口是外部可以调用的接口

    //根据指定的inputField或字符串来进行处理
    public bool StartPrase() 
    {
        if (inputType == InputType.CONST_STRING)
            return PraseTotalString(constStr);
        else if (inputType == InputType.INPUT_FIELD)
            return PraseTotalString(input.text);
        else
            return PraseTotalString(currentStr);  
    }
    public bool PraseTotalString(string sourceStr)
    {
        elementDic.Clear();
        //rtfView.removeAllElements();
        //依次解析所有类型
        //解析普通字符
        ParseHead(sourceStr);
        ParseTail(sourceStr);
        PraseNormalText(sourceStr, s_RegexNormal1);
        PraseNormalText(sourceStr, s_RegexNormal2);
        PraseLink(sourceStr);

        foreach (KeyValuePair<int, LRichElement> pair in elementDic)
        {
            insertElement(pair.Value);
        }
//         onClickHandler = (string data) =>
//         {
//             UIManager.GetInstance().CallLuaMethod("UIChat.ClickRichText", gameObject, data);
//         };
        reloadData();

        return true;
    }

    public void BindClickHandler(System.Action<string> onClick)
    {
        onClickHandler = onClick;
    }

    void ParseHead(string str)
    {
        Match match = s_RegexHead.Match(str);
        if(match != Match.Empty)
        {
            var value = match.Groups[1].Value;
            if (value == "" || value.Contains("]"))
                return;

            LRichElementText element = new LRichElementText(normalTextColor, value, normalFontSize, false, false, "");
            elementDic.Add(match.Index, element);
        }
    }

    void ParseTail(string str)
    {
        Match match = s_RegexTail.Match(str);
        if (match != Match.Empty)
        {
            var value = match.Groups[1].Value;
            if (value == "" || value.Contains("["))
                return;

            LRichElementText element = new LRichElementText(normalTextColor, value, normalFontSize, false, false, "");
            elementDic.Add(match.Index, element);
        }
    }

    void PraseNormalText(string str, Regex reg)
    {
        foreach (Match match in reg.Matches(str))
        {
            var value = match.Groups[1].Value;
            if (value == "")
                continue;
            LRichElementText element = new LRichElementText(normalTextColor, value, normalFontSize, false, false, "");
            elementDic.Add(match.Index, element);
        }
    }

    void PraseLink(string str)
    {
        foreach (Match match in s_RegexLink.Matches(str))
        {
            var value = match.Groups[1].Value;
            if (value == "")
                continue;

            string sourceStr = string.Format("[{0}]", value);
            int index = match.Index;

            //解析换行
            if(PraseNewLine(sourceStr, index))
                continue;
            //解析物品链接
            else if(PraseItem(sourceStr, index))
                continue;
            //解析彩色字符
            else if(ParseColorText(sourceStr, index))
                continue;
            ////解析图片
            else if(ParseImage(sourceStr, index))
                continue;
            //解析表情
            else if(ParseEmote(sourceStr, index))
                continue;
            //解析坐标
            else if (ParseFenXianLocation(sourceStr, index))
                continue;
            //解析坐标
            else if (ParseLocation(sourceStr, index))
                continue;
            else
            {
                LRichElementText element = new LRichElementText(normalTextColor, sourceStr, normalFontSize, false, false, "");
                elementDic.Add(index, element);
            }
            
        }
    }
    bool PraseNewLine(string str, int index)
    {
        if (s_RegexNewLine.IsMatch(str))
        {
            LRichElementNewline element = new LRichElementNewline();
            elementDic.Add(index, element);
            return true;
        }

        return false;
    }
    
    bool PraseItem(string str, int index)
    {
        Match match = s_RegexItem.Match(str);
        if(match != Match.Empty)
        {
            var name = match.Groups[1].Value;
            var data = match.Groups[2].Value;
            int quality = System.Convert.ToInt32( match.Groups[3].Value);
            string strItem = string.Format("[{0}]", name);
            string strData = data;
            Color itemColor = Color.white;
            if(quality < itemTextColor.Length)
                itemColor = itemTextColor[quality];
            LRichElementText element = new LRichElementText(itemColor, strItem, normalFontSize, false, false, strData);
            elementDic.Add(index, element);

            return true;
        }

        return false;
    }

    bool ParseColorText(string str , int index)
    {
        Match match = s_RegexString.Match(str);
        if (match != Match.Empty)
        {
            var r = Mathf.Clamp(int.Parse( match.Groups[1].Value), 0, 255);
            var g = Mathf.Clamp(int.Parse(match.Groups[2].Value), 0, 255);
            var b = Mathf.Clamp(int.Parse(match.Groups[3].Value), 0, 255);
            var text = string.Format("{0}", match.Groups[4].Value);

            Color textColor = new Color((float)r / 255, (float)g / 255, (float)b / 255);

            LRichElementText element = new LRichElementText(textColor, text, normalFontSize, false, false, "");
            elementDic.Add(index, element);
            return true;
        }

        return false;
    }

    bool ParseImage(string str, int index)
    {
        Match match = s_RegexImage.Match(str);
        if (match != Match.Empty)
        {
            //这里如果图片种类不多的话，可以考虑直接写个
            var id = match.Groups[1].Value;
            var data = match.Groups[2].Value;
            if (!GameTable.EmoteDict.ContainsKey(id))
            {
                return false;
            }
            Emote emote = GameTable.EmoteDict[id];
            string path = emote.emotePath;
            int width = emote.width;
            int height = emote.height;
            string strData = string.Format("image,{0}",data);
            LRichElementImage element = new LRichElementImage(path, width, height, strData);
            elementDic.Add(index, element);

            return true;
        }

        return false;
    }

    bool ParseEmote(string str, int index)
    {
        Match match = s_RegexEmote.Match(str);
        if (match != Match.Empty)
        {
            var id = match.Groups[1].Value;
            if (!GameTable.EmoteDict.ContainsKey(id))
            {
                return false;
            }
            Emote emote = GameTable.EmoteDict[id];
            string path = emote.emotePath;
            int frameCount = emote.frameCount;
            float fps = emote.fps;
            int width = emote.width;
            int height = emote.height;
            LRichElementAnim element = new LRichElementAnim(path, frameCount,width, height, fps, "");
            elementDic.Add(index, element);
            return true;
        }

        return false;
    }

    bool ParseLocation(string str, int index) 
    {
        Match match = s_RegexLocation.Match(str);
        if (match != Match.Empty)
        {
            var mapName = match.Groups[1].Value;
            var posX = match.Groups[2].Value;
            var posY = match.Groups[3].Value;
            string strLink = "";
            if (posX == "0" && posY == "0")
            {
                strLink = string.Format("[{0}]", mapName);
                Scene scene = getSceneByName(mapName);
                if (scene == null) return false;

                posX = Mathf.RoundToInt(scene.bornpos.x * 2).ToString();
                posY = Mathf.RoundToInt(scene.bornpos.y * 2).ToString();
            }
            else
                strLink = string.Format("[{0}<{1},{2}>]", mapName, posX, posY);
            string strData = string.Format("location,{0},{1},{2}", mapName, posX, posY);
            LRichElementText element = new LRichElementText(linkTextColor, strLink, normalFontSize, true, false, strData);
            elementDic.Add(index, element);
            return true;
        }

        return false;
    }

    bool ParseFenXianLocation(string str, int index) 
    {
        Match match = s_RegexFenxianLocation.Match(str);
        if (match != Match.Empty)
        {
            var mapName = match.Groups[1].Value;
            var fenxianID = match.Groups[2].Value;
            var posX = match.Groups[3].Value;
            var posY = match.Groups[4].Value;
            string strLink = "";
            if (posX == "0" && posY == "0")
            {
                strLink = string.Format("[{0}]", mapName);
                Scene scene = getSceneByName(mapName);
                if (scene == null) return false;

                posX = Mathf.RoundToInt(scene.bornpos.x * 2).ToString();
                posY = Mathf.RoundToInt(scene.bornpos.y * 2).ToString();
            }
            else
                strLink = string.Format("[{0}{1}线<{2},{3}>]", mapName, fenxianID, posX, posY);
            string strData = string.Format("fenxianLocation,{0},{1},{2},{3}", mapName, fenxianID, posX, posY);
            LRichElementText element = new LRichElementText(linkTextColor, strLink, normalFontSize, true, false, strData);
            elementDic.Add(index, element);
            return true;
        }

        return false;
    }

    Scene getSceneByName(string sceneName)
    {
        foreach(KeyValuePair<int, Scene> kv in GameTable.SceneDict)
        {
            if (kv.Value.name == sceneName)
                return kv.Value;
        }

        return null;
    }

    void removeAllElements()
    {
        for (int i = 0; i < _cacheLabElements.Count; i++) 
        {
            LRichCacheElement lab = _cacheLabElements[i];
            lab.isUse = false;
            lab.node.transform.SetParent(Hierarchy.UIRoot.transform);            
        }
        for (int i = 0; i < _cacheImgElements.Count; i++)
        {
            LRichCacheElement lab = _cacheImgElements[i];
            lab.isUse = false;
            lab.node.transform.SetParent(Hierarchy.UIRoot.transform);
        }
        for (int i = 0; i < _cacheFramAnimElements.Count; i++)
        {
            LRichCacheElement lab = _cacheFramAnimElements[i];
            lab.isUse = false;
            lab.node.transform.SetParent(Hierarchy.UIRoot.transform);
        }
        _elemRenderArr.Clear();
        _objectDataMap.Clear();
    }

    //插入各种元素的接口，一般不会直接使用
    void insertElement(string txt, Color color, int fontSize, bool isUnderLine, bool isOutLine, Color outLineColor, string data)
    {
        _richElements.Add(new LRichElementText(color, txt, fontSize, isUnderLine, isOutLine, data));
    }

    void insertElement(string path,int frameCount,int width ,int height ,float fp, string data)
    {
        _richElements.Add(new LRichElementAnim(path,frameCount, width, height, fp, data));
    }

    void insertElement(string path, int width, int height, string data)
    {
        _richElements.Add(new LRichElementImage(path, width, height, data));
    }

    void insertElement(int newline)
    {
        _richElements.Add(new LRichElementNewline());
    }

    //通用插入方法，插入已经构造好的LRichElement子类对象
    void insertElement(LRichElement element)
    {
        _richElements.Add(element);
    }

    public LRichText()
    {
        this.alignType = RichAlignType.LEFT_TOP;
        this.verticalSpace = 0;
        this.maxLineWidth = 300;
        this.inputType = InputType.MANUAL_CONTROL;

        _richElements = new List<LRichElement>();
        _elemRenderArr = new List<LRenderElement>();
        _cacheLabElements = new List<LRichCacheElement>();
        _cacheImgElements = new List<LRichCacheElement>();
		_cacheFramAnimElements = new List<LRichCacheElement> ();
        _objectDataMap = new Dictionary<GameObject, string>();
        elementDic = new SortedDictionary<int, LRichElement>();
        currentStr = "";
    }

    //public LRichText(InputType inputType):this()
    //{
    //    this.inputType = inputType;
    //}

    //===================================================================
    //解析内部结构并生成相关GameObject的方法
    //===================================================================
    //将_richElements中的单个元素拆解为每个字符一个元素，这个时候是一字排开的状态
    //_elemRenderArr中存放的所有元素的list
    void reloadData()
    {
        this.removeAllElements();

		RectTransform rtran = this.GetComponent<RectTransform>();
		//align
		if (alignType == RichAlignType.DESIGN_CENTER)
		{
			rtran.GetComponent<RectTransform>().pivot = new Vector2(0.5f, 0.5f);

		}else if (alignType == RichAlignType.LEFT_TOP)
		{
			rtran.GetComponent<RectTransform>().pivot = new Vector2(0f, 1f);
		}

        foreach (LRichElement elem in _richElements)
        {
            if (elem.type == RichType.TEXT)
            {
                LRichElementText elemText = elem as LRichElementText;
                char[] _charArr = elemText.txt.ToCharArray();
                TextGenerator gen = new TextGenerator();

                foreach (char strChar in _charArr)
                {
                    LRenderElement rendElem = new LRenderElement();
                    rendElem.type = RichType.TEXT;
                    rendElem.strChar = strChar.ToString();
                    rendElem.isOutLine = elemText.isOutLine;
                    rendElem.isUnderLine = elemText.isUnderLine;
                    rendElem.font = this.font;
                    rendElem.fontSize = elemText.fontSize;
                    rendElem.data = elemText.data;
                    rendElem.color = elemText.color;

                    TextGenerationSettings setting = new TextGenerationSettings();
                    setting.font = this.font;
                    setting.fontSize = elemText.fontSize;
                    setting.lineSpacing = 1;
                    setting.scaleFactor = 1;
					setting.verticalOverflow = VerticalWrapMode.Overflow;
					setting.horizontalOverflow = HorizontalWrapMode.Overflow;

                    rendElem.width = (int)gen.GetPreferredWidth(rendElem.strChar, setting);
                    rendElem.height = (int)gen.GetPreferredHeight(rendElem.strChar, setting);
                    _elemRenderArr.Add(rendElem);
                }
            }
            else if (elem.type == RichType.IMAGE)
            {
                LRichElementImage elemImg = elem as LRichElementImage;
                LRenderElement rendElem = new LRenderElement();
                rendElem.type = RichType.IMAGE;
                rendElem.path = elemImg.path;
                rendElem.data = elemImg.data;
                //从配置直接传进来，不用再读取图片大小了
                //Sprite sp = Resources.LoadAssetAtPath(AppConst.RawResPath + rendElem.path, typeof(Sprite)) as Sprite;
                rendElem.width = elemImg.width;
                rendElem.height = elemImg.height;
                _elemRenderArr.Add(rendElem);
            }
            else if (elem.type == RichType.ANIM)
            {
                LRichElementAnim elemAnim = elem as LRichElementAnim;
                LRenderElement rendElem = new LRenderElement();
                rendElem.type = RichType.ANIM;
                rendElem.path = elemAnim.path;
                rendElem.data = elemAnim.data;
                rendElem.frameCount = elemAnim.frameCount;
                rendElem.fs = elemAnim.fs;
                //Sprite sp = Resources.LoadAssetAtPath(AppConst.RawResPath + rendElem.path + "/1", typeof(Sprite)) as Sprite;
                rendElem.width = elemAnim.width;
                rendElem.height = elemAnim.height;
                _elemRenderArr.Add(rendElem);
            }
            else if (elem.type == RichType.NEWLINE)
            {
                LRenderElement rendElem = new LRenderElement();
                rendElem.isNewLine = true;
                _elemRenderArr.Add(rendElem);
            }
        }

        _richElements.Clear();

        formarRenderers();
    }

    protected void formarRenderers()
    {
        int oneLine = 0;
        int lines = 1;
        bool isReplaceInSpace = false;
        int len = _elemRenderArr.Count;
        //这里开始根据刚才已经拆解过的单个元素的长宽，以及每行的最大宽度maxLineWidth
        //从而确定每个元素在每一行的大致相对位置
        for (int i = 0; i < len; i++)
        {
            isReplaceInSpace = false;
            LRenderElement elem = _elemRenderArr[i];
            if (elem.isNewLine) // new line
            {
                oneLine = 0;
                lines++;
                elem.width = 10;
                elem.height = 27;
                elem.pos = new Vector2(oneLine, -lines * 27);

            }
            else //other elements
            {
                if (oneLine + elem.width > maxLineWidth)
                {
                    if (elem.type == RichType.TEXT)
                    {
                       //if (isChinese(elem.strChar) || elem.strChar == " ")
                       //{
                        oneLine = 0;
                        lines++;

                        elem.pos = new Vector2(oneLine, -lines * 27);
                        oneLine = elem.width;
                       //}
                       //else // en
                       //{
                       //    int spaceIdx = 0;
                       //    int idx = i;
                       //    while (idx > 0)
                       //    {
                       //        idx--;
                       //        if (_elemRenderArr[idx].strChar == " " && 
                       //            _elemRenderArr[idx].pos.y == _elemRenderArr[i-1].pos.y ) // just for the same line
                       //        {
                       //            spaceIdx = idx;
                       //            break;
                       //        }
                       //    }
                       //    // can't find space , force new line
                       //    if (spaceIdx == 0)
                       //    {
                       //        oneLine = 0;
                       //        lines++;
                       //        elem.pos = new Vector2(oneLine, -lines * 27);
                       //        oneLine = elem.width;
                       //    }
                       //    else
                       //    {
                       //        oneLine = 0;
                       //        lines++;
                       //        isReplaceInSpace = true; //reset cuting words position

                       //        for (int _i = spaceIdx +1; _i <= i; ++_i)
                       //        {
                       //            LRenderElement _elem = _elemRenderArr[_i];
                       //            _elem.pos = new Vector2(oneLine, -lines * 27);
                       //            oneLine += _elem.width;

                       //            _elemRenderArr[_i] = _elem;
                       //        }
                       //    }
                       //}
                    }else if (elem.type == RichType.ANIM || elem.type == RichType.IMAGE)
                    {
                        lines++;
                        elem.pos = new Vector2(0, -lines * 27);
                        oneLine = elem.width;
                    }
                }
                else
                {
                    elem.pos = new Vector2(oneLine, -lines * 27);
                    oneLine += elem.width;
                }
            }
            if (isReplaceInSpace == false)
            {
                _elemRenderArr[i] = elem;
            }
        }
        //sort all lines
        //根据每个元素的大致位置，确定最终的行数以及每一行所包含的所有元素
        Dictionary<int,List<LRenderElement>> rendElemLineMap = new Dictionary<int,List<LRenderElement>>();
        List<int> lineKeyList = new List<int>();
        len = _elemRenderArr.Count;
        for (int i = 0; i < len ; i++ )
        {
            LRenderElement elem = _elemRenderArr[i];
            List<LRenderElement> lineList;
            
            if (!rendElemLineMap.ContainsKey((int)elem.pos.y))
            {
                lineList = new List<LRenderElement>();
                rendElemLineMap[(int)elem.pos.y] = lineList;
            }
            rendElemLineMap[(int)elem.pos.y].Add(elem);
        }
        // all lines in arr
        List<List<LRenderElement>> rendLineArrs = new List<List<LRenderElement>>();
        foreach (var item in rendElemLineMap)
        {
            lineKeyList.Add(-1 * item.Key);
        }
        lineKeyList.Sort();
        len = lineKeyList.Count;

        //这里开始将单个的元素再组装成一个渲染单元(String,Image,Anim等)
        for (int i = 0; i < len; i++)
        {
            int posY = -1 * lineKeyList[i];
            string lineString = "";
            LRenderElement _lastEleme = rendElemLineMap[posY][0];
            LRenderElement _lastDiffStartEleme = rendElemLineMap[posY][0];
            if (rendElemLineMap[posY].Count > 0)
            {
                List<LRenderElement> lineElemArr = new List<LRenderElement>();

                foreach (LRenderElement elem in rendElemLineMap[posY])
                {
                    if (_lastEleme.type == RichType.TEXT && elem.type == RichType.TEXT)
                    {
                        if (_lastEleme.color == elem.color && _lastEleme.data == elem.data)
                        {
                            // the same color can mergin one string
                            lineString += elem.strChar;
                        }
                        else // diff color
                        {
                            if (_lastDiffStartEleme.type == RichType.TEXT)
                            {
                                LRenderElement _newElem = _lastDiffStartEleme.Clone();
                                _newElem.strChar = lineString;
                                lineElemArr.Add(_newElem);

                                _lastDiffStartEleme = elem;
                                lineString = elem.strChar;
                            }
                        }
                    }
                    else if (elem.type == RichType.IMAGE || elem.type == RichType.ANIM || elem.type == RichType.NEWLINE)
                    {
                        //interrupt
                        if (_lastDiffStartEleme.type == RichType.TEXT)
                        {
                            LRenderElement _newEleme = _lastDiffStartEleme.Clone();
                            _newEleme.strChar = lineString;
                            lineString = "";
                            lineElemArr.Add(_newEleme);
                        }
                        lineElemArr.Add(elem);

                    }else if (_lastEleme.type != RichType.TEXT)
                    {
                        //interrupt
                        _lastDiffStartEleme = elem;
                        if (elem.type == RichType.TEXT)
                        {
                            lineString = elem.strChar;
                        }
                    }
                    _lastEleme = elem;
                }
                // the last elementText
                if (_lastDiffStartEleme.type == RichType.TEXT)
                {
                    LRenderElement _newElem = _lastDiffStartEleme.Clone();
                    _newElem.strChar = lineString;
                    lineElemArr.Add(_newElem);
                }
                rendLineArrs.Add(lineElemArr);
            }
        }

        // offset position
        //确定每个元素的最终y方向位置，并统计出所有行的总高度
        int _offsetLineY = 0;
        realLineHeight = 0;
        len = rendLineArrs.Count;
        for (int i = 0; i < len; i++ )
        {
            List<LRenderElement> _lines = rendLineArrs[i];
            int _lineHeight = 0;
            foreach (LRenderElement elem in _lines)
            {
                _lineHeight = Mathf.Max(_lineHeight, elem.height);
            }
            _lineHeight += verticalSpace;   //加入行间距
            realLineHeight += _lineHeight;
            _offsetLineY += (_lineHeight - 27);

            int _len = _lines.Count;
            for (int j = 0; j < _len; j++ )
            {
                LRenderElement elem = _lines[j];
                elem.pos = new Vector2(elem.pos.x, elem.pos.y - _offsetLineY);
                realLineHeight = Mathf.Max(realLineHeight, (int)Mathf.Abs(elem.pos.y));
				_lines[j] = elem;
            }
            rendLineArrs[i] = _lines;
        }
    
        // place all position
        //将每一个的各个组装好的元素转化为实际的gameObject，置为RichText对象的子对象，并统计出最终的宽度
        realLineWidth = 0;
        GameObject obj = null;
        foreach (List<LRenderElement> _lines in rendLineArrs)
        {
            int _lineWidth = 0;
            foreach (LRenderElement elem in _lines)
            {
                if (!elem.isNewLine)
                {
                    string strComponent = "Text";
                    if (elem.type == RichType.TEXT)
                    {
                        obj = getCacheLabel();
                        makeLabel(obj, elem);
						_lineWidth += (int)obj.GetComponent<Text>().preferredWidth;
                        strComponent = "Text";
                    }
                    else if (elem.type == RichType.IMAGE)
                    {
                        obj = getCacheImage(true);
                        makeImage(obj, elem);
                        _lineWidth += (int)obj.GetComponent<Image>().preferredWidth;
                        strComponent = "Image";
                    }
                    else if (elem.type == RichType.ANIM)
                    {
                        obj = getCacheFramAnim();
                        makeFramAnim(obj, elem);
						_lineWidth += elem.width;
                        strComponent = "Animation";
					}
                    obj.GetComponent<Graphic>().raycastTarget = RaycastTarget;;
					obj.transform.SetParent(transform);
                    RectTransform rect = obj.transform as RectTransform;
                    rect.anchoredPosition3D = new Vector3(elem.pos.x, elem.pos.y /*+ realLineHeight*/,0);
                    rect.localScale = new Vector3(1, 1, 1);
                    _objectDataMap[obj] = elem.data;
                }
            }
            realLineWidth = Mathf.Max(_lineWidth, realLineWidth);
        }

        //调整RichText对象的宽高
        RectTransform rtran = this.GetComponent<RectTransform>();
        //align
        if (alignType == RichAlignType.DESIGN_CENTER)
        {
            rtran.sizeDelta = new Vector2(realLineWidth, realLineHeight);

        }else if (alignType == RichAlignType.LEFT_TOP)
        {
            rtran.sizeDelta = new Vector2(realLineWidth, realLineHeight);
        }
    }

   	void makeLabel(GameObject lab,LRenderElement elem)
    {
        Text comText = lab.GetComponent<Text>();
        if (comText != null)
        {
            comText.text = elem.strChar;
            comText.font = elem.font;
            comText.fontSize = elem.fontSize;
            comText.fontStyle = FontStyle.Normal;
            comText.color = elem.color;
        }

		Outline outline = lab.GetComponent<Outline>();
		if (elem.isOutLine) {
			if(outline == null){
				outline = lab.AddComponent<Outline>();
			}
		} else {
			if(outline){
				Destroy(outline);
			}
		}

		if (elem.isUnderLine)
        {
            GameObject underLine = getCacheImage(false);
            Image underImg = underLine.GetComponent<Image>();
            underImg.sprite = null;
            underImg.color = elem.color;
            underImg.GetComponent<RectTransform>().sizeDelta = new Vector2(comText.preferredWidth, 2);
            underLine.transform.SetParent(transform);
            underLine.transform.localPosition = Vector3.zero;
            RectTransform rect = underLine.transform as RectTransform;
            rect.anchoredPosition = new Vector2(elem.pos.x, elem.pos.y);
            rect.localScale = new Vector3(1, 1, 1);
            //underLine.transform.localPosition = new Vector2(elem.pos.x, elem.pos.y);
        }
    }

    void makeImage(GameObject img, LRenderElement elem)
    {
        Image comImage = img.GetComponent<Image>();
        comImage.color = Color.white;
        if (comImage != null)
        {
            Sprite sp  = AssetBundleManager.godLoader.Load(GameResType.Emote, PathUtil.GetFileNameWithoutExtension(elem.path),typeof(Sprite)) as Sprite;
			comImage.sprite = sp;
        }
    }

	void makeFramAnim(GameObject anim, LRenderElement elem)
    {
        LMovieClip comFram = anim.GetComponent<LMovieClip>();
        if (comFram != null)
        {
            comFram.path = elem.path;
			comFram.fps = elem.fs;
            comFram.frameLength = elem.frameCount;
			comFram.loadTexture ();
            comFram.play();
        }
    }

    protected GameObject getCacheLabel()
    {
        GameObject ret = null;
        int len = _cacheLabElements.Count;
        for (int i = 0; i < len;i++ )
        {
            LRichCacheElement cacheElem = _cacheLabElements[i];
            if (cacheElem.isUse == false)
            {
                cacheElem.isUse = true;
                ret = cacheElem.node;
                break;
            }
        }
        if (ret == null)
        {
            ret = new GameObject();
            ret.AddComponent<Text>();
            if (textShadow)
                ret.AddComponent<Shadow>();
            ContentSizeFitter fit = ret.AddComponent<ContentSizeFitter>();
            fit.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
            fit.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;
			
			RectTransform rtran = ret.GetComponent<RectTransform>();
			rtran.pivot = Vector2.zero;
			rtran.anchorMax =new Vector2(0,1);
			rtran.anchorMin = new Vector2(0,1);

            LRichCacheElement cacheElem = new LRichCacheElement(ret);
            cacheElem.isUse = true;
            _cacheLabElements.Add(cacheElem);
        }
        return ret;
    }

    protected GameObject getCacheImage(bool isFitSize)
    {
        GameObject ret = null;
        int len = _cacheImgElements.Count;
        for (int i = 0; i < len; i++)
        {
            LRichCacheElement cacheElem = _cacheImgElements[i];
            if (cacheElem.isUse == false)
            {
                cacheElem.isUse = true;
                ret = cacheElem.node;
                break;
            }
        }
        if (ret == null)
        {
            ret = new GameObject();
            ret.AddComponent<Image>();
            ContentSizeFitter fit = ret.AddComponent<ContentSizeFitter>();
            fit.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
            fit.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;

            RectTransform rtran = ret.GetComponent<RectTransform>();
            rtran.pivot = Vector2.zero;
            rtran.anchorMax = new Vector2(0, 1);
            rtran.anchorMin = new Vector2(0, 1);
            
            LRichCacheElement cacheElem = new LRichCacheElement(ret);
            cacheElem.isUse = true;
            _cacheImgElements.Add(cacheElem);
        }
        ContentSizeFitter fitCom = ret.GetComponent<ContentSizeFitter>();
        fitCom.enabled = isFitSize;
        return ret;
    }

	protected GameObject getCacheFramAnim()
	{
		GameObject ret = null;
		int len = _cacheFramAnimElements.Count;
		for (int i = 0; i < len;i++ )
		{
			LRichCacheElement cacheElem = _cacheFramAnimElements[i];
			if (cacheElem.isUse == false)
			{
				cacheElem.isUse = true;
				ret = cacheElem.node;
				break;
			}
		}
		if (ret == null)
		{
			ret = new GameObject();
            ret.AddComponent<Image>();
            ContentSizeFitter fit = ret.AddComponent<ContentSizeFitter>();
            fit.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
            fit.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;

            RectTransform rtran = ret.GetComponent<RectTransform>();
            rtran.pivot = Vector2.zero;
            rtran.anchorMax = new Vector2(0, 1);
            rtran.anchorMin = new Vector2(0, 1);

			ret.AddComponent<LMovieClip>();
			
			LRichCacheElement cacheElem = new LRichCacheElement(ret);
			cacheElem.isUse = true;
			_cacheFramAnimElements.Add(cacheElem);
		}
		return ret;
	}

    protected bool isChinese(string text)
    {
        bool hasChinese = false;
        char[] c = text.ToCharArray();
        int len = c.Length;
        for (int i = 0; i < len; i++)
        {
            if (c[i] >= 0x4e00 && c[i] <= 0x9fbb)
            {
                hasChinese = true;
                break;
            }
        }
        return hasChinese;
    }

    public void OnPointerClick(PointerEventData data)
    {
        if (_objectDataMap.ContainsKey(data.pointerEnter))
        {
            if (onClickHandler !=null)
            {
                onClickHandler(_objectDataMap[data.pointerEnter]);
            }
        }
        
    }

    public void OnPointerUp(PointerEventData eventData)
    {

    }

    public void OnPointerDown(PointerEventData eventData)
    {

    }

    public static bool IsRichElement(string text)
    {
        Match match = s_RegexItem.Match(text);
        if (match != Match.Empty)
            return true;

        match = s_RegexEmote.Match(text);
        if (match != Match.Empty)
            return true;

        match = s_RegexLocation.Match(text);
        if (match != Match.Empty)
            return true;

        match = s_RegexFenxianLocation.Match(text);
        if (match != Match.Empty)
            return true;

        return false;
            
    }
}
