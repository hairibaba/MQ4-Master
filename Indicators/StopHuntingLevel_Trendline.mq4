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
input color Col_Trendline = clrLightYellow,
            Col_Today     = C'59,166,236';

// --- Global Variable ------------------------------------------------------------------
int      MajorPeriod    = ((4-1)*24)+1,
         MajorPeriodRef = ((7-1)*24)+1,
         MajorToday     = 1;
string   ObjIdentifier  = "SHT_";
datetime Major_TimeHigh,Major_TimeLow,Prev_TimeHigh,Prev_TimeLow,Major_TimeHighRef,Major_TimeLowRef;
double   Major_PriceHigh,Major_PriceLow,Major_PriceMid,Prev_PriceHigh,Prev_PriceLow,Prev_PriceMid,Major_PriceHighRef,Major_PriceLowRef,Major_PriceMidRef;
double   Target_Above,Target_Below,MidLevel,RangeTop,RangeBottom;
double   Target_AboveM,Target_BelowM,MidLevelM,RangeTopM,RangeBottomM;
double   Target_AbovePrev,Target_BelowPrev,MidLevelPrev,RangeTopPrev,RangeBottomPrev;
double   Target_AboveX,Target_BelowX,MidLevelX,RangeTopX,RangeBottomX;
double   Hedge_Below,Hedge_Above;
double   Ext_TargetAbove,Ext_TargetBelow;
int Swing_Major,Swing_Ref,Swing_Today,Swing_Yesterday;
datetime TimeHigh_Major,TimeLow_Major,TimeHigh_MajorPrev,TimeLow_MajorPrev,TimeHigh_MajorX,TimeLow_MajorX,TimeHigh_Minor,TimeLow_Minor;

