using UnityEngine;
using UnityEditor;
using System.Collections;

public class GUILayoutWindow : EditorWindow {

	[MenuItem("LearnEditor/打开/GUILayoutWindow")]
    public static void ShowWindow() {
        EditorWindow.GetWindow<GUILayoutWindow>();
    }

    void OnGUI() {
        GUILayout.Button("Top", GUILayout.Height(80));
        GUILayout.BeginArea(new Rect(10, 10, 300, 200));
        GUILayout.Button("A");
        GUILayout.BeginHorizontal("ttt", GUILayout.Width(290));
        GUILayout.BeginVertical("ttttt", GUILayout.Width(250));
        GUILayout.Button("B1");
        GUILayout.Button("B2");
        GUILayout.Button("B3");
        GUILayout.Button("B4");
        GUILayout.Button("B5");
        GUILayout.EndVertical();
        GUILayout.Button("D", GUILayout.Height(20));
        GUILayout.EndHorizontal();
        GUILayout.Button("C");
        GUILayout.EndArea();
        GUILayout.Button("Buttom");
        
    }
}
