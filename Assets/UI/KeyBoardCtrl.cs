using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using LuaInterface;

public class KeyBoardCtrl : UISingleton<KeyBoardCtrl>
{
    public List<UIWrapper> btns = new List<UIWrapper>();
    public UIWrapper editText = null;  //点击键盘要操作的文本框
    public bool bDefaultOne = true;  //初始的1,被任意数字覆盖
    public int maxCount = 999;
	// Use this for initialization
	void Start () {
        //这里记录下12个按键的UIWarpper
        for (int i = 0; i < 12; ++i)
        {
            UIWrapper grid = this["KeyBoard"]["grid"];
            UIWrapper btn = grid[i];
            btns.Add(btn);
        }
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void SetUsingText(UIWrapper inputText) 
    {
        editText = inputText;
        //if (!editText.text.Equals("1"))
        //    bDefaultOne = false;
        for (int i = 0; i < btns.Count; ++i)
        {
            btns[i].BindButtonClick(OnButton);      
        }  
    }

    public void OnButton(GameObject go)
    {  
        if (editText == null)
            return;

        //点击确定键，关闭键盘面板(移到脚本)
        if (go.name.Contains("Enter"))
        {
            //GameObject obj = GameObject.Find("UIKeyBoard");
            //Destroy(obj);
            return;
        }
        
        string oldString = editText.text;
        string newString = "";
        for(int i = 0; i <= 9; ++i)
        {            
            //这里判断点击的是否是数字键
            if(go.name.Contains(i.ToString())) 
            {
                //原有字符是默认1，将1替换为当前点击的字符
                if (oldString.Equals("1") && bDefaultOne) 
                {
                    if (i == 0)
                        return;
                    else 
                    {
                        newString = i.ToString();
                        bDefaultOne = false;
                        break;                      
                    }          
                }
                else
                {
                    newString = string.Concat(oldString, i.ToString());
                    if (int.Parse(newString) > maxCount)
                    {
                        //SysInfoLayer.Instance.ShowMsg("数量达到上限！");
                        newString = maxCount.ToString();                   
                    }
                    break;
                }
            }       
        }

        //点击删除键，删掉最后一个字符
        if(go.name.Contains("Delete")) 
        {
            if (oldString.Length > 1)
                newString = oldString.Substring(0, oldString.Length - 1);
            else 
            {
                newString = "1";
                bDefaultOne = true;
            }
        }

        editText.text = newString;
    }

    //public void BindButtonClick(Action<GameObject> onClick)
    //{
    //    if (editText != null) 
    //    {
            
        
    //    }
    //}
}
