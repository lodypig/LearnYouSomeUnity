using UnityEngine;
using System.Collections;

public class SendMessage : MonoBehaviour {
	// Use this for initialization
	void Start () {
        print("--------------send message---------------");
        SendMessage("Receive", "argument");
        print("--------------broadcase message---------------");
        BroadcastMessage("Receive", "argument");
        print("--------------send message upwards---------------");
        SendMessageUpwards("Receive", "argument");
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
