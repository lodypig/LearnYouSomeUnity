using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Text;

[RequireComponent(typeof(Text))]
public class EllipsisEffect : MonoBehaviour {

    public float frequency = 1f;

    private Text text;
    private string content;
    private float delta = 0f;
    private int count = 0;
    StringBuilder sb = new StringBuilder();

    void Awake()
    {
        text = GetComponent<Text>();
        content = text.text;
        sb.Append(content);
    }

	// Update is called once per frame
	void Update () {
        delta += Time.deltaTime;
        if(delta > frequency)
        {
            delta = 0;
            count++;
            count = count % 4;
            sb.Remove(content.Length, sb.Length - content.Length);
            for(int i=0; i<count; i++)
            {
                sb.Append(".");
            }
            text.text = sb.ToString();
        }
	}
}
