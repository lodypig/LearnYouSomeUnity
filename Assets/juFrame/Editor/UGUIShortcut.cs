using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine.UI;
using System.Text;
/// <summary>
/// 根据快捷键创建UGUI控件
/// 快捷键符号% Ctrl  # Shift & Alt   
/// </summary>
public class UGUIShortcutKey : Editor
{

    public const int UIlayer = 5;         //UI

    [MenuItem("UI/创建/文本 #&L")]
    public static void CreateText()
    {
        if (Selection.gameObjects.Length > 0)
        {
            GameObject obj = Selection.gameObjects[0];
            GameObject text = new GameObject();
            RectTransform textRect = text.AddComponent<RectTransform>();
            Text textTx = text.AddComponent<Text>();

            textTx.fontSize = 16;
            textTx.supportRichText = true;
            textTx.alignment = TextAnchor.MiddleCenter;
            text.transform.SetParent(obj.transform);
            text.name = "Text";
            
            text.layer = UIlayer;
            textTx.text = "旋律豬";

            textRect.localScale = new Vector3(1, 1, 1);
            textRect.anchoredPosition = Vector2.zero;
            textRect.anchoredPosition3D = Vector3.zero;


            RectTransformZero(textRect);
            Selection.activeGameObject = text;
        }


    }

    [MenuItem("UI/创建/按钮 #&B")]
    public static void CreateButton()
    {
        if (Selection.gameObjects.Length > 0)
        {
            GameObject obj = Selection.gameObjects[0];
            if (obj == null) return;

            GameObject button = new GameObject();
            GameObject buttonTx = new GameObject();

            RectTransform buttonRect = button.AddComponent<RectTransform>();
            RectTransform buttonTxRect = buttonTx.AddComponent<RectTransform>();

            button.AddComponent<Image>();
            Button btn = button.AddComponent<Button>();
            buttonTx.AddComponent<Text>().alignment = TextAnchor.MiddleCenter;


            btn.transition = Selectable.Transition.SpriteSwap;

            Navigation nav = btn.navigation;
            nav.mode = Navigation.Mode.None;
            btn.navigation = nav;


            button.transform.SetParent(obj.transform);
            buttonTx.transform.SetParent(button.transform);

            button.name = "Button";
            buttonTx.name = "Text";

            button.layer = UIlayer;
            buttonTx.layer = UIlayer;

            RectTransformZero(buttonRect);
            RectTransformZero(buttonTxRect);
            Selection.activeGameObject = button;

        }
    }

    [MenuItem("UI/创建/图片 #&S")]
    public static void CreateImage()
    {
        if (Selection.gameObjects.Length > 0)
        {
            GameObject obj = Selection.gameObjects[0];
            RectTransform selectionObjRect = Selection.gameObjects[0].GetComponent<RectTransform>();

            GameObject image = new GameObject();
            RectTransform imageRect = image.AddComponent<RectTransform>();
            image.AddComponent<Image>();
            image.transform.SetParent(obj.transform);
            image.name = "Image";
            image.layer = 5;
            RectTransformZero(imageRect);
            Selection.activeGameObject = image;
        }

    }

    [MenuItem("GameObject/UI/GetPath")]
    public static void CopyGOPath() {
        GameObject obj = Selection.gameObjects[0];

        List<string> strList = new List<string>();
        strList.Add(obj.name);
        Transform trans = obj.transform;
        while (trans.parent != null) {
            strList.Add(trans.parent.name);
            trans = trans.parent;
        }

        strList.Reverse();
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i < strList.Count; i++) {
            sb.Append(strList[i]);
            if (i != strList.Count - 1) {
                sb.Append(".");
            }
        }
        TTLoger.LogError(sb.ToString());


    }

    [MenuItem("UI/创建/输入框 #&I")]
    public static void CreateInputField()
    {
        //创建UGUI标签
        GameObject obj = Selection.gameObjects[0];

        GameObject inputField = new GameObject();
        RectTransform rectTransform = inputField.AddComponent<RectTransform>();
        Image image = inputField.AddComponent<Image>();
        image.sprite = Resources.Load<Sprite>("UnityPlugins/UGUIShortcutKeyTexture/background1");
        inputField.AddComponent<InputField>();
        rectTransform.localScale = new Vector3(1, 1, 1);
        inputField.layer = UIlayer;

        inputField.transform.SetParent(obj.transform);
        inputField.name = "InputField";

        GameObject placeholder = new GameObject();
        Text placeholderTx = placeholder.AddComponent<Text>();
        placeholder.transform.SetParent(inputField.transform);
        placeholder.name = "Placeholder";
        placeholder.layer = UIlayer;
        placeholderTx.color = Color.black;

        GameObject text = new GameObject();
        Text textTx = text.AddComponent<Text>();
        text.transform.SetParent(inputField.transform);
        text.name = "Text";
        text.layer = UIlayer;

        textTx.color = Color.black;

        RectTransformZero(rectTransform);
        Selection.activeGameObject = inputField;

    }

    [MenuItem("UI/创建/RichText #&R")]
    public static void CreateRichText()
    {
        if (Selection.gameObjects.Length > 0)
        {
            GameObject obj = Selection.gameObjects[0];
            RectTransform selectionObjRect = Selection.gameObjects[0].GetComponent<RectTransform>();

            GameObject richText = new GameObject();
            RectTransform richTextRect = richText.AddComponent<RectTransform>();
            richText.AddComponent<LRichText>();
            richText.transform.SetParent(obj.transform);
            richText.name = "RichText";
            richText.layer = UIlayer;
            RectTransformZero(richTextRect);
            Selection.activeGameObject = richText;
        }
    }

    public static void RectTransformZero(RectTransform rectTransform)
    {
        rectTransform.localScale = new Vector3(1, 1, 1);
        rectTransform.anchoredPosition = Vector2.zero;
        rectTransform.anchoredPosition3D = Vector3.zero;
    }
}