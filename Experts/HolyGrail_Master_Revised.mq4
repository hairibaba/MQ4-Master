//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "HolyGrail"
#property strict

#define TIME_ADD_MINUTE    60
#define TIME_ADD_HOUR      3600
#define TIME_ADD_DAY	      86400
#define TIME_ADD_WEEK      604800
#define IDENTIFIER_TRADE   34567
#define RETRY_DELAY        2000
#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

// --- Input Variable ------------------------------------------------------------------
input bool     ActivateEA     = true,
               UseLimitEquity = false;
input double   MaxEquity      = 0;

// --- Global Variable ------------------------------------------------------------------
       bool NotiEnable;
     string Acc_Broker,Acc_Currency,Market_Symbol,
            SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix,SymbolCurrMid;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
            Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel;
            
int         MagicS_1,MagicS_2,MagicS_3,MagicS_4,MagicS_5,MagicS_6,MagicS_7,MagicS_8,MagicS_9,MagicS_10,
            MagicE_1,MagicE_2,MagicE_3,MagicE_4,MagicE_5,
            MagicB_1,MagicB_2,MagicB_3,MagicB_4,MagicB_5;
double      TradeLot_FM,TradeLot_SM,TradeLot_LS,TradeLot_LS2,TradeLot_EX,TradeLot_EX2;

string      ObjIdentifier  = "HGX_";
string      CommentSwing   = "DeadPools ",
            CommentExtreme = " ",
            CommentScalp   = " ";

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){   
   if(!InitFailed()) return INIT_FAILED;
   // Account Inilization
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   ChartSetting();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(); //--- Delete All Drawings
   Print(getUninitReasonText(reason));
}

void OnTick(){
   AllowTrading();
   ChartHistory();
   // Special Assigning Magic Number
   MagicNum(VariableIdentifier(),MagicS_1,MagicS_2,MagicS_3,MagicS_4,MagicS_5,MagicS_6,MagicS_7,MagicS_8,MagicS_9,MagicS_10,
            MagicE_1,MagicE_2,MagicE_3,MagicE_4,MagicE_5,MagicB_1,MagicB_2,MagicB_3,MagicB_4,MagicB_5);
   // Account Inilization
   AccountParameter_Var();
   
   
   SentStatus(23,53,PerformanceClosed_Daily(),PerformanceClosed_Weekly(),PerformanceClosed_Monthly());

   double FullCapacity     = ceil((MarginRequired(Acc_Leverage,Market_Spread+20,Market_MaxLot,4)*1.1)/1000.0)*1000.0;
   double FullCapacity_S   = (ceil((MarginRequired(Acc_Leverage,Market_Spread+20,10,4)*1.1)/1000.0)*1000.0)*10;
   bool AccDouble          = Acc_Equity>Acc_Balance*2;
   
   // Assigning Lot
   AssigningLot(TradeLot_FM,TradeLot_SM,TradeLot_EX,TradeLot_EX2,TradeLot_LS,TradeLot_LS2);
   // Closing on Max Equity
   TriggerMaxEquity();
   // Swing Trade
   GhostOrder();
/*
   GrailSystemSwing("GBPUSD",OP_SELL,9,7,16,0,1.3194);
   GrailSystemSwing("GBPUSD",OP_BUY,10,7,9,20,1.3297);
   GrailSystemSwing("GBPUSD",OP_SELL,11,7,17,5,1.3191);
   GrailSystemSwing("GBPUSD",OP_BUY,12,7,14,5,1.3240);
   GrailSystemSwing("GBPUSD",OP_SELL,12,7,19,2,1.3108);
   GrailSystemSwing("GBPUSD",OP_BUY,13,7,12,23,1.3238);
   GrailSystemSwing("GBPUSD",OP_BUY,16,7,10,45,1.32915);
   GrailSystemSwing("GBPUSD",OP_SELL,16,7,14,10,1.3219);
   GrailSystemSwing("GBPUSD",OP_SELL,17,7,12,9,1.3146);
   GrailSystemSwing("GBPUSD",OP_SELL,17,7,18,42,1.3075);
   GrailSystemSwing("GBPUSD",OP_SELL,17,7,20,48,1.3014);
   GrailSystemSwing("GBPUSD",OP_SELL,19,7,7,55,1.2959);
   GrailSystemSwing("GBPUSD",OP_BUY,19,7,16,1,1.3005);
   GrailSystemSwing("GBPUSD",OP_BUY,19,7,19,51,1.3048);
   GrailSystemSwing("GBPUSD",OP_SELL,19,7,21,6,1.3002);
   GrailSystemSwing("GBPUSD",OP_BUY,20,7,4,46,1.3036);
   GrailSystemSwing("GBPUSD",OP_SELL,20,7,9,6,1.2998);
   GrailSystemSwing("GBPUSD",OP_BUY,20,7,13,17,1.3110);
   GrailSystemSwing("GBPUSD",OP_SELL,23,7,10,50,1.3114);
   GrailSystemSwing("GBPUSD",OP_BUY,23,7,12,37,1.3148);
   GrailSystemSwing("GBPUSD",OP_SELL,23,7,14,6,1.3090);
   GrailSystemSwing("GBPUSD",OP_SELL,24,7,5,3,1.3073);
   GrailSystemSwing("GBPUSD",OP_BUY,24,7,9,59,1.3104);
   GrailSystemSwing("GBPUSD",OP_BUY,24,7,15,56,1.3158);
   GrailSystemSwing("GBPUSD",OP_BUY,25,7,7,8,1.317);
   GrailSystemSwing("GBPUSD",OP_SELL,25,7,16,45,1.3134);
   GrailSystemSwing("GBPUSD",OP_BUY,25,7,19,16,1.32);
   GrailSystemSwing("GBPUSD",OP_SELL,26,7,10,23,1.3182);
   GrailSystemSwing("GBPUSD",OP_SELL,26,7,12,52,1.3172);
   GrailSystemSwing("GBPUSD",OP_SELL,26,7,15,40,1.3124);
   GrailSystemSwing("GBPUSD",OP_BUY,26,7,17,31,1.31525);
   GrailSystemSwing("GBPUSD",OP_SELL,26,7,18,43,1.3113);
   GrailSystemSwing("GBPUSD",OP_SELL,27,7,11,4,1.3083);
   GrailSystemSwing("GBPUSD",OP_BUY,27,7,15,46,1.3119);
   GrailSystemSwing("GBPUSD",OP_BUY,30,7,10,9,1.3137);
   GrailSystemSwing("GBPUSD",OP_SELL,30,7,10,54,1.3108);
   GrailSystemSwing("GBPUSD",OP_BUY,30,7,15,1,1.3151);
   GrailSystemSwing("GBPUSD",OP_SELL,31,7,3,11,1.3113);
   GrailSystemSwing("GBPUSD",OP_SELL,31,7,14,16,1.31215);
   GrailSystemSwing("GBPUSD",OP_SELL,31,7,16,36,1.3094);
   GrailSystemSwing("GBPUSD",OP_BUY,1,8,9,13,1.3126);
   GrailSystemSwing("GBPUSD",OP_BUY,1,8,12,22,1.3137);
   GrailSystemSwing("GBPUSD",OP_BUY,1,8,20,21,1.3138,60);
   GrailSystemSwing("GBPUSD",OP_SELL,2,8,9,7,1.3069,59);
   GrailSystemSwing("GBPUSD",OP_BUY,2,8,13,56,1.3120,15);
   GrailSystemSwing("GBPUSD",OP_SELL,2,8,14,11,1.3090,8);
   GrailSystemSwing("GBPUSD",OP_SELL,2,8,14,38,1.3029,16);
   GrailSystemSwing("GBPUSD",OP_BUY,2,8,15,25,1.30635,91);
   GrailSystemSwing("GBPUSD",OP_SELL,2,8,16,54,1.3027,93);
   GrailSystemSwing("GBPUSD",OP_SELL,2,8,19,15,1.3019,64);
   GrailSystemSwing("GBPUSD",OP_SELL,3,8,8,56,1.2976,126);
   GrailSystemSwing("GBPUSD",OP_BUY,3,8,13,46,1.30415,52);
   GrailSystemSwing("GBPUSD",OP_SELL,3,8,14,38,1.301,40);
   GrailSystemSwing("GBPUSD",OP_BUY,3,8,15,17,1.30375,15);
   GrailSystemSwing("GBPUSD",OP_SELL,3,8,15,32,1.3016,5);
   GrailSystemSwing("GBPUSD",OP_SELL,3,8,15,45,1.3);
   GrailSystemSwing("GBPUSD",OP_SELL,6,8,10,15,1.2955,94);
   GrailSystemSwing("GBPUSD",OP_SELL,6,8,13,0,1.2935,22);
   GrailSystemSwing("GBPUSD",OP_BUY,6,8,16,58,1.295,32);
   GrailSystemSwing("GBPUSD",OP_BUY,7,8,8,53,1.2973,67);
   GrailSystemSwing("GBPUSD",OP_SELL,7,8,16,2,1.2941,86);
   GrailSystemSwing("GBPUSD",OP_SELL,7,8,18,54,1.2926,152);
   GrailSystemSwing("GBPUSD",OP_SELL,8,8,8,20,1.2929,90);
   GrailSystemSwing("GBPUSD",OP_SELL,8,8,10,48,1.2903,62);
   GrailSystemSwing("GBPUSD",OP_SELL,8,8,13,9,1.286,57);
   GrailSystemSwing("GBPUSD",OP_BUY,8,8,17,36,1.28965,37);
   GrailSystemSwing("GBPUSD",OP_BUY,9,8,4,28,1.28895,101);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,9,16,1.2842,80);
   GrailSystemSwing("GBPUSD",OP_BUY,9,8,11,28,1.28825,44);
   GrailSystemSwing("GBPUSD",OP_BUY,9,8,12,37,1.291,50);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,13,26,1.2884,44);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,15,40,1.2870,71);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,17,51,1.2861,23);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,18,42,1.2836,90);
   GrailSystemSwing("GBPUSD",OP_SELL,9,8,21,43,1.2839,28);
   GrailSystemSwing("GBPUSD",OP_SELL,10,8,9,2,1.27745,17);
   GrailSystemSwing("GBPUSD",OP_SELL,10,8,10,19,1.274,24);
   GrailSystemSwing("GBPUSD",OP_BUY,10,8,11,50,1.2781,43);
   GrailSystemSwing("GBPUSD",OP_SELL,10,8,15,54,1.2726,37);
   GrailSystemSwing("GBPUSD",OP_BUY,10,8,16,30,1.2768,58);
   GrailSystemSwing("GBPUSD",OP_BUY,10,8,17,32,1.2781,20);
   GrailSystemSwing("GBPUSD",OP_SELL,10,8,18,22,1.27565,48);
   GrailSystemSwing("GBPUSD",OP_SELL,10,8,19,35,1.2744,22);
   GrailSystemSwing("GBPUSD",OP_SELL,13,8,2,15,1.2749,140);
   GrailSystemSwing("GBPUSD",OP_BUY,13,8,11,12,1.2766,29);
   GrailSystemSwing("GBPUSD",OP_BUY,13,8,14,34,1.2779,25);
   GrailSystemSwing("GBPUSD",OP_SELL,13,8,17,33,1.2743,153);
   GrailSystemSwing("GBPUSD",OP_BUY,14,8,9,7,1.2797,23);
   GrailSystemSwing("GBPUSD",OP_BUY,14,8,9,43,1.2803,24);
   GrailSystemSwing("GBPUSD",OP_SELL,14,8,11,11,1.2789,18);
   GrailSystemSwing("GBPUSD",OP_SELL,14,8,11,36,1.2767,28);
   GrailSystemSwing("GBPUSD",OP_SELL,14,8,18,12,1.2705,114);
   GrailSystemSwing("GBPUSD",OP_SELL,15,8,10,42,1.2708,29);
   GrailSystemSwing("GBPUSD",OP_SELL,15,8,15,53,1.2668,57);
   GrailSystemSwing("GBPUSD",OP_BUY,15,8,17,2,1.2689,25);
   GrailSystemSwing("GBPUSD",OP_SELL,15,8,17,40,1.2666,17);
   GrailSystemSwing("GBPUSD",OP_BUY,15,8,17,58,1.2706,13);
   GrailSystemSwing("GBPUSD",OP_BUY,15,8,18,59,1.2709,45);
   GrailSystemSwing("GBPUSD",OP_SELL,16,8,9,40,1.2704,35);
   GrailSystemSwing("GBPUSD",OP_BUY,16,8,11,23,1.2731,16);
   GrailSystemSwing("GBPUSD",OP_SELL,16,8,11,40,1.2698,70);
   GrailSystemSwing("GBPUSD",OP_BUY,16,8,15,30,1.272,15);
   GrailSystemSwing("GBPUSD",OP_BUY,16,8,16,14,1.2752,40);
   GrailSystemSwing("GBPUSD",OP_BUY,17,8,9,6,1.2747,44);
   GrailSystemSwing("GBPUSD",OP_SELL,17,8,9,49,1.271,41);
   GrailSystemSwing("GBPUSD",OP_BUY,17,8,11,4,1.2731,8);
   GrailSystemSwing("GBPUSD",OP_BUY,20,8,13,51,1.2765,23);
   GrailSystemSwing("GBPUSD",OP_SELL,20,8,17,41,1.2759,20);
   GrailSystemSwing("GBPUSD",OP_BUY,20,8,18,34,1.2778,55);
   GrailSystemSwing("GBPUSD",OP_BUY,20,8,19,2,1.2786,52);
   GrailSystemSwing("GBPUSD",OP_BUY,21,8,2,27,1.2827,109);
   GrailSystemSwing("GBPUSD",OP_BUY,21,8,15,18,1.2876,146);
   GrailSystemSwing("GBPUSD",OP_SELL,21,8,17,43,1.2849,41);
   GrailSystemSwing("GBPUSD",OP_BUY,21,8,19,15,1.2923,127);
   GrailSystemSwing("GBPUSD",OP_SELL,22,8,9,6,1.2869,147);
   GrailSystemSwing("GBPUSD",OP_BUY,22,8,11,32,1.2896,87);
   GrailSystemSwing("GBPUSD",OP_BUY,22,8,13,49,1.291,36);
   GrailSystemSwing("GBPUSD",OP_SELL,22,8,16,13,1.2918,77);
   GrailSystemSwing("GBPUSD",OP_SELL,22,8,21,7,1.2908,43);
   GrailSystemSwing("GBPUSD",OP_SELL,23,8,2,20,1.2858,286);
   GrailSystemSwing("GBPUSD",OP_BUY,23,8,7,6,1.2873,67);
   GrailSystemSwing("GBPUSD",OP_BUY,23,8,9,4,1.2884,29);
   GrailSystemSwing("GBPUSD",OP_BUY,23,8,11,35,1.2877,22);
   GrailSystemSwing("GBPUSD",OP_BUY,23,8,12,50,1.2908,71);
   GrailSystemSwing("GBPUSD",OP_SELL,23,8,14,53,1.2871,41);
   GrailSystemSwing("GBPUSD",OP_SELL,23,8,15,44,1.2855,28);
   GrailSystemSwing("GBPUSD",OP_SELL,23,8,16,54,1.2818,55);
   GrailSystemSwing("GBPUSD",OP_SELL,24,8,12,0,1.2809,29);
   GrailSystemSwing("GBPUSD",OP_BUY,24,8,12,31,1.2856,77);
   GrailSystemSwing("GBPUSD",OP_BUY,24,8,16,58,1.288,9);
   GrailSystemSwing("GBPUSD",OP_SELL,24,8,17,21,1.2842,21);
   GrailSystemSwing("GBPUSD",OP_SELL,27,8,9,4,1.2831,62);
   GrailSystemSwing("GBPUSD",OP_BUY,27,8,14,54,1.2879,27);
   GrailSystemSwing("GBPUSD",OP_BUY,27,8,15,54,1.2879,100);
   GrailSystemSwing("GBPUSD",OP_SELL,27,8,16,49,1.2872,17);
   GrailSystemSwing("GBPUSD",OP_SELL,28,8,3,48,1.2877,48);
   GrailSystemSwing("GBPUSD",OP_BUY,28,8,9,41,1.2902,49);
   GrailSystemSwing("GBPUSD",OP_BUY,28,8,14,27,1.2919,35);
   GrailSystemSwing("GBPUSD",OP_SELL,28,8,17,1,1.2882,29); 
   GrailSystemSwing("GBPUSD",OP_SELL,28,8,20,51,1.2869,42);
   GrailSystemSwing("GBPUSD",OP_BUY,29,8,10,0,1.2881,21);
   GrailSystemSwing("GBPUSD",OP_SELL,29,8,15,27,1.2869,38);
   GrailSystemSwing("GBPUSD",OP_BUY,29,8,16,52,1.2982,10);
   GrailSystemSwing("GBPUSD",OP_BUY,29,8,17,10,1.2998,20);
   GrailSystemSwing("GBPUSD",OP_SELL,29,8,19,21,1.2975,4);
   GrailSystemSwing("GBPUSD",OP_SELL,30,8,8,20,1.3015,9);
   GrailSystemSwing("GBPUSD",OP_SELL,30,8,9,26,1.3018,11);
   GrailSystemSwing("GBPUSD",OP_SELL,30,8,10,22,1.2991,80);
   GrailSystemSwing("GBPUSD",OP_SELL,30,8,15,56,1.2986,40);
   GrailSystemSwing("GBPUSD",OP_SELL,30,8,18,20,1.299,25);
   GrailSystemSwing("GBPUSD",OP_BUY,31,8,7,46,1.3024,22);
   GrailSystemSwing("GBPUSD",OP_SELL,31,8,10,16,1.2995,8);
   GrailSystemSwing("GBPUSD",OP_SELL,31,8,13,57,1.2969,40);
   GrailSystemSwing("GBPUSD",OP_SELL,31,8,15,35,1.2961,38);
   GrailSystemSwing("GBPUSD",OP_BUY,31,8,17,10,1.2998,34);
   GrailSystemSwing("GBPUSD",OP_SELL,31,8,17,58,1.2948,74);

   GrailSystemSwing("GBPUSD",OP_SELL,3,9,9,14,1.2905,17);
   GrailSystemSwing("GBPUSD",OP_SELL,3,9,11,4,1.2887,28);
   GrailSystemSwing("GBPUSD",OP_SELL,3,9,13,55,1.2868,39);
   GrailSystemSwing("GBPUSD",OP_BUY,3,9,17,26,1.2884,11);
   GrailSystemSwing("GBPUSD",OP_SELL,3,9,18,45,1.2876,16);
   GrailSystemSwing("GBPUSD",OP_SELL,3,9,19,58,1.2873,29);
   GrailSystemSwing("GBPUSD",OP_SELL,4,9,16,40,1.282,33);
   GrailSystemSwing("GBPUSD",OP_BUY,4,9,17,45,1.2835,14);
   GrailSystemSwing("GBPUSD",OP_BUY,4,9,19,39,1.2866,10);
   GrailSystemSwing("GBPUSD",OP_SELL,5,9,8,56,1.2819,88);
   GrailSystemSwing("GBPUSD",OP_SELL,5,9,10,58,1.2804,17);
   GrailSystemSwing("GBPUSD",OP_SELL,5,9,12,48,1.279,12);
   GrailSystemSwing("GBPUSD",OP_BUY,5,9,13,6,1.2826,51);
   GrailSystemSwing("GBPUSD",OP_BUY,5,9,15,58,1.2982,20);
   GrailSystemSwing("GBPUSD",OP_SELL,5,9,18,20,1.2874,10);
   GrailSystemSwing("GBPUSD",OP_BUY,5,9,18,48,1.2906,10);
   GrailSystemSwing("GBPUSD",OP_BUY,5,9,19,12,1.2914,10);
   GrailSystemSwing("GBPUSD",OP_BUY,6,9,10,58,1.2945,48);
   GrailSystemSwing("GBPUSD",OP_BUY,6,9,12,49,1.2942,47);
   GrailSystemSwing("GBPUSD",OP_SELL,6,9,17,4,1.2922,16);
   GrailSystemSwing("GBPUSD",OP_BUY,6,9,17,48,1.2959,8);
   GrailSystemSwing("GBPUSD",OP_SELL,6,9,17,58,1.2922,26);
   GrailSystemSwing("GBPUSD",OP_BUY,7,9,9,4,1.2946,35);
   GrailSystemSwing("GBPUSD",OP_BUY,7,9,12,46,1.2975,18);
   GrailSystemSwing("GBPUSD",OP_BUY,7,9,13,35,1.3028,18);
   GrailSystemSwing("GBPUSD",OP_BUY,7,9,14,59,1.3015,19);
   GrailSystemSwing("GBPUSD",OP_SELL,7,9,15,42,1.295,23);
   GrailSystemSwing("GBPUSD",OP_SELL,7,9,17,55,1.2945,12);
   GrailSystemSwing("GBPUSD",OP_BUY,10,9,9,53,1.2942,60);
   GrailSystemSwing("GBPUSD",OP_BUY,10,9,15,45,1.305,27);
   GrailSystemSwing("GBPUSD",OP_SELL,10,9,16,26,1.3008,12);
   GrailSystemSwing("GBPUSD",OP_BUY,10,9,17,2,1.3035,18);
   GrailSystemSwing("GBPUSD",OP_SELL,10,9,17,24,1.3012,27);
   GrailSystemSwing("GBPUSD",OP_BUY,11,9,2,57,1.3036,47);
   GrailSystemSwing("GBPUSD",OP_BUY,11,9,10,6,1.3084,13);
   GrailSystemSwing("GBPUSD",OP_SELL,11,9,11,43,1.2991,202);
   GrailSystemSwing("GBPUSD",OP_SELL,11,9,14,48,1.2983,17);
   GrailSystemSwing("GBPUSD",OP_BUY,11,9,15,11,1.3022,7);
   GrailSystemSwing("GBPUSD",OP_SELL,11,9,15,17,1.2975,30);
   GrailSystemSwing("GBPUSD",OP_BUY,12,9,10,34,1.3037,47);
   GrailSystemSwing("GBPUSD",OP_SELL,12,9,13,39,1.2981,32);
   GrailSystemSwing("GBPUSD",OP_BUY,12,9,18,9,1.3041,17);
   GrailSystemSwing("GBPUSD",OP_BUY,12,9,19,48,1.3081,31); // edit time range
   GrailSystemSwing("GBPUSD",OP_SELL,16,10,16,15,1.3162,1005);
   GrailSystemSwing("GBPUSD",OP_SELL,17,10,10,0,1.3103,345);
   GrailSystemSwing("GBPUSD",OP_SELL,18,10,14,0,1.3017,615);
   GrailSystemSwing("GBPUSD",OP_SELL,22,10,9,45,1.296,83*15);
   GrailSystemSwing("GBPUSD",OP_SELL,24,10,6,30,1.287,55*15);
   GrailSystemSwing("GBPUSD",OP_SELL,25,10,16,0,1.2815,12*15);
*/
   GrailSystemSwing("GBPUSD",OP_BUY,10,12,2,5,1.2755,5*27);
   GrailSystemSwing("GBPUSD",OP_SELL,10,12,11,35,1.2695,5*17);
   GrailSystemSwing("GBPUSD",OP_SELL,10,12,13,35,1.261,5*34);
   GrailSystemSwing("GBPUSD",OP_SELL,10,12,17,20,1.251,5*10);
   
   GrailSystemSwing("GBPUSD",OP_BUY,11,12,9,10,1.2635,5*37);
   GrailSystemSwing("GBPUSD",OP_SELL,11,12,15,55,1.2501,5*87);
   
   GrailSystemSwing("GBPUSD",OP_SELL,11,12,21,45,1.2483,5*20);
   GrailSystemSwing("GBPUSD",OP_BUY,12,12,10,15,1.2667,5*93);
   GrailSystemSwing("GBPUSD",OP_BUY,13,12,9,15,1.2685,5*20);
   
   GrailSystemSwing("GBPUSD",OP_SELL,13,12,15,30,1.2616,5*30);
   GrailSystemSwing("GBPUSD",OP_BUY,13,12,19,30,1.267,5*36);
   
   GrailSystemSwing("GBPUSD",OP_SELL,14,12,8,5,1.2607,5*10);
   GrailSystemSwing("GBPUSD",OP_SELL,14,12,10,0,1.2571,5*12);
   GrailSystemSwing("GBPUSD",OP_SELL,14,12,12,25,1.2538,5*44);
   GrailSystemSwing("GBPUSD",OP_BUY,14,12,17,25,1.2587,5*66);
   
   GrailSystemSwing("GBPUSD",OP_BUY,17,12,9,50,1.264,5*51);
   GrailSystemSwing("GBPUSD",OP_BUY,17,12,18,55,1.2631,5*34);
   GrailSystemSwing("GBPUSD",OP_BUY,18,12,9,30,1.2662,5*11);
   GrailSystemSwing("GBPUSD",OP_BUY,18,12,12,20,1.2704,5*21);
   
   GrailSystemSwing("GBPUSD",OP_SELL,18,12,14,5,1.2637,5*74);
   
   GrailSystemSwing("GBPUSD",OP_SELL,19,12,11,50,1.2616,5*45);
   GrailSystemSwing("GBPUSD",OP_BUY,19,12,15,35,1.2671,5*22);
   GrailSystemSwing("GBPUSD",OP_SELL,19,12,19,20,1.2607,5*58);
   
   GrailSystemSwing("GBPUSD",OP_BUY,20,12,6,5,1.2668,5*40);
   GrailSystemSwing("GBPUSD",OP_BUY,20,12,10,5,1.2705,5*44);
   
   GrailSystemSwing("GBPUSD",OP_SELL,20,12,13,55,1.2669,5*15);
   GrailSystemSwing("GBPUSD",OP_SELL,20,12,15,50,1.2629,5*22);
   
   
   GrailSystemSwing("GBPUSD",OP_BUY,20,12,17,55,1.2692,5*39);
   
   GrailSystemSwing("GBPUSD",OP_BUY,21,12,8,0,1.2696,5*28);
   
   GrailSystemSwing("GBPUSD",OP_SELL,20,12,21,25,1.266,5*30);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,2,10,1.2646,5*60);
   
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,10,50,1.2647,5*20);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,11,55,1.2648,5*5);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,14,20,1.2647,5*15);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,16,5,1.2636,5*7);
   
   GrailSystemSwing("GBPUSD",OP_BUY,21,12,16,40,1.2693,5*18);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,18,55,1.262,5*44);
   GrailSystemSwing("GBPUSD",OP_SELL,21,12,21,35,1.2619,5*14);

   // Extreme Trade
