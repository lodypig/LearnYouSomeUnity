using UnityEngine;
using System.Collections;
using DG.Tweening;
using UnityEngine.UI;

[RequireComponent(typeof(Toggle))]
public class DotweenToggle : MonoBehaviour {

	// Use this for initialization
    public GameObject target;
    DOTweenAnimation ani;
    Toggle toggle;

	void Awake ()
    {
        toggle = GetComponent<Toggle>();
        toggle.onValueChanged.AddListener(Toggle);
        ani = target.GetComponent<DOTweenAnimation>();
	}

    void Start()
    { 
        Toggle(toggle.isOn);
    }
	
	// Update is called once per frame
	public void Toggle (bool toggle)
    {
        if(ani != null)
        {
	        if(toggle)
            {
                ani.DOPlayForward();
            }
            else
            {
                ani.DOPlayBackwards();
            }
        }
           
	}
}
