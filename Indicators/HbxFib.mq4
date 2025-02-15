//+------------------------------------------------------------------+
//|                                                       HbxFib.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright  "Coded by hairibaba © 2018"
#property link       "https://www.mql5.com/en/users/hairi"
#property version    "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input int      ChannelDay        = 4;
input bool     DrawMinorTrend    = true,
               Draw_PitchFork    = true,
               Draw_Regression   = true,
               DrawAvgPrice      = true;
input color    MajorTrend        = C'37,44,63',
               MinorTrend        = C'59,166,236',
               AvgLine           = C'59,166,236';

// --- Global Variable ------------------------------------------------------------------
int      MajorPeriod    = ((ChannelDay-1)*24)+1;
string   ObjIdentifier  = "fib_";
datetime Major_TimeHigh,Major_TimeLow,Minor_TimeHigh,Minor_TimeLow;
double   Major_PriceHigh,Major_PriceLow,Minor_PriceHigh,Minor_PriceLow,
         Target_Above,Target_Below,Mid,top,bottom;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
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
   if (Bars(_Symbol,_Period)<rates_total) return(0);
   
   int MajorSwing = FilterSwing(MajorPeriod,Major_TimeHigh,Major_PriceHigh,Major_TimeLow,Major_PriceLow);
   int MinorSwing = FilterSwing(25,Minor_TimeHigh,Minor_PriceHigh,Minor_TimeLow,Minor_PriceLow);
   SwingTarget(Target_Above,Target_Below,Mid,top,bottom);
   
   int range_side = PointToInt((Target_Above-top)/2);
   double range_point = IntToPoint(range_side);
   
   double AvgPrice = PVAnalysis();
   double AvgPriceB = PVAnalysis(24);
   
   if(DrawAvgPrice)
   {
      HLine("AvgP","Average Price",25,AvgPrice,STYLE_SOLID,AvgLine,4);
      HLine("AvgPB","Average Price Previous",49,AvgPriceB,STYLE_SOLID,AvgLine,4);
   }
   
   DrawFibo(MajorSwing,"MajorSwing",MajorTrend,Major_TimeLow,Major_PriceLow,Major_TimeHigh,Major_PriceHigh);
   if(MajorSwing!=MinorSwing) 
   {
      if(DrawMinorTrend) DrawFibo(MinorSwing,"MinorSwing",MinorTrend,Minor_TimeLow,Minor_PriceLow,Minor_TimeHigh,Minor_PriceHigh);
      if(Draw_PitchFork)
      {
         if(MajorSwing==OP_BUY) DrawPitchfork("PitchFork",MajorTrend,Major_TimeLow,Major_PriceLow,Major_TimeHigh,Major_PriceHigh,Minor_TimeLow,Minor_PriceLow);
         else if(MajorSwing==OP_SELL) DrawPitchfork("PitchFork",MajorTrend,Major_TimeHigh,Major_PriceHigh,Major_TimeLow,Major_PriceLow,Minor_TimeHigh,Minor_PriceHigh);
      }
      else ObjectDelete(0,ObjIdentifier+"PitchFork");
   }
   else ObjectDelete(0,ObjIdentifier+"MinorSwing");
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

int PointToInt (double point)
{
   return int(point/_Point);
}

double IntToPoint(int integer)
{
   return integer*_Point;
}

void ObjectDeleteAll()
{
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

double PVAnalysis(int candle=0)
{
   double price = 0;
   double totalprice = 0;
   double avgprice = 0;
   long vol = 0;
   long totalvol = 0;
   
   for(int i=25+candle;i>=1+candle;i--)
   {
      price = iClose(_Symbol,PERIOD_H1,i);
      vol = iVolume(_Symbol,PERIOD_H1,i);
   
      totalprice += price*vol;
      totalvol += vol;
      
      avgprice = totalprice/totalvol;
   }

   return NormPrice(avgprice);
}

int FilterSwing(int bar, datetime& timehigh, double& pricehigh, datetime& timelow, double& pricelow)
{
   int sig = 100;
   int shiftLowest = iLowest(_Symbol,PERIOD_H1,MODE_LOW,bar+Hour());
   int shiftHighest = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,bar+Hour());
   
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

void SwingTarget(double& Tar_Above, double& Tar_Below, double& mid, double& high, double& low)
{
   int shiftLowest = iLowest(_Symbol,PERIOD_D1,MODE_LOW,3,1);
   int shiftHighest = iHighest(_Symbol,PERIOD_D1,MODE_HIGH,3,1);
   
   low = iLow(_Symbol,PERIOD_D1,shiftLowest);
   high = iHigh(_Symbol,PERIOD_D1,shiftHighest);
   
   double range = high-low;
   double tarfib = 0.162;
   
   Tar_Above   = NormPrice(range*tarfib)+high;
   Tar_Below   = low-NormPrice(range*tarfib);
   Mid         = NormPrice(range*0.5)+low;
}

double NormPrice(double price)
{
   double tickSize=MarketInfo(_Symbol,MODE_TICKSIZE);
   return round(price/tickSize)*tickSize;
}

void DrawPitchfork(string name, color col, datetime time1, double price1, datetime time2, double price2, datetime time3, double price3)
{
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_PITCHFORK,0,time1,price1,time2,price2,time3,price3);
   else
   {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_PITCHFORK,0,time1,price1,time2,price2,time3,price3);
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_RAY_RIGHT,true);
}

