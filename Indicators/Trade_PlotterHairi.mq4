
#property strict
#property indicator_chart_window

int   OT    = -1;
int   OT2   = -1;

int init() 
{
   return(0); 
}

int deinit() 
{
   int OBTotal=ObjectsTotal();
   for (int i=OBTotal; i>=0; i--) if(StringSubstr(ObjectName(i),0, 2)=="# ")ObjectDelete(ObjectName(i));
   return(0);    
}
  
int start() 
{
   int cnt, total, total2;
   total=OrdersTotal();
   total2=OrdersHistoryTotal();
   color col, ccol, linecol;
   string PL="";  
   
   if(OT==total && OT2==total2)return(0); //no change in orders to plot
     
   //Plot Orders History 
   for(cnt=0;cnt<=total2;cnt++)
   {
      bool select = OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
      
      if(OrderSymbol()==Symbol() && select)  // check for symbol
      {
         if(OrderType()==OP_BUY)
         { 
            col=clrBlue;
            ccol=clrBlue;
            linecol=clrBlue; 
            PL=DoubleToStr((OrderClosePrice()-OrderOpenPrice())/Point,1)+" pips";
         }

      if(OrderType()==OP_SELL)
         { 
            col=clrRed;
            ccol=clrRed;
            linecol=clrRed; 
            PL=DoubleToStr((OrderOpenPrice()-OrderClosePrice())/Point,1)+" pips";
         }
                
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         {
            ObjectCreate("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
            ObjectSet("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6, col);
            ObjectSet("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
                
            ObjectCreate("# "+OrderTicket()+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),OBJ_ARROW,0,OrderCloseTime(),OrderClosePrice());
            ObjectSet("# "+OrderTicket()+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),6, ccol);
            ObjectSet("# "+OrderTicket()+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),14,3);
              
            ObjectCreate("# "+OrderTicket()+" : "+PL, OBJ_TREND, 0, OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice());
            ObjectSet("# "+OrderTicket()+" : "+PL,6,linecol);
            ObjectSet("# "+OrderTicket()+" : "+PL,7,2);
            ObjectSet("# "+OrderTicket()+" : "+PL,10,false);
         }
      }            
   }
   
   
   //Plot current orders
   for(cnt=0;cnt<=total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol()==Symbol() )   // check for symbol
      {
         if(OrderType()==OP_BUY)   col=clrBlue; 
         if(OrderType()==OP_SELL)  col=clrRed; 
         
         if(OrderType()==OP_BUY ||OrderType()==OP_SELL)
         {
            ObjectCreate("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
            ObjectSet("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6, col);
            ObjectSet("# "+OrderTicket()+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
         }
      }            
   }

    OT   = total;
    OT2  = total2;
    
   return(0);
}

