using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using DG.Tweening;
public class UICenterOnChild : MonoBehaviour, IEndDragHandler, IDragHandler
{

    private ScrollRect _scrollView;
    private Transform _container;
    private RectTransform _rtContainer;
    private RectTransform _viewport;
 
    private List<float> _childrenPos = new List<float> ();
    private float _targetPos;
 
    void Awake ()
    {
        _scrollView = GetComponent<ScrollRect> ();
        if (_scrollView == null)
        {
            Debug.LogError ("CenterOnChild: No ScrollRect");
            return;
        }
        _container = _scrollView.content;
        _viewport = _scrollView.viewport;
        _rtContainer = _container.GetComponent<RectTransform>();
    }
 
    public void OnEndDrag (PointerEventData eventData)
    {
        _targetPos = FindClosestPos (_container.localPosition.x);
        ScrollRect.MovementType preType = _scrollView.movementType;
        _scrollView.movementType = ScrollRect.MovementType.Unrestricted;
        _rtContainer.DOAnchorPosX(_targetPos, 0.5f).OnComplete(() => { 
            _scrollView.movementType = preType; 
        });
    }
 
    public void OnDrag (PointerEventData eventData)
    {
        _rtContainer.DOKill(true);
    }
 
    private float FindClosestPos (float currentPos)
    {
        int childIndex = 0;
        float closest = 0;
        float distance = Mathf.Infinity;

        //滑动到最左边时，坐标置0，否则取反（因为container的x坐标为负）
        currentPos = currentPos > 0 ? 0 : -currentPos;

        //滑动到最右边时，不做物体居中处理
        if (_rtContainer.rect.width - _viewport.rect.width < currentPos)
            return -(_rtContainer.rect.width - _viewport.rect.width);

        for (int i = 0; i < _container.childCount - 1; i++)
        {
            float p = _container.GetChild(i).transform.localPosition.x;
            float d = Mathf.Abs(p - currentPos);
            if (d < distance)
            {
                distance = d;
                closest = p;
                childIndex = i;
            }
        }
        
        return -closest;
    }
}
