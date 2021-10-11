using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineToggle : MonoBehaviour
{
    public bool showOutline = true;
    [Space]
    public int defaultLayerIndex;
    public int outlineLayerIndex;

    private int currentLayer;

    private void Update()
    {
        currentLayer = showOutline ? outlineLayerIndex : defaultLayerIndex;

        if(gameObject.layer != currentLayer)
            gameObject.layer = currentLayer; 
    }
}
