//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property description   "Round Number"
#property version       "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input int               Levels      = 25,
                        BoxSize     = 20,
                        ZoneSize    = 500;
input ENUM_LINE_STYLE   LevelStyle  = STYLE_DOT;
input color             LevelColor  = clrLime,
                        ZoneColor   = clrNavy;
            
// --- Global Variable ------------------------------------------------------------------
double   rounding;
string   ObjIdentifier  = "HZ_",
         Z_A            = "-a",
         Z_B            = "-b";

int OnInit(){
   rounding = NumToPoint(ZoneSize);
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectDeleteAll();
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
   RefreshRates();
   double  x = round(Bid/rounding)*rounding;
   double nearestLevel = x-NumToPoint(ZoneSize)*int((Levels/2));
   
   for(int i=0;i<Levels;i++) {
      string name  = "lvl"+IntegerToString(1+i);
      string namer = "lvlz"+IntegerToString(1+i);
      double lvl = nearestLevel+i*NumToPoint(ZoneSize);
      DrawHLine(name,lvl,LevelStyle,LevelColor,1);
      if(BoxSize>0) DrawZone(namer,lvl);
      else ObjectDrawDelete(ObjIdentifier+namer);   
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
//+------------------------------------------------------------------+

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void ObjectDrawDelete(string name){
   ObjectDelete(0,ObjIdentifier+name);
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return round(price/ticksize)*ticksize;
}

void DrawRectangle(string name, double pPrice1, double pPrice2, color Col){
   datetime pTime1 = Time[0];
   datetime pTime2 = 0;
   
   if(ObjectFind(0,ObjIdentifier+name) != 0) 
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);
   else {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
}

void DrawZone(string name, double HPrice) {
   double mid     = HPrice;
   double Zone    = NumToPoint(BoxSize);
   DrawRectangle(name,mid-Zone,mid+Zone,ZoneColor);
}

void DrawHLine(string name, double lvl, int style, color Col, int width){
   if(ObjectFind(ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name, OBJ_HLINE, 0, 0, lvl);
   else{
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name, OBJ_HLINE, 0, 0, lvl);
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,false);  
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
}