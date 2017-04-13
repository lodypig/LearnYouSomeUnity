using UnityEngine;
using System.Collections;

public class ReceiveMessage2 : MonoBehaviour {
    void Receive(object o) {
        print(this.name + " receive message2 : " + o);
    }
}
