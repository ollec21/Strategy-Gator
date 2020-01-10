//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements Gator strategy based on the Gator oscillator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_Gator.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __Gator_Parameters__ = "-- Gator strategy params --";  // >>> GATOR <<<
INPUT int Gator_Active_Tf = 0;             // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int Gator_Period_Jaw = 6;            // Jaw Period
INPUT int Gator_Period_Teeth = 10;         // Teeth Period
INPUT int Gator_Period_Lips = 8;           // Lips Period
INPUT int Gator_Shift_Jaw = 5;             // Jaw Shift
INPUT int Gator_Shift_Teeth = 7;           // Teeth Shift
INPUT int Gator_Shift_Lips = 5;            // Lips Shift
INPUT ENUM_MA_METHOD Gator_MA_Method = 2;  // MA Method
INPUT ENUM_APPLIED_PRICE Gator_Applied_Price = 3;                  // Applied Price
INPUT int Gator_Shift = 2;                                         // Shift
INPUT ENUM_TRAIL_TYPE Gator_TrailingStopMethod = 22;               // Trail stop method
INPUT ENUM_TRAIL_TYPE Gator_TrailingProfitMethod = 1;              // Trail profit method
INPUT double Gator_SignalOpenLevel = 0.00000000;                   // Signal open level
INPUT int Gator1_SignalBaseMethod = 0;                             // Signal base method (0-
INPUT int Gator1_OpenCondition1 = 0;                               // Open condition 1 (0-1023)
INPUT int Gator1_OpenCondition2 = 0;                               // Open condition 2 (0-)
INPUT ENUM_MARKET_EVENT Gator1_CloseCondition = C_GATOR_BUY_SELL;  // Close condition // Close condition for M1
INPUT double Gator_MaxSpread = 6.0;                                // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_Gator_Params : Stg_Params {
  unsigned int Gator_Period;
  ENUM_APPLIED_PRICE Gator_Applied_Price;
  int Gator_Shift;
  ENUM_TRAIL_TYPE Gator_TrailingStopMethod;
  ENUM_TRAIL_TYPE Gator_TrailingProfitMethod;
  double Gator_SignalOpenLevel;
  long Gator_SignalBaseMethod;
  long Gator_SignalOpenMethod1;
  long Gator_SignalOpenMethod2;
  double Gator_SignalCloseLevel;
  ENUM_MARKET_EVENT Gator_SignalCloseMethod1;
  ENUM_MARKET_EVENT Gator_SignalCloseMethod2;
  double Gator_MaxSpread;

  // Constructor: Set default param values.
  Stg_Gator_Params()
      : Gator_Period(::Gator_Period),
        Gator_Applied_Price(::Gator_Applied_Price),
        Gator_Shift(::Gator_Shift),
        Gator_TrailingStopMethod(::Gator_TrailingStopMethod),
        Gator_TrailingProfitMethod(::Gator_TrailingProfitMethod),
        Gator_SignalOpenLevel(::Gator_SignalOpenLevel),
        Gator_SignalBaseMethod(::Gator_SignalBaseMethod),
        Gator_SignalOpenMethod1(::Gator_SignalOpenMethod1),
        Gator_SignalOpenMethod2(::Gator_SignalOpenMethod2),
        Gator_SignalCloseLevel(::Gator_SignalCloseLevel),
        Gator_SignalCloseMethod1(::Gator_SignalCloseMethod1),
        Gator_SignalCloseMethod2(::Gator_SignalCloseMethod2),
        Gator_MaxSpread(::Gator_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Gator : public Strategy {
 public:
  Stg_Gator(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Gator *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_Gator_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_Gator_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_Gator_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_Gator_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_Gator_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_Gator_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_Gator_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    Gator_Params adx_params(_params.Gator_Period, _params.Gator_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_Gator);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Gator(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Gator_SignalBaseMethod, _params.Gator_SignalOpenMethod1, _params.Gator_SignalOpenMethod2,
                       _params.Gator_SignalCloseMethod1, _params.Gator_SignalCloseMethod2,
                       _params.Gator_SignalOpenLevel, _params.Gator_SignalCloseLevel);
    sparams.SetStops(_params.Gator_TrailingProfitMethod, _params.Gator_TrailingStopMethod);
    sparams.SetMaxSpread(_params.Gator_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Gator(sparams, "Gator");
    return _strat;
  }

  /**
   * Check if Gator Oscillator is on buy or sell.
   *
   * Note: It doesn't give independent signals. Is used for Alligator correction.
   * Principle: trend must be strengthened. Together with this Gator Oscillator goes up.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double gator_0_jaw = ((Indi_Gator *)this.Data()).GetValue(LINE_JAW, 0);
    double gator_0_teeth = ((Indi_Gator *)this.Data()).GetValue(LINE_TEETH, 0);
    double gator_0_lips = ((Indi_Gator *)this.Data()).GetValue(LINE_LIPS, 0);
    double gator_1_jaw = ((Indi_Gator *)this.Data()).GetValue(LINE_JAW, 1);
    double gator_1_teeth = ((Indi_Gator *)this.Data()).GetValue(LINE_TEETH, 1);
    double gator_1_lips = ((Indi_Gator *)this.Data()).GetValue(LINE_LIPS, 1);
    double gator_2_jaw = ((Indi_Gator *)this.Data()).GetValue(LINE_JAW, 2);
    double gator_2_teeth = ((Indi_Gator *)this.Data()).GetValue(LINE_TEETH, 2);
    double gator_2_lips = ((Indi_Gator *)this.Data()).GetValue(LINE_LIPS, 2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    double gap = _signal_level1 * pip_size;
    switch (_cmd) {
      /*
        //4. Gator Oscillator
        //Lower part of diagram is taken for calculations. Growth is checked on 4 periods.
        //The flag is 1 of trend is strengthened, 0 - no strengthening, -1 - never.
        //Uses part of Alligator's variables
        if
        (iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,3)>iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,2)
        &&iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,2)>iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,1)
        &&iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,1)>iGator(NULL,piga,jaw_tf,jaw_shift,teeth_tf,teeth_shift,lips_tf,lips_shift,MODE_SMMA,PRICE_MEDIAN,LOWER,0))
        {f4=1;}
      */
      case ORDER_TYPE_BUY:
        break;
      case ORDER_TYPE_SELL:
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
