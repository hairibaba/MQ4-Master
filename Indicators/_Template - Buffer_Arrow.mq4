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

#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrRed
#property indicator_width1 3

#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrGreen
#property indicator_width2 3


// --- Input Variable ------------------------------------------------------------------
input ENUM_TIMEFRAMES IndicatorPeriod = PERIOD_H1;

// --- Indicator Buffer ----------------------------------------------------------------
double Buffer_SELL[];
double Buffer_BUY[];

// --- Global Variable ------------------------------------------------------------------
string ObjIdentifier  = "UIX_";
datetime ArrayTime[], LastTime;

int OnInit(){
   ChartHistory();
   // Indicator Buffer mapping
   SetIndexBuffer(0,Buffer_SELL);
   SetIndexArrow(0,234);
   SetIndexBuffer(1,Buffer_BUY);
   SetIndexArrow(1,233);
   
   //---- name for DataWindow and indicator subwindow label
   //string sShortName="RSL("+IntegerToString(InpMAPeriod)+")";
   //IndicatorShortName(sShortName);
   SetIndexLabel(0,"SELL");
   SetIndexLabel(1,"BUYY"); 
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
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
                const int &spread[])
  {
//---
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   double buffer = IntToPoint(Zoom(_Period));
   
   for(int i=0;i<bars;i++) {
      // Counting UP (TimeAsSeries)
      double bar1_open,bar1_high,bar1_low,bar1_close;
      double bar2_open,bar2_high,bar2_low,bar2_close;
      double bar3_open,bar3_high,bar3_low,bar3_close;
      double bar4_open,bar4_high,bar4_low,bar4_close;
      int bar1_formation,bar2_formation,bar3_formation,bar4_formation;
      //double PeriodHigh,PeriodLow;
   
      // OHLC
      OHLC(IndicatorPeriod,i+4,bar1_open,bar1_high,bar1_low,bar1_close,bar1_formation);
      OHLC(IndicatorPeriod,i+3,bar2_open,bar2_high,bar2_low,bar2_close,bar2_formation);
      OHLC(IndicatorPeriod,i+2,bar3_open,bar3_high,bar3_low,bar3_close,bar3_formation);
      OHLC(IndicatorPeriod,i+1,bar4_open,bar4_high,bar4_low,bar4_close,bar4_formation);
      
      // Period
      //RangePeriod(IndicatorPeriod,4,i+2,PeriodHigh,PeriodLow);
      
      
      if(bar3_low<bar2_low && bar2_low<bar1_low && bar4_low>bar3_low && bar4_close>bar3_high) Buffer_BUY[i] = Low[i] - buffer;
      else if(bar3_high>bar2_high && bar2_high>bar1_high && bar4_high<bar3_high && bar4_close<bar3_low) Buffer_SELL[i] = High[i] + buffer;
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

double IntToPoint(int integer){
   return integer*_Point;
}

void OHLC(int period, int whichbar, double& open, double& high, double& low, double& close, int& formation){
   int x = 100;
   open  = iOpen(_Symbol,period,whichbar);
   high  = iHigh(_Symbol,period,whichbar);
   low   = iLow(_Symbol,period,whichbar);
   close = iClose(_Symbol,period,whichbar);

   // Bulish/Bearish/Doji
   if(close>open) x = OP_BUY;
   else if(close<open) x = OP_SELL;
   formation = x;
}


void RangePeriod(int period, int range_bar, int bar_start, double& pricehigh, double& pricelow){
   int shiftLowest   = iLowest(_Symbol,period,MODE_LOW,range_bar,bar_start);
   int shiftHighest  = iHighest(_Symbol,period,MODE_HIGH,range_bar,bar_start);
   pricehigh = iHigh(_Symbol,period,shiftHighest);
   pricelow = iLow(_Symbol,period,shiftLowest);
}

int Zoom(int timeframe){
   int z = 0;
   if(timeframe==PERIOD_CURRENT || timeframe==_Period) {
      int x = _Period;
      if(x==PERIOD_W1) z = 100;
      else if(x==PERIOD_D1) z = 70;
      else if(x==PERIOD_H4) z = 60;
      else if(x==PERIOD_H1) z = 50;
      else if(x==PERIOD_M30) z = 40;
      else if(x==PERIOD_M15) z = 30;
      else if(x==PERIOD_M5) z = 20;
      else if(x==PERIOD_M1) z = 10;
   }
   else if(timeframe==PERIOD_W1) z = 100;
   else if(timeframe==PERIOD_D1) z = 70;
   else if(timeframe==PERIOD_H4) z = 60;
   else if(timeframe==PERIOD_H1) z = 50;
   else if(timeframe==PERIOD_M30) z = 40;
   else if(timeframe==PERIOD_M15) z = 30;
   else if(timeframe==PERIOD_M5) z = 20;
   else if(timeframe==PERIOD_M1) z = 10;
   return z;
}