//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright  "hairibaba © 2018"
#property link       "https://www.mql5.com/en/users/hairi"
#property version    "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input color Col_Watermark     = clrGray;

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
   
   string Market_Price = DoubleToStr(Bid, Digits);
   int spr = int(MarketInfo(_Symbol,MODE_SPREAD));
   string spreadX = IntegerToString(spr);
   string display = StringConcatenate(Market_Price," (",spreadX,")");
   
   int shift = 900;
   int shiftX = 870;
   int shiftY = 0;
   if(spr<10) shiftY = 50;
   string tf = ChartTimeframe();
   if(tf=="M30" || tf=="M15") {
      shift += 110;
      shiftX = 910;
   }
   if(prevRange != range) {
      CreateWaterMark("Watermark",timeframe(),40,CORNER_RIGHT_LOWER,shift,130,Col_Watermark);
      
   }
   displayinfo("Market_Price_Label",display,shiftX-shiftY,330,35,Col_Watermark);
  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void displayinfo(string label,string displayitem, int x, int y, int size, color col) {
   if (ObjectFind(0,ObjIdentifier+label) != 0)
      ObjectCreate(0,ObjIdentifier+label,OBJ_LABEL, 0, 0, 0 );
   else
   {
      ObjectDelete(0,ObjIdentifier+label);
      ObjectCreate(0,ObjIdentifier+label,OBJ_LABEL, 0, 0, 0 );
   }
   
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_BACK,true);
   
   ObjectSetString(0,ObjIdentifier+label,OBJPROP_TEXT,displayitem);
   ObjectSetString(0,ObjIdentifier+label,OBJPROP_FONT,"Arial Black");
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_COLOR,col);
   ObjectSetInteger(0,ObjIdentifier+label,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
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
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Arial Black");
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,size);
   ObjectSetDouble(0,ObjIdentifier+name,OBJPROP_ANGLE,0);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
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
   int Market_CalcMode = int(MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   string symbol = _Symbol;
   if(Market_CalcMode==0 && StringLen(_Symbol)>6) symbol = StringSubstr(_Symbol,0,6);
   string msg = StringConcatenate(symbol+" "+ChartTimeframe());
   return msg;
}