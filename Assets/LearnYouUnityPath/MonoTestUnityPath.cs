using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class MonoTestUnityPath : MonoBehaviour
{

	// Use this for initialization
	void Start () {
        GameObject.Find("Canvas/tfDataPath").GetComponent<Text>().text = "dataPath : \n    " + Application.dataPath;
        GameObject.Find("Canvas/tfStreamingAssetsPath").GetComponent<Text>().text = "streamAssetPath : \n    " + Application.streamingAssetsPath;
        GameObject.Find("Canvas/tfPersistentDataPath").GetComponent<Text>().text = "persistentDatapath :\n     " + Application.persistentDataPath;
	}
	
}
