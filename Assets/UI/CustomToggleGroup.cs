using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class CustomToggleGroup : MonoBehaviour {

    private List<CustomToggle> list = new List<CustomToggle>();
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void addToggle(CustomToggle toggle) {
        list.Add(toggle);
    }

    public void resetOther(CustomToggle toggle) {

        for(int i = 0; i < list.Count; i++) {
            if(list[i] != toggle) {
                list[i].Reset();
            }
        }
    }
    

    


}
