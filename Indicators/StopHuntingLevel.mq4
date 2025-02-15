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
#property version    "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input color Col_Fib     = C'37,44,63',
            Col_Level   = C'214,87,95',
            Col_Hunting = C'102,184,149',
            Col_ResSup  = clrLightYellow;

// --- Global Variable ------------------------------------------------------------------
int      MajorPeriod    = ((4-1)*24)+1,
         MajorPeriodRef = ((7-1)*24)+1;
string   ObjIdentifier  = "SMD_";
datetime Major_TimeHigh,Major_TimeLow,Prev_TimeHigh,Prev_TimeLow,Major_TimeHighRef,Major_TimeLowRef;
double   Major_PriceHigh,Major_PriceLow,Major_PriceMid,Prev_PriceHigh,Prev_PriceLow,Prev_PriceMid,Major_PriceHighRef,Major_PriceLowRef,Major_PriceMidRef;
double   Target_Above,Target_Below,MidLevel,RangeTop,RangeBottom;
double   Target_AboveM,Target_BelowM,MidLevelM,RangeTopM,RangeBottomM;
double   Target_AbovePrev,Target_BelowPrev,MidLevelPrev,RangeTopPrev,RangeBottomPrev;
double   Target_AboveX,Target_BelowX,MidLevelX,RangeTopX,RangeBottomX;
double   Hedge_Below,Hedge_Above;
double   Ext_TargetAbove,Ext_TargetBelow;
double   Day_LimitUpper,Day_LimitLower;
int MajorSwing,MajorSwingPrev,MajorSwingRef;
datetime TimeHigh_Major,TimeLow_Major,TimeHigh_MajorPrev,TimeLow_MajorPrev,TimeHigh_MajorX,TimeLow_MajorX,TimeHigh_Minor,TimeLow_Minor;

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
   
   MajorSwing = FilterSwing(MajorPeriod,Major_TimeHigh,Major_PriceHigh,Major_TimeLow,Major_PriceLow,Major_PriceMid);
   MajorSwingRef = FilterSwing(MajorPeriodRef,Major_TimeHighRef,Major_PriceHighRef,Major_TimeLowRef,Major_PriceLowRef,Major_PriceMidRef);
   
   DrawFibo(MajorSwing,"MajorSwing",Col_Fib,Major_TimeLow,Major_PriceLow,Major_TimeHigh,Major_PriceHigh,"M");
   if(!(Major_PriceHigh==Major_PriceHighRef && Major_PriceLow==Major_PriceLowRef)) DrawFibo(MajorSwingRef,"MajorSwingRef",Col_Fib,Major_TimeLowRef,Major_PriceLowRef,Major_TimeHighRef,Major_PriceHighRef,"R");
   else ObjectDrawDelete("MajorSwingRef");

   SwingTarget(1,3,Target_Above,Target_Below,MidLevel,RangeTop,RangeBottom);
   SwingTarget(1,2,Target_AboveM,Target_BelowM,MidLevelM,RangeTopM,RangeBottomM);
   SwingTarget(2,3,Target_AbovePrev,Target_BelowPrev,MidLevelPrev,RangeTopPrev,RangeBottomPrev);
   SwingTarget(3,3,Target_AboveX,Target_BelowX,MidLevelX,RangeTopX,RangeBottomX);
   VarTargetInside(0.118034,Major_PriceHigh,Major_PriceLow,Hedge_Above,Hedge_Below);
   VarTargetExtend(0.618,RangeTop,RangeBottom,Ext_TargetAbove,Ext_TargetBelow);
   avglimit(Day_LimitUpper,Day_LimitLower);

   int range_side = PointToInt((Target_Above-RangeTop)/2);
   int range_sidePrev = PointToInt((Target_AbovePrev-RangeTopPrev)/2);
   int range_sideH = PointToInt((Target_Above-RangeTop)/4);
   int StartDraw = Hour();
   int StartDrawPrev = 24+Hour();
   int StartDrawX = 48+Hour();
   if(StartDraw<12) StartDraw=12;
   double range_point = IntToPoint(range_side);
   double range_pointPrev = IntToPoint(range_sidePrev);
   double range_pointH = IntToPoint(range_sideH);
   double buffer = IntToPoint(30);
   
   double AvgPrice = PVAnalysis();
   double AvgPriceB = PVAnalysis(24);
   bool OrderBull = AvgPrice>=AvgPriceB;
   
   HLine("AvgP","Average Price",25,AvgPrice,STYLE_SOLID,C'59,166,236',4);
   HLine("AvgPB","Average Price Previous",49,AvgPriceB,STYLE_SOLID,C'59,166,236',4);
   
   HLine("Limit_Upper","Price Upper Limit",25,Day_LimitUpper,STYLE_SOLID,clrDeepPink,4);
   HLine("Limit_Lower","Price Lower Limit",25,Day_LimitLower,STYLE_SOLID,clrDeepPink,4);
   
   // Current Day Target
   HLine("TargetA","ST-Stops",StartDraw,Target_Above,STYLE_SOLID,Col_Level,4);
   HLine("TargetB","ST-Stops",StartDraw,Target_Below,STYLE_SOLID,Col_Level,4);
   HLine("Pivot","ST-Base",StartDraw,MidLevel,STYLE_SOLID,Col_Level,4);   
   HLine("Pivot_Prev","MT-Base",StartDrawPrev,MidLevelPrev,STYLE_SOLID,Col_Hunting,2);
   HLine("Pivot_X","LT-Base",StartDrawX,MidLevelX,STYLE_SOLID,Col_Hunting,2);
   HLine("yy","Ext ST-Stops",StartDraw,Ext_TargetAbove,STYLE_SOLID,Col_Level,4);
   HLine("zz","Ext ST-Stops",StartDraw,Ext_TargetBelow,STYLE_SOLID,Col_Level,4);
   
   // finding the mid direction
   double range_u = fmax(MidLevel,fmax(MidLevelPrev,MidLevelX));
   double range_l = fmin(MidLevel,fmin(MidLevelPrev,MidLevelX));
   double dayhigh = iHigh(_Symbol,PERIOD_D1,0);
   double daylow = iLow(_Symbol,PERIOD_D1,0);
   
   if(RangeBottomX!=RangeBottomPrev) HLine("4","MT-Sup",StartDrawPrev,RangeBottomPrev,STYLE_DOT,Col_ResSup,1);
   else ObjectDrawDelete("4");
   if(RangeTopX!=RangeTopPrev) HLine("3","MT-Res",StartDrawPrev,RangeTopPrev,STYLE_DOT,Col_ResSup,1);
   else ObjectDrawDelete("3");
   
   // Intraday Hunting
   HLine("HuntingAbove","StopHunt",StartDraw,RangeTopM+range_point,STYLE_SOLID,Col_Level,4);
   HLine("HuntingBelow","StopHunt",StartDraw,RangeBottomM-range_point,STYLE_SOLID,Col_Level,4);
   
   if(MajorSwingRef==OP_SELL) {      
      double HL = RangeTopPrev+range_pointPrev;
      HLine("HuntingPrev","StopHunt Prev",StartDrawPrev,HL,STYLE_SOLID,Col_Hunting,2);
      
      HLine("LT-Stops-Above","LT-Stops",StartDrawX,RangeTopX+buffer,STYLE_SOLID,Col_Hunting,2);
      HLine("LT-Stops-Below","LT-Stops",StartDrawX,Target_BelowX,STYLE_SOLID,Col_Hunting,2);  
      HLine("2","LT-Sup",StartDrawPrev,RangeBottomX,STYLE_DOT,Col_ResSup,1);
      
      if(RangeBottomX!=RangeBottomPrev) {
         HLine("MT-Stops-Above","MT-Stops",StartDrawPrev,RangeTopPrev+buffer,STYLE_SOLID,Col_Hunting,2);
         HLine("MT-Stops-Below","MT-Stops",StartDrawPrev,Target_BelowPrev,STYLE_SOLID,Col_Hunting,2);
      }
      else {
         ObjectDrawDelete("MT-Stops-Above");
         ObjectDrawDelete("MT-Stops-Below");
      } 
   }
   
   else if(MajorSwingRef==OP_BUY) {     
      double HL = RangeBottomPrev-range_pointPrev;
      HLine("HuntingPrev","Hunting Line Prev",StartDrawPrev,HL,STYLE_SOLID,Col_Hunting,2);
      
      HLine("LT-Stops-Above","LT-Stops",StartDrawX,Target_AboveX,STYLE_SOLID,Col_Hunting,2);
      HLine("LT-Stops-Below","LT-Stops",StartDrawX,RangeBottomX-buffer,STYLE_SOLID,Col_Hunting,2);
      HLine("1","LT-Res",StartDrawPrev,RangeTopX,STYLE_DOT,Col_ResSup,1);
      
      if(RangeBottomX!=RangeBottomPrev) {
         HLine("MT-Stops-Above","MT-Stops",StartDrawPrev,Target_AbovePrev,STYLE_SOLID,Col_Hunting,2);
         HLine("MT-Stops-Below","MT-Stops",StartDrawPrev,RangeBottomPrev-buffer,STYLE_SOLID,Col_Hunting,2);
      }
      else {
         ObjectDrawDelete("MT-Stops-Above");
         ObjectDrawDelete("MT-Stops-Below");
      }
   }
   
   double takeprofit = 0;
   double retracement = 0;
   double hedgingclose = 0;
   double buffdrw = IntToPoint(20);
   
   double ST_Base  = MidLevel;
   double ST_Above = Target_Above;
   double SH_Above = RangeTopM+range_point;
   double MT_Above = ObjectGetValueByShift(ObjIdentifier+"MT-Stops-Above",0);
   double LT_Above = ObjectGetValueByShift(ObjIdentifier+"LT-Stops-Above",0);
   
   double ST_Below = Target_Below;
   double SH_Below = RangeBottomM-range_point;
   double MT_Below = ObjectGetValueByShift(ObjIdentifier+"MT-Stops-Below",0);
   double LT_Below = ObjectGetValueByShift(ObjIdentifier+"LT-Stops-Below",0);
   double refprice = iOpen(_Symbol,PERIOD_D1,0);

   bool BullOrientation = refprice>=ST_Base;
   if(BullOrientation) {
      if(MajorSwingRef==OP_SELL) {
         if(refprice>LT_Above && refprice>MT_Above) {
            takeprofit = ST_Base;
            //DrawArrow("tar",takeprofit-buffer,140,ANCHOR_BOTTOM,clrGreenYellow);
            ObjectDrawDelete("tar2");
         }
         else {
            takeprofit = SH_Above;
            if(Major_PriceMidRef>SH_Above) takeprofit = Target_Above;
            retracement = ST_Base;
            hedgingclose = Hedge_Below;
            //DrawArrow("rec",retracement-buffer,140,ANCHOR_TOP,clrOrangeRed);
            //DrawArrow("tar",takeprofit+buffer,141,ANCHOR_BOTTOM,clrGreenYellow);
            //DrawArrow("tar2",ST_Above+buffer,142,ANCHOR_BOTTOM,clrGreenYellow);
         }
      }
      else {
         takeprofit = Target_Above;
         retracement = ST_Base;
         hedgingclose = Hedge_Below;
         //DrawArrow("rec",retracement-buffer,140,ANCHOR_TOP,clrOrangeRed);
         //DrawArrow("tar",takeprofit+buffer,141,ANCHOR_BOTTOM,clrGreenYellow);
         ObjectDrawDelete("tar2");
      }
   }
   else {
      if(MajorSwingRef==OP_BUY) {
         if(refprice<LT_Below && refprice<MT_Below) {
            takeprofit = ST_Base;
            //DrawArrow("tar",takeprofit+buffer,140,ANCHOR_BOTTOM,clrGreenYellow);
            ObjectDrawDelete("tar2");
         }
         else {
            takeprofit = SH_Below;
            if(Major_PriceMidRef<SH_Below) takeprofit = Target_Below;
            retracement = ST_Base;
            hedgingclose = Hedge_Above;
            //DrawArrow("rec",retracement+buffer,140,ANCHOR_BOTTOM,clrOrangeRed);
            //DrawArrow("tar",takeprofit-buffer,141,ANCHOR_TOP,clrGreenYellow);
            //DrawArrow("tar2",ST_Below-buffer,142,ANCHOR_BOTTOM,clrGreenYellow);
         }
      }
      else {
         takeprofit = Target_Below;
         retracement = ST_Base;
         hedgingclose = Hedge_Above;
         //DrawArrow("rec",retracement+buffer,140,ANCHOR_BOTTOM,clrOrangeRed);
         //DrawArrow("tar",takeprofit-buffer,141,ANCHOR_TOP,clrGreenYellow);
         ObjectDrawDelete("tar2");
      }
   }
   
   DrawRectangle("TakeProfitArea",iTime(_Symbol,PERIOD_H1,StartDrawPrev),takeprofit+buffdrw,Time[0],takeprofit-buffdrw,clrGreenYellow);
   if(retracement>0) DrawRectangle("RetracementArea",iTime(_Symbol,PERIOD_H1,StartDrawPrev),retracement+buffdrw,Time[0],retracement-buffdrw,clrOrangeRed);
   else ObjectDrawDelete("RetracementArea");
   if(hedgingclose>0) {
      DrawRectangle("HedgingClose",iTime(_Symbol,PERIOD_H1,StartDrawPrev),hedgingclose+buffdrw,Time[0],hedgingclose-buffdrw,C'59,166,236');
      HLine("HedgeClose","Hedging Stops",StartDrawPrev,hedgingclose,STYLE_SOLID,C'214,87,95',4);
   }
   else {
      ObjectDrawDelete("HedgingClose");
      ObjectDrawDelete("HedgeClose");
   }

   /*
   Comment(
   "\n\n ST Above : ",ST_Above,
   "\n\n SH Above : ",SH_Above,
   "\n\n MT Above : ",MT_Above,
   "\n\n LT Above : ",LT_Above);
   */
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

int FilterSwing(int bar, datetime& timehigh, double& pricehigh, datetime& timelow, double& pricelow, double& pricemid, int StartCount = 0){
   int sig = 100;
   int shiftLowest = iLowest(_Symbol,PERIOD_H1,MODE_LOW,bar+Hour(),StartCount);
   int shiftHighest = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,bar+Hour(),StartCount);
   
   // Time coordinate
   timehigh = iTime(_Symbol,PERIOD_H1,shiftHighest);
   timelow = iTime(_Symbol,PERIOD_H1,shiftLowest);
   
   
   // Price coordinate
   pricehigh = iHigh(_Symbol,PERIOD_H1,shiftHighest);
   pricelow = iLow(_Symbol,PERIOD_H1,shiftLowest);
   double range   = pricehigh-pricelow;
   double MultiM  = NormPrice(range*0.5);
   pricemid       = MultiM+pricelow;
   
   if(shiftHighest > shiftLowest) sig = OP_SELL;
   else if(shiftHighest < shiftLowest) sig = OP_BUY;
   
   return sig;
}

void VarTargetExtend(double multiplier, double high, double low, double& above, double& below) {
   double range = high-low;
   above   = NormPrice(range*multiplier)+high;
   below   = low-NormPrice(range*multiplier);
}

void VarTargetInside(double multiplier, double high, double low, double& above, double& below) {
   double range = high-low;
   below   = NormPrice(range*multiplier)+low;
   above   = high-NormPrice(range*multiplier);
}

void SwingTarget(int Start, int Range, double& Tar_Above, double& Tar_Below, double& Mid_Level, double& high, double& low){
   /*
   int shiftLowest   = 0;
   int shiftHighest  = 0;
   double Highest[], Lowest[],BarHigh[],BarLow[];
   ArraySetAsSeries(Highest,true);
   ArraySetAsSeries(Lowest,true);
   ArraySetAsSeries(BarHigh,true);
   ArraySetAsSeries(BarLow,true);
   int copyHighest   = CopyHigh(_Symbol,PERIOD_D1,Start,Range,Highest);
   int copyLowest    = CopyLow(_Symbol,PERIOD_D1,Start,Range,Lowest);
   if(copyHighest>0) shiftHighest = ArrayMaximum(Highest,Range,Start);
   if(copyLowest>0)  shiftLowest = ArrayMinimum(Lowest,Range,Start);
   
   int copyHigh   = CopyHigh(_Symbol,PERIOD_D1,shiftHighest,3,BarHigh);
   int copyLow    = CopyLow(_Symbol,PERIOD_D1,shiftLowest,3,BarLow);
   if(copyHigh>0) high = BarHigh[shiftHighest];
   if(copyLow>0) low = BarLow[shiftLowest];
   */
   
   int shiftLowest = iLowest(_Symbol,PERIOD_D1,MODE_LOW,Range,Start);
   int shiftHighest = iHighest(_Symbol,PERIOD_D1,MODE_HIGH,Range,Start);
   low = iLow(_Symbol,PERIOD_D1,shiftLowest);
   high = iHigh(_Symbol,PERIOD_D1,shiftHighest);
   
   
   double range = high-low;
   double tarfib = 0.162; // 0.162
   
   Tar_Above   = NormPrice(range*tarfib)+high;
   Tar_Below   = low-NormPrice(range*tarfib);
   Mid_Level   = NormPrice(range*0.5)+low;
}

