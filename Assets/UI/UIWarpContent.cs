using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using System;
using UnityEngine.EventSystems;
using DG.Tweening;

[DisallowMultipleComponent]
public class UIWarpContent : MonoBehaviour, IEndDragHandler
{
    public Action<GameObject, int> onInitializeItem;

	public enum Arrangement
	{
		Horizontal,
		Vertical,
        Page,
	}

	/// <summary>
	/// Type of arrangement -- vertical or horizontal.
	/// </summary>

	public Arrangement arrangement = Arrangement.Horizontal;

	/// <summary>
	/// Maximum children per line.
	/// If the arrangement is horizontal, this denotes the number of columns.
	/// If the arrangement is vertical, this stands for the number of rows.
	/// </summary>
	[Range(1,50)]
	public int maxPerLine = 1;
    [Range(1, 50)]
    public int linePerPage = 1;
    [Range(0, 30)]
    public int viewCount = 5;

	/// <summary>
	/// The width of each of the cells.
	/// </summary>

	public float cellWidth = 200f;

	/// <summary>
	/// The height of each of the cells.
	/// </summary>

	public float cellHeight = 200f;

	/// <summary>
	/// The Width Space of each of the cells.
	/// </summary>
	[Range(0, 50)]
	public float cellWidthSpace = 0f;

	/// <summary>
	/// The Height Space of each of the cells.
	/// </summary>
	[Range(0, 50)]
	public float cellHeightSpace = 0f;

    [Range(0, 50)]
    public float cellPageSpace = 0f;

	public ScrollRect scrollRect;

	public RectTransform content;

	public GameObject goItemPrefab;

	private int dataCount;

	private int curScrollPerLineIndex = -1;
    private int curScrollPage = 0;
    private int pageCount;
    private float pageWidth;

    private List<UIWarpContentItem> listItem = new List<UIWarpContentItem>();

    private Queue<UIWarpContentItem> unUseItem = new Queue<UIWarpContentItem>();

    //翻页
    public Transform pageRoot;
    public Image pageNoraml; //分页圆点
    public Image pageSelect; //分页圆点选中
    public List<GameObject> pageList;


	void Awake(){		
        pageList = new List<GameObject>();
        if(pageNoraml != null) pageNoraml.gameObject.SetActive(false);
        if(pageSelect != null) pageSelect.gameObject.SetActive(false);
        scrollRect.onValueChanged.RemoveAllListeners();
        scrollRect.onValueChanged.AddListener(onValueChanged);
}

    public void BindInitializeItem(Action<GameObject,int> onInitializeItem)
    {
        this.onInitializeItem = onInitializeItem;
    }

	public void Init(int dataCount)
	{
		if (scrollRect == null || content == null || goItemPrefab == null) {
            TTLoger.LogError("异常:请检测<" + gameObject.name + ">对象上UIWarpContent对应ScrollRect、Content、GoItemPrefab 是否存在值...." + scrollRect + " _" + content + "_" + goItemPrefab);
			return;
		}
		if (dataCount < 0)
		{
			return;
		}
		setDataCount(dataCount);

		
        if (arrangement == Arrangement.Page)
        {
            scrollRect.inertia = false;
        }

        //移除
        for (int i = listItem.Count - 1; i >= 0; i--)
        {
            UIWarpContentItem item = listItem[i];
            item.Index = -1;
            unUseItem.Enqueue(item);
        }
        listItem.Clear();

        setUpdateRectItem(getCurScrollPerLineIndex());
	}

    // 在listItem初始化后使用
    public void ForEach(Action<GameObject, int> func)
    {        
        for (int i = 0; i < listItem.Count; ++i)
        {
            listItem[i].Call(func);
        }
    }

	private void setDataCount(int count)
	{
		if (dataCount == count) 
		{
			return;
		}
		dataCount = count;
		setUpdateContentSize();
        if (arrangement == Arrangement.Page)
        {
            initPage();
            setCurPage(0);
        }
	}

    private void initPage()
    {
        if (pageRoot == null || pageNoraml == null)
            return;

        for (int i = 0; i < pageCount; i++)
        {
            if (pageList.Count <= i)
            {
                GameObject go = GameObject.Instantiate(pageNoraml.gameObject);
                go.SetActive(true);
                go.transform.SetParent(pageRoot);
                go.transform.localPosition = Vector3.zero;
                go.transform.localRotation = Quaternion.identity;
                go.transform.localScale = Vector3.one;
                pageList.Add(go);
            }
            else
            {
                pageList[i].SetActive(true);
            }
        }
        for(int i=pageCount; i<pageList.Count; i++)
            pageList[i].SetActive(false);
    }

    private void setCurPage(int page)
    {
        //设置页数
        for (int i = 0; i < pageList.Count; i++)
        {
            Image image = pageList[i].GetComponent<Image>();
            if (i == page)
                image.sprite = pageSelect.sprite;
            else
                image.sprite = pageNoraml.sprite;
        }
    }

	private void onValueChanged(Vector2 vt2)
    {

		int _curScrollPerLineIndex = getCurScrollPerLineIndex ();
		if (_curScrollPerLineIndex == curScrollPerLineIndex){
			return;
		}
		setUpdateRectItem (_curScrollPerLineIndex);
	}

    public virtual void OnEndDrag(PointerEventData eventData)
    {
        if(arrangement == Arrangement.Page)
        {
            float posX = content.anchoredPosition.x < 0 ? Mathf.Abs(content.anchoredPosition.x) : 0;
            int toPage = Mathf.RoundToInt(posX / (pageWidth + cellPageSpace));//当前第几页

            if (eventData.delta.x > 10)
                toPage--;
            else if (eventData.delta.x < -10)
                toPage++;

            if (toPage < 0 ) toPage = 0;
            if (toPage >= pageCount) toPage = pageCount - 1;

            content.DOKill();
            content.DOAnchorPosX(-toPage * (pageWidth + cellPageSpace), 0.5f);

            setCurPage(toPage);
        }
    }

    public void Refresh(int count) {
        if (dataCount != count) {
            setDataCount(count);
            setUpdateRectItem(getCurScrollPerLineIndex());
        }

        for (int i = 0; i < listItem.Count; ++i) {
            listItem[i].Refresh();
        }
    }
        


    /**
     * @des:设置更新区域内item
     * 功能:
     * 1.隐藏区域之外对象
     * 2.更新区域内数据
     * 3.Arrangement类型为page时，参数为当前页
     */
    private void setUpdateRectItem(int scrollPerLineIndex)
	{
		if (scrollPerLineIndex < 0) 
		{
			return;
		}
		curScrollPerLineIndex = scrollPerLineIndex;
		int startDataIndex = curScrollPerLineIndex * maxPerLine;
		int endDataIndex = (curScrollPerLineIndex + viewCount) * maxPerLine;

        //分页显示时，显示区域加上后一页的内容
        if (arrangement == Arrangement.Page)
        {
            curScrollPage = scrollPerLineIndex;
            startDataIndex = curScrollPage * linePerPage * maxPerLine;
            endDataIndex = (curScrollPage + 2) * linePerPage * maxPerLine;
        }

		//移除
		for (int i = listItem.Count - 1; i >= 0; i--) 
		{
			UIWarpContentItem item = listItem[i];
			int index = item.Index;
			if (index < startDataIndex || index >= endDataIndex || index >= dataCount) 
			{
				item.Index = -1;
				listItem.Remove (item);
				unUseItem.Enqueue (item);
			}
		}
		//显示
		for(int dataIndex = startDataIndex;dataIndex<endDataIndex;dataIndex++)
		{
			if (dataIndex >= dataCount) 
			{
				continue;
			}
			if (isExistDataByDataIndex (dataIndex)) 
			{
				continue;
			}
			createItem (dataIndex);
		}

	}

    public void ResetPosition()
    {
        content.anchoredPosition = Vector2.zero;
        setUpdateRectItem(getCurScrollPerLineIndex());
        if (arrangement == Arrangement.Page)
        {
            setCurPage(0);
        }
    }
	/**
	 * @des:添加当前数据索引数据
	 */
	public void AddItem(int dataIndex)
	{
		if (dataIndex<0 || dataIndex > dataCount) 
		{
			return;
		}
		//检测是否需添加gameObject
		bool isNeedAdd = false;
		for (int i = listItem.Count-1; i>=0 ; i--) {
			UIWarpContentItem item = listItem [i];
			if (item.Index >= (dataCount - 1)) {
				isNeedAdd = true;
				break;
			}
		}
		setDataCount (dataCount+1);

		if (isNeedAdd) {
			for (int i = 0; i < listItem.Count; i++) {
				UIWarpContentItem item = listItem [i];
				int oldIndex = item.Index;
				if (oldIndex>=dataIndex) {
					item.Index = oldIndex+1;
				}
				item = null;
			}
			setUpdateRectItem (getCurScrollPerLineIndex());
		} else {
			//重新刷新数据
			for (int i = 0; i < listItem.Count; i++) {
				UIWarpContentItem item = listItem [i];
				int oldIndex = item.Index;
				if (oldIndex>=dataIndex) {
					item.Index = oldIndex;
				}
				item = null;
			}
		}

	}

	/**
	 * @des:删除当前数据索引下数据
	 */
	public void DelItem(int dataIndex){
		if (dataIndex < 0 || dataIndex >= dataCount) {
			return;
		}
		//删除item逻辑三种情况
		//1.只更新数据，不销毁gameObject,也不移除gameobject
		//2.更新数据，且移除gameObject,不销毁gameObject
		//3.更新数据，销毁gameObject

		bool isNeedDestroyGameObject = (listItem.Count >= dataCount);
		setDataCount (dataCount-1);

		for (int i = listItem.Count-1; i>=0 ; i--) {
			UIWarpContentItem item = listItem [i];
			int oldIndex = item.Index;
			if (oldIndex == dataIndex) {
				listItem.Remove (item);
				if (isNeedDestroyGameObject) {
					GameObject.Destroy (item.gameObject);
				} else {
					item.Index = -1;
					unUseItem.Enqueue (item);			
				}
			}
			if (oldIndex > dataIndex) {
				item.Index = oldIndex - 1;
			}
		}
		setUpdateRectItem(getCurScrollPerLineIndex());
	}


	/**
	 * @des:获取当前index下对应Content下的本地坐标
	 * @param:index
	 * @内部使用
	*/
	public Vector3 getLocalPositionByIndex(int index){
        if(index == -1)
            return new Vector3(-10000, 0, 0);

		float x = 0f;
		float y = 0f;
		float z = 0f;
		switch (arrangement) {
		case Arrangement.Horizontal: //水平方向
			x = (index / maxPerLine) * (cellWidth + cellWidthSpace);
			y = -(index % maxPerLine) * (cellHeight + cellHeightSpace);
			break;
		case  Arrangement.Vertical://垂着方向
			x =  (index % maxPerLine) * (cellWidth + cellWidthSpace);
			y = -(index / maxPerLine) * (cellHeight + cellHeightSpace);
			break;
        case Arrangement.Page:
            int page = index / (linePerPage * maxPerLine);
            index = index % (linePerPage * maxPerLine);
            x = (index % maxPerLine) * (cellWidth + cellWidthSpace) + page * (pageWidth + cellPageSpace) + cellPageSpace * 0.5f;
            y = -(index / maxPerLine) * (cellHeight + cellHeightSpace);
            break;
		}
		return new Vector3(x,y,z);
	}

	/**
	 * @des:创建元素
	 * @param:dataIndex
	 */
	private void createItem(int dataIndex){
		UIWarpContentItem item;
		if (unUseItem.Count > 0) {
			item = unUseItem.Dequeue();
		} else {
			item = addChild (goItemPrefab, content).AddComponent<UIWarpContentItem>();
		}
		item.WarpContent = this;
		item.Index = dataIndex;
		listItem.Add(item);
	}

	/**
	 * @des:当前数据是否存在List中
	 */
	private bool isExistDataByDataIndex(int dataIndex){
		if (listItem == null || listItem.Count <= 0) {
			return false;
		}
		for (int i = 0; i < listItem.Count; i++) {
			if (listItem [i].Index == dataIndex) {
				return true;
			}
		}
		return false;
	}


	/**
	 * @des:根据Content偏移,计算当前开始显示所在数据列表中的行或列
	 */
	private int getCurScrollPerLineIndex()
	{
        float posY = content.anchoredPosition.y > 0 ? content.anchoredPosition.y : 0;
        float posX = content.anchoredPosition.x < 0 ? Mathf.Abs(content.anchoredPosition.x) : 0;
		switch (arrangement) 
		{
		case Arrangement.Horizontal: //水平方向
            return Mathf.FloorToInt(posX / (cellWidth + cellWidthSpace));
		case  Arrangement.Vertical://垂着方向
            return Mathf.FloorToInt(posY / (cellHeight + cellHeightSpace));
        case Arrangement.Page:
            return Mathf.FloorToInt(posX / (pageWidth + cellPageSpace));//当前第几页
		}
		return 0;
	}

	/**
	 * @des:更新Content SizeDelta
	 */
	private void setUpdateContentSize()
	{
		int lineCount = Mathf.CeilToInt((float)dataCount/maxPerLine);
		switch (arrangement)
		{
		 case Arrangement.Horizontal:
			content.sizeDelta = new Vector2(cellWidth * lineCount + cellWidthSpace * (lineCount - 1), content.sizeDelta.y);
			break;
		 case Arrangement.Vertical:
			content.sizeDelta = new Vector2(content.sizeDelta.x, cellHeight * lineCount + cellHeightSpace * (lineCount - 1));
			break;
        case Arrangement.Page:
            pageCount = Mathf.CeilToInt((float)dataCount / (maxPerLine * linePerPage));
            pageWidth = cellWidth  * maxPerLine + cellWidthSpace * (maxPerLine - 1) ;
            content.sizeDelta = new Vector2((pageWidth + cellPageSpace) * pageCount, content.sizeDelta.y);
            break;
		}

	}

	/**
	 * @des:实例化预设对象 、添加实例化对象到指定的子对象下
	 */
	private GameObject addChild(GameObject goPrefab,Transform parent)
	{
		if (goPrefab == null || parent == null) {
            TTLoger.LogError("异常。UIWarpContent.cs addChild(goPrefab = null  || parent = null)");
			return null;
		}
		GameObject goChild = GameObject.Instantiate (goPrefab) as GameObject;
		goChild.layer = parent.gameObject.layer;
		goChild.transform.SetParent (parent,false);
        goChild.SetActive(true);

		return goChild;
	}

	void OnDestroy(){
		
		scrollRect = null;
		content = null;
		goItemPrefab = null;
		onInitializeItem = null;

		listItem.Clear ();
		unUseItem.Clear ();

		listItem = null;
		unUseItem = null;

	}
}