/*
   GrailSystemExtreme("GBPUSD",OP_SELL,11,7,19,15,1.32);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,7,20,45,1.3170);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,7,2,10,1.3189);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,7,5,25,1.3108);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,7,15,50,1.3238);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,7,9,50,1.3228);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,7,16,18,1.3272);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,7,17,37,1.3223);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,7,19,15,1.32175);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,7,19,35,1.3244);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,7,4,40,1.325);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,7,9,12,1.3259);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,7,10,1,1.3237);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,7,10,44,1.3233);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,7,11,24,1.3262);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,7,11,38,1.3268);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,7,13,55,1.3197);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,7,14,47,1.3146);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,7,16,8,1.3179);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,7,19,17,1.3075);
   GrailSystemExtreme("GBPUSD",OP_SELL,18,7,4,45,1.308);
   GrailSystemExtreme("GBPUSD",OP_SELL,18,7,11,22,1.3014);
   GrailSystemExtreme("GBPUSD",OP_BUY,18,7,15,4,1.3066);
   GrailSystemExtreme("GBPUSD",OP_BUY,18,7,18,10,1.3043);
   GrailSystemExtreme("GBPUSD",OP_BUY,18,7,18,54,1.3072);
   GrailSystemExtreme("GBPUSD",OP_BUY,18,7,22,45,1.3081);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,9,15,1.3019);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,11,27,1.2987);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,11,33,1.3013);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,12,29,1.2992);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,13,30,1.2975);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,14,37,1.2959);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,16,28,1.2990);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,17,0,1.3005);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,18,0,1.2982);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,20,13,1.3048);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,20,49,1.3016);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,20,52,1.3040);
   GrailSystemExtreme("GBPUSD",OP_SELL,19,7,21,27,1.3002);
   GrailSystemExtreme("GBPUSD",OP_BUY,19,7,23,2,1.3019);
   GrailSystemExtreme("GBPUSD",OP_SELL,20,7,4,10,1.2996);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,5,19,1.3026);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,7,33,1.3036);
   GrailSystemExtreme("GBPUSD",OP_SELL,20,7,10,2,1.2998);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,13,52,1.3059);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,15,42,1.3089);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,16,11,1.3110);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,16,54,1.3116);
   GrailSystemExtreme("GBPUSD",OP_BUY,20,7,19,37,1.3139);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,7,4,14,1.3155);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,4,46,1.3139);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,7,10,3,1.3157);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,11,39,1.3114);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,16,29,1.3104);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,18,4,1.3099);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,18,51,1.3095);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,7,20,37,1.3090);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,7,7,36,1.3085);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,7,8,56,1.3073);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,7,10,22,1.3128);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,7,10,36,1.3104);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,7,11,13,1.31);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,7,12,44,1.3132);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,7,13,32,1.3137);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,7,14,58,1.3112);
   GrailSystemExtreme("GBPUSD",OP_SELL,25,7,4,31,1.3138);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,9,25,1.317);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,9,50,1.3173);
   GrailSystemExtreme("GBPUSD",OP_SELL,25,7,10,1,1.3159);
   GrailSystemExtreme("GBPUSD",OP_SELL,25,7,10,29,1.3141);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,15,25,1.3177);
   GrailSystemExtreme("GBPUSD",OP_SELL,25,7,17,1,1.3134);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,17,21,1.3153);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,20,58,1.32);
   GrailSystemExtreme("GBPUSD",OP_BUY,25,7,23,27,1.3197);
   GrailSystemExtreme("GBPUSD",OP_BUY,26,7,1,3,1.3212);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,4,25,1.3198);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,9,24,1.3192);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,11,9,1.3177);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,11,47,1.3175);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,15,53,1.3153);
   GrailSystemExtreme("GBPUSD",OP_BUY,26,7,16,7,1.3167);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,16,20,1.3137);
   GrailSystemExtreme("GBPUSD",OP_BUY,26,7,16,31,1.3155);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,16,37,1.3140);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,17,7,1.3124);
   GrailSystemExtreme("GBPUSD",OP_BUY,26,7,17,52,1.31525);
   GrailSystemExtreme("GBPUSD",OP_BUY,26,7,19,2,1.3132);
   GrailSystemExtreme("GBPUSD",OP_SELL,26,7,20,58,1.3106);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,8,48,1.3091);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,9,25,1.3105);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,10,1,1.3122);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,10,30,1.3106);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,11,24,1.3088);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,12,27,1.3083);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,13,6,1.31);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,14,33,1.3085);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,15,58,1.3119);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,16,8,1.3105);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,17,2,1.3126);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,17,9,1.3109);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,17,43,1.313);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,18,0,1.3114);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,18,53,1.3107);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,7,20,23,1.31165);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,7,21,47,1.3101);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,7,3,36,1.3098);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,7,8,7,1.3116);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,7,13,21,1.3108);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,7,16,45,1.3151);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,7,17,56,1.3139);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,7,18,23,1.3132);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,7,19,23,1.3146);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,7,20,56,1.31275);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,3,48,1.31195);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,4,59,1.3113);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,5,20,1.3123);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,7,9,1.3146);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,10,47,1.316);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,11,58,1.3142);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,12,5,1.3163);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,12,51,1.3172);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,15,29,1.31615);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,15,43,1.3122);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,16,16,1.3142);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,16,28,1.3126);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,17,33,1.3094);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,17,53,1.312);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,7,18,16,1.313);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,7,23,34,1.3096);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,9,40,1.3126);
   GrailSystemExtreme("GBPUSD",OP_SELL,1,8,10,27,1.3109);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,13,36,1.3137);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,15,23,1.31435);
   GrailSystemExtreme("GBPUSD",OP_SELL,1,8,16,5,1.3122);
   GrailSystemExtreme("GBPUSD",OP_SELL,1,8,16,31,1.31145);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,17,17,1.31345,33);
   GrailSystemExtreme("GBPUSD",OP_SELL,1,8,17,49,1.3105,152);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,21,2,1.3131);
   GrailSystemExtreme("GBPUSD",OP_BUY,1,8,21,5,1.3138,14);
   GrailSystemExtreme("GBPUSD",OP_SELL,2,8,4,51,1.31);
   GrailSystemExtreme("GBPUSD",OP_SELL,2,8,9,40,1.3069,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,2,8,15,0,1.3016,25);
   GrailSystemExtreme("GBPUSD",OP_BUY,2,8,15,52,1.30635,64);
   GrailSystemExtreme("GBPUSD",OP_SELL,2,8,17,46,1.3027,43);
   GrailSystemExtreme("GBPUSD",OP_BUY,2,8,18,27,1.3043,45);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,8,10,30,1.2976,32);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,8,16,17,1.2995,24);
   GrailSystemExtreme("GBPUSD",OP_BUY,3,8,17,27,1.3024,24);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,8,20,18,1.3,215);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,11,59,1.2955,15);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,8,12,13,1.2968,29);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,13,39,1.2933,21);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,14,9,1.2924,39);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,15,6,1.2920,24);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,8,15,28,1.2942,55);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,16,24,1.2926,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,17,29,1.2936,54);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,8,18,23,1.2951,8);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,8,18,30,1.2937,50);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,8,6,53,1.2947,52);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,8,9,42,1.2973,18);
   GrailSystemExtreme("GBPUSD",OP_SELL,7,8,15,14,1.295,7);
   GrailSystemExtreme("GBPUSD",OP_BUY,8,8,5,46,1.2959,90);
   GrailSystemExtreme("GBPUSD",OP_BUY,8,8,9,48,1.2946,28);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,10,16,1.2930,20);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,11,7,1.2903,43);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,12,27,1.2894,7);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,13,36,1.286,30);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,14,38,1.2855,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,8,8,15,49,1.2877,75);
   GrailSystemExtreme("GBPUSD",OP_SELL,8,8,18,12,1.28735,80);
   GrailSystemExtreme("GBPUSD",OP_BUY,8,8,19,31,1.2894,150);
   GrailSystemExtreme("GBPUSD",OP_SELL,9,8,4,18,1.2854,11);
   GrailSystemExtreme("GBPUSD",OP_BUY,9,8,5,43,1.28895,27);
   GrailSystemExtreme("GBPUSD",OP_SELL,9,8,6,11,1.287,113);
   GrailSystemExtreme("GBPUSD",OP_BUY,9,8,8,2,1.2886,76);
   GrailSystemExtreme("GBPUSD",OP_SELL,9,8,10,25,1.2842,11);
   GrailSystemExtreme("GBPUSD",OP_BUY,9,8,15,11,1.2906,31);
   GrailSystemExtreme("GBPUSD",OP_BUY,9,8,16,51,1.28885,18);
   GrailSystemExtreme("GBPUSD",OP_SELL,9,8,19,58,1.2836,15);
   GrailSystemExtreme("GBPUSD",OP_BUY,9,8,20,13,1.28555,51);
   GrailSystemExtreme("GBPUSD",OP_SELL,9,8,22,36,1.2822,75);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,8,7,34,1.2799,70);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,8,9,19,1.2795,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,8,10,43,1.2768,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,8,12,55,1.2767,18);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,8,13,35,1.27645,65);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,8,14,59,1.2759,10);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,8,15,24,1.2752,12);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,8,18,13,1.2791,10);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,8,20,30,1.2758,18);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,8,21,38,1.2775,47);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,8,1,5,1.2778,72);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,8,7,58,1.2769,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,8,23,1.275,21);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,9,42,1.2741,58);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,10,16,1.2734,25);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,11,41,1.2743,40);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,8,16,18,1.279,80);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,18,29,1.2743,96);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,8,20,4,1.2763,80);
   GrailSystemExtreme("GBPUSD",OP_SELL,13,8,21,24,1.2748,55);
   GrailSystemExtreme("GBPUSD",OP_BUY,13,8,22,20,1.2765,70);
   GrailSystemExtreme("GBPUSD",OP_BUY,14,8,8,47,1.2775,13);
   GrailSystemExtreme("GBPUSD",OP_BUY,14,8,10,51,1.2817,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,14,8,12,3,1.2788,52);
   GrailSystemExtreme("GBPUSD",OP_BUY,14,8,13,20,1.279,15);
   GrailSystemExtreme("GBPUSD",OP_SELL,14,8,13,34,1.2765,76);
   GrailSystemExtreme("GBPUSD",OP_SELL,14,8,17,50,1.2747,8);
   GrailSystemExtreme("GBPUSD",OP_SELL,14,8,19,3,1.2705,65);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,5,41,1.2693,120);
   GrailSystemExtreme("GBPUSD",OP_BUY,15,8,8,19,1.2734,145);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,11,27,1.2698,14);
   GrailSystemExtreme("GBPUSD",OP_BUY,15,8,12,15,1.2726,39);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,13,17,1.2696,34);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,14,4,1.2694,45);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,16,29,1.2668,23);
   GrailSystemExtreme("GBPUSD",OP_SELL,15,8,20,21,1.2685,49);
   GrailSystemExtreme("GBPUSD",OP_BUY,15,8,21,54,1.2704,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,8,4,34,1.2722,55);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,8,12,39,1.2698,14);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,8,13,14,1.269,23);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,8,14,2,1.271,39);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,8,16,45,1.2752,9);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,8,16,53,1.272,55);
   GrailSystemExtreme("GBPUSD",OP_SELL,16,8,18,16,1.2695,159);
   GrailSystemExtreme("GBPUSD",OP_BUY,16,8,20,54,1.2715,126);
   GrailSystemExtreme("GBPUSD",OP_SELL,17,8,11,35,1.2705,50);
   GrailSystemExtreme("GBPUSD",OP_BUY,17,8,20,25,1.275,151);
   GrailSystemExtreme("GBPUSD",OP_SELL,20,8,3,40,1.2739,80);
   GrailSystemExtreme("GBPUSD",OP_SELL,20,8,8,58,1.2731,27);
   GrailSystemExtreme("GBPUSD",OP_BUY,21,8,5,43,1.2841,223);
   GrailSystemExtreme("GBPUSD",OP_SELL,21,8,9,26,1.2813,195);
   GrailSystemExtreme("GBPUSD",OP_BUY,21,8,12,55,1.2843,96);
   GrailSystemExtreme("GBPUSD",OP_SELL,21,8,14,31,1.2813,50);
   GrailSystemExtreme("GBPUSD",OP_BUY,21,8,16,47,1.2876,53);
   GrailSystemExtreme("GBPUSD",OP_BUY,21,8,18,23,1.2873,27);
   GrailSystemExtreme("GBPUSD",OP_SELL,21,8,21,21,1.29,61);
   GrailSystemExtreme("GBPUSD",OP_SELL,22,8,10,35,1.2869,58);
   GrailSystemExtreme("GBPUSD",OP_SELL,22,8,12,59,1.2879,17);
   GrailSystemExtreme("GBPUSD",OP_BUY,22,8,14,42,1.2915,16);
   GrailSystemExtreme("GBPUSD",OP_BUY,22,8,15,27,1.2927,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,22,8,15,54,1.2935,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,22,8,21,0,1.2932,7);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,4,24,1.2865,129);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,6,57,1.2858,9);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,8,8,32,1.2876,16);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,10,38,1.2854,58);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,11,55,1.2851,46);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,8,13,43,1.2907,17);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,14,0,1.289,44);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,8,16,37,1.2874,18);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,8,17,47,1.2835,48);
   GrailSystemExtreme("GBPUSD",OP_SELL,23,8,19,5,1.2814,32);
   GrailSystemExtreme("GBPUSD",OP_BUY,23,8,22,45,1.2817,12);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,7,36,1.2825,46);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,8,29,1.283,22);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,9,53,1.2838,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,13,6,1.2856,42);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,17,42,1.2863,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,8,18,24,1.2848,24);
   GrailSystemExtreme("GBPUSD",OP_BUY,24,8,18,49,1.2865,24);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,8,19,30,1.2851,30);
   GrailSystemExtreme("GBPUSD",OP_SELL,24,8,20,31,1.2841,34);
   GrailSystemExtreme("GBPUSD",OP_SELL,27,8,6,36,1.2848,122);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,8,13,24,1.2857,66);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,8,16,13,1.2888,37);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,8,17,5,1.2889,58);
   GrailSystemExtreme("GBPUSD",OP_BUY,27,8,19,9,1.29,31);
   GrailSystemExtreme("GBPUSD",OP_SELL,28,8,7,59,1.2862,25);
   GrailSystemExtreme("GBPUSD",OP_BUY,28,8,15,31,1.293,49);
   GrailSystemExtreme("GBPUSD",OP_SELL,28,8,16,23,1.2914,29);
   GrailSystemExtreme("GBPUSD",OP_BUY,28,8,16,50,1.2924,9);
   GrailSystemExtreme("GBPUSD",OP_BUY,28,8,17,56,1.2887,13);
   GrailSystemExtreme("GBPUSD",OP_BUY,28,8,18,34,1.2887,13);
   GrailSystemExtreme("GBPUSD",OP_SELL,28,8,19,19,1.2881,18);
   GrailSystemExtreme("GBPUSD",OP_SELL,29,8,8,6,1.2847,94);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,9,42,1.2857,19);
   GrailSystemExtreme("GBPUSD",OP_SELL,29,8,10,21,1.2869,12);
   GrailSystemExtreme("GBPUSD",OP_SELL,29,8,10,43,1.2866,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,11,41,1.2886,14);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,12,11,1.2887,10);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,13,9,1.2898,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,14,3,1.2895,15);
   GrailSystemExtreme("GBPUSD",OP_SELL,29,8,14,42,1.2878,22);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,16,7,1.2883,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,16,58,1.2982,3);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,17,22,1.2998,6);
   GrailSystemExtreme("GBPUSD",OP_SELL,29,8,17,29,1.2978,11);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,17,40,1.3006,5);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,18,20,1.301,8);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,19,25,1.3004,39);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,19,50,1.301,17);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,20,38,1.3014,25);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,21,24,1.3026,48);
   GrailSystemExtreme("GBPUSD",OP_BUY,29,8,22,46,1.3032,29);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,8,8,44,1.3017,13);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,8,58,1.3038,27);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,9,36,1.3042,36);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,8,11,14,1.2991,27);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,12,15,1.3018,23);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,13,27,1.3026,14);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,14,42,1.3029,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,8,16,12,1.2987,25);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,16,35,1.3008,15);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,17,23,1.3024,15);
   GrailSystemExtreme("GBPUSD",OP_SELL,30,8,17,43,1.3,22);
   GrailSystemExtreme("GBPUSD",OP_BUY,30,8,19,15,1.301,26);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,8,3,32,1.3023,74);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,8,4,48,1.3006,75);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,8,10,24,1.3028,39);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,8,15,20,1.2996,16);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,8,18,38,1.2948,35);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,8,19,40,1.2962,9);
   GrailSystemExtreme("GBPUSD",OP_BUY,31,8,20,3,1.2967,24);
   GrailSystemExtreme("GBPUSD",OP_SELL,31,8,21,55,1.2956,6);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,9,11,44,1.2877,49);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,9,12,52,1.2866,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,3,9,13,13,1.289,41);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,9,14,42,1.286,51);
   GrailSystemExtreme("GBPUSD",OP_BUY,3,9,16,10,1.2875,20);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,9,17,3,1.2868,23);
   GrailSystemExtreme("GBPUSD",OP_BUY,3,9,18,25,1.2888,9);
   GrailSystemExtreme("GBPUSD",OP_SELL,3,9,17,3,1.2868,23);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,2,23,1.2854,120);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,8,30,1.2842,73);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,10,25,1.2825,53);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,12,4,1.2815,20);
   GrailSystemExtreme("GBPUSD",OP_BUY,4,9,14,34,1.2839,16);
   GrailSystemExtreme("GBPUSD",OP_BUY,4,9,15,40,1.2852,11);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,17,25,1.2811,19);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,18,12,1.2814,21);
   GrailSystemExtreme("GBPUSD",OP_BUY,4,9,19,42,1.2866,8);
   GrailSystemExtreme("GBPUSD",OP_BUY,4,9,19,59,1.287,4);
   GrailSystemExtreme("GBPUSD",OP_SELL,4,9,21,18,1.2846,74);
   GrailSystemExtreme("GBPUSD",OP_BUY,4,9,22,54,1.2859,10);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,5,59,1.2854,136);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,4,12,1.2869,22);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,9,50,1.2819,35);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,10,45,1.2818,11);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,11,29,1.2824,16);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,12,18,1.2827,4);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,12,28,1.2831,5);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,14,35,1.2828,20);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,15,38,1.2836,17);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,16,15,1.2982,8);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,17,1,1.2954,3);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,17,34,1.2957,6);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,17,58,1.2937,6);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,18,41,1.2889,6);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,19,39,1.2898,19);
   GrailSystemExtreme("GBPUSD",OP_BUY,5,9,19,58,1.2912,22);
   GrailSystemExtreme("GBPUSD",OP_SELL,5,9,20,20,1.2895,39);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,9,5,50,1.2908,68);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,9,9,2,1.2914,32);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,9,9,53,1.2928,33);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,9,11,46,1.2927,38);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,9,12,3,1.2919,48);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,9,14,11,1.2959,73);
   GrailSystemExtreme("GBPUSD",OP_SELL,6,9,16,4,1.2933,26);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,9,18,23,1.2938,11);
   GrailSystemExtreme("GBPUSD",OP_BUY,6,9,19,1,1.2945,17);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,10,15,1.2946,46);
   GrailSystemExtreme("GBPUSD",OP_SELL,7,9,12,17,1.2928,30);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,12,51,1.2975,13);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,13,50,1.3028,5);
   GrailSystemExtreme("GBPUSD",OP_SELL,7,9,14,18,1.2983,31);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,16,56,1.2971,13);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,17,25,1.2988,14);
   GrailSystemExtreme("GBPUSD",OP_SELL,7,9,18,12,1.2929,31);
   GrailSystemExtreme("GBPUSD",OP_SELL,7,9,20,5,1.291,41);
   GrailSystemExtreme("GBPUSD",OP_BUY,7,9,20,46,1.2923,27);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,9,4,8,1.2909,174);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,9,9,35,1.29,16);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,9,12,28,1.2925,80);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,9,14,45,1.295,31);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,9,15,56,1.305,14);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,9,16,14,1.303,9);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,9,18,47,1.3029,6);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,9,19,3,1.3031,63);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,9,20,20,1.3037,26);
   GrailSystemExtreme("GBPUSD",OP_SELL,10,9,21,10,1.3024,86);
   GrailSystemExtreme("GBPUSD",OP_SELL,11,9,13,55,1.3009,8);
   GrailSystemExtreme("GBPUSD",OP_BUY,11,9,16,38,1.3014,40);
   GrailSystemExtreme("GBPUSD",OP_BUY,11,9,18,11,1.3014,51);
   GrailSystemExtreme("GBPUSD",OP_BUY,11,9,20,2,1.3018,36);
   GrailSystemExtreme("GBPUSD",OP_BUY,11,9,22,48,1.3034,31);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,9,2,6,1.3,475);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,9,9,17,1.2995,43);
   GrailSystemExtreme("GBPUSD",OP_BUY,12,9,10,11,1.3013,16);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,9,11,28,1.3017,42);
   GrailSystemExtreme("GBPUSD",OP_BUY,12,9,12,11,1.3039,40);
   GrailSystemExtreme("GBPUSD",OP_BUY,12,9,14,57,1.3013,57);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,9,16,16,1.3,24);
   GrailSystemExtreme("GBPUSD",OP_BUY,12,9,16,55,1.3025,30);
   GrailSystemExtreme("GBPUSD",OP_SELL,12,9,18,25,1.3025,26);
   GrailSystemExtreme("GBPUSD",OP_BUY,12,9,20,2,1.307,13);
*/
   GrailSystemExtreme("GBPUSD",OP_BUY,10,12,16,20,1.2647,15*11);
   GrailSystemExtreme("GBPUSD",OP_BUY,10,12,18,5,1.2576,15*21);

   // Scalping Trade
