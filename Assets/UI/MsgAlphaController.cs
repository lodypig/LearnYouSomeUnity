using UnityEngine;
using System.Collections;
using UnityEngine.UI;
public class MsgAlphaController : MonoBehaviour {

    public RectTransform textRT;
    private RectTransform selfRT;
    public float delay;
    public float showTime;
    private float elaspe;
    public float innerShowTime;

    public Text text;
    



	void Start () {
        selfRT = GetComponent<RectTransform>();
        elaspe = 0f;
	}

    void setAlpha() {
        text.color = new Color(text.color.r, text.color.g, text.color.b, (showTime - elaspe) / (showTime - delay));
    }
    

	
	void Update () {
        if (selfRT.sizeDelta != new Vector2(textRT.rect.width + 100, textRT.rect.height)) {
            selfRT.sizeDelta = new Vector2(textRT.rect.width + 100, textRT.rect.height);
        }
        elaspe  += Time.deltaTime;
        if (elaspe  > delay) {
            setAlpha();
        }
        if (elaspe > showTime) {
            //TTLoger.Log(SysInfoLayer.Instance.pickList.Remove(gameObject));
            GameObject.Destroy(gameObject);
        }
	}


}
