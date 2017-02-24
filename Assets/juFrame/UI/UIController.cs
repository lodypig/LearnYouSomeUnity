using UnityEngine;
using System.Collections;

public class UIController : MonoBehaviour {

    public WindowLayer layer = WindowLayer.SECOND_LEVEL_PANEL;

    private UILayer mUILayer = null;

    public UILayer uiLayer
    {
        get
        {
            if (mUILayer == null)
            {
                mUILayer = this.GetComponent<UILayer>();
            }
            return mUILayer;
        }
    }

    public void OnDestroy()
    {
        UIManager.Instance.RemoveFromLayer(layer, this);

        if (layer == WindowLayer.SECOND_LEVEL_PANEL)
        {
            AudioManager.PlaySoundFromAssetBundle("close_ui");
        }
    }
}
