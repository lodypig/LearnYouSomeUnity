using UnityEngine;
using UnityEditor;
using System.Collections;

public class BaseGUIWindow : EditorWindow {

    [MenuItem("LearnEditor/打开/BaseGUIWindow")]
    public static void ShowWindow() {
        EditorWindow.GetWindow(typeof(BaseGUIWindow));
    }

    void OnGUI() {
        GUILayout.Label("Label");
        GUILayout.Box("Box");
        if (GUILayout.Button("Button")) {
            UnityEngine.MonoBehaviour.print("Button click");
        }
        GUILayout.Label("BoldLabel", EditorStyles.boldLabel);
        if (GUILayout.RepeatButton("RepeatButton")) {
            UnityEngine.MonoBehaviour.print("Repeat button click");
        }
        GUILayout.TextField("TextField");
        GUILayout.TextArea("TextArea");
        GUILayout.PasswordField("PasswordField", '*', 20);
        GUILayout.Toggle(false, "Toggle");
        GUILayout.Toolbar(0, new string[] { "ToolBar1", "ToolBar2", "ToolBar3"});
        GUILayout.SelectionGrid(0, new string[] { "Grid1", "Grid2", "Grid3", "Grid4" }, 2);
        GUILayout.HorizontalSlider(5, 0, 10);
        GUILayout.HorizontalScrollbar(2, 500, 0, 10);
        GUILayout.VerticalSlider(3, 0, 10);
        GUILayout.VerticalScrollbar(4, 8, 0, 10);
    }
}
