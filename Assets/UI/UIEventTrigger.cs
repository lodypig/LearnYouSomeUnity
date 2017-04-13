using UnityEngine;
using System;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class UIEventTrigger : EventTrigger
{

    #region 事件

    public event Action<GameObject> onButtonUp;
    public event Action<GameObject,int> onButtonDown;
    public event Action<GameObject> onBeginDrag;
    public event Action<GameObject, Vector2> onDrag;
    public event Action<GameObject> onEndDrag;
    public event Action<GameObject> onTouchEnter;
    public event Action<GameObject> onTouchExit;

    public override void OnBeginDrag(PointerEventData eventData)
    {
        base.OnBeginDrag(eventData);
        FireBeginDrag();
    }

    public override void OnDrag(PointerEventData eventData)
    {
        base.OnDrag(eventData);

        FireDrag(eventData);
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        base.OnEndDrag(eventData);

        FireEndDrag();
    }

    public override void OnCancel(BaseEventData eventData)
    {
        base.OnCancel(eventData);
    }
   


    public override void OnPointerDown(PointerEventData eventData)
    {
        base.OnPointerDown(eventData);

        FireButtonDown(eventData);
    }


    public override void OnPointerEnter(PointerEventData eventData)
    {
        base.OnPointerEnter(eventData);
        if (onTouchEnter != null)
            onTouchEnter(gameObject);
    }


    public override void OnPointerExit(PointerEventData eventData)
    {
        base.OnPointerExit(eventData);
        if (onTouchExit != null)
            onTouchExit(gameObject);
    }


    public override void OnPointerUp(PointerEventData eventData)
    {
        base.OnPointerUp(eventData);

        FireButtonUp();
    }

    public void BindBeginDrag(Action<GameObject> onBeginDrag)
    {
        if (onBeginDrag == null)
            return;
        this.onBeginDrag += onBeginDrag;
    }

    public void BindDrag(Action<GameObject, Vector2> _onDrag)
    {
        if (_onDrag == null)
            return;
        this.onDrag = _onDrag;
    }

    public void BindEndDrag(Action<GameObject> onEndDrag)
    {
        if (onEndDrag == null)
            return;
        this.onEndDrag += onEndDrag;
    }

    public void BindButtonUp(Action<GameObject> onButtonUp)
    {
        if (onButtonUp == null)
            return;
        this.onButtonUp += onButtonUp;
    }

    public void BindButtonDown(Action<GameObject,int> onButtonDown)
    {
        if (onButtonDown == null)
            return;
        this.onButtonDown += onButtonDown;
    }

    public void BindTouchEnter(Action<GameObject> onTouchEnter)
    {
        this.onTouchEnter += onTouchEnter;
    }

    public void BindTouchExit(Action<GameObject> onTouchExit)
    {
        this.onTouchExit += onTouchExit;
    }

    public void FireButtonUp()
    {
        if (this.onButtonUp != null)
        {
            this.onButtonUp(this.gameObject);
        }
    }

    public void FireButtonDown(PointerEventData eventData)
    {
        
        if (this.onButtonDown != null)
        {
            if (!NativeManager.GetInstance().shouldForbideTouch()) { 
                this.onButtonDown(this.gameObject, eventData.pointerId);
            }
        }
    }

    public void FireBeginDrag()
    {
        if (this.onBeginDrag != null)
        {
            this.onBeginDrag(this.gameObject);
        }
    }

    public void FireDrag(PointerEventData eventData)
    {
        if (this.onDrag != null)
        {
            this.onDrag(this.gameObject, eventData.delta);
        }
    }

    public void FireEndDrag()
    {
        if (this.onEndDrag != null)
        {
            this.onEndDrag(this.gameObject);
        }
    }

    #endregion

}
