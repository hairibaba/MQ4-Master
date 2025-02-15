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
#property description   "Support_Resistance"
#property version       "1.15"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
extern ENUM_TIMEFRAMES  MTF            = PERIOD_H4; 
input int               inpBars        = 320,            // Bars Calculation
                        inpCalcRange   = 10,             // Bars Range
                        inpLineSize    = 3;              // Line Size
input ENUM_LINE_STYLE   inpLineStyle   = STYLE_SOLID;    // Line Style
input color             inpSuppColor   = C'102,184,149', // Supp Color
                        inpResColor    = C'214,87,95';   // Res Color
sinput string           Notifications  = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
input ENUM_TIMEFRAMES   _Freq          = PERIOD_M5;      // Notification Frequency
input bool              _Alert         = false,          // Send Alert
                        _Noti          = false,          // Send Notifications
                        _Email         = false;          // Send Email

// --- Global Variable ------------------------------------------------------------------
string   ObjIdentifier  = "SnR_";

int OnInit(){
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
   // Update only on new bar MTF
   
   if(_Period==PERIOD_D1) MTF = PERIOD_D1;
   else if(_Period==PERIOD_W1) MTF = PERIOD_W1;
   else if(_Period==PERIOD_MN1) MTF = PERIOD_MN1;
   
   int rates_totalMTF = Bars(_Symbol,MTF); 
   datetime MTF_TF[1];
   int ret = CopyTime(_Symbol,MTF,rates_totalMTF-inpCalcRange,1,MTF_TF);
   if(ret<0) return(0); 
   if(SeriesInfoInteger(_Symbol,MTF,SERIES_BARS_COUNT)<inpBars) return(0);
   if(!verifyHistory()) return(prev_calculated);
   
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(open,false); 
   ArraySetAsSeries(low,false); 
   ArraySetAsSeries(close,false); 
   ArraySetAsSeries(high,false); 
   
   // Redraw SnR Extension on new bar Current Timeframe
   if(NewBar(PERIOD_CURRENT)) {
      UpdateSegment(ObjIdentifier,time[rates_total-1]); 
      ChartRedraw();                    
   }
   
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - prev_calculated;
   
   for(int i = bars; i >=0; i--){
      if(time[i]<MTF_TF[0]) break;
      datetime diff = time[i]-(int)(time[i]% PeriodSeconds(MTF));
      int iMTF = rates_totalMTF - iBarShift(_Symbol,MTF,time[i]);
   
      if(iMTF > rates_totalMTF-inpBars && iMTF < rates_totalMTF-inpCalcRange ) {
         bool LLV = true, 
              HHV = true,
              ForwardLLV = true,
              ForwardHHV = true;
         double Low_i_MTF[1],High_i_MTF[1];
         ret = CopyLow(_Symbol,MTF,rates_totalMTF-iMTF,1,Low_i_MTF);
         if (ret <0) return(0);
         ret = CopyHigh(_Symbol,MTF,rates_totalMTF-iMTF,1,High_i_MTF);
         if (ret <0) return(0 );
              
         for(int k=1;k<inpCalcRange;k++) {
            double Low_i_plusk_MTF[1],High_i_plusk_MTF[1];
            double Low_i_lessk_MTF[1],High_i_lessk_MTF[1];
            
            ret = CopyLow(_Symbol,MTF,rates_totalMTF-(iMTF+k),1,Low_i_plusk_MTF);
            if (ret <0) return(0);
            ret = CopyHigh(_Symbol,MTF,rates_totalMTF-(iMTF+k),1,High_i_plusk_MTF); 
            if (ret <0) return(0);         
            ret = CopyLow(_Symbol,MTF,rates_totalMTF-(iMTF-k),1,Low_i_lessk_MTF);
            if (ret <0) return(0);
            ret = CopyHigh(_Symbol,MTF,rates_totalMTF-(iMTF-k),1,High_i_lessk_MTF); 
            if (ret <0) return(0);
            
            if(Low_i_plusk_MTF[0]<Low_i_MTF[0])   ForwardLLV = false;  
            if(Low_i_lessk_MTF[0]<Low_i_MTF[0])   LLV = false; 
            if(High_i_plusk_MTF[0]>High_i_MTF[0]) ForwardHHV = false;  
            if(High_i_lessk_MTF[0]>High_i_MTF[0]) HHV = false; 
         }

         if(LLV && ForwardLLV) DrawSnR(ObjIdentifier+" Sup "+(string)diff,diff,Low_i_MTF[0],inpSuppColor);
         if(HHV && ForwardHHV) DrawSnR(ObjIdentifier+" Res "+(string)diff,diff,High_i_MTF[0],inpResColor);  
      }
   }
   alerter(_Freq);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
}

