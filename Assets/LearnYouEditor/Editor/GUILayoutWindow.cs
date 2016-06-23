using UnityEngine;
using UnityEditor;
using System.Collections;

public class GUILayoutWindow : EditorWindow {

	[MenuItem("LearnEditor/打开/GUILayoutWindow")]
    public static void ShowWindow() {
        EditorWindow.GetWindow<GUILayoutWindow>();
    }

    void OnGUI() {
        GUILayout.Box("I'm a box", GUILayout.Width(250), GUILayout.Height(180));
    }
}
