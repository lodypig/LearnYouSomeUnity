using UnityEngine;
using System.Collections;

public class ReceiveMessage : MonoBehaviour {
    void Receive(object o) {
        print(this.name + " receive message : " + o);
    }
}