void DrawFibo(int swing, string name, color fibclr, datetime time1, double price1, datetime time2, double price2)
{
   if(swing==OP_SELL)
   {
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      else
      {
         ObjectDelete(0,ObjIdentifier+name);
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      }
   }
   else if(swing==OP_BUY)
   {
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time2,price2,time1,price1); 
      else
      {
         ObjectDelete(0,ObjIdentifier+name);
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time2,price2,time1,price1); 
      }
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,fibclr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_RAY_RIGHT,true);
   
   // level
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_LEVELCOLOR,fibclr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_LEVELSTYLE,STYLE_DOT);
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FIBOLEVELS,14);
   
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+0,0);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+1,0.118034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+2,0.236068);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+3,0.381966);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+4,0.500000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+5,0.618034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+6,0.763932);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+7,0.881966);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+8,1.000000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+9,1.236068);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+10,1.381966);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+11,1.618034);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+12,2.000000);
   ObjectSet(ObjIdentifier+name,OBJPROP_FIRSTLEVEL+13,2.618034);
   
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,0,"000");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,1,"012");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,2,"023");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,3,"038");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,4,"050");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,5,"061");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,6,"076");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,7,"088");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,8,"100");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,9,"123");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,10,"138");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,11,"162");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,12,"200");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,13,"262");
}

void CreatePriceFlag(string name, double price, color col)
{
   datetime time = Time[0]+_Period*60;
   
   if (ObjectFind(0,ObjIdentifier+name) != 0)
   {
      ObjectCreate(0,ObjIdentifier+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(0,ObjIdentifier+name,0, time, price);

}

void HLine(string name, string desc, int pShiftTime, double pPrice, int pStyle, color pColor, int pWidth)
{
   DrawShortHLine(name,pShiftTime,pPrice,pStyle,pColor,pWidth);
   CreatePriceLabel(name+" Label",desc,pPrice,pColor);
   CreatePriceFlag (name+" Price",pPrice,pColor);
}

int ChartScaleGet()
{
   long result = -1;
   ChartGetInteger(0,CHART_SCALE,0,result);
   return((int)result);
}

void DrawShortHLine(string nameX, int time1, double P0, int style, color clr, int width)
{   
   string objName;
   
   datetime T0 = iTime(_Symbol,PERIOD_H1,time1);
   datetime T1 = iTime(_Symbol,PERIOD_M1,1);
   
   objName=nameX;
   if (ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   else
   {
      ObjectDelete(0,ObjIdentifier+objName);
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY, false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
}

void CreatePriceLabel(string name, string desc, double price, color col)
{
   int Chart_Scale  ,Bar_Width  ;      
   Chart_Scale = ChartScaleGet();
                 
   if(Chart_Scale == 0) Bar_Width = 64;
   else if(Chart_Scale == 1) Bar_Width = 32;      
   else if(Chart_Scale == 2) Bar_Width = 16;
   else if(Chart_Scale == 3) Bar_Width = 9;
   else if(Chart_Scale == 4) Bar_Width = 5;
   else if(Chart_Scale == 5) Bar_Width = 3;
   else Bar_Width = 2;
   
   datetime time = Time[0]+_Period*120*Bar_Width ;

   if (ObjectFind(0,ObjIdentifier+name) != 0)
   {
      ObjectCreate(0,ObjIdentifier+name,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString (0,ObjIdentifier+name,OBJPROP_TEXT,desc);
      ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(0,ObjIdentifier+name,0, time, price);
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col)
{
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2); 
   else
   {
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}