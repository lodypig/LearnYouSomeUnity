using UnityEngine;
using System.Collections;

public class WarmUpShader : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Debug.Log("start : " + Time.realtimeSinceStartup);
        Shader.WarmupAllShaders();
        Debug.Log("finish : " + Time.realtimeSinceStartup);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
