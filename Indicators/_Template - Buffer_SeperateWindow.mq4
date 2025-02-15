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

#property indicator_separate_window
#property indicator_buffers    1
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_label1    "RSL"
#property indicator_level1    1.0
#property indicator_color1    DodgerBlue
#property indicator_type1     DRAW_LINE

// --- Input Variable ------------------------------------------------------------------
input int InpMAPeriod = 14; // MA Period
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE InpMAPrice = PRICE_CLOSE;

// --- Indicator Buffer ----------------------------------------------------------------
double Buffer[];
string ObjIdentifier  = "XXX_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   ChartHistory();
   // Indicator Buffer mapping
   SetIndexBuffer(0,Buffer);
   string sShortName="RSL("+IntegerToString(InpMAPeriod)+")";
   IndicatorShortName(sShortName);
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
   ObjectDeleteAll(); //--- Delete All Drawings
}


//+------------------------------------------------------------------+
//| Relative Strength Levy indicator                                 |
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
                const int &spread[])
  {
//---
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   
   for(int i=0; i<bars; i++){
      Buffer[i] = Close[i]/iMA(_Symbol,0,InpMAPeriod,0,InpMAMethod,InpMAPrice,i);
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