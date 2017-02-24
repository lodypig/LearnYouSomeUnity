using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

public class UIPrefabListener  {

	[InitializeOnLoadMethod]
    static void StartInitializeOnLoadMethod(){
        PrefabUtility.prefabInstanceUpdated = OnPrefabInstanceUpdate;
    }

    static void OnPrefabInstanceUpdate(GameObject instance) { 
        GameObject prefab = PrefabUtility.GetPrefabParent(instance) as GameObject;
        LuaBehaviour lb = prefab.GetComponent<LuaBehaviour>();
        if (lb == null) {
            return;
        }        

        UILuaExporter expt = prefab.GetComponent<UILuaExporter>();
        if (expt == null) {
            return;
            //expt = prefab.AddComponent<UILuaExporter>();
            
        }
        lb.exporter = expt;
        expt.subCtrlList = null;

        FillLuaExporter(prefab, expt, true);

        EditorUtility.SetDirty(prefab);
    }

    static void  FillLuaExporter(GameObject go, UILuaExporter parent, bool isRoot)
    {
        var expt = go.GetComponent<UILuaExporter>();
        var currentParent = parent;
        if (expt != null) {
            if (go.name.StartsWith("_") || isRoot) {
                currentParent = expt;
                List<string> names = new List<string>();
                List<UIWrapper> wraps = new List<UIWrapper>();
                FindExport(go, ref names, ref wraps, true);
                expt.SetExport(names, wraps);
                expt.next = null;
                expt.subCtrlList = null;
                string exportName;
                if (isRoot){
                    exportName = go.name;
                } else {
                    exportName = go.name.Substring(1, go.name.Length - 1);
                }
                expt.name = exportName;
                if (string.IsNullOrEmpty(expt.scriptName)) { 
                    expt.scriptName = exportName + "View";
                }
                AddUlc(parent, expt);
            }
        }

        for (int i = 0; i < go.transform.childCount; ++i){
            FillLuaExporter(go.transform.GetChild(i).gameObject, currentParent, false);
        }
    }

    static void AddUlc(UILuaExporter parent, UILuaExporter expt)
    {
        if (parent == expt) {
            return;
        }
        int i = 0;
        if (parent.subCtrlList == null) {
            parent.subCtrlList = new List<UILuaExporter>();
        }
        for (; i < parent.subCtrlList.Count; ++i){
            if (parent.subCtrlList[i].name.Equals(expt.name)){
                var p = parent.subCtrlList[i];
                while (p.next != null) {
                    p = p.next;
                }
                p.next = expt;
                break;
            }
        }

        if (i == parent.subCtrlList.Count) {
            parent.subCtrlList.Add(expt);
        }
    }
   

    static void FindExport(GameObject go, ref List<string> names, ref List<UIWrapper> wrappers, bool isRoot) {
        var expt = go.GetComponent<UILuaExporter>();
        if (expt != null && !isRoot){
            return;
        }

        if (go.name.StartsWith("_")) {
            UIWrapper wrapper = go.GetComponent<UIWrapper>();
            if (wrapper == null) {
                wrapper = go.AddComponent<UIWrapper>();
            }

            string exptName = go.name.Substring(1, go.name.Length - 1);
            names.Add(exptName);
            wrappers.Add(wrapper);
        }

        for (int i = 0; i < go.transform.childCount; ++i) {
            FindExport(go.transform.GetChild(i).gameObject, ref names, ref wrappers, false);
        }
    }
}
