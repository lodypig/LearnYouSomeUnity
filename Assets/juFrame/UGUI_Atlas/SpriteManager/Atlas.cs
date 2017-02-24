using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Atlas {

    Dictionary<string, Sprite> _dict;
    string _name;

    public string name {
        get {
            return _name;
        }
    }

    Material _grayMat;

    public Material grayMaterial {
        get {
            if (_grayMat == null) {
                _grayMat = new Material(material);
                _grayMat.shader = Shader.Find("UI/Default_Gray(MW)");
            }
            return _grayMat;
        }
    }

    public Material material;

    public Atlas(string name) {
        this._dict = new Dictionary<string, Sprite>();
        this._name = name;
    }
    
    public void Add(string spriteName, Sprite sp) {
        this._dict.Add(spriteName, sp);
    }
    public bool Contains(string key) {
        return this._dict.ContainsKey(key);
    }

    public Sprite this[string spriteName] {
        get {
            if (this._dict.ContainsKey(spriteName))
                return this._dict[spriteName];
            return null;
        }
    }

    public void Unload() {
        Dictionary<string, Sprite>.Enumerator enumerator = _dict.GetEnumerator();
        while (enumerator.MoveNext()) { 
            SpriteManager.UnCacheAtlas(enumerator.Current.Key);
        }
        _dict = null;
    }
	
}
