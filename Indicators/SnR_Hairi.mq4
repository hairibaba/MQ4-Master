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
#property version       "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// --- Input Variable ------------------------------------------------------------------
input int               Neighborhood   = 10,
                        NBar           = 300,
                        LineSize       = 3;
input ENUM_LINE_STYLE   LineStyle      = STYLE_SOLID; 
input color             SuppColor      = C'102,184,149',
                        ResColor       = C'214,87,95';

// --- Global Variable ------------------------------------------------------------------
string   ObjIdentifier  = "SnR_";

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
   
   // Redraw SnR Extension on new bar MTF
   if(NewBar(PERIOD_CURRENT)) {
      ExtendSegment(ObjIdentifier,time[rates_total-1]); 
      ChartRedraw();                    
   }
   
   //for (int i=rates_total;i>=(int)MathMax(prev_calculated-Neighborhood,Neighborhood); i--) {
   for (int i=rates_total-1;i>=0; i--) {
      if(i<rates_total-Neighborhood && i> rates_total-NBar) {
         bool LLV = true, 
              HHV = true,
              ForwardLLV = true,
              ForwardHHV = true;
              
         for(int k=1;k<Neighborhood;k++) {
            if(low[i+k]<low[i])  ForwardLLV = false;  
            if(low[i-k]<low[i])  LLV = false; 
            if(high[i+k]>high[i]) ForwardHHV = false;  
            if(high[i-k]>high[i]) HHV = false; 
         }
         
         if(LLV && ForwardLLV)  DrawLineSegment(ObjIdentifier+" Sup "+(string)time[i],low[i],time[i],time[rates_total-1],SuppColor);
         if(HHV && ForwardHHV)  DrawLineSegment(ObjIdentifier+" Res "+(string)time[i],high[i],time[i],time[rates_total-1],ResColor);  
      }
   }
   //ul_res = GetMicrosecondCount()-ul;
   //string ms = DoubleToString((ul_res/1000.0),2);
   //if(!IsTesting()) PrintFormat("SnR Calculated in %s ms.",ms);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
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

void DrawLineSegment(string Prefix, double pPrice, datetime T0, datetime T1,color coLinea) {           
   ObjectCreate(0,Prefix,OBJ_TREND, 0, T0, pPrice, T1, pPrice);   
   ObjectSetInteger(0,Prefix,OBJPROP_RAY,false);
   ObjectSetInteger(0,Prefix,OBJPROP_COLOR,coLinea);  
   ObjectSetInteger(0,Prefix,OBJPROP_STYLE,LineStyle);
   ObjectSetInteger(0,Prefix,OBJPROP_WIDTH,LineSize);
   ObjectSetInteger(0,Prefix,OBJPROP_BACK,true);
   ChartRedraw();
}

void ExtendSegment(string Prefix, datetime xf){
   for(int i = ObjectsTotal(0,-1,-1)-1; i>=0; i--) {
      string tmp = ObjectName(0,i,-1,-1);
      if(StringFind(tmp,Prefix) >= 0) {
         double yf = ObjectGetDouble(0,tmp,OBJPROP_PRICE,1);
         bool ret = ObjectMove(0,tmp,1,xf,yf);   
      }
   }
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