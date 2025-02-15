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
#property version       "1.21"
#property description   "Four Pivot Timeframe"
#property strict
#property indicator_chart_window

enum PivotMethod {
   Method_Classic,
   Method_Camarilla,
   Method_TomDeMark,
   Method_Fibonacci,
   Method_Woodies,
};

input PivotMethod       PivotFormula      = Method_Fibonacci;
input ENUM_TIMEFRAMES   Applied_TimeFrame = PERIOD_W1;
input bool              PriceLabel        = true;
input color             LevelColor        = clrBlue;
sinput string           Notifications     = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
input ENUM_TIMEFRAMES   _Freq             = PERIOD_M5;      // Notification Frequency
input bool              _Alert            = false,          // Send Alert
                        _Noti             = false,          // Send Notifications
                        _Email            = false;          // Send Email

string      Objname,
            ObjIdentifier = "IN_";
double      Classic_R4,Classic_R3,Classic_R2,Classic_R1,Classic_Pivot,Classic_S1,Classic_S2,Classic_S3,Classic_S4,
            Camarilla_R4,Camarilla_R3,Camarilla_R2,Camarilla_R1,Camarilla_Pivot,Camarilla_S1,Camarilla_S2,Camarilla_S3,Camarilla_S4,
            Woodies_R4,Woodies_R3,Woodies_R2,Woodies_R1,Woodies_Pivot,Woodies_S1,Woodies_S2,Woodies_S3,Woodies_S4,
            TomDeMark_R3,TomDeMark_R2,TomDeMark_R1,TomDeMark_Pivot,TomDeMark_S1,TomDeMark_S2,TomDeMark_S3,
            Fibonacci_R3,Fibonacci_R2,Fibonacci_R1,Fibonacci_Pivot,Fibonacci_S1,Fibonacci_S2,Fibonacci_S3;

int OnInit(){
   return(INIT_SUCCEEDED);
}

int deinit() {
   ObjectDeleteAll();
   return (0);
}