/*
   GrailSystemScalping("GBPUSD",OP_BUY,10,7,15,30);
   GrailSystemScalping("GBPUSD",OP_SELL,13,7,1,0);
   GrailSystemScalping("GBPUSD",OP_SELL,13,7,10,5);
   GrailSystemScalping("GBPUSD",OP_BUY,13,7,17,0);
   GrailSystemScalping("GBPUSD",OP_BUY,16,7,12,15);
   GrailSystemScalping("GBPUSD",OP_BUY,16,7,13,45);
   GrailSystemScalping("GBPUSD",OP_BUY,16,7,11,10);
   GrailSystemScalping("GBPUSD",OP_SELL,16,7,15,25);
   GrailSystemScalping("GBPUSD",OP_SELL,16,7,17,37);
   GrailSystemScalping("GBPUSD",OP_SELL,17,7,14,47);
   GrailSystemScalping("GBPUSD",OP_SELL,17,7,20,24);
   GrailSystemScalping("GBPUSD",OP_SELL,17,7,21,50);
   GrailSystemScalping("GBPUSD",OP_BUY,18,7,17,54);
   GrailSystemScalping("GBPUSD",OP_SELL,18,7,4,45);
   GrailSystemScalping("GBPUSD",OP_SELL,18,7,11,22);
   GrailSystemScalping("GBPUSD",OP_SELL,19,7,10,5);
   GrailSystemScalping("GBPUSD",OP_SELL,19,7,11,27);
   GrailSystemScalping("GBPUSD",OP_SELL,19,7,13,30);
   GrailSystemScalping("GBPUSD",OP_SELL,19,7,15,0);
   GrailSystemScalping("GBPUSD",OP_BUY,19,7,16,28);
   GrailSystemScalping("GBPUSD",OP_BUY,19,7,17,0);
   GrailSystemScalping("GBPUSD",OP_BUY,19,7,20,13);
   GrailSystemScalping("GBPUSD",OP_SELL,20,7,4,10);
   GrailSystemScalping("GBPUSD",OP_SELL,20,7,10,2);
   GrailSystemScalping("GBPUSD",OP_BUY,20,7,13,54);
   GrailSystemScalping("GBPUSD",OP_BUY,20,7,15,42);
   GrailSystemScalping("GBPUSD",OP_BUY,20,7,16,11);
   GrailSystemScalping("GBPUSD",OP_BUY,20,7,16,54);
   GrailSystemScalping("GBPUSD",OP_BUY,20,7,19,37);
   GrailSystemScalping("GBPUSD",OP_SELL,23,7,4,46);
   GrailSystemScalping("GBPUSD",OP_BUY,23,7,10,3);
   GrailSystemScalping("GBPUSD",OP_SELL,23,7,11,40);
   GrailSystemScalping("GBPUSD",OP_SELL,23,7,15,55);
   GrailSystemScalping("GBPUSD",OP_SELL,23,7,20,37);
   GrailSystemScalping("GBPUSD",OP_SELL,24,7,6,14);
   GrailSystemScalping("GBPUSD",OP_BUY,24,7,10,30);
   GrailSystemScalping("GBPUSD",OP_BUY,24,7,12,44);
   GrailSystemScalping("GBPUSD",OP_SELL,24,7,14,58);
   GrailSystemScalping("GBPUSD",OP_BUY,24,7,16,35);
   GrailSystemScalping("GBPUSD",OP_SELL,25,7,4,31);
   GrailSystemScalping("GBPUSD",OP_BUY,25,7,9,25);
   GrailSystemScalping("GBPUSD",OP_BUY,25,7,15,25);
   GrailSystemScalping("GBPUSD",OP_SELL,25,7,17,1);
   GrailSystemScalping("GBPUSD",OP_BUY,25,7,20,58);
   GrailSystemScalping("GBPUSD",OP_BUY,26,7,1,3);
   GrailSystemScalping("GBPUSD",OP_SELL,26,7,4,25);
   GrailSystemScalping("GBPUSD",OP_SELL,26,7,15,53);
   GrailSystemScalping("GBPUSD",OP_SELL,26,7,16,20);
   GrailSystemScalping("GBPUSD",OP_SELL,26,7,17,7);
   GrailSystemScalping("GBPUSD",OP_SELL,31,7,15,31);
   GrailSystemScalping("GBPUSD",OP_SELL,31,7,17,33);
   GrailSystemScalping("GBPUSD",OP_SELL,31,7,23,34);
   GrailSystemScalping("GBPUSD",OP_SELL,2,8,9,40);
   GrailSystemScalping("GBPUSD",OP_SELL,3,8,10,10);
   GrailSystemScalping("GBPUSD",OP_BUY,3,8,17,27);
   GrailSystemScalping("GBPUSD",OP_SELL,6,8,10,31);
   GrailSystemScalping("GBPUSD",OP_SELL,6,8,10,55);
   GrailSystemScalping("GBPUSD",OP_SELL,6,8,10,55);
   GrailSystemScalping("GBPUSD",OP_BUY,6,8,15,28);
   GrailSystemScalping("GBPUSD",OP_BUY,8,8,5,47);
   GrailSystemScalping("GBPUSD",OP_BUY,8,8,15,50);
   GrailSystemScalping("GBPUSD",OP_SELL,8,8,18,13);
   GrailSystemScalping("GBPUSD",OP_SELL,9,8,4,19);
   GrailSystemScalping("GBPUSD",OP_SELL,9,8,9,58);
   GrailSystemScalping("GBPUSD",OP_BUY,9,8,12,59);
   GrailSystemScalping("GBPUSD",OP_SELL,9,8,19,27);
   GrailSystemScalping("GBPUSD",OP_SELL,10,8,8,7);
   GrailSystemScalping("GBPUSD",OP_BUY,10,8,10,44);
   GrailSystemScalping("GBPUSD",OP_SELL,10,8,13,35);
   GrailSystemScalping("GBPUSD",OP_SELL,10,8,14,59);
   GrailSystemScalping("GBPUSD",OP_BUY,10,8,16,59);
   GrailSystemScalping("GBPUSD",OP_SELL,13,8,9,42);
   GrailSystemScalping("GBPUSD",OP_BUY,13,8,16,18);
   GrailSystemScalping("GBPUSD",OP_SELL,13,8,18,45);
   GrailSystemScalping("GBPUSD",OP_SELL,14,8,18,46);
   GrailSystemScalping("GBPUSD",OP_BUY,15,8,9,5);
   GrailSystemScalping("GBPUSD",OP_SELL,15,8,11,27);
   GrailSystemScalping("GBPUSD",OP_SELL,15,8,13,20);
   GrailSystemScalping("GBPUSD",OP_BUY,16,8,16,42);
   GrailSystemScalping("GBPUSD",OP_SELL,17,8,10,6);
   GrailSystemScalping("GBPUSD",OP_SELL,17,8,11,36);
   GrailSystemScalping("GBPUSD",OP_BUY,17,8,20,57);
   GrailSystemScalping("GBPUSD",OP_BUY,21,8,3,27);
   GrailSystemScalping("GBPUSD",OP_SELL,21,8,9,27);
   GrailSystemScalping("GBPUSD",OP_SELL,21,8,14,31);
   GrailSystemScalping("GBPUSD",OP_BUY,21,8,16,6);
   GrailSystemScalping("GBPUSD",OP_SELL,22,8,10,5);
   GrailSystemScalping("GBPUSD",OP_BUY,22,8,20,59);
   GrailSystemScalping("GBPUSD",OP_SELL,23,8,4,41);
   GrailSystemScalping("GBPUSD",OP_BUY,23,8,13,18);
   GrailSystemScalping("GBPUSD",OP_BUY,24,8,12,58);
   GrailSystemScalping("GBPUSD",OP_SELL,27,8,6,34);
   GrailSystemScalping("GBPUSD",OP_SELL,28,8,16,24);
   GrailSystemScalping("GBPUSD",OP_BUY,29,8,12,50);
   GrailSystemScalping("GBPUSD",OP_BUY,29,8,16,59);
   GrailSystemScalping("GBPUSD",OP_BUY,29,8,17,23);
   GrailSystemScalping("GBPUSD",OP_SELL,30,8,10,43);
   GrailSystemScalping("GBPUSD",OP_BUY,30,8,16,37);
   GrailSystemScalping("GBPUSD",OP_SELL,31,8,18,18);
   GrailSystemScalping("GBPUSD",OP_SELL,3,9,11,30);
   GrailSystemScalping("GBPUSD",OP_SELL,3,9,11,53);
   GrailSystemScalping("GBPUSD",OP_BUY,5,9,16,17);
   GrailSystemScalping("GBPUSD",OP_BUY,6,9,11,38);
   GrailSystemScalping("GBPUSD",OP_SELL,7,9,18,31);
   GrailSystemScalping("GBPUSD",OP_BUY,10,9,15,57);
*/

   if(IsTesting()) {
      Comment(
      "\n\n Account Balance : ",StringDollar(Acc_Balance),
      "\n\n Account Equity : ",StringDollar(Acc_Equity),
      "\n\n PnL Daily : ",StringDollar(PerformanceClosed_Daily())," (",ReturnPercent(PerformanceClosed_Daily()),")",
      "\n\n PnL Weekly : ",StringDollar(PerformanceClosed_Weekly())," (",ReturnPercent(PerformanceClosed_Weekly()),")",
      "\n\n PnL Monthly : ",StringDollar(PerformanceClosed_Monthly())," (",ReturnPercent(PerformanceClosed_Monthly()),")",
      "\n\n"
      "\n\n Equity Factor : ",DoubleToString(EquityFactor(),2),
      "\n\n Account Double! : ",AccDouble,
      "\n\n Balance Control : ",BalanceControl(),
      "\n\n Account Leverage: ",Acc_Leverage,
      "\n\n"
      "\n\n Max Balance Single: ",StringDollar(FullCapacity),
      "\n\n Max Balance Seperated: ",StringDollar(FullCapacity_S),
      "\n\n"
      "\n\n Movement Value : ",StringDollar(PointMovement()),
      "\n\n PnL : ",StringDollar(OrderProperty_FloatingStatus()),
      "\n\n"
      "\n\n TradeLot_FullMargin : ",StringLot(TradeLot_FM),
      "\n\n TradeLot_SepMargin : ",StringLot(TradeLot_SM),
      "\n\n TradeLot_Extreme : ",StringLot(TradeLot_EX),
      "\n\n TradeLot_Extreme2 : ",StringLot(TradeLot_EX2),
      "\n\n TradeLot_Scalping : ",StringLot(TradeLot_LS),
      "\n\n TradeLot_Scalping2 : ",StringLot(TradeLot_LS2),
      "\n\n Reference Price : ",refPrice(),
      "\n\n Identifier : ",VariableIdentifier(),
      "\n\n Margin Call : ",Acc_MarginCall,"%",
      "\n\n Stop-Out : ",Acc_StopOut,"%"
      );
   }
   else {
      Comment(
      "\n\n Account Balance : ",StringDollar(Acc_Balance),
      "\n\n Account Equity : ",StringDollar(Acc_Equity),
      "\n\n PnL Daily : ",StringDollar(PerformanceClosed_Daily())," (",ReturnPercent(PerformanceClosed_Daily()),")",
      "\n\n PnL Weekly : ",StringDollar(PerformanceClosed_Weekly())," (",ReturnPercent(PerformanceClosed_Weekly()),")",
      "\n\n PnL Monthly : ",StringDollar(PerformanceClosed_Monthly())," (",ReturnPercent(PerformanceClosed_Monthly()),")",
      "\n\n"
      "\n\n Reference Price : ",refPrice()
      );  
   }
}

