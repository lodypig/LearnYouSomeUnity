using UnityEngine.UI;
using UnityEngine;
using System;

/// <summary>
/// 新手引导遮罩
/// </summary>
public class GuideMask : Image{

    public RectTransform target;       //要点击目标对像
    private event Action<bool> onTouchUp;    //点到目标的回调 
    private event Action<bool> onTouchDown;    //点到目标的回调 
    private bool touchInTarget;         //是否点在目标上
    void Awake()
    {
        base.Awake();
    }

    void Update()
    {
        if (Util.IsTouchDown && onTouchDown != null )
        {
            onTouchDown(touchInTarget);
        }

        if(Util.IsTouchUp && onTouchUp != null)
        {
            onTouchUp(touchInTarget);
        }
    }

    public void BindTouchDown(Action<bool> onTouchDown)
    {
        if (onTouchDown == null)
            return;
        this.onTouchDown = onTouchDown;
    }

    public void BindTouchUp(Action<bool> onTouchUp)
    {
        if (onTouchUp == null)
            return;
        this.onTouchUp = onTouchUp;
    }

    public override bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera)
    {
        if (target != null)
        {
            if(RectTransformUtility.RectangleContainsScreenPoint(target, screenPoint, eventCamera))
            {
                touchInTarget = true;
                return false;
            }
        }

        touchInTarget = false;
        return base.IsRaycastLocationValid(screenPoint, eventCamera);
    }

}