int start()  {
   int BarCheck = IndicatorCounted();
   if (BarCheck < 0) return (-1);
   if (BarCheck > 0) BarCheck--;
   int TotalBar = Bars - BarCheck;

   for (int BarMeasure = 0; BarMeasure <= 200; BarMeasure++) {
      if(PivotFormula==Method_Camarilla) {
         Camarilla(Applied_TimeFrame,Camarilla_R4,Camarilla_R3,Camarilla_R2,Camarilla_R1,Camarilla_Pivot,Camarilla_S1,Camarilla_S2,Camarilla_S3,Camarilla_S4);
         HLine("PPCamarilla_Pivot","Camarilla_Pivot",Camarilla_Pivot,STYLE_SOLID,2);
         HLine("PPCamarilla_R4","Camarilla_R4",Camarilla_R4,STYLE_DOT,1);
         HLine("PPCamarilla_R3","Camarilla_R3",Camarilla_R3,STYLE_DOT,1);
         HLine("PPCamarilla_R2","Camarilla_R2",Camarilla_R2,STYLE_DOT,1);
         HLine("PPCamarilla_R1","Camarilla_R1",Camarilla_R1,STYLE_DOT,1);
         HLine("PPCamarilla_S4","Camarilla_S4",Camarilla_S4,STYLE_DOT,1);
         HLine("PPCamarilla_S3","Camarilla_S3",Camarilla_S3,STYLE_DOT,1);
         HLine("PPCamarilla_S2","Camarilla_S2",Camarilla_S2,STYLE_DOT,1);
         HLine("PPCamarilla_S1","Camarilla_S1",Camarilla_S1,STYLE_DOT,1);
      }
      
      else if(PivotFormula==Method_Classic) {
         Classic(Applied_TimeFrame,Classic_R4,Classic_R3,Classic_R2,Classic_R1,Classic_Pivot,Classic_S1,Classic_S2,Classic_S3,Classic_S4);
         HLine("PPClassic_Pivot","Classic_Pivot",Classic_Pivot,STYLE_SOLID,2);
         HLine("PPClassic_R4","Classic_R4",Classic_R4,STYLE_DOT,1);
         HLine("PPClassic_R3","Classic_R3",Classic_R3,STYLE_DOT,1);
         HLine("PPClassic_R2","Classic_R2",Classic_R2,STYLE_DOT,1);
         HLine("PPClassic_R1","Classic_R1",Classic_R1,STYLE_DOT,1);
         HLine("PPClassic_S4","Classic_S4",Classic_S4,STYLE_DOT,1);
         HLine("PPClassic_S3","Classic_S3",Classic_S3,STYLE_DOT,1);
         HLine("PPClassic_S2","Classic_S2",Classic_S2,STYLE_DOT,1);
         HLine("PPClassic_S1","Classic_S1",Classic_S1,STYLE_DOT,1);
      }
      
      else if(PivotFormula==Method_Woodies) {
         Woodies(Applied_TimeFrame,Woodies_R4,Woodies_R3,Woodies_R2,Woodies_R1,Woodies_Pivot,Woodies_S1,Woodies_S2,Woodies_S3,Woodies_S4);
         HLine("PPWoodies_Pivot","Woodies_Pivot",Woodies_Pivot,STYLE_SOLID,2);
         HLine("PPWoodies_R4","Woodies_R4",Woodies_R4,STYLE_DOT,1);
         HLine("PPWoodies_R3","Woodies_R3",Woodies_R3,STYLE_DOT,1);
         HLine("PPWoodies_R2","Woodies_R2",Woodies_R2,STYLE_DOT,1);
         HLine("PPWoodies_R1","Woodies_R1",Woodies_R1,STYLE_DOT,1);
         HLine("PPWoodies_S4","Woodies_S4",Woodies_S4,STYLE_DOT,1);
         HLine("PPWoodies_S3","Woodies_S3",Woodies_S3,STYLE_DOT,1);
         HLine("PPWoodies_S2","Woodies_S2",Woodies_S2,STYLE_DOT,1);
         HLine("PPWoodies_S1","Woodies_S1",Woodies_S1,STYLE_DOT,1);
      }
      
      else if(PivotFormula==Method_TomDeMark)
      {
         TomDeMark(Applied_TimeFrame,TomDeMark_R3,TomDeMark_R2,TomDeMark_R1,TomDeMark_Pivot,TomDeMark_S1,TomDeMark_S2,TomDeMark_S3);
         HLine("PPTomDeMark_Pivot","TomDeMark_Pivot",TomDeMark_Pivot,STYLE_SOLID,2);
         HLine("PPTomDeMark_R3","TomDeMark_R3",TomDeMark_R3,STYLE_DOT,1);
         HLine("PPTomDeMark_R2","TomDeMark_R2",TomDeMark_R2,STYLE_DOT,1);
         HLine("PPTomDeMark_R1","TomDeMark_R1",TomDeMark_R1,STYLE_DOT,1);
         HLine("PPTomDeMark_S3","TomDeMark_S3",TomDeMark_S3,STYLE_DOT,1);
         HLine("PPTomDeMark_S2","TomDeMark_S2",TomDeMark_S2,STYLE_DOT,1);
         HLine("PPTomDeMark_S1","TomDeMark_S1",TomDeMark_S1,STYLE_DOT,1);
      }
      
      else if(PivotFormula==Method_Fibonacci) {
         Fibonacci(Applied_TimeFrame,Fibonacci_R3,Fibonacci_R2,Fibonacci_R1,Fibonacci_Pivot,Fibonacci_S1,Fibonacci_S2,Fibonacci_S3);
         HLine("PPFibonacci_Pivot","Fibonacci_Pivot",Fibonacci_Pivot,STYLE_SOLID,2);
         HLine("PPFibonacci_R3","Fibonacci_R3",Fibonacci_R3,STYLE_DOT,1);
         HLine("PPFibonacci_R2","Fibonacci_R2",Fibonacci_R2,STYLE_DOT,1);
         HLine("PPFibonacci_R1","Fibonacci_R1",Fibonacci_R1,STYLE_DOT,1);
         HLine("PPFibonacci_S3","Fibonacci_S3",Fibonacci_S3,STYLE_DOT,1);
         HLine("PPFibonacci_S2","Fibonacci_S2",Fibonacci_S2,STYLE_DOT,1);
         HLine("PPFibonacci_S1","Fibonacci_S1",Fibonacci_S1,STYLE_DOT,1);
      }
   }
   
   alerter(_Freq);
   
   return (0);
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void DrawShortHLine(string nameX, double P0, int style, color clr, int width){   
   string objName;
   
   datetime T0 = iTime(_Symbol,Applied_TimeFrame,10);
   
   objName=nameX;
   if (ObjectFind(0,ObjIdentifier+objName) != 0)
      ObjectCreate(ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   else{
      ObjectDelete(ObjIdentifier+objName);
      ObjectCreate(ObjIdentifier+objName,OBJ_TREND, 0, T0, P0, Time[0], P0 );
   }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY, false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
}

void HLine(string name, string desc, double pPrice, int pStyle, int pWidth){
   DrawShortHLine(name,pPrice,pStyle,LevelColor,pWidth);
   if(PriceLabel){
      CreatePriceLabel(name+" Label",desc,pPrice,LevelColor);
      CreatePriceFlag (name+" Price",pPrice,LevelColor);
   }
}

void DrawFourLine() {



}

void CreatePriceFlag(string name, double price, color col) {
   datetime time = Time[0]+_Period*60;
   
   if (ObjectFind(0,ObjIdentifier+name) != 0){
      ObjectCreate(ObjIdentifier+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(ObjIdentifier+name,0, time, price);

}

void CreatePriceLabel(string name, string desc, double price, color col)  {
   int Bar_Width  ;      
   int Chart_Scale = int(ChartGetInteger(0,CHART_SCALE));
                 
   if(Chart_Scale == 0) Bar_Width = 64;
   else if(Chart_Scale == 1) Bar_Width = 32;      
   else if(Chart_Scale == 2) Bar_Width = 16;
   else if(Chart_Scale == 3) Bar_Width = 9;
   else if(Chart_Scale == 4) Bar_Width = 5;
   else if(Chart_Scale == 5) Bar_Width = 3;
   else Bar_Width = 2;
   
   datetime time = Time[0]+_Period*120*Bar_Width ;

   if (ObjectFind(0,ObjIdentifier+name) != 0){
      ObjectCreate(ObjIdentifier+name,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString (0,ObjIdentifier+name,OBJPROP_TEXT,desc);
      ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,ObjIdentifier+name, OBJPROP_COLOR, col);
   }
   
   else ObjectMove(ObjIdentifier+name,0, time, price);
}

void Camarilla (int Timeframe, double& R4, double& R3, double& R2, double& R1, double& PP, double& S1, double& S2, double& S3, double& S4) {
   double PTF_Open   = iOpen(_Symbol,Timeframe,1);
   double PTF_High   = iHigh(_Symbol,Timeframe,1);
   double PTF_Low    = iLow(_Symbol,Timeframe,1);
   double PTF_Close  = iClose(_Symbol,Timeframe,1);
   double Range      = PTF_High-PTF_Low;
   
   PP = (PTF_High+PTF_Low+PTF_Close)/3;
   
   R4 = NormPrice(PTF_Close+Range*1.5);
   R3 = NormPrice(PTF_Close+Range*1.25);
   R2 = NormPrice(PTF_Close+Range*1.1666);
   R1 = NormPrice(PTF_Close+Range*1.0833);
   S1 = NormPrice(PTF_Close-Range*1.0833);
   S2 = NormPrice(PTF_Close-Range*1.1666);
   S3 = NormPrice(PTF_Close-Range*1.25);
   S4 = NormPrice(PTF_Close-Range*1.5);
}

void Woodies (int Timeframe, double& R4, double& R3, double& R2, double& R1, double& PP, double& S1, double& S2, double& S3, double& S4) {
   double PTF_Open   = iOpen(_Symbol,Timeframe,1);
   double PTF_High   = iHigh(_Symbol,Timeframe,1);
   double PTF_Low    = iLow(_Symbol,Timeframe,1);
   double PTF_Close  = iClose(_Symbol,Timeframe,1);
   double Range      = PTF_High-PTF_Low;
   
   PP = (PTF_High+PTF_Low+PTF_Open+PTF_Open)/4;
   
   R1 = (2 * PP) - PTF_Low;
   S1 = (2 * PP) - PTF_High;
   
   R4 = NormPrice(PP + Range*3);
   R3 = NormPrice(PTF_High+R1);
   R2 = NormPrice(PP + Range);
   
   S2 = NormPrice(PP - Range);
   S3 = NormPrice(PTF_Low-S1);
   S4 = NormPrice(PP - Range*3);
}

void Classic (int Timeframe, double& R4, double& R3, double& R2, double& R1, double& PP, double& S1, double& S2, double& S3, double& S4) {
   double PTF_Open   = iOpen(_Symbol,Timeframe,1);
   double PTF_High   = iHigh(_Symbol,Timeframe,1);
   double PTF_Low    = iLow(_Symbol,Timeframe,1);
   double PTF_Close  = iClose(_Symbol,Timeframe,1);
   double Range      = PTF_High-PTF_Low;
   
   PP = (PTF_High+PTF_Low+PTF_Close)/3;
   
   R4 = NormPrice(PP + Range*3);
   R3 = NormPrice(PP + Range*2);
   R2 = NormPrice(PP + Range);
   R1 = (2 * PP) - PTF_Low;
   S1 = (2 * PP) - PTF_High;
   S2 = NormPrice(PP - Range);
   S3 = NormPrice(PP - Range*2);
   S4 = NormPrice(PP - Range*3);
}

void TomDeMark (int Timeframe, double& R3, double& R2, double& R1, double& PP, double& S1, double& S2, double& S3) {
   double PTF_Open   = iOpen(_Symbol,Timeframe,1);
   double PTF_High   = iHigh(_Symbol,Timeframe,1);
   double PTF_Low    = iLow(_Symbol,Timeframe,1);
   double PTF_Close  = iClose(_Symbol,Timeframe,1);
   double Range      = PTF_High-PTF_Low;
   
   if(PTF_Close>PTF_Open) PP = NormPrice(((2*PTF_High)+PTF_Low+PTF_Close)/4);
   else if (PTF_Close<PTF_Open) PP = NormPrice(((2*PTF_Low)+PTF_High+PTF_Close)/4);
   else if (PTF_Close==PTF_Open) PP = NormPrice(((2*PTF_Close)+PTF_High+PTF_Low)/4);
   
   R1 = NormPrice((2*PP) - PTF_Low);
   R2 = NormPrice(PP + Range);
   R3 = NormPrice(R1 + Range);
   S1 = NormPrice((2*PP) - PTF_High);
   S2 = NormPrice(PP - Range);
   S3 = NormPrice(S1 - Range);
}

void Fibonacci(int Timeframe, double& R3, double& R2, double& R1, double& PP, double& S1, double& S2, double& S3) {
   double PTF_Open   = iOpen(_Symbol,Timeframe,1);
   double PTF_High   = iHigh(_Symbol,Timeframe,1);
   double PTF_Low    = iLow(_Symbol,Timeframe,1);
   double PTF_Close  = iClose(_Symbol,Timeframe,1);
   double Range      = PTF_High-PTF_Low;
   
   PP = (PTF_High+PTF_Low+PTF_Close)/3;

   R3 = NormPrice(PP + Range); 
   R2 = NormPrice(PP + 0.618 *Range);
   R1 = NormPrice(PP + 0.382 *Range);
   
   S1 = NormPrice(PP - 0.382 *Range);
   S2 = NormPrice(PP - 0.618 *Range);
   S3 = NormPrice(PP - Range);

}

double NormPrice(double price){
   double tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   int priceTicks = (int) round( price / tickSize );
   
   return priceTicks * tickSize;
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