double Today_PriceHigh,Today_PriceLow,Yesterday_PriceHigh,Yesterday_PriceLow;
datetime Today_TimeHigh,Today_TimeLow,Yesterday_TimeHigh,Yesterday_TimeLow;
double Today_Low,Today_High,Yesterday_Low,Yesterday_High;
double Yes_High,Yes_Low,Tod_High,Tod_Low;
datetime Yes_HighTime, Yes_LowTime,Tod_TimeHigh,Tod_TimeLow;

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
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
                const int &spread[]){
//---
   if (Bars(_Symbol,_Period)<rates_total) return(0);
   
   Swing_Major = FilterSwing(MajorPeriod,Major_TimeHigh,Major_PriceHigh,Major_TimeLow,Major_PriceLow);
   Swing_Ref   = FilterSwing(MajorPeriodRef,Major_TimeHighRef,Major_PriceHighRef,Major_TimeLowRef,Major_PriceLowRef);
   Swing_Today = FilterSwing(1,Today_TimeHigh,Today_PriceHigh,Today_TimeLow,Today_PriceLow);
   Swing_Yesterday = FilterSwing(24-Hour(),Yesterday_TimeHigh,Yesterday_PriceHigh,Yesterday_TimeLow,Yesterday_PriceLow,24);
   TwoDay(Today_Low,Today_High,Yesterday_Low,Yesterday_High);
   YesterdayRange(Yes_High,Yes_Low,Yes_HighTime,Yes_LowTime);
   TodayRange(Tod_High,Tod_Low,Tod_TimeHigh,Tod_TimeLow);
   
   DrawTrendLine("Upper_Res",Yes_HighTime,Yes_High,Tod_TimeHigh,Today_High,STYLE_DASH,clrDeepPink,1);
   DrawTrendLine("Lower_Sup",Yes_LowTime,Yes_Low,Tod_TimeLow,Tod_Low,STYLE_DASH,clrDeepPink,1);
   
   if(Swing_Ref==OP_BUY) {
      ObjectDrawDelete("MajorRes");
      if(Major_PriceLow==Tod_Low) DrawTrendLine("MajorSup",Major_TimeLowRef,Major_PriceLowRef,Major_TimeLow,Major_PriceLow,STYLE_DASH,Col_Trendline,1);
      else DrawTrendLine("MajorSup",Major_TimeLowRef,Major_PriceLowRef,Major_TimeLow,Major_PriceLow,STYLE_SOLID,Col_Trendline,3);
      
      if(Major_PriceLow!=Tod_Low && Major_PriceLow!=Yes_Low) DrawTrendLine("MinorSup2",Major_TimeLow,Major_PriceLow,Yes_LowTime,Yes_Low,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MinorSup2");
       
      if(Swing_Major==OP_BUY && Yes_Low>Major_PriceLow && Yes_LowTime>Major_TimeLow) DrawTrendLine("MinorSup3",Yes_LowTime,Yes_Low,Tod_TimeLow,Tod_Low,STYLE_DASH,clrYellow,1);
      else ObjectDrawDelete("MinorSup3");
      
      // Inside Bar
      if(Major_PriceHigh<Major_PriceHighRef && Major_PriceLow>Major_PriceLowRef && Major_PriceHigh!=Tod_High) DrawTrendLine("MajorSup_Res_IB",Major_TimeHighRef,Major_PriceHighRef,Major_TimeHigh,Major_PriceHigh,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MajorSup_Res_IB");
      
      if(Tod_Low<Yesterday_Low) DrawTrendLine("MinorSup",Major_TimeLow,Major_PriceLow,Tod_TimeLow,Tod_Low,STYLE_DASH,Col_Today,1);
      else ObjectDrawDelete("MinorSup");
      
      if(Tod_High<Major_PriceHighRef) DrawTrendLine("MajorSup_Res",Major_TimeHighRef,Major_PriceHighRef,Tod_TimeHigh,Tod_High,STYLE_DASH,Col_Today,1);
      else ObjectDrawDelete("MajorSup_Res");
      
      if(Yes_High<Major_PriceHighRef && Tod_High!=Major_PriceHighRef) DrawTrendLine("MajorSup_Res2",Major_TimeHighRef,Major_PriceHighRef,Yes_HighTime,Yes_High,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MajorSup_Res2");
   }
   else if(Swing_Ref==OP_SELL) {
      ObjectDrawDelete("MajorSup");
      if(Major_PriceHigh==Tod_High) DrawTrendLine("MajorRes",Major_TimeHighRef,Major_PriceHighRef,Major_TimeHigh,Major_PriceHigh,STYLE_DASH,Col_Trendline,1);
      else DrawTrendLine("MajorRes",Major_TimeHighRef,Major_PriceHighRef,Major_TimeHigh,Major_PriceHigh,STYLE_SOLID,Col_Trendline,3);
      
      if(Major_PriceHigh!=Tod_High && Major_PriceHigh!=Yes_High) DrawTrendLine("MinorRes2",Major_TimeHigh,Major_PriceHigh,Yes_HighTime,Yes_High,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MinorRes2");
      
      if(Swing_Major==OP_SELL && Yes_High<Major_PriceHigh && Yes_HighTime>Major_TimeHigh) DrawTrendLine("MinorRes3",Yes_HighTime,Yes_High,Tod_TimeHigh,Tod_High,STYLE_DASH,clrYellow,1);
      else ObjectDrawDelete("MinorRes3");
      
      // Inside Bar
      if(Major_PriceHigh<Major_PriceHighRef && Major_PriceLow>Major_PriceLowRef && Major_PriceLow!=Tod_Low) DrawTrendLine("MajorRes_Sup_IB",Major_TimeLowRef,Major_PriceLowRef,Major_TimeLow,Major_PriceLow,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MajorRes_Sup_IB");
      
      if(Tod_High>Yesterday_High) DrawTrendLine("MinorRes",Major_TimeHigh,Major_PriceHigh,Tod_TimeHigh,Tod_High,STYLE_DASH,Col_Today,1);
      else ObjectDrawDelete("MinorRes");
      
      if(Tod_Low>Major_PriceLowRef) DrawTrendLine("MajorRes_Sup",Major_TimeLowRef,Major_PriceLowRef,Tod_TimeLow,Tod_Low,STYLE_DASH,Col_Today,1);
      else ObjectDrawDelete("MajorRes_Sup");
      
      if(Yes_Low>Major_PriceLowRef && Tod_Low!=Major_PriceLowRef) DrawTrendLine("MajorRes_Sup2",Major_TimeLowRef,Major_PriceLowRef,Yes_LowTime,Yes_Low,STYLE_SOLID,Col_Trendline,3);
      else ObjectDrawDelete("MajorRes_Sup2");
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

int PointToInt (double point){
   return int(point/_Point);
}

double IntToPoint(int integer){
   return integer*_Point;
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void ObjectDrawDelete(string name){
   ObjectDelete(0,ObjIdentifier+name);
}

void TwoDay(double& lowtoday, double& hightoday, double& lowYesterday, double& highYesterday) {
   lowtoday = iLow(_Symbol,PERIOD_D1,0);
   lowYesterday = iLow(_Symbol,PERIOD_D1,1);
   hightoday = iHigh(_Symbol,PERIOD_D1,0);
   highYesterday = iHigh(_Symbol,PERIOD_D1,1);
}

int FilterSwing(int bar, datetime& timehigh, double& pricehigh, datetime& timelow, double& pricelow, int StartCount = 0){
   int sig = 100;
   int shiftLowest = iLowest(_Symbol,PERIOD_H1,MODE_LOW,bar+Hour(),StartCount);
   int shiftHighest = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,bar+Hour(),StartCount);
   
   // Time coordinate
   timehigh = iTime(_Symbol,PERIOD_H1,shiftHighest);
   timelow = iTime(_Symbol,PERIOD_H1,shiftLowest);
   
   // Price coordinate
   pricehigh = iHigh(_Symbol,PERIOD_H1,shiftHighest);
   pricelow = iLow(_Symbol,PERIOD_H1,shiftLowest);
   
   if(shiftHighest > shiftLowest) sig = OP_SELL;
   else if(shiftHighest < shiftLowest) sig = OP_BUY;
   
   return sig;
}

void VarTargetExtend(double multiplier, double high, double low, double& above, double& below) {
   double range = high-low;
   above   = NormPrice(range*multiplier)+high;
   below   = low-NormPrice(range*multiplier);
}

double NormPrice(double price){
   double tickSize=MarketInfo(_Symbol,MODE_TICKSIZE);
   return round(price/tickSize)*tickSize;
}

void DrawTrendLine(string name, datetime T0, double P0, datetime T1, double P1, int style, color clr, int width, bool ray=true)
{   
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_TREND, 0, T0, P0, T1, P1 );
   else
   {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_TREND, 0, T0, P0, T1, P1 );
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_RAY, ray);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   //ObjectSetString (0,ObjIdentifier+name,name);
}

void YesterdayRange(double& pricehigh, double& pricelow, datetime& timehigh, datetime& timelow){
   int shiftLowest   = iLowest(_Symbol,PERIOD_H1,MODE_LOW,24,Hour()+1);
   int shiftHighest  = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,24,Hour()+1);
   pricehigh = iHigh(_Symbol,PERIOD_H1,shiftHighest);
   pricelow = iLow(_Symbol,PERIOD_H1,shiftLowest);
   timehigh = iTime(_Symbol,PERIOD_H1,shiftHighest);
   timelow = iTime(_Symbol,PERIOD_H1,shiftLowest);
}

void TodayRange(double& pricehigh, double& pricelow, datetime& timehigh, datetime& timelow){
   if(Hour()==0) {
      pricehigh = iHigh(_Symbol,PERIOD_H1,0);
      pricelow = iLow(_Symbol,PERIOD_H1,0);
      timehigh = iTime(_Symbol,PERIOD_H1,0);
      timelow = iTime(_Symbol,PERIOD_H1,0);
   }
   else {
      int shiftLowest   = iLowest(_Symbol,PERIOD_H1,MODE_LOW,Hour()+1);
      int shiftHighest  = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,Hour()+1);
      pricehigh = iHigh(_Symbol,PERIOD_H1,shiftHighest);
      pricelow = iLow(_Symbol,PERIOD_H1,shiftLowest);
      timehigh = iTime(_Symbol,PERIOD_H1,shiftHighest);
      timelow = iTime(_Symbol,PERIOD_H1,shiftLowest);
   }
}