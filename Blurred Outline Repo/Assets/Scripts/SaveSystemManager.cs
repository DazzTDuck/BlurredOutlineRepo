using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class SaveData
{
     //add data
     public ExampleData _exampleData = new ExampleData();
}
public class SaveSystemManager : MonoBehaviour
{
     public SaveData allSaveData;
}