string getUninitReasonText(int reasonCode){
   string text = "";
   switch(reasonCode){      
      case REASON_PROGRAM:       text = __FILE__+" was terminated by ExpertRemove()"; break;
      case REASON_REMOVE:        text = __FILE__+" was removed from chart";break;
      case REASON_RECOMPILE:     text = __FILE__+" was recompiled";break;
      case REASON_CHARTCHANGE:   text = "Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:    text = "Chart was closed";break;
      case REASON_PARAMETERS:    text = "Input-parameter was changed";break;
      case REASON_ACCOUNT:       text = "Account was changed";break;
      case REASON_TEMPLATE:      text = "New template was applied to chart";break;
      case REASON_INITFAILED:    text = "Initialization fail";break;
      case REASON_CLOSE:         text = "Terminal was closed";break;
      default:                   text = "Another reason...";
   }
   return text;
}

double EquityFactor(){
   return NormDollar(Acc_Equity/Acc_Balance);
}

string Drawdown() {
   return DoubleToString(Acc_Drawdown,1)+" %";
}

void AssigningLot(double& lot1, double& lot2, double& lot3, double& lot4, double& lot5, double& lot6) {
   int limitpercent = fmax(Acc_MarginCall+20,120);
   lot1 = FullMarginLot(limitpercent,1,4);
   lot2 = FullMarginLot(limitpercent,10,4);
   lot3 = FullMarginLot(limitpercent,2,4);
   lot4 = FullMarginLot(limitpercent,10,4);
   lot5 = FullMarginLot(limitpercent,11,4);
   lot6 = FullMarginLot(limitpercent,55,4);
}