void DrawSnR(string Prefix, datetime pTime, double pPrice, color col) {           
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   CopyTime(_Symbol,_Period,0,2,ArrayTime);
   
   if (ObjectFind(0,Prefix) != 0)
      ObjectCreate(0,Prefix,OBJ_TREND, 0, pTime, pPrice, ArrayTime[0], pPrice);  
   else{
      ObjectDelete(0,Prefix);
      ObjectCreate(0,Prefix,OBJ_TREND, 0, pTime, pPrice, ArrayTime[0], pPrice);  
   }
   ObjectSetInteger(0,Prefix,OBJPROP_RAY,false);
   ObjectSetInteger(0,Prefix,OBJPROP_COLOR,col);  
   ObjectSetInteger(0,Prefix,OBJPROP_STYLE,inpLineStyle);
   ObjectSetInteger(0,Prefix,OBJPROP_WIDTH,inpLineSize);
   ObjectSetInteger(0,Prefix,OBJPROP_BACK,true);
   ObjectSetInteger(0,Prefix,OBJPROP_HIDDEN,true);
   SetIndexLabel(0,NULL);
   ChartRedraw();
}

bool NewBar(ENUM_TIMEFRAMES timeframe){
   datetime ArrayTime[];
   static datetime LastTime = 0;
   bool firstRun = false, newBar = false;
   ArraySetAsSeries(ArrayTime,true);
	CopyTime(_Symbol,timeframe,0,2,ArrayTime);
	
	if(LastTime == 0) firstRun = true;
	if(ArrayTime[0] > LastTime){
		if(firstRun == false) newBar = true;
		LastTime = ArrayTime[0];
	}
	return newBar;   
}

int TickCount(ENUM_TIMEFRAMES timeframe) {
   static int TickCount = 0;
   static datetime BarTime = 0; 
   datetime timechk = iTime(_Symbol,timeframe,0);
   
   if(timechk!=BarTime) { 
      TickCount = 0; 
      BarTime = timechk;
   } else TickCount++;
   return TickCount;
}

bool FirstTick(ENUM_TIMEFRAMES timeframe) {
   return TickCount(timeframe)==1;
}

void UpdateSegment(string Prefix, datetime xf){
   for(int i = ObjectsTotal(0,-1,-1)-1; i>=0; i--) {
      string tmp = ObjectName(0,i,-1,-1);
      if(StringFind(tmp,Prefix) >= 0) {
         int z = StringLen(tmp); 
         int y = StringLen(ObjIdentifier+" Sup ");
         datetime some_time = StringToTime(StringSubstr(tmp,y));
         int shift = iBarShift(_Symbol,MTF,some_time);

         if(shift>inpBars) ObjectDelete(0,tmp);
         else {
            double yf = ObjectGetDouble(0,tmp,OBJPROP_PRICE,1);
            ObjectMove(0,tmp,1,xf,yf); 
         }  
      }
   }
}

bool verifyHistory(string symbol = NULL) {
   if(symbol==NULL) symbol=_Symbol;
   bool x = true;
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   int copied = CopyTime(symbol,PERIOD_M1,0,5,ArrayTime);
   if(copied<0) x = false;
   return x;
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return round(price/ticksize)*ticksize;
}

bool detectCross(string Prefix, string& line, double& level) {
   bool x = false;
   
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied = CopyRates(_Symbol,PERIOD_M1,0,2,rates);
   if(copied>0) {
      for(int i = ObjectsTotal(0,-1,-1)-1; i>=0; i--) {
         string tmp = ObjectName(0,i,-1,-1);
         if(StringFind(tmp,Prefix) >= 0) {
            level = NormPrice(ObjectGetValueByTime(0,tmp,rates[0].time,0));
            if((rates[0].open<level && rates[0].high>level )|| (rates[0].open>level && rates[0].low<level)) {
               line = tmp;
               x = true;
            }
         }
      }
   }
   return x;
}

void alerter(ENUM_TIMEFRAMES timeframe) {
   string line = "";
   double level = 0;
   static int counter = 0;
   string NewLine = "\n", sInput  = "%s";
   
   if(detectCross(ObjIdentifier,line,level) && counter==1) {
      int z = StringLen(line); 
      int y = StringLen(ObjIdentifier+" Sup ");
      string s = StringSubstr(line,y-4,3);
      string some_time = StringSubstr(line,y);
      string what = "Support";
      if(s=="res") what = "Resistance";
                                           
      string msg = StringFormat("%s Alert on %s \n%s Location : %s\nPrice Level : %s",
                                 what,
                                 _Symbol,
                                 what,
                                 some_time,
                                 DoubleToString(level,_Digits));
                   
      if(_Alert) Alert(msg);
      if(_Noti && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
      if(_Email) SendMailFunction(what+" Alert on "+_Symbol,msg);
      counter++;
   }
   if(FirstTick(timeframe)) counter = 0;
}

void SendMailFunction(string subject, string text) {
   if(TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) {
      bool send = SendMail(subject,text); 
      if(!send) Alert("Error sending email");
   }
}