using UnityEngine;
using System.Collections;
/***
 *@des:warp下Element对应标记
 */
[DisallowMultipleComponent]
public class UIWarpContentItem : MonoBehaviour {

	private int index;
	private UIWarpContent warpContent;

	void OnDestroy(){
		warpContent = null;
	}

	public UIWarpContent WarpContent{
		set{ 
			warpContent = value;
		}
	}

    public void Refresh() {
        transform.localPosition = warpContent.getLocalPositionByIndex(index);
        gameObject.name = index.ToString();
        if (warpContent.onInitializeItem != null && index >= 0)
        {
            warpContent.onInitializeItem(gameObject, index + 1);//匹配LUA索引从1开始，index+1
        }
    }

    public void Call(System.Action<GameObject, int> func)
    {
        func(gameObject, index + 1);
    }

	public int Index {
		set{
			index = value;
            Refresh();
		}
		get{ 
			return index;
		}
	}

}
