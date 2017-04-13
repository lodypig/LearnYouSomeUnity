using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class CustomToggle : MonoBehaviour {

    public CustomToggleGroup group;
    private UIWrapper wrapper;
    private Image image;
	// Use this for initialization
    public Sprite normal;
    public Sprite down;
    public Sprite choosen;

    void Awake() {

        group.addToggle(this);

        wrapper = this.GetComponent<UIWrapper>();
        image = this.GetComponent<Image>();
    }
	void Start () {
        

        if (null == wrapper || null == image) {
            return;
        }
        wrapper.BindButtonDown(btnDown);
        wrapper.BindButtonUp(btnUp);
        wrapper.BindButtonClick(btnClick);
	}

    public void btnDown(GameObject go) {
        image.sprite = down;
        Animation ani = this.GetComponent<Animation>();
        ani.Play();
         
    }



    public void btnUp(GameObject go) {
        wrapper.transform.localScale = new Vector3(1, 1, 1);
    }

    public void btnClick(GameObject go) {
        SetChoosen();
    }


    public void SetChoosen() {
        //
        if (image != null) {
            image.sprite = choosen;
        } else {
            GetComponent<Image>().sprite = choosen;
        }
        
        group.resetOther(this);
    }


    public void Reset() {
        image.sprite = normal;
        wrapper.transform.localScale = new Vector3(1, 1, 1);
    }




}
