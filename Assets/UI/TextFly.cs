using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

public class TextFly : MonoBehaviour {

    //public RectTransform textRT;
    //private RectTransform selfRT;

	void Start () {
        //selfRT = GetComponent<RectTransform>();
        //selfRT.sizeDelta.x = textRT.rect.width;
	}
	
	// Update is called once per frame
	void Update () {
    /*    if (selfRT.sizeDelta != new Vector2(textRT.rect.width + 104, textRT.rect.height + 15))
        {
            selfRT.sizeDelta = new Vector2(textRT.rect.width + 104, textRT.rect.height + 15);
        } */
	}

    void AnimationEnd(Object f) {

        GameObject go = this.gameObject;
        go.SetActive(false);
        SysInfoLayer.Instance.Remove(go);
        GameObject.Destroy(go);
    }

    void AppearEnd(Object f) {
        GameObject go = f as GameObject;
        UIManager.Instance.SysLayer.Fly(go);
    }
}
