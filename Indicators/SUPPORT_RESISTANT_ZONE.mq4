//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's contact   : +60123337356 (Whatsapp)                                      |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's skype     : hairibaba@outlook.com                                        |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Code release date : 25-Aug-2018                                                  |
//|                                                                                    |
//|   Development copyright © 2015-2018 of hairibaba.                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "Adams Emmanuel"
#property link          "https://www.mql5.com/en/users/adamadam"
#property description   "Support & Resistance Zone"
#property version       "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input bool              DrawSnR           = true;
input int               ZoneCoverage      = 500,
                        ZoneSizeAbove     = 100,
                        ZoneSizeBelow     = 100,
                        H_Line_Width      = 1;
input ENUM_LINE_STYLE   H_Line_Style      = STYLE_DOT;
input color             H_Line_Color      = clrRed,
                        H_Line_Color_Unc  = clrGreen,       // H_Line_Color (Unconfirmed)
                        ZoneColorAbove    = clrLightGray,
                        ZoneColorBelow    = clrGainsboro;
input string            Password          = "G78hyfUi";
            
// --- Global Variable ------------------------------------------------------------------
bool     Coverage       = false;
double   Globalrange    = 0;
string   NonDrawZone1   = "Unconfirmed-1",
         NonDrawZone2   = "Unconfirmed-2",
         NonDrawZone3   = "Unconfirmed-3",
         ObjIdentifier  = "HZ_",
         Z_A            = "-a",
         Z_B            = "-b";
string   ProductPass    = "G78hyfUi";

int OnInit(){
   if(!ProductLicense()) return INIT_FAILED;
   Globalrange = NumToPoint(ZoneCoverage);
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
  
   string hline,recchk,hchk,rectangle;
   int len;
   double hprice,rprice;
  
   for(int z=0;z<ObjectsTotal(OBJ_RECTANGLE);z++) {
      rectangle = ObjectName(0,z,-1,OBJ_RECTANGLE);
      rprice = NormPrice(ObjectGetDouble(0,rectangle,OBJPROP_PRICE));
      len = StringLen(rectangle);
      recchk = StringSubstr(rectangle,len-2,2);
      hchk = StringSubstr(rectangle,0,len-2);
      if(!DrawSnR || recchk==Z_A || recchk==Z_B || !BetweenPriceRange(rprice+Globalrange,rprice-Globalrange)) ObjectDelete(0,rectangle);
      if(hchk==NonDrawZone1 || hchk==NonDrawZone2 || hchk==NonDrawZone3) ObjectDelete(0,rectangle);
   }
   
   for(int z=0;z<ObjectsTotal(OBJ_HLINE);z++) {
      hline = ObjectName(0,z,-1,OBJ_HLINE);
      hprice = NormPrice(ObjectGetDouble(0,hline,OBJPROP_PRICE));
      if(BetweenPriceRange(hprice+Globalrange,hprice-Globalrange)) {
         if(DrawSnR && hline!=NonDrawZone1 && hline!=NonDrawZone2 && hline!=NonDrawZone3) DrawZone(hline,hprice,ZoneSizeAbove,ZoneSizeBelow,ZoneColorAbove,ZoneColorBelow); 
         // default horizontal line property code --
         ObjectSetInteger(0,hline,OBJPROP_STYLE,H_Line_Style);
         ObjectSetInteger(0,hline,OBJPROP_COLOR,H_Line_Color);
         ObjectSetInteger(0,hline,OBJPROP_WIDTH,H_Line_Width);
         ObjectSetInteger(0,hline,OBJPROP_BACK,false); 
      }
      else if(!DrawSnR) {
         // default horizontal line property code --
         ObjectSetInteger(0,hline,OBJPROP_STYLE,H_Line_Style);
         ObjectSetInteger(0,hline,OBJPROP_COLOR,H_Line_Color);
         ObjectSetInteger(0,hline,OBJPROP_WIDTH,H_Line_Width);
         ObjectSetInteger(0,hline,OBJPROP_BACK,false);
      }
      else {
         // hidden horizontal line property code --
         long bgcolor = ChartGetInteger(0,CHART_COLOR_BACKGROUND);
         ObjectSetInteger(0,hline,OBJPROP_STYLE,STYLE_DOT);
         ObjectSetInteger(0,hline,OBJPROP_COLOR,bgcolor);
         ObjectSetInteger(0,hline,OBJPROP_WIDTH,1);
         ObjectSetInteger(0,hline,OBJPROP_BACK,true); 
      }
      if(hline==NonDrawZone1 || hline==NonDrawZone2 || hline==NonDrawZone3) {
         // default horizontal line property code --
         ObjectSetInteger(0,hline,OBJPROP_STYLE,H_Line_Style);
         ObjectSetInteger(0,hline,OBJPROP_COLOR,H_Line_Color_Unc);
         ObjectSetInteger(0,hline,OBJPROP_WIDTH,H_Line_Width);
         ObjectSetInteger(0,hline,OBJPROP_BACK,false); 
      }
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
   datetime pTime2 = 0; // iTime(_Symbol,PERIOD_MN1,2)
   
   if(ObjectFind(0,ObjIdentifier+name) != 0) 
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);
   else {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}

void DrawZone(string name, double HPrice, int AZ_Distance, int BZ_Distance, color ZoneAbove, color ZoneBelow) {
   double mid     = HPrice;
   double ZoneA   = NumToPoint(AZ_Distance);
   double ZoneB   = NumToPoint(BZ_Distance);
   DrawRectangle(name+Z_A,mid,mid+ZoneA,ZoneAbove);
   DrawRectangle(name+Z_B,mid-ZoneB,mid,ZoneBelow);
}

bool BetweenPriceRange(double above, double below) {
   bool x = false;
   RefreshRates();
   if(Ask<=above && Bid>=below) x = true;   
   return x;
}

bool ProductLicense(){
   bool auth = true;
   string msg;
   
   if(Password=="") {
      msg = StringConcatenate("Please enter password!");
      Alert(msg);
      auth = false;
   }
   else if(Password!=ProductPass) {
      msg = StringConcatenate("Invalid password!");
      Alert(msg);
      auth = false;
   }
   return auth;
}