void AccountParameter_Var() {
   // Account Info
   Acc_Balance       = AccountInfoDouble(ACCOUNT_BALANCE);
   Acc_Equity        = AccountInfoDouble(ACCOUNT_EQUITY);
   Acc_FreeMargin    = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   Acc_MarginLevel   = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   Market_TickValue  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   Market_Spread     = int(MarketInfo(_Symbol,MODE_SPREAD));
   Acc_Drawdown      = 0;
   NotiEnable        = TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);
   if(Acc_Balance>Acc_Equity && Acc_Balance>0) {
      Acc_Drawdown = StringToDouble(DoubleToString((1-(Acc_Equity/Acc_Balance))*100,1));
   }
}

void AccountParameter_Symbol() {   
   Market_CalcMode   = int(MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   Market_Symbol     = _Symbol;
   SymbolCurr1       = StringSubstr(_Symbol,0,3);
   SymbolCurr2       = StringSubstr(_Symbol,3,3);
   SymbolCurrPrefix  = "";
   SymbolCurrSuffix  = "";
   SymbolCurrMid     = "";
   
   if(Market_CalcMode==0 && StringLen(_Symbol)>6) {
      string symbolTest = "EURUSD";
      getPrefixSuffix(SymbolCurrPrefix,SymbolCurrSuffix,symbolTest);
      int len = StringLen(symbolTest);
      
      if(len==6) {
         if(SymbolCurrPrefix=="") {
            Market_Symbol   = StringSubstr(_Symbol,0,6);
            SymbolCurr1     = StringSubstr(_Symbol,0,3);
            SymbolCurr2     = StringSubstr(_Symbol,3,3);
         }
         else {
            int x    = StringLen(SymbolCurrPrefix);
            Market_Symbol   = StringSubstr(_Symbol,x,6);
            SymbolCurr1     = StringSubstr(_Symbol,x,3);
            SymbolCurr2     = StringSubstr(_Symbol,x+3,3);
         }
      }
      else if(len==7) {
         if(SymbolCurrPrefix=="") {
            SymbolCurr1     = StringSubstr(_Symbol,0,3);
            SymbolCurr2     = StringSubstr(_Symbol,4,3);
            SymbolCurrMid      = StringSubstr(_Symbol,3,1);
            Market_Symbol   = SymbolCurr1+SymbolCurr2;
         }
         else {
            int x    = StringLen(SymbolCurrPrefix);
            SymbolCurr1     = StringSubstr(_Symbol,x,3);
            SymbolCurr2     = StringSubstr(_Symbol,x+4,3);
            SymbolCurrMid      = StringSubstr(_Symbol,x+3,1);
            Market_Symbol   = SymbolCurr1+SymbolCurr2;
         }
      }
   }
}

void AccountParameter_Fixed() {
   // Account Info
   Acc_Login            = int(AccountInfoInteger(ACCOUNT_LOGIN));
   Acc_Leverage         = int(AccountInfoInteger(ACCOUNT_LEVERAGE));
   Acc_Broker           = AccountInfoString(ACCOUNT_COMPANY);
   Acc_Currency         = AccountInfoString(ACCOUNT_CURRENCY);
   Acc_MaxOrder         = int(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   Acc_Slippage         = 2;
   // Market Info
   Market_ContractSize  = MarketInfo(_Symbol,MODE_LOTSIZE);
   Market_MarginHedge   = MarketInfo(_Symbol,MODE_MARGINHEDGED)/Market_ContractSize;
   Market_MaxLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   Market_MinLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   Market_LotStep       = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   Market_TickSize      = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)/_Point;
   Market_StopLevel     = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   Market_FreezeLevel   = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   Acc_MarginCall       = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   Acc_StopOut          = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Acc_Pips             = 1;

   if(_Digits == 3 || _Digits == 5) {
      Acc_Slippage    = 15;
      Acc_Pips = 10;
   }
}

void getPrefixSuffix(string& prefix, string& suffix, string& accSymbol){ 
   int SectorSize = 1936;
   prefix=""; suffix="";

   int retry = 0;
   int fileHandle = -1;
   while(retry <= MAX_RETRIES) {   
      fileHandle = FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ);
      if (fileHandle != -1) break;
      else {
         retry++;
         Sleep(1000);
      }
   }
   if (fileHandle == -1) {
      Alert("File opening error: ",ErrorDescription(GetLastError()));
      ResetLastError();
      return; //HFILE Error
   }
   else {
      for(int i=0;; i++){
         int pos;
         FileSeek(fileHandle, SectorSize*i, SEEK_SET); 
         if (FileIsEnding(fileHandle)) { prefix="err"; break; }
         string symbolName = FileReadString(fileHandle,12);
         
         symbolName = StringSubstr(symbolName,0);
         pos = StringFind(symbolName,"EURUSD",0);
         if (pos > -1){
            if (pos>0) prefix = StringSubstr(symbolName,0,pos);
            if ((pos+6)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+6),0);
            accSymbol = "EURUSD";
            break;
         }
         else {
            pos = StringFind(symbolName,"EUR/USD",0);
            if (pos > -1){
               if (pos>0) prefix = StringSubstr(symbolName,0,pos);
               if ((pos+7)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+7),0);
               accSymbol = "EUR/USD";
               break;
            }
            else {
               pos = StringFind(symbolName,"EUR.USD",0);
               if (pos > -1){
                  if (pos>0) prefix = StringSubstr(symbolName,0,pos);
                  if ((pos+7)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+7),0);
                  accSymbol = "EUR.USD";
                  break;
               }
            }
         } 
      } 
      FileClose(fileHandle);
   }
}

void GhostOrder() {
   if(CountPosition(MagicS_1)==0) {
      if(CountPosition(MagicS_2>0)) CloseOrder(MagicS_2);
      if(CountPosition(MagicS_3>0)) CloseOrder(MagicS_3);
      if(CountPosition(MagicS_4>0)) CloseOrder(MagicS_4);
      if(CountPosition(MagicS_5>0)) CloseOrder(MagicS_5);
      if(CountPosition(MagicS_6>0)) CloseOrder(MagicS_6);
      if(CountPosition(MagicS_7>0)) CloseOrder(MagicS_7);
      if(CountPosition(MagicS_8>0)) CloseOrder(MagicS_8);
      if(CountPosition(MagicS_9>0)) CloseOrder(MagicS_9);
      if(CountPosition(MagicS_10>0)) CloseOrder(MagicS_10);
   }
   if(CountPosition(MagicE_1)==0) {
      if(CountPosition(MagicE_2>0)) CloseOrder(MagicE_2);
      if(CountPosition(MagicE_3>0)) CloseOrder(MagicE_3);
      if(CountPosition(MagicE_4>0)) CloseOrder(MagicE_4);
      if(CountPosition(MagicE_5>0)) CloseOrder(MagicE_5);
   }
   if(CountPosition(MagicB_1)==0) {
      if(CountPosition(MagicB_2>0)) CloseOrder(MagicB_2);
      if(CountPosition(MagicB_3>0)) CloseOrder(MagicB_3);
      if(CountPosition(MagicB_4>0)) CloseOrder(MagicB_4);
      if(CountPosition(MagicB_5>0)) CloseOrder(MagicB_5);
   }
}

void GrailSystemSwing(string GrailSymbol, int type, int day, int month, int hour, int minutes, double pTakeProfit, int limitbar = 0){
   if(Market_Symbol==GrailSymbol){
      if(CountPosition(MagicS_1)>0) {
         if(GrailTiming(MagicS_1,month,day,hour,minutes)){
            ManagingOrderSeq(MagicS_10,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_9,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_8,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_7,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_6,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_5,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_4,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_3,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_2,pTakeProfit,limitbar);
            ManagingOrderSeq(MagicS_1,pTakeProfit,limitbar);
         }
      }
      else if(ActivateEA && NewTradeSeq(month,day,hour,minutes)) {
         bool correctswing = ((type==OP_BUY && pTakeProfit>Ask) || (type==OP_SELL && pTakeProfit<Bid));
         if(BalanceControl() && correctswing) {
            string TradeComment = CommentSwing;
            if(TradeLot_FM<Market_MaxLot-5) OpenSeqOrder(MagicS_1,type,TradeLot_FM,TradeComment);
            else{
               OpenSeqOrder(MagicS_1,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_2,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_3,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_4,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_5,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_6,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_7,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_8,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_9,type,TradeLot_SM,TradeComment);
               OpenSeqOrder(MagicS_10,type,TradeLot_SM,TradeComment);
            }
         }
      }
   }
}

void ManagingOrderSeq(int magic, double pTakeProfit, int limitbar){
   if(CountPosition(magic)>0){
      int SL = FailSafeSL();
      HiddenSL(magic,SL);
      GrailTP(magic,pTakeProfit,limitbar);
   }
}

void GrailTP(int magic, double pPrice,int limitbar){
   if(CountPosition(magic)>0) VariableOrderExtreme(magic,200,pPrice,limitbar);
}

bool BetweenPriceRange(double above, double below) {
   bool x = false;
   RefreshRates();
   if(Bid<=above && Bid>=below) x = true;   
   return x;
}

void ProtectingTarget_HG(int magic, double TP_Level, bool partialclose = true, int trigger = 20, int lock = 20) {
   if(CountPosition(magic)>0) {
      int type = OrderProperty_OrderType(magic);
      double SL = OrderProperty_OrderStopLoss(magic);
      double OP = OrderProperty_OrderOpenPrice(magic);
      double OL = OrderProperty_OrderLot(magic);
      double PCL = NormLotMax(OL*0.25);
      double trigger_buy,trigger_sell,trigger_buyPC,trigger_sellPC,TriggerSL;
      double dis_trigger   = NumToPoint(trigger);
      double dis_triggerPC = NumToPoint(10);
      double dis_lock      = NumToPoint(lock);
      double buffer        = NumToPoint(25);
      bool checkrange      = BetweenPriceRange(TP_Level+dis_trigger+buffer,TP_Level-dis_trigger-buffer);

      if(TP_Level>0 && checkrange) {
         trigger_buy    = TP_Level-dis_trigger;
         trigger_buyPC  = TP_Level-dis_triggerPC;
         trigger_sell   = TP_Level+dis_trigger;
         trigger_sellPC = TP_Level+dis_triggerPC;
         RefreshRates();
         if(type==OP_BUY && TP_Level>OP && Bid>trigger_buy) {
            TriggerSL = Bid-(dis_lock+Market_StopLevel);
            if(SL<TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
            if(partialclose) {
               if(Bid>=TP_Level) {
                  ProtectingTargetScalp(magic);
                  CloseOrder(magic);
               }
               else if(Bid>=trigger_buyPC && FirstTick(PERIOD_M1)) PartialClose(magic,PCL);
            }
         }
         else if(type==OP_SELL && TP_Level<OP && Bid<trigger_sell) {
            TriggerSL = Ask+(dis_lock+Market_StopLevel);
            if(SL>TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
            if(partialclose) {
               if(Bid<=TP_Level) {
                  ProtectingTargetScalp(magic);
                  CloseOrder(magic);
               }
               else if(Bid<=trigger_sellPC && FirstTick(PERIOD_M1)) PartialClose(magic,PCL);
            }
         }
      }
   }
}

void ProtectingTargetScalp(int magic, int lock = 5) {
   if(CountPosition(magic)>0) {
      int type = OrderProperty_OrderType(magic);
      double SL = OrderProperty_OrderStopLoss(magic);
      double TriggerSL;
      double dis_lock = NumToPoint(lock)+Market_StopLevel;

      RefreshRates();
      if(type==OP_BUY) {
         TriggerSL = Bid-dis_lock;
         if(SL<TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
      else if(type==OP_SELL) {
         TriggerSL = Ask+dis_lock;
         if(SL>TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
   }
}

void GrailSystemScalping(string GrailSymbol, int type, int day, int month, int hour, int minutes){
   if(Market_Symbol==GrailSymbol){
      if(CountPosition(MagicB_1)>0) {
         bool ThisOrder = GrailTiming(MagicB_1,month,day,hour,minutes);
         if(ThisOrder) {
            VariableOrderExtreme(MagicB_5);
            VariableOrderExtreme(MagicB_4);
            VariableOrderExtreme(MagicB_3);
            VariableOrderExtreme(MagicB_2);
            VariableOrderExtreme(MagicB_1);
         }
      }
      else if(ActivateEA && NewTradeSeq(month,day,hour,minutes) && BalanceControl()) {
         string TradeCom = CommentScalp;
         if(TradeLot_LS<Market_MaxLot-5) OpenSeqOrder(MagicB_1,type,TradeLot_LS,TradeCom);
         else {
            OpenSeqOrder(MagicB_1,type,TradeLot_LS2,TradeCom);
            OpenSeqOrder(MagicB_2,type,TradeLot_LS2,TradeCom);
            OpenSeqOrder(MagicB_3,type,TradeLot_LS2,TradeCom);
            OpenSeqOrder(MagicB_4,type,TradeLot_LS2,TradeCom);
            OpenSeqOrder(MagicB_5,type,TradeLot_LS2,TradeCom);
         }
      }
   }
}

void BadBroker(int type, int ordertype) {
   if(type!=ordertype) {
      string NewLine = "\n", sInput  = "%s";
      string output_string = StringConcatenate("Major Warning!!",
                                             NewLine,"Broker ",sInput," has change your order!",
                                             NewLine,"Acc No : ",sInput,
                                             NewLine,"Acc Balance : ",sInput
                                           );
                                           
      string msg = StringFormat(output_string,Acc_Broker,IntegerToString(Acc_Login),StringDollar(Acc_Balance));
      NotifySetting(msg);
      ScreenShot("Bad Broker");
      CloseOrder(MagicS_2);
      CloseOrder(MagicS_3);
      CloseOrder(MagicS_4);
      CloseOrder(MagicS_5);
      CloseOrder(MagicS_6);
      CloseOrder(MagicS_7);
      CloseOrder(MagicS_8);
      CloseOrder(MagicS_9);
      CloseOrder(MagicS_10);
      
      CloseOrder(MagicE_2);
      CloseOrder(MagicE_3);
      CloseOrder(MagicE_4);
      CloseOrder(MagicE_5);
      
      CloseOrder(MagicB_2);
      CloseOrder(MagicB_3);
      CloseOrder(MagicB_4);
      CloseOrder(MagicB_5);
      
      CloseOrder(MagicS_1);
      CloseOrder(MagicE_1);
      CloseOrder(MagicB_1);
      
      if(CountExistingPosition()==0) ExpertRemove();
   }
}

void GrailSystemExtreme(string GrailSymbol, int type, int day, int month, int hour, int minutes, double TP_Level, int limitbar = 0){
   bool correctswing = ((type==OP_BUY && TP_Level>Ask) || (type==OP_SELL && TP_Level<Bid));
   if(Market_Symbol==GrailSymbol){
      if(CountPosition(MagicE_1)>0) {
         bool ThisOrder = GrailTiming(MagicE_1,month,day,hour,minutes);
         int dir = OrderProperty_OrderType(MagicE_1);
         if(ThisOrder) {
            if(TP_Level>0) {
               VariableOrderExtreme(MagicE_5,150,TP_Level,limitbar);
               VariableOrderExtreme(MagicE_4,150,TP_Level,limitbar);
               VariableOrderExtreme(MagicE_3,150,TP_Level,limitbar);
               VariableOrderExtreme(MagicE_2,150,TP_Level,limitbar);
               VariableOrderExtreme(MagicE_1,150,TP_Level,limitbar);
            }
         }
      }
      else if(ActivateEA && NewTradeSeq(month,day,hour,minutes) && BalanceControl() && correctswing  && StopLevel(TP_Level) && (EquityFactor()==1 || EquityFactor()>=1.07)) {
         string TradeCom = CommentExtreme;
         if(TradeLot_EX<Market_MaxLot-5) OpenSeqOrder(MagicE_1,type,TradeLot_EX,TradeCom);
         else {
            OpenSeqOrder(MagicE_1,type,TradeLot_EX2,TradeCom);
            OpenSeqOrder(MagicE_2,type,TradeLot_EX2,TradeCom);
            OpenSeqOrder(MagicE_3,type,TradeLot_EX2,TradeCom);
            OpenSeqOrder(MagicE_4,type,TradeLot_EX2,TradeCom);
            OpenSeqOrder(MagicE_5,type,TradeLot_EX2,TradeCom);
         }
      }
   }
}

bool GrailTiming(int magic, int month, int day, int hour, int minutes) {
   int Trade_Year = TimeYear(TimeCurrent());
   int thisMinStart = minutes;
   int thisMinEnd = minutes;
   int thisHourStart = hour;
   int thisHourEnd = hour;
   int thisDayEnd = day;
   if(minutes==0) {
      thisMinStart   = 60;
      thisHourStart -= 1;
   }
   else if(minutes==58) {
      thisMinEnd     = 0;
      if(hour==23) {
         thisHourEnd = 0;
         thisDayEnd += 1;
      }
      else thisHourEnd += 1;
   }
   
   datetime ThisOrderTime = OrderProperty_OrderOpenTime(magic);
   return ThisOrderTime>=GrailTime(Trade_Year,month,day,thisHourStart,thisMinStart-1) && ThisOrderTime<=GrailTime(Trade_Year,month,thisDayEnd,thisHourEnd,thisMinEnd+2);
}

void VariableOrderExtreme(int magic, int BE = 0, double TP_Level = 0, int limitbar = 0) {
   double OrderOP = OrderProperty_OrderOpenPrice(magic);
   double distanceTri = NumToPoint(15);
   double RangeHigh,RangeLow;
   double LvlTrigger, LvlScalp = 0;
   int dir = OrderProperty_OrderType(magic);
   bool activateExtreme = false;
   bool activateScalping = false;
   int rangeTP = PointToInt(fabs(OrderOP-TP_Level));
   int minBE = 85;
   if(TP_Level>0 && rangeTP>=200) minBE = BE;
   int SL = FailSafeSL();

   // Stoploss
   HiddenSL(magic,SL);
   BreakEven(magic,minBE);
   RangePeriod(PERIOD_M1,10,0,RangeHigh,RangeLow);
   
   RefreshRates();
   if(TP_Level>0) {
      if(dir==OP_BUY) {
         LvlTrigger = TP_Level-distanceTri;
         if(Bid>=LvlTrigger || RangeHigh>=LvlTrigger) activateExtreme = true;
      }
      else if(dir==OP_SELL) {
         LvlTrigger = TP_Level+distanceTri;
         if(Bid<=LvlTrigger || RangeLow<=LvlTrigger) activateExtreme = true;
      }
   }
   else {
      if(dir==OP_BUY) {
         LvlScalp = OrderOP+NumToPoint(SL*2);
         LvlTrigger = LvlScalp-distanceTri;
         if(Bid>=LvlTrigger || RangeHigh>=LvlTrigger) activateScalping = true;
      }
      else if(dir==OP_SELL) {
         LvlScalp = OrderOP-NumToPoint(SL*2);
         LvlTrigger = LvlScalp+distanceTri;
         if(Bid<=LvlTrigger || RangeLow<=LvlTrigger) activateScalping = true;
      }
   }
   if(activateExtreme) ProtectingTarget_HG(magic,TP_Level);
   if(activateScalping) ProtectingTarget_HG(magic,LvlScalp,false);
   if(FailSafeDuration(magic,limitbar)) ProtectingTargetScalp(magic);
}

bool NewTradeSeq(int month,int day, int hour, int minutes){
   bool x = false;
   int Trade_Year = TimeYear(TimeCurrent());
   if(month>=1 && month<=12 && day>=1 && day<=31 && hour>=0 && hour<=23 && minutes>=0 && minutes<=59){
      int thisMin = minutes;
      int thisHour = hour;
      if(minutes==0) {
         thisMin=60;
         thisHour -= 1;
      }
      if(TimeCurrent()>=GrailTime(Trade_Year,month,day,thisHour,thisMin-1,59) && TimeCurrent()<=GrailTime(Trade_Year,month,day,hour,minutes,20)) x = true;
   }
   return x;
}

int FailSafeSL(){
   int add_buffer = 100;
   int Spread     = Market_Spread;
   int x          = Spread+add_buffer;
   
   if(Spread<=10)       x = add_buffer;
   else if(Spread<=20)  x = 10+add_buffer;
   else if(Spread<=30)  x = 20+add_buffer;
   else if(Spread<=40)  x = 30+add_buffer;

   return x;
}

bool FailSafeDuration(int magic, int bar) {
   bool x = false;
   if(CountPosition(magic)>0 && bar>0) {
      datetime OT = OrderProperty_OrderOpenTime(magic);
      string OS = OrderProperty_OrderSymbol(magic);
      int shift = iBarShift(OS,PERIOD_M1,OT);
      if(shift>bar) x = true;
   }
   
   if(x && FirstTick(PERIOD_M1) && !IsTesting()) {
      string msg = "[Fail safe Duration Alert!] There is Order over limit!";
      NotifySetting(msg);
   }
   return x;
}

double FullMarginLot(double MinMarginPercentage = 102, int divider = 1, double CommPerStdLotRoundTurn = 0){
   int buffer              = 30;
   int margin              = Market_Spread*2+buffer;
   double CommissionCost   = 0;
   double LotSize          = Market_MaxLot;
   double LevMargin        = Market_ContractSize/(double)Acc_Leverage;
   double RefPrice         = refPrice();
   
   // CommissionPer1MilContract =  $4/roundtrip/1StdLot. for most broker = $20 per 1 million traded lot per turn
   if(CommPerStdLotRoundTurn>0) CommissionCost = RefPrice*CommPerStdLotRoundTurn;
   
   // Some room for margin calculation
   if(Market_Spread<=15)       margin = 30+buffer;
   else if(Market_Spread<=25)  margin = 50+buffer;
   else if(Market_Spread<=35)  margin = 70+buffer;
   
   // calculation for cost
   double SpreadCost       = margin*Market_TickValue;
   double MarginReqCost    = RefPrice*LevMargin;
   double AccociateCost    = CommissionCost+MarginReqCost+SpreadCost;
   
   double divider_starter = MinMarginPercentage/100.0;
   if(divider_starter<1) divider_starter = 1.01;
   if(Acc_Balance<100) divider_starter += 0.01;
   double Extreme = Acc_Balance/divider_starter;
   
   double rawlot = (Extreme/AccociateCost)/divider;
   double SuicideLot = NormLot(rawlot);
   if(SuicideLot<Market_MaxLot) LotSize = SuicideLot;

   return LotSize;
}

string SymShort(int a, int b, int c) {
   return getletter(a)+getletter(b)+getletter(c);
}

bool GetSuffix(string& suff) {
   bool x = false;
   int SymLen = StringLen(_Symbol);
   if(SymLen>6) {
      x = true;
      suff = StringSubstr(_Symbol,6,SymLen-6);
   }
   return x;
}

double refPrice() {
   string refSym = "", refSym2 = "", suffix = "";
   string sym1 = SymShort(0,1,2);
   string sym2 = SymShort(3,4,5);
   bool hvsuffix = GetSuffix(suffix);
   double RefPrice = 1;
   double buffer = NumToPoint(1*Acc_Pips);

   // Get Reference Price
   RefreshRates();
   if(sym1==Acc_Currency) RefPrice = 1;
   else if(sym2==Acc_Currency || _Symbol=="BRENT" || _Symbol=="WTI") RefPrice = Ask;
   else {
      refSym = sym1+Acc_Currency;
      string ThisSym1 = refSym;
      if(hvsuffix) ThisSym1 = refSym+suffix;
      
      refSym2 = Acc_Currency+sym1;
      string ThisSym2 = refSym2;
      if(hvsuffix) ThisSym2 = refSym2+suffix;
      
      if(Acc_Currency=="USD"){
         if(refSym=="EURUSD" || refSym=="GBPUSD" || refSym=="AUDUSD" || refSym=="NZDUSD" || refSym=="XAUUSD" || refSym=="XAGUSD" || 
         refSym=="BTCUSD" || refSym=="ETHUSD" || refSym=="XRPUSD") RefPrice = SymbolInfoDouble(ThisSym1,SYMBOL_ASK);
         else RefPrice = 1/(SymbolInfoDouble(ThisSym2,SYMBOL_ASK));
      }
      else RefPrice = 1; // need to refine this code for deposit currency other than USD
   }
   
   return RefPrice+buffer;
}

double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0) {
   int margin              = spread*2;
   double marginRequired   = 0, CommissionCost = 0;
   double referencePrice   = refPrice();
   string sym1             = SymShort(0,1,2);
   
   // Account Multiplier
   double multiplier = (Market_ContractSize/(double)leverage)*lotsize;
   // Margin Required
   if(sym1==Acc_Currency) marginRequired = multiplier;
   else marginRequired = multiplier*referencePrice;
   // Commission Cost
   if(CommPerStdLotRoundTurn>0) CommissionCost = referencePrice*lotsize*CommPerStdLotRoundTurn;
   // Spread Cost
   if(Market_Spread<=15) margin = 15;
   else if(Market_Spread<=20) margin = 20;
   else if(Market_Spread<=25) margin = 25;
   else if(Market_Spread<=30) margin = 30;
   double SpreadCost = margin*lotsize*Market_TickValue;
   return NormDollar(marginRequired+CommissionCost+SpreadCost);
}

string getletter(int pos){
   string x = "None";
   
   string sym = Market_Symbol;
   ushort loc = StringGetCharacter(sym,pos);
   
   if(loc==65) x = "A";
   else if(loc==66) x = "B";
   else if(loc==67) x = "C";
   else if(loc==68) x = "D";
   else if(loc==69) x = "E";
   else if(loc==70) x = "F";
   else if(loc==71) x = "G";
   else if(loc==72) x = "H";
   else if(loc==73) x = "I";
   else if(loc==74) x = "J";
   else if(loc==75) x = "K";
   else if(loc==76) x = "L";
   else if(loc==77) x = "M";
   else if(loc==78) x = "N";
   else if(loc==79) x = "O";
   else if(loc==80) x = "P";
   else if(loc==81) x = "Q";
   else if(loc==82) x = "R";
   else if(loc==83) x = "S";
   else if(loc==84) x = "T";
   else if(loc==85) x = "U";
   else if(loc==86) x = "V";
   else if(loc==87) x = "W";
   else if(loc==88) x = "X";
   else if(loc==89) x = "Y";
   else if(loc==90) x = "Z";

   return x;
}

bool InitFailed() {
   string login = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   bool x = true;
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Alert("Please enable Automated Trading in the terminal settings!");
      x = false;
   }
   else if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Alert("Automated trading is forbidden in the program settings for ",__FILE__);
      x = false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
      Alert("Automated trading is forbidden for the account ",login," at the trade server side");
      x = false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Alert("Trading is forbidden for the account ",login,
      ".\nPerhaps an investor password has been used to connect to the trading account.",
      "\nCheck the terminal journal for the following entry:",
      "\n\'",login,"\': trading has been disabled - investor mode.");
      x = false;
   }
   return x;
}

void AllowTrading() {
   if (!InitFailed()) ExpertRemove();
}

bool VariableSpreadFilter(){
   bool allow = true;
   int MaxSpread = MAXSPREAD;
   string sym = Market_Symbol;
   //if(sym=="EURUSD" || sym=="USDJPY" || sym=="GBPUSD") MaxSpread = 20;
   //else if(sym=="AUDUSD" || sym=="NZDUSD" || sym=="EURJPY") MaxSpread = 24;
   //else if(sym=="USDCAD" || sym=="USDCHF") MaxSpread = 26;
   if(Market_Spread>MaxSpread) allow=false;
   return allow;
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

bool StopLevel(double pPrice) {
   bool x = true;
   double res = fmax(Market_StopLevel,Market_FreezeLevel);
   RefreshRates();
   double uppermargin = Ask + res;
   double lowermargin = Bid - res;
   if(pPrice<=uppermargin && pPrice>=lowermargin) x = false;
   return x;
}

double NormPrice(double price) {
   double ticksize = Market_TickSize*_Point;
   return round(price/ticksize)*ticksize;
}

double NormDollar(double Dollar){
   return round(Dollar/0.01)*0.01;
}

string ReturnPercent(double curr) {
   string x = "0";
   if(curr!=0 && Acc_Balance>0) {
      double acc = ((Acc_Balance/(Acc_Balance-curr))-1)*100;
      if(acc<100 && acc>-100) x = DoubleToString(acc,1);
      else x = IntegerProper((int)acc);
   }
   return StringConcatenate(x," %");
}

string IntegerProper(int pInteger) {
   string p1 = "";
   string p2 = "";
   string p3 = "";
   string comma = ",";
   string x = IntegerToString(pInteger);
   int z = StringLen(x);
   int shift = 0;
   if(pInteger<0)  shift = 1;
   
   if(z>3+shift && z<7+shift) {
      if(z==4+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift);
      }
      else if(z==5+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift);
      }
      else if(z==6+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift);
      }
      x = p1+comma+p2;
   }
   else if(z>=7+shift && z<10+shift) {
      if(z==7+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift,3+shift);
         p3 = StringSubstr(x,4+shift);
      }
      else if(z==8+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift,4+shift);
         p3 = StringSubstr(x,5+shift);
      }
      else if(z==9+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift,5+shift);
         p3 = StringSubstr(x,6+shift);
      }
      x = p1+comma+p2+comma+p3;
   }
   return x;
}

string StringDollar(double dollaValue) {
   string currency = "$";

   string x = DoubleToString(NormDollar(dollaValue),2);
   string res = x;
   int z = StringLen(x); 

   int shift = 0;
   if(dollaValue<0)  shift = 1;
   if(Acc_Currency!="USD") currency = Acc_Currency;
   
   if(z>6+shift) {
      string s1 = StringSubstr(x,0,z-3);
      string s2 = StringSubstr(x,z-3);
      int ins1 = StrToInteger(s1);
      string sx = IntegerProper(ins1);
      res =  sx+s2; 
   }

   return currency+" "+res;
}

double NormLot(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   double useLot  = minLot;
   if(lot>useLot) {
      if(lot>maxLot) useLot = maxLot;
      else useLot = floor(lot/lotStep)*lotStep;
   }
   return useLot;
}

double NormLotMax(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   double useLot  = minLot;
   if(lot>useLot) {
      if(lot>maxLot) useLot = maxLot;
      else useLot = ceil(lot/lotStep)*lotStep;
   }
   return useLot;
}

string StringLot(double lot) {
   double step = Market_LotStep;
   int x = 0;
   if(step==0.01) x = 2;
   else if(step==0.1) x = 1;
   
   return DoubleToString(lot,x);
}

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double step = Market_LotStep;
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}

int PointToInt (double point){
   return int(point/_Point);
}

int CountPosition(int Magic){
   int count = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == Magic && OrderSymbol()==_Symbol && OrderType()<2) count++;
   }
   return count;
}

int CountExistingPosition(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol && OrderType()<2) count++;
   }
   return count;
}

void TickData(){
   if(!IsTesting()){
      while(!IsConnected()) Sleep(1);
      while(IsTradeContextBusy()) Sleep(1);
      while(!RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

void OpenOrder(int type, int magic, double lot, string comment){
   string msg;
   if(type==OP_BUYLIMIT || type==OP_BUYSTOP || type==OP_SELLLIMIT || type==OP_SELLSTOP) {
      msg = _Symbol+" Market Order: Invalid order type!";
      NotifySetting(msg);
      return;
   }
   else if(lot<Market_MinLot || lot>Market_MaxLot) {
      msg = _Symbol+" Market Order: Invalid lot!";
      NotifySetting(msg);
      return;
   }
   else if(!EnoughFund(lot) || !MarginLevelProcced(105)) {
      msg = StringConcatenate(_Symbol+" Market Order: Not enough funds to open order with  ",lot," lot!");
      NotifySetting(msg);
      Sleep(5000);
      return;
   }
   else if(type==OP_BUY || type==OP_SELL){
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
      TickData(); // Updating Latest Tick Data
      double price = Bid;
      color arrow  = clrRed;
      if(type==OP_BUY) {price = Ask;arrow = clrGreen;}
      int ticket = OrderSend(_Symbol,type,lot,price,Acc_Slippage,0,0,comment,magic,0,arrow);
      if(ticket == -1) OrderSendError("Market");
      else {
         ul_res = GetMicrosecondCount()-ul;
         string ms = DoubleToString((ul_res/1000.0),2);
         if(!IsTesting()) PrintFormat("Market order execute in %s ms.",ms);
      }
   }
}

bool EnoughFund(double lot, int commission = 4) {
   return Acc_FreeMargin > MarginRequired(Acc_Leverage,Market_Spread+30,lot,commission);
}

void OpenSeqOrder(int magic, int type, double lot, string comment){
   if(CountPosition(magic)==0 && MarginLevelProcced(100) && VariableSpreadFilter()) OpenOrder(type,magic,lot,comment);
}

void OrderSendError(string ordertype){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Symbol : ",sInput,
                                             NewLine,sInput," order failed!",
                                             NewLine,"Reason : ",sInput
                                           );
                                           
   string msg = StringFormat( output_string,_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void ModifyError(int ticket){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #",sInput," - Symbol : ",sInput,
                                             NewLine,"Order ticket #",sInput," modify failed!",
                                             NewLine,"Reason : ",sInput
                                           );
      
   string msg = StringFormat(output_string,IntegerToString(Acc_Login),_Symbol,IntegerToString(ticket),ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void OrderCloseError(int ticket, string action){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Symbol : ",sInput,
                                             NewLine,"Order ticket #",sInput," failed to ",sInput,
                                             NewLine,"Reason : ",sInput
                                           );
                               
   string msg = StringFormat(output_string,_Symbol,IntegerToString(ticket),action,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void NotifySetting(string msg) {
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(msg);
   if(NotiEnable) SendNotification(acc);
   ResetLastError();
}

void ModifyStopLoss(int magic, double pPriceSL) { 
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && pPriceSL>=0){
         double NormSL = NormPrice(pPriceSL);
         if(AcceptableDifference(OrderStopLoss(),NormSL) && StopLevel(NormSL)){
            int retry = 0;
            bool modify = false;
            while(retry <= MAX_RETRIES) {
               modify = OrderModify(OrderTicket(),OrderOpenPrice(),NormSL,OrderTakeProfit(),0);
               if(modify) break;
               else {
                  bool RetryOnServerError = ServerError(_LastError);
                  if(RetryOnServerError) {
                     retry++;
                     Print("Server error detected, retrying...");
                     Sleep(RETRY_DELAY);
                  }
                  else break;
               }
            }
            if(!modify) ModifyError(OrderTicket());
         }
      }
   }
}

bool AcceptableDifference(double price, double pricecompare) {
   bool x = true;
   double buffer = NumToPoint(2);
   double range_u = pricecompare+buffer,
          range_b = pricecompare-buffer;
   if(price==pricecompare || (price<range_u && price>range_b)) x = false;
   return x;
}

void CloseOrder(int magic){
   if(CountPosition(magic)>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         bool select = OrderSelect(order,SELECT_BY_POS);
         if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2){
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  TickData(); // Updating Latest Tick Data
                  closeorder = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Acc_Slippage,clrRed);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     string ms = DoubleToString((ul_res/1000.0),2);
                     if(IsTesting()) Print("Order #",OrderTicket()," closed.");
                     else PrintFormat("Order ticket %d closed in %s ms.",OrderTicket(),ms);
                     break;
                  }
                  else {
                     bool RetryOnServerError = ServerError(_LastError);
                     if(RetryOnServerError) {
                        retry++;
                        Print("Server error detected, retrying...");
                        Sleep(RETRY_DELAY);
                     }
                     else break;
                  }
               } // -- end while retry ---
               if(!closeorder) OrderCloseError(OrderTicket(),"close");
            }
         }     
      }
   }
}

void PartialClose(int magic, double lot) {
   if(CountPosition(magic)>0) {
      string msg1 = "Partial Order #";
      string msg2 = " closed. Order ticket change";
      double originallot = OrderProperty_OrderLot(magic);
      if(lot>0) {
         if(lot>=originallot) {
            lot = originallot;
            msg1 = "Order #";
            msg2 = " closed";
         }
         for(int order = OrdersTotal()-1; order >= 0; order--){
            bool select = OrderSelect(order,SELECT_BY_POS);
            if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2){
               bool proceed = true;     
               if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
               else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
               if(proceed) {
                  int retry = 0;
                  bool closeorder = false;
                  while(retry <= MAX_RETRIES) {
                     TickData(); // Updating Latest Tick Data
                     double ClosePrice = Bid;
                     if(OrderType()==OP_SELL) ClosePrice = Ask;
                     closeorder = OrderClose(OrderTicket(),lot,ClosePrice,Acc_Slippage,clrRed);
                     if(closeorder) {
                        Print(msg1, OrderTicket(),msg2);
                        break;
                     }
                     else {
                        bool RetryOnServerError = ServerError(_LastError);
                        if(RetryOnServerError) {
                           retry++;
                           Print("Server error detected, retrying...");
                           Sleep(RETRY_DELAY);
                        }
                        else break;
                     }
                  } // end while retry loop
                  if(!closeorder) OrderCloseError(OrderTicket(),"partial close");
               }
            }     
         }
      }
   }
}

void HiddenSL(int magic, int SLPoint){
   bool     ChkCondition   = false;
   double   bufferSL       = NumToPoint(SLPoint);
   double   stopLoss;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && SLPoint!=0){
         RefreshRates();
         double ClosingBuy = Bid;
         double ClosingSell = Ask;
         if(!VariableSpreadFilter()){
            ClosingBuy = Ask;
            ClosingSell = Bid;
         }
         
         if(OrderType()==OP_BUY) {
            stopLoss    = OrderOpenPrice() - bufferSL;
            if(ClosingBuy<=stopLoss) ChkCondition = true;
         }
         else if(OrderType()==OP_SELL){
            stopLoss    = OrderOpenPrice() + bufferSL;
            if(ClosingSell>=stopLoss) ChkCondition = true;
         }
         
         if(ChkCondition) CloseOrder(magic);
      }
   }
}

void BreakEven(int Magic, int Distance, int Lock=10){
   double TrailingLevel,LockBE;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
         
      if(select && OrderMagicNumber()==Magic && OrderSymbol()==_Symbol && OrderType()<2 && Distance>0){         
         if(OrderType() == OP_SELL){
            TrailingLevel = OrderOpenPrice() - NumToPoint(Distance);
            LockBE = OrderOpenPrice() - NumToPoint(Lock);
         
            if(Ask<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) ModifyStopLoss(Magic,LockBE);
         }
      
         else if(OrderType() == OP_BUY){
            TrailingLevel = OrderOpenPrice() + NumToPoint(Distance);
            LockBE = OrderOpenPrice() + NumToPoint(Lock);
         
            if(Bid>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) ModifyStopLoss(Magic,LockBE);
         }
      } 
   } 
}

void TrailingStop(int Magic, int Distance, int Step=10){
   double TrailingLevel = 0,
          StepLevel     = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
         
      if(select && OrderMagicNumber()==Magic && OrderSymbol()==_Symbol && OrderType()<2 && OrderStopLoss()>0 && Distance>0){
         RefreshRates();
         if(OrderType() == OP_SELL && OrderStopLoss()<=OrderOpenPrice()){
            TrailingLevel = OrderStopLoss() - NumToPoint(Distance);
            StepLevel     = OrderStopLoss() - NumToPoint(Step);
         
            if(Ask<=TrailingLevel) ModifyStopLoss(Magic,StepLevel);
         }
      
         else if(OrderType() == OP_BUY && OrderStopLoss()>=OrderOpenPrice()){
            TrailingLevel = OrderStopLoss() + NumToPoint(Distance);
            StepLevel     = OrderStopLoss() + NumToPoint(Step);
         
            if(Bid>=TrailingLevel) ModifyStopLoss(Magic,StepLevel);
         }
      } 
   } 
}

datetime GrailTime(int pYear = 0, int pMonth = 0, int pDay = 0, int pHour = 0, int pMinute = 0, int pSec = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   
   timeStruct.year   = pYear;    // Year
   timeStruct.mon    = pMonth;   // Month
   timeStruct.day    = pDay;     // Day
   timeStruct.hour   = pHour;    // Hour
   timeStruct.min    = pMinute;  // Minutes
   timeStruct.sec    = pSec;     // Sec

   return StructToTime(timeStruct);
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

string OrderProperty_OrderSymbol(int magic){
   string x = "";
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic) x = OrderSymbol();  
   }
   return x;
}

double OrderProperty_OrderOpenPrice(int magic){
   double ChkLevel = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) ChkLevel = OrderOpenPrice();  
   }
   
   return ChkLevel;
}

double OrderProperty_OrderLot(int magic){
   double lot = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) lot = OrderLots();  
   }
   return lot;
}

datetime OrderProperty_OrderOpenTime(int magic)
{
   datetime time = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) time = OrderOpenTime();  
   }
   
   return time;
}

int OrderProperty_OrderType(int Magic){   
   int type = 100;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == Magic && OrderSymbol()==_Symbol) type = OrderType();
   }
   return type;
}

double OrderProperty_OrderStopLoss(int magic){
   double ChkLevel = 0;
   
   for(int order = 0; order <= OrdersTotal() - 1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) ChkLevel = OrderStopLoss();  
   }
   
   return ChkLevel;
}

double OrderProperty_FloatingStatus(){
   double PnL = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderType()<2) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

void MagicNum(int identifier, int& Mag1, int& Mag2, int& Mag3, int& Mag4, int& Mag5, int& Mag6, int& Mag7, int& Mag8, int& Mag9, int& Mag10,
              int& Mag11,int& Mag12, int& Mag13, int& Mag14, int& Mag15, int& Mag16, int& Mag17, int& Mag18, int& Mag19, int& Mag20){
   int x = Identifier(identifier);
   Mag1 = x + 1;
   Mag2 = x + 2;
   Mag3 = x + 3;
   Mag4 = x + 4;
   Mag5 = x + 5;
   Mag6 = x + 6;
   Mag7 = x + 7;
   Mag8 = x + 8;
   Mag9 = x + 9;
   Mag10 = x + 10;
   Mag11 = x + 11;
   Mag12 = x + 12;
   Mag13 = x + 13;
   Mag14 = x + 14;
   Mag15 = x + 15;
   Mag16 = x + 16;
   Mag17 = x + 17;
   Mag18 = x + 18;
   Mag19 = x + 19;
   Mag20 = x + 20;
}

int Identifier(int identifier){
   int x = 50;
   string sym = Market_Symbol;
   
   if(sym=="EURUSD") x = 1;
   else if(sym=="GBPUSD") x = 2;
   else if(sym=="GBPJPY") x = 3;
   else if(sym=="GBPAUD") x = 4;
   else if(sym=="GBPNZD") x = 5;
   else if(sym=="GBPCHF") x = 6;
   else if(sym=="GBPCAD") x = 7;
   return x * identifier;
}

bool ServerError(int pErrorCode){
   switch(pErrorCode) {
		case ERR_BROKER_BUSY:
		case ERR_COMMON_ERROR:
		case ERR_NO_ERROR:
		case ERR_NO_CONNECTION:
		case ERR_NO_RESULT:
		case ERR_SERVER_BUSY:
		case ERR_NOT_ENOUGH_RIGHTS:
      case ERR_MALFUNCTIONAL_TRADE:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_TRADE_TIMEOUT:
      case ERR_REQUOTE:
      case ERR_TOO_MANY_REQUESTS:
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_TOO_FREQUENT_REQUESTS:
		return(true);
	}
	return(false);
}

int VariableIdentifier() {
   int year = TimeYear(TimeCurrent());
   int week = StdWeek();
   return week*year;
}

bool MarginLevelProcced(int margin){
   bool proceed = false;
   if(Acc_MarginLevel==0 || Acc_MarginLevel>=margin) proceed = true;
   return proceed;
}

double CurrentOrderLot(int direction) {
   double x = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==direction) x += OrderLots();  
   }
   return x;
}

double PointMovement() {
   double buy = CurrentOrderLot(OP_BUY);
   double sell = CurrentOrderLot(OP_SELL);
   double v = fabs(buy-sell);
   string y = StringLot(v);
   return StringToDouble(y)*Market_TickSize;
}

void TriggerMaxEquity() {
   if(UseLimitEquity && MaxEquity>=500) {
      int buffer = 300;
      double equitytrigger = PointMovement()*10;
      
      if(MaxEquity<=5000) buffer = 100;
      else if(MaxEquity<=30000) buffer = 200;
      
      double limitEquity = MaxEquity-buffer-equitytrigger;
      double balancelimit = MaxEquity*0.9;
      bool alertwithdraw = Acc_Equity>=balancelimit || Acc_Balance>=balancelimit;
      if(Acc_Equity>=limitEquity) {
         CloseOrder(MagicS_1);
         CloseOrder(MagicE_1);
         CloseOrder(MagicB_1);
      }
      if(alertwithdraw && FirstTick(PERIOD_M5)) {
         WithdrawText();
         if(CountExistingPosition()==0) {
            ScreenShot("Darkpool_Withdraw");
            ExpertRemove();
         }
      }
   }
}

bool BalanceControl() {
   bool x = true;
   if(UseLimitEquity) {
      double balancelimit = MaxEquity*0.9;
      if(Acc_Balance>=balancelimit) x = false;
   }
   return x;
}

void WithdrawText(){
   string acc = " (Real)";
   if(IsDemo()) acc = " (Demo)";
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Withdraw Alert!",
                                             NewLine,"Broker : ",sInput,
                                             NewLine,"Acc No : ",sInput,sInput,
                                             NewLine,"Acc Balance : ",sInput
                                           );
      
   string msg = StringFormat(output_string,Acc_Broker,IntegerToString(Acc_Login),acc,StringDollar(Acc_Balance));
   NotifySetting(msg);
}

void ChartSetting(bool setcolor = true){
   ChartSetInteger(0,CHART_MODE,1);
   ChartSetInteger(0,CHART_SCALE,3);
   ChartSetInteger(0,CHART_AUTOSCROLL,0,true);
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,0,false);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,true);
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   ChartSetInteger(0,CHART_SHIFT,0,true);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,0,false);
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,0,false);
   if(setcolor){
      ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'19,23,34');
      ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrLightSlateGray);
      ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrWhiteSmoke);
      ChartSetInteger(0,CHART_COLOR_CHART_UP,C'102,184,149');
      ChartSetInteger(0,CHART_COLOR_CHART_DOWN,C'214,87,95');
   
      ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,C'102,184,149');
      ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,C'214,87,95');
      ChartSetInteger(0,CHART_COLOR_VOLUME,C'37,44,63');
      ChartSetInteger(0,CHART_COLOR_BID,C'37,44,63');
      ChartSetInteger(0,CHART_COLOR_ASK,C'214,87,95');
   }
}

bool VerifyHistory(string symbol) {
   bool x = true;
   datetime times[];
   ResetLastError();
   ArrayCopySeries(times,MODE_TIME,symbol,PERIOD_M1);
   if(_LastError==ERR_HISTORY_WILL_UPDATED || _LastError==ERR_NO_HISTORY_DATA) x = false; // Error ERR_HISTORY_WILL_UPDATED
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

void RangePeriod(ENUM_TIMEFRAMES timeframe, int range, int startbar, double& pricehigh, double& pricelow){
   int shiftHighest = iHighest(_Symbol,timeframe,MODE_HIGH,range,startbar);
   int shiftLowest = iLowest(_Symbol,timeframe,MODE_LOW,range,startbar);
   pricehigh = iHigh(_Symbol,timeframe,shiftHighest);
   pricelow = iLow(_Symbol,timeframe,shiftLowest);
}

double PerformanceClosed_Daily(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(4*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeDay(OrderCloseTime())==Day() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double PerformanceClosed_Monthly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(32*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeMonth(OrderCloseTime())==Month() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

double PerformanceClosed_Weekly(){
   double PnL = 0;
   datetime HistoryRange = TimeCurrent()-(14*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && ChkWeek(OrderCloseTime())==StdWeek() && OrderType()<2 && OrderCloseTime()>=HistoryRange) {
         PnL += OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   return NormDollar(PnL);
}

int StdWeek(){
   int iDay  = (DayOfWeek() + 6 ) % 7 + 1;        // convert day to standard index (1=Mon,...,7=Sun)
   int iWeek = (DayOfYear() - iDay + 10 ) / 7;    // calculate standard week number
   return iWeek;
}

int ChkWeek(datetime time){
   int iDay  = ( TimeDayOfWeek(time) + 6 ) % 7 + 1;      // convert day to standard index (1=Mon,...,7=Sun)
   int iWeek = ( TimeDayOfYear(time) - iDay + 10 ) / 7;  // calculate standard week number
   return iWeek;
}

int TickCount(ENUM_TIMEFRAMES timeframe) {
   static int TickCount = 0;
   static datetime BarTime = 0; 
   datetime timechk = iTime(_Symbol,timeframe,0);
   
   if(timechk!=BarTime) { 
      TickCount = 0; 
      BarTime= timechk;
   } else TickCount++;
   return TickCount;
}

bool FirstTick(ENUM_TIMEFRAMES timeframe) {
   return TickCount(timeframe)==1;
}

bool BetweenTimeRange(datetime timeStart, datetime timeEnd) {
   datetime compare = TimeCurrent();
   return compare>=timeStart && compare<timeEnd;
}

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}

void SentStatus(int hour, int minutes, double report1, double report2, double report3) {
   string NewLine = "\n", sInput  = "%s";
   datetime time1 = HourMin(hour,minutes);
   datetime time2 = HourMin(hour,minutes+1);
   
   if(BetweenTimeRange(time1,time2) && FirstTick(PERIOD_M1)) {
      string floating = "No Order";
      string acc = " (Real)";
      if(IsDemo()) acc = " (Demo)";
      if(Acc_MarginLevel>0) floating = StringConcatenate(StringDollar(OrderProperty_FloatingStatus()),NewLine,"Margin Level : ",IntegerProper(Acc_MarginLevel),NewLine,"Drawdown : ",Drawdown());
      
      string output_string = StringConcatenate("Broker : ",sInput,
                                                NewLine,"Acc Number : ",sInput,sInput,
                                                NewLine,"Acc Balance : ",sInput,
                                                NewLine,"PnL Today : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Weekly : ",sInput,"  (",sInput,")",
                                                NewLine,"PnL Monthly : ",sInput,"  (",sInput,")",
                                                NewLine,"Orders Status : ",sInput
                                              );
                           
      string msg = StringFormat( output_string,
                                 Acc_Broker,
                                 IntegerToString(Acc_Login),acc,
                                 StringDollar(Acc_Balance),
                                 StringDollar(report1),ReturnPercent(report1),
                                 StringDollar(report2),ReturnPercent(report2),
                                 StringDollar(report3),ReturnPercent(report3),
                                 floating
                               );
      Print(msg);
      SendNotification(msg);
   }
}

string TimeStamp() {
   datetime Now = iTime(_Symbol,PERIOD_M1,0);
   int year = TimeYear(Now);
   int month = TimeMonth(Now);
   int day = TimeDay(Now);
   int hour = TimeHour(Now);
   int min = TimeMinute(Now);
   return StringConcatenate(year,ProperDigit(month),ProperDigit(day),ProperDigit(hour),ProperDigit(min));
}

string ProperDigit(int value) {
   string ret = IntegerToString(value);
   if(value<10) ret = StringConcatenate("0",value);
   return ret;
}

string DirectoryMonthYear(datetime time) {
   int month = TimeMonth(time);
   int year = TimeYear(time);
   
   string x = "";
   switch(month){      
      case 1:  x = "JAN"; break;
      case 2:  x = "FEB"; break;
      case 3:  x = "MAR"; break;
      case 4:  x = "APR"; break;
      case 5:  x = "MAY"; break;
      case 6:  x = "JUN"; break;
      case 7:  x = "JUL"; break;
      case 8:  x = "AUG"; break;
      case 9:  x = "SEP"; break;
      case 10: x = "OCT"; break;
      case 11: x = "NOV"; break;
      default: x = "DEC";
   }
   return x+"-"+string(year);
}

void ScreenShot(string directory = "TradeScreenshot") {
   if(!IsTesting()) {
      int width = int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));   // Chart's width
      int heigh = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear(TimeCurrent())+"/"+Market_Symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string pairscreen = Market_Symbol+"_"+ChartTimeframe()+"_"+TimeStamp()+".gif";
      string ScreenShotName = FolderDirectory+pairscreen;
   
      //Making ScreenShot
      if(!WindowScreenShot(ScreenShotName,width,heigh)) Alert(GetLastError());
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}