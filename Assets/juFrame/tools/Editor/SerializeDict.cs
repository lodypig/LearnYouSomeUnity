using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

/*
 * dict to serialize
 * list<Tkey> list<TValue> is Serializable
 * 
 */
[System.Serializable]
public class SerializeDict<TKey, TValue> : Dictionary<TKey, TValue>, ISerializationCallbackReceiver
{
    [SerializeField]
    List<TKey> _keys = new List<TKey>();

    [SerializeField]
    List<TValue> _values = new List<TValue>();


    // Before the serialization we fill these lists
    public void OnBeforeSerialize()
    {
        _keys.Clear();
        _values.Clear();
        foreach (var kvp in this)
        {
            _keys.Add(kvp.Key);
            _values.Add(kvp.Value);
        }
    }

    // After the serialization we create the dictionary from the two lists
    public void OnAfterDeserialize()
    {
        this.Clear();        
        for (int i = 0; i < _keys.Count; ++i)
        {
            this.Add(_keys[i], _values[i]);
        }
    }
}

[System.Serializable]
public class strfileDict : SerializeDict<string, TFileInfo> { }

[System.Serializable]
public class strdirDict : SerializeDict<string, TDirInfo> { }
