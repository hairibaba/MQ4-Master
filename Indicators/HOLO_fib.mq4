
#property link          "http://www.forexfactory.com/showthread.php?t=590623"
#property version       "1.0"
#property description   "HOLO"
#property strict
#property indicator_chart_window       

double   CurrentDayHigh    = 0,
         CurrentDayLow     = 0,
         HighestTodayOpen  = 0,
         LowestTodayOpen   = 0;
         
int      ShiftLowest       = 0,
         ShiftHighest      = 0;
string   ObjIdentifier     = "hfi_";

int OnInit()
{
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
   //--- Delete All Drawings
   ObjectDeleteAll();
}

int start() 
{
   HighestTodayOpen  = iOpen(_Symbol,PERIOD_H1,0);
   LowestTodayOpen   = iOpen(_Symbol,PERIOD_H1,0);
   CurrentDayHigh    = iHigh(_Symbol,PERIOD_D1,0);
   CurrentDayLow     = iLow(_Symbol,PERIOD_D1,0);
   
   int i = 0;
   for (i=Hour(); i>=0; i--)
   {
      datetime currentH1Time = iTime(_Symbol,PERIOD_H1,i);
      double openH1Price = iOpen(_Symbol,PERIOD_H1,i);
      if(HighestTodayOpen < openH1Price) HighestTodayOpen = openH1Price;
      if(LowestTodayOpen > openH1Price) LowestTodayOpen = openH1Price;
   }
   
   int rangeUpper = PointToInt(CurrentDayHigh-HighestTodayOpen);
   int rangeLower = PointToInt(LowestTodayOpen-CurrentDayLow);
   
   ShiftLowest = iLowest(_Symbol,PERIOD_H1,MODE_LOW,Hour()+1);
   ShiftHighest = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,Hour()+1);
   
   datetime time_highest = iTime(_Symbol,PERIOD_H1,ShiftHighest);
   datetime time_lowest = iTime(_Symbol,PERIOD_H1,ShiftLowest);
   
   if(Hour()>0 && HighestTodayOpen!=LowestTodayOpen)
   {
      DrawRectangle("HO",time_highest,CurrentDayHigh,Time[0],HighestTodayOpen,clrBisque);
      DrawRectangle("LO",time_lowest,CurrentDayLow,Time[0],LowestTodayOpen,clrBisque);
   }
   else
   {
      ObjectDrawDelete("HO");
      ObjectDrawDelete("LO");
   }
   
   if(rangeUpper>80) DrawFibo(OP_SELL,"Fib_Upper",clrRed,time_highest,HighestTodayOpen,time_highest,CurrentDayHigh);
   else ObjectDelete(0,ObjIdentifier+"Fib_Upper");
   
   if(rangeLower>80) DrawFibo(OP_BUY,"Fib_Lower",clrBlue,time_lowest,CurrentDayLow,time_lowest,LowestTodayOpen);
   else ObjectDelete(0,ObjIdentifier+"Fib_Lower");
   
   return (0);
}

int PointToInt (double point)
{
   return int(point/_Point);
}

void ObjectDeleteAll()
{
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void ObjectDrawDelete(string name)
{
   ObjectDelete(0,ObjIdentifier+name);
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col)
{
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2); 
   else
   {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}

void DrawFibo(int swing, string name, color fibclr, datetime time1, double price1, datetime time2, double price2)
{
   if(swing==OP_SELL)
   {
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      else
      {
         ObjectDelete(0,ObjIdentifier+name);
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      }
   }
   else if(swing==OP_BUY)
   {
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time2,price2,time1,price1); 
      else
      {
         ObjectDelete(0,ObjIdentifier+name);
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time2,price2,time1,price1); 
      }
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,fibclr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_RAY_RIGHT,true);
   
   // level
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_LEVELCOLOR,fibclr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FIBOLEVELS,13);
   
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+0,0);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+1,0.236068);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+2,0.381966);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+3,0.500000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+4,0.618034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+5,0.763932);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+6,1.000000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+7,1.236068);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+8,1.381966);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+9,1.618034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+10,2.000000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+11,2.618034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+12,4.236068);

   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,0,"000");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,1,"023");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,2,"038");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,3,"050");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,4,"061");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,5,"076");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,6,"100");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,7,"123");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,8,"138");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,9,"162");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,10,"200");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,11,"262");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,12,"423");
}