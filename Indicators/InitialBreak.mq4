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
#property description   "Initial Break (IB)"
#property version       "1.00"
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
string   ObjIdentifier  = "XXX_";


int OnInit(){
   ChartHistory();
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
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
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(open,false); 
   ArraySetAsSeries(low,false); 
   ArraySetAsSeries(close,false); 
   ArraySetAsSeries(high,false); 
   
   for (int i=rates_total-1;i>=0; i--) {
      if(i<rates_total-1 && i>rates_total-500) {             
         bool  IB_Bullish  = true,
               IB_Bearish  = true,
               IB_HH       = true,
               IB_LL       = true,
               IB_HC       = true,
               IB_LC       = true,
               IB_ExtHigh  = true,
               IB_ExtLow   = true,
               PR_Bullish  = true,
               PR_Bearish  = true,
               PR_HH       = true,
               PR_LL       = true;
         
         // Evaluate IB Candle condition
         if(close[i]<open[i]) IB_Bullish = false;
         if(close[i]>open[i]) IB_Bearish = false;

         for(int a=1;a<4;a++) {
            if(high[i-a]>high[i])   IB_HH = false;
            if(low[i-a]<low[i])     IB_LL = false;
            if(close[i-a]>close[i]) IB_HC = false;
            if(close[i-a]<close[i]) IB_LC = false;
         }
         
         // Evaluate PR Candle condition
         if(close[i-1]<open[i-1]) PR_Bullish = false;
         if(close[i-1]>open[i-1]) PR_Bearish = false;
         
         for(int b=2;b<8;b++) {
            if(high[i-b]>high[i-1])   PR_HH = false;
            if(low[i-b]<low[i-1])     PR_LL = false;
         }
         
         if(IB_Bullish && PR_Bearish && IB_HH && IB_HC && (IB_LL||PR_LL)) {
            double upper   = high[i];
            double lower   = fmin(low[i-1],low[i]);
            double range   = upper-lower;
            double frac    = NormPrice(range/4.0);
            double middle  = lower+(2*frac);
            double entry   = lower + (range*0.381966);
            double entry2  = lower + (range*0.236068);
            double entry3  = lower + (range*0.118);
            double entry4  = lower + (range*0.763932);
            double sl      = lower - (range*0.5);
            double tp      = upper + (range*0.272);
            double tp2     = upper + (range*0.618034);
            double tp3     = upper + (range*0.618034) + range;
            
            if(PointToInt(range)>=220) {
               DrawRectangle("Bull_"+(string)time[i],time[i],upper,time[i-1],lower,clrLime);
               DrawShortHLine("BH1_"+(string)time[i],time[i],time[i-5],upper,clrLime);
               DrawShortHLine("BH2_"+(string)time[i],time[i],time[i-5],lower,clrLime);
               DrawShortHLine("BH3_"+(string)time[i],time[i],time[i-7],middle,clrLime);
               DrawShortHLine("BH4_"+(string)time[i],time[i],time[i-5],sl,clrLime);
               DrawShortHLine("BH5_"+(string)time[i],time[i],time[i-5],tp,clrLime);
               DrawShortHLine("BH6_"+(string)time[i],time[i],time[i-5],tp2,clrLime);
               DrawShortHLine("BH7_"+(string)time[i],time[i],time[i-5],tp3,clrLime);
               DrawShortHLine("BH8_"+(string)time[i],time[i],time[i-7],entry,clrLime);
               DrawShortHLine("BH9_"+(string)time[i],time[i],time[i-7],entry2,clrLime);
               DrawShortHLine("BH10_"+(string)time[i],time[i],time[i-7],entry3,clrLime);
               DrawShortHLine("BH11_"+(string)time[i],time[i],time[i-7],entry4,clrLime);
            }
         }
         if(IB_Bearish && PR_Bullish && IB_LL && IB_LC && (IB_HH||PR_HH)) {
            double upper   = fmax(high[i-1],high[i]);
            double lower   = low[i];
            double range   = upper-lower;
            double frac    = NormPrice(range/4.0);
            double middle  = lower+(2*frac);
            double entry   = upper - (range*0.381966);
            double entry2  = upper - (range*0.236068);
            double entry3  = upper - (range*0.118);
            double entry4  = upper - (range*0.763932);
            double sl      = upper + (range*0.5);
            double tp      = lower - (range*0.272);
            double tp2     = lower - (range*0.618034);
            double tp3     = lower - (range*0.618034) - range;
            
            if(PointToInt(range)>=220) {
               DrawRectangle("Bear_"+(string)time[i],time[i],lower,time[i-1],upper,clrOrangeRed);
               DrawShortHLine("SH1_"+(string)time[i],time[i],time[i-5],lower,clrOrangeRed);
               DrawShortHLine("SH2_"+(string)time[i],time[i],time[i-5],upper,clrOrangeRed);
               DrawShortHLine("SH3_"+(string)time[i],time[i],time[i-7],middle,clrOrangeRed);
               DrawShortHLine("SH4_"+(string)time[i],time[i],time[i-5],sl,clrOrangeRed);
               DrawShortHLine("SH5_"+(string)time[i],time[i],time[i-5],tp,clrOrangeRed);
               DrawShortHLine("SH6_"+(string)time[i],time[i],time[i-5],tp2,clrOrangeRed);
               DrawShortHLine("SH7_"+(string)time[i],time[i],time[i-5],tp3,clrOrangeRed);
               DrawShortHLine("SH8_"+(string)time[i],time[i],time[i-7],entry,clrOrangeRed);
               DrawShortHLine("SH9_"+(string)time[i],time[i],time[i-7],entry2,clrOrangeRed);
               DrawShortHLine("SH10_"+(string)time[i],time[i],time[i-7],entry3,clrOrangeRed);
               DrawShortHLine("SH11_"+(string)time[i],time[i],time[i-7],entry4,clrOrangeRed);
            }
         }
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
}

void ChartHistory(string symbol = NULL) {
   if(symbol==NULL) symbol=_Symbol;
   ENUM_TIMEFRAMES tfs[] = {
      PERIOD_M1,  PERIOD_M5, PERIOD_M15,
      PERIOD_M30, PERIOD_H1, PERIOD_H4, 
      PERIOD_D1,  PERIOD_W1, PERIOD_MN1
   };
         
   for(int j=ArraySize(tfs)-1; j>=0; --j)
      while(!verifyHistory(symbol,tfs[j]));
   RefreshRates();
}

bool verifyHistory(string symbol, ENUM_TIMEFRAMES tf) {
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   int copied = CopyTime(symbol,tf,0,5,ArrayTime);
   if(copied<0) {
      Sleep(10);
      return false;
   }
   else return true;
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return Round(price,ticksize);
}

double Round(double value, double rounding) {
   return round(value/rounding)*rounding;
}

int PointToInt (double point) {
   return int(point/_Point);
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col) {
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2); 
   else{
      ObjectDelete(0,ObjIdentifier+name);
      ObjectCreate(0,ObjIdentifier+name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   }
   
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
}

void DrawShortHLine(string objName, datetime T0, datetime T1, double pPrice, color clr) {   
   if (ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   else{
      ObjectDelete(0,ObjIdentifier+objName);
      ObjectCreate(0,ObjIdentifier+objName,OBJ_TREND, 0, T0, pPrice, T1, pPrice);
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY,false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
}

void alerter() {
   string msg = StringFormat("Initial Break (IB) on %s",_Symbol);
   Alert(msg);
   if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
} 