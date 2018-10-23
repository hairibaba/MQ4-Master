//+------------------------------------------------------------------+
//|                                             TimeToNextCandle.mq4 |
//|                                               Yaroslav Krasovsky |
//|                       https://www.mql5.com/en/users/rock-n-rolla |
//+------------------------------------------------------------------+
#property copyright "Yaroslav Krasovsky"
#property link      "https://www.mql5.com/en/users/rock-n-rolla"
#property version   "1.00"
#property strict
#property indicator_chart_window

input string   LabelFont      = "Arial";
input int      LabelSize      = 15,
               LabelDistance  = 15;
input color    LabelColor     = C'102,184,149';
const string   LabelName      = "TimeToNextCandle";

int OnInit() {
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectDelete(0, LabelName);
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
                const int &spread[]){
   CalcTime();
   return(rates_total);
}

void OnTimer() {
   CalcTime();
}

void CalcTime() {
   if (ObjectFind(LabelName) == -1) {
      ObjectCreate(0, LabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, LabelName, OBJPROP_FONT, LabelFont);
      ObjectSetInteger(0, LabelName, OBJPROP_FONTSIZE, LabelDistance);
      ObjectSetInteger(0, LabelName, OBJPROP_COLOR, LabelColor);
      ObjectSetInteger(0, LabelName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0, LabelName, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, LabelName, OBJPROP_XDISTANCE, LabelDistance);
      ObjectSetInteger(0, LabelName, OBJPROP_YDISTANCE, LabelDistance);
      ObjectSetInteger(0, LabelName, OBJPROP_HIDDEN,true);
      SetIndexLabel(0,NULL);
   }

// calculating remaining time to next candle
   datetime TimeTo = PeriodSeconds() - (TimeCurrent() - Time[0]);

// assembling the output string depending on current period on the chart
   string Out = StringFormat("%.2d", TimeSeconds(TimeTo));
   if(TimeTo >= 3600) {
      Out = StringFormat("%.2d:%s", TimeMinute(TimeTo), Out);
      if (TimeTo >= 86400) Out = StringFormat("%d day(s) %.2d:%s", int(TimeTo / 86400), TimeHour(TimeTo), Out);
      else Out = StringFormat("%d:%s", TimeHour(TimeTo), Out);
   }
   else Out = StringFormat("%d:%s", TimeMinute(TimeTo), Out);
   
   ObjectSetString(0, LabelName, OBJPROP_TEXT, StringFormat("%s (%.0f%s)", Out, 100.0 / PeriodSeconds() * TimeTo, "%"));
}
