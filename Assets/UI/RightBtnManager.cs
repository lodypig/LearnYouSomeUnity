using UnityEngine;
using System.Collections.Generic;

public class RightBtnManager : UISingleton<RightBtnManager>
{
    public List<UIWrapper> btns = new List<UIWrapper>();
    public UIWrapper current = null;

    public void OnButton(GameObject go)
    {
        Swap(go, current.gameObject);
        current = go.GetComponent<UIWrapper>();
    }


    //交换点击按钮和当前选中按钮的状态
    public void Swap(GameObject go1, GameObject go2)
    {
        if (go1 == go2)
            return;
        UIWrapper uw1 = go1.GetComponent<UIWrapper>();
        UIWrapper uw2 = go2.GetComponent<UIWrapper>();
        //交换形状信息
        RectTransform rt1 = go1.GetComponent<RectTransform>();
        RectTransform rt2 = go2.GetComponent<RectTransform>();
        Vector2 tempRect = Vector2.zero;
        tempRect = rt1.sizeDelta;
        rt1.sizeDelta = rt2.sizeDelta;
        rt2.sizeDelta = tempRect;

        Vector3 ap1 = rt1.anchoredPosition;
        Vector3 ap2 = rt2.anchoredPosition;
        float tempX = ap1.x;
        ap1.x = ap2.x;
        ap2.x = tempX;
        rt1.anchoredPosition = ap1;
        rt2.anchoredPosition = ap2;

        //交换图片
        Sprite tempSprite = uw1.Sprite;
        uw1.Sprite = uw2.Sprite;
        uw2.Sprite = tempSprite;
        //交换文字颜色,位置
        Color tempColor = uw1["text"].textColor;
        uw1["text"].textColor = uw2["text"].textColor;
        uw2["text"].textColor = tempColor;
        RectTransform rect1 = uw1["text"].gameObject.GetComponent<RectTransform>();
        RectTransform rect2 = uw2["text"].gameObject.GetComponent<RectTransform>();
        Vector2 tempPos = rect1.anchoredPosition;
        rect1.anchoredPosition = rect2.anchoredPosition;
        rect2.anchoredPosition = tempPos;
    }


    //public void SetChoosen(UIWrapper btn) 
    //{
    //    btn.sprite = Util.LoadSprite("Qianghua/Dynamic/bqy_1");
    //}

    //public void SetUnChoosen(UIWrapper btn) 
    //{
    //    btn.sprite = Util.LoadSprite("Qianghua/Dynamic/bqy_2"); 
    //}

	// Use this for initialization
	void Start () {

        for (int i = 0; i < this.transform.childCount; ++i)
        {
            UIWrapper btn = this[this.transform.GetChild(i).name];
            btns.Add(btn);
            btn.BindButtonClick(OnButton);
        }
        current = this.transform.GetChild(0).gameObject.GetComponent<UIWrapper>();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
