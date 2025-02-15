//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|------------------------------------------------------------------------------------|
//|   Development copyright © 2012-2018 of hairibaba.                                  |
//|------------------------------------------------------------------------------------|
//|   ChangeLog:                                                                       |
//|   Release date : xx-xxx-xxxx                                                       |
//|                                                                                    |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property description   "Scalping Timing"
#property version       "1.00"
#property strict
#property indicator_chart_window

// --- Input Variable ------------------------------------------------------------------
input color Col_Hour    = clrRed,
            Col_Half    = clrGreen,
            Col_Max     = clrBlue;

// --- Global Variable ------------------------------------------------------------------
string   ObjIdentifier  = "SXT_";
string   Obj            = "Time";

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   //--- Delete All Drawings
   ObjectDeleteAll();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){
//---
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   
   for(int i = bars; i >=0; i--){
      if(startDraw(i,0)) DrawVLine(Obj,i,Col_Hour,STYLE_SOLID,3);
      if(startDraw(i,10)) DrawVLine(Obj,i,Col_Hour,STYLE_DOT,1);
      if(startDraw(i,30)) DrawVLine(Obj,i,Col_Half,STYLE_DOT,1);
      if(startDraw(i,40)) DrawVLine(Obj,i,Col_Max,STYLE_DOT,1);
      if(startDraw(i,50)) DrawVLine(Obj,i,Col_Hour,STYLE_DOT,1);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

int ID(){
   static int s_itemID = 0;
   return s_itemID++;
}

string timeIdentifier() {
   return TimeToString(iTime(_Symbol,PERIOD_M1,0),TIME_DATE|TIME_MINUTES);
}

void DrawVLine(string name, int loc, color col, int style, int width){
   string frac = IntegerToString(ID());
   if(ObjectFind(ObjIdentifier+name+frac) != 0) ObjectCreate(0,ObjIdentifier+name+frac, OBJ_VLINE, 0, Time[loc], 0);        
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_COLOR,col);
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_TIMEFRAMES,OBJ_PERIOD_M1|OBJ_PERIOD_M5);
   ObjectSetInteger(0,ObjIdentifier+name+frac,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
}

bool startDraw(int i, int min) {
   return TimeMinute(Time[i])==min && TimeSeconds(Time[i])==0;
}