using UnityEngine;
using System.Collections;

public class CoroutineProvider : MonoBehaviour {

    public static CoroutineProvider _instance;

    public static CoroutineProvider Instance { 
        get {
            if (_instance == null) {
                GameObject go = new GameObject();
                _instance = go.AddComponent<CoroutineProvider>();
            }
            return _instance;
        }
    }
    
}