double NormPrice(double price){
   double tickSize=MarketInfo(_Symbol,MODE_TICKSIZE);
   return round(price/tickSize)*tickSize;
}

void CreatePriceFlag(string name, double price, color col){
   datetime time = Time[0]+_Period*60;
   if(ObjectFind(0,ObjIdentifier+name) != 0) ObjectCreate(0,ObjIdentifier+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
   else ObjectMove(0,ObjIdentifier+name,0, time, price);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
}

void HLine(string name, string desc, int pShiftTime, double pPrice, int pStyle, color pColor, int pWidth){
   DrawShortHLine(name,pShiftTime,pPrice,pStyle,pColor,pWidth);
   CreatePriceLabel(name+" Label",desc,pPrice,pColor);
   CreatePriceFlag (name+" Price",pPrice,pColor);
}

int ChartScaleGet(){
   long result = -1;
   ChartGetInteger(0,CHART_SCALE,0,result);
   return((int)result);
}

void DrawShortHLine(string nameX, int time1, double P0, int style, color clr, int width){   
   string objName;
   
   datetime T0 = iTime(_Symbol,PERIOD_H1,time1);
   datetime T1 = iTime(_Symbol,PERIOD_M1,1);
   
   objName=nameX;
   if (ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   else{
      ObjectDelete(0,ObjIdentifier+objName);
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY, false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
}

void CreatePriceLabel(string name, string desc, double price, color col){
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

   if (ObjectFind(0,ObjIdentifier+name) != 0){
      ObjectCreate(0,ObjIdentifier+name,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString (0,ObjIdentifier+name,OBJPROP_TEXT,desc);
      ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(0,ObjIdentifier+name,0, time, price);
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col){
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2); 
   else{
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
}

void DrawFibo(int swing, string name, color fibclr, datetime time1, double price1, datetime time2, double price2, string mark = ""){
   if(swing==OP_SELL){
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      else{
         ObjectDelete(0,ObjIdentifier+name);
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time1,price1,time2,price2); 
      }
   }
   else if(swing==OP_BUY){
      if (ObjectFind(0,ObjIdentifier+name) != 0)
         ObjectCreate(0,ObjIdentifier+name, OBJ_FIBO, 0, time2,price2,time1,price1); 
      else{
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
   
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,0,mark+"000 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,1,mark+"012 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,2,mark+"023 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,3,mark+"038 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,4,mark+"050 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,5,mark+"062 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,6,mark+"076 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,7,mark+"088 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,8,mark+"100 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,9,mark+"123 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,10,mark+"138 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,11,mark+"162 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,12,mark+"200 - %$");
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_LEVELTEXT,13,mark+"262 - %$");
}

void DrawArrow(string name, double price, uchar arrow_code, ENUM_ARROW_ANCHOR anchor, color col){
   if (ObjectFind(0,ObjIdentifier+name) != 0){
      ObjectCreate(0,ObjIdentifier+name,OBJ_ARROW,0,Time[0],price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ARROWCODE,arrow_code);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH,5);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(0,ObjIdentifier+name,0,Time[0],price);
}

double PVAnalysis(int candle=0){
   double price = 0;
   double totalprice = 0;
   double avgprice = 0;
   long vol = 0;
   long totalvol = 0;
   
   for(int i=25+candle;i>=1+candle;i--){
      price = iClose(_Symbol,PERIOD_H1,i);
      vol = iVolume(_Symbol,PERIOD_H1,i);
   
      totalprice += price*vol;
      totalvol += vol;
      
      avgprice = totalprice/totalvol;
   }

   return NormPrice(avgprice);
}

void avglimit(double& limit_up, double& limit_down) {
   double dayHigh = iHigh(_Symbol,PERIOD_D1,0);
   double dayLow = iLow(_Symbol,PERIOD_D1,0);
   int avg = AvgDailyRange(14,1);
   int atr = ATR(PERIOD_D1,14);
   int avgavg = int((avg+atr)/2);
   int range = PointToInt(dayHigh-dayLow);
   limit_down = dayHigh-IntToPoint(avgavg);
   limit_up = dayLow+IntToPoint(avgavg);
}

int ATR(int timeframe, int period){
   double ATR = iATR(_Symbol,timeframe,period,1);
   return int(ATR * MathPow(10,_Digits));
}

int AvgDailyRange(int range, int startbar=0){
   double sum = 0;
   int count = 0;
   
   for (int i=range+startbar; i>startbar; i--){
      double hi = iHigh(_Symbol,PERIOD_D1,i);
      double lo = iLow(_Symbol,PERIOD_D1,i);
      datetime dt = iTime(_Symbol,PERIOD_D1,i);
      if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6) {
         sum += hi-lo;
         count++;
      }
   }
   return PointToInt(sum/count);
}