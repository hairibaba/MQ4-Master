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
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1 "LW"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color1 clrRed

#property indicator_label2 "PC"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_color2 clrBlue

// --- Input Variable ------------------------------------------------------------------
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;

// --- Indicator Buffer ----------------------------------------------------------------
double Buffer_LW[];
double Buffer_PC[];

// --- Global Variable ------------------------------------------------------------------
string ObjIdentifier  = "max_";
datetime ArrayTime[], LastTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Indicator Buffer mapping
   SetIndexBuffer(0,Buffer_LW);
   SetIndexBuffer(1,Buffer_PC);
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
   //--- Delete All Drawings
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
                const int &spread[])
  {
//---
   int i;
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   
   for(i = bars; i >=0; i--)
   {
      Buffer_LW[i] = iMA(_Symbol,Timeframe,5,0,MODE_LWMA,PRICE_CLOSE,i);
      Buffer_PC[i] = iMAOnArray(Buffer_LW,prev_calculated,5,0,MODE_LWMA,i);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll()
{
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}