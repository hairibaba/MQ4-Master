//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property link          "http://www.forexfactory.com/showthread.php?t=590623"
#property version       "2.0"
#property description   "HOLO"
#property strict
#property indicator_chart_window       

// --- Input Variable ------------------------------------------------------------------
input ENUM_TIMEFRAMES   Timeframe   = PERIOD_H1;
input color             BoxColor    = clrLightSlateGray;

double   CurrentDayHigh,CurrentDayLow,HighestTodayOpen,LowestTodayOpen;
int      ShiftLowest,ShiftHighest;
string   ObjIdentifier = "HLO_";

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectDeleteAll(); //--- Delete All Drawings
}

int start() {
   HighestTodayOpen  = iOpen(_Symbol,Timeframe,0);
   LowestTodayOpen   = iOpen(_Symbol,Timeframe,0);
   CurrentDayHigh    = iHigh(_Symbol,PERIOD_D1,0);
   CurrentDayLow     = iLow(_Symbol,PERIOD_D1,0);
   
   int limit = Hour();
   int corr = 1;
   if(Timeframe==PERIOD_M30) {
      limit *= 2;
      corr = 2;
   }
   else if(Timeframe==PERIOD_M15) {
      limit *= 4;
      corr = 4;
   }
   else if(Timeframe==PERIOD_M5) {
      limit *= 12;
      corr = 12;
   }
   
   for (int i=limit; i>=0; i--){
      datetime currentH1Time = iTime(_Symbol,Timeframe,i);
      double openH1Price = iOpen(_Symbol,Timeframe,i);
      if(HighestTodayOpen < openH1Price) HighestTodayOpen = openH1Price;
      if(LowestTodayOpen > openH1Price) LowestTodayOpen = openH1Price;
   }
   
   ShiftLowest = iLowest(_Symbol,Timeframe,MODE_LOW,limit+corr);
   ShiftHighest = iHighest(_Symbol,Timeframe,MODE_HIGH,limit+corr);
   datetime time_highest = iTime(_Symbol,Timeframe,ShiftHighest);
   datetime time_lowest = iTime(_Symbol,Timeframe,ShiftLowest);
   
   if(Hour()>0 && HighestTodayOpen!=LowestTodayOpen){
      DrawRectangle("HO",time_highest,CurrentDayHigh,Time[0],HighestTodayOpen,BoxColor);
      DrawRectangle("LO",time_lowest,CurrentDayLow,Time[0],LowestTodayOpen,BoxColor);
   }
   else{
      ObjectDelete(0,ObjIdentifier+"HO");
      ObjectDelete(0,ObjIdentifier+"LO");
   }
   
   return (0);
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col)
{
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2); 
   else{
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}