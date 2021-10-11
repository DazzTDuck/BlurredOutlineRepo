using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ExampleData
{
    public string playerName;
   public int amountOfLives;
   public bool testBool;
   public List<GameObject> playerInventory;

   public void SetData(string playerName, int amountOfLives, bool testBool, List<GameObject> playerInventory)
   {
       this.playerName = playerName;
       this.amountOfLives = amountOfLives;
       this.testBool = testBool;
       this.playerInventory = playerInventory;
   }
}
