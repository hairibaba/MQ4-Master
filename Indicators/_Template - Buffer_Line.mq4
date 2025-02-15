//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property description   "xxx"
#property version       "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrRed
#property indicator_width1 2

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrBlue
#property indicator_width2 2


// --- Input Variable ------------------------------------------------------------------
input ENUM_TIMEFRAMES Timeframe = PERIOD_M5;

// --- Indicator Buffer ----------------------------------------------------------------
double Buffer_Buffer1[];
double Buffer_Buffer2[];

// --- Global Variable ------------------------------------------------------------------
string ObjIdentifier  = "III_";
datetime ArrayTime[], LastTime;

int OnInit(){
   ChartHistory();
   // Indicator Buffer mapping
   SetIndexBuffer(0,Buffer_Buffer1);
   SetIndexBuffer(1,Buffer_Buffer2);
   
   //---- name for DataWindow and indicator subwindow label
   //string sShortName="RSL("+IntegerToString(InpMAPeriod)+")";
   //IndicatorShortName(sShortName);
   SetIndexLabel(0,"Buffer1");
   SetIndexLabel(1,"Buffer2"); 
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   ObjectDeleteAll(); //--- Delete All Drawings
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
                const int &spread[])
  {
//---
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   
   for(int i = bars; i >=0; i--){
      // Counting down (TimeNotAsSeries)
      Buffer_Buffer1[i] = iMA(_Symbol,Timeframe,5,0,MODE_LWMA,PRICE_CLOSE,i);
      Buffer_Buffer2[i] = iMAOnArray(Buffer_Buffer1,prev_calculated,5,0,MODE_LWMA,i);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

bool VerifyHistory(string symbol) {
   bool x = true;
   datetime times[];
   ResetLastError();
   ArrayCopySeries(times,MODE_TIME,symbol,PERIOD_M1);
   if(_LastError==ERR_HISTORY_WILL_UPDATED || _LastError==ERR_NO_HISTORY_DATA) x = false;
   ResetLastError();
   return x;
}

void ChartHistory(string symbol = NULL) {
   if(!IsTesting()){
      if(symbol==NULL) symbol=_Symbol;
      while(!VerifyHistory(symbol)) {
         Sleep(5000); 
         RefreshRates();
      }
   }
   else RefreshRates();
}