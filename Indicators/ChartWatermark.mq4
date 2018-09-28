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

#property copyright  "Coded by hairibaba © 2018"
#property link       "https://www.mql5.com/en/users/hairi"
#property version    "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input color Col_Watermark     = C'24,28,40';

// --- Global Variable ------------------------------------------------------------------
string   ObjIdentifier     = "WTM_";

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectDeleteAll(); //--- Delete All Drawings
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
  
   double chartHi = WindowPriceMax(0);
   double chartLo = WindowPriceMin(0);
   double range = chartHi - chartLo;
   static double prevRange;
   
   if(prevRange != range) {
      CreateWaterMark("Watermark",timeframe(),80,CORNER_LEFT_UPPER,1000,800,Col_Watermark);
   }
  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void CreateWaterMark(string name, string text, int size, int corner, int Xdist, int Ydist, color clr)
{
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_LABEL, 0, 0, 0 );
   else
   {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_LABEL, 0, 0, 0 );
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_XDISTANCE,Xdist);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_YDISTANCE,Ydist);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_CORNER,corner);

   ObjectSetString(0,ObjIdentifier+name,OBJPROP_TEXT,text);
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,size);
   ObjectSetDouble(0,ObjIdentifier+name,OBJPROP_ANGLE,0);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}

void watermark(string obj, string text, int fontSize, string fontName, color colour, int xPos, int yPos)
{
      ObjectCreate(obj, OBJ_LABEL, 0, 0, 0); 
      ObjectSetText(obj, text, fontSize, fontName, colour);
      ObjectSet(obj, OBJPROP_CORNER, 0); 
      ObjectSet(obj, OBJPROP_XDISTANCE, xPos); 
      ObjectSet(obj, OBJPROP_YDISTANCE, yPos);
      ObjectSet(obj, OBJPROP_BACK, true);
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}

string timeframe() {
     string symbol = _Symbol;
     if(!(symbol=="BRENT"||symbol=="WTI")) symbol = StringSubstr(_Symbol,0,6);
     string msg = StringConcatenate(symbol+" "+ChartTimeframe());
     return msg;
}