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
INPUT int Gator_Period_Jaw = 6;                                     // Jaw Period
INPUT int Gator_Period_Teeth = 10;                                  // Teeth Period
INPUT int Gator_Period_Lips = 8;                                    // Lips Period
INPUT int Gator_Shift_Jaw = 5;                                      // Jaw Shift
INPUT int Gator_Shift_Teeth = 7;                                    // Teeth Shift
INPUT int Gator_Shift_Lips = 5;                                     // Lips Shift
INPUT ENUM_MA_METHOD Gator_MA_Method = 2;                           // MA Method
INPUT ENUM_APPLIED_PRICE Gator_Applied_Price = 3;                   // Applied Price
INPUT int Gator_Shift = 2;                                          // Shift
INPUT int Gator_SignalOpenMethod = 0;                               // Signal open method (0-
INPUT double Gator_SignalOpenLevel = 0.00000000;                    // Signal open level
INPUT int Gator_SignalOpenFilterMethod = 0.00000000;                // Signal open filter method
INPUT int Gator_SignalOpenBoostMethod = 0.00000000;                 // Signal open boost method
INPUT int Gator_SignalCloseMethod = 0;                              // Signal close method (0-
INPUT double Gator_SignalCloseLevel = 0.00000000;                   // Signal close level
INPUT int Gator_PriceLimitMethod = 0;                               // Price limit method
INPUT double Gator_PriceLimitLevel = 0;                             // Price limit level
INPUT double Gator_MaxSpread = 6.0;                                 // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_Gator_Params : StgParams {
  int Gator_Period_Jaw;
  int Gator_Period_Teeth;
  int Gator_Period_Lips;
  int Gator_Shift_Jaw;
  int Gator_Shift_Teeth;
  int Gator_Shift_Lips;
  ENUM_MA_METHOD Gator_MA_Method;
  ENUM_APPLIED_PRICE Gator_Applied_Price;
  int Gator_Shift;
  int Gator_SignalOpenMethod;
  double Gator_SignalOpenLevel;
  int Gator_SignalOpenFilterMethod;
  int Gator_SignalOpenBoostMethod;
  int Gator_SignalCloseMethod;
  double Gator_SignalCloseLevel;
  int Gator_PriceLimitMethod;
  double Gator_PriceLimitLevel;
  double Gator_MaxSpread;

  // Constructor: Set default param values.
  Stg_Gator_Params()
      : Gator_Period_Jaw(::Gator_Period_Jaw),
        Gator_Period_Teeth(::Gator_Period_Teeth),
        Gator_Period_Lips(::Gator_Period_Lips),
        Gator_Shift_Jaw(::Gator_Shift_Jaw),
        Gator_Shift_Teeth(::Gator_Shift_Teeth),
        Gator_Shift_Lips(::Gator_Shift_Lips),
        Gator_MA_Method(::Gator_MA_Method),
        Gator_Applied_Price(::Gator_Applied_Price),
        Gator_Shift(::Gator_Shift),
        Gator_SignalOpenMethod(::Gator_SignalOpenMethod),
        Gator_SignalOpenLevel(::Gator_SignalOpenLevel),
        Gator_SignalOpenFilterMethod(::Gator_SignalOpenFilterMethod),
        Gator_SignalOpenBoostMethod(::Gator_SignalOpenBoostMethod),
        Gator_SignalCloseMethod(::Gator_SignalCloseMethod),
        Gator_SignalCloseLevel(::Gator_SignalCloseLevel),
        Gator_PriceLimitMethod(::Gator_PriceLimitMethod),
        Gator_PriceLimitLevel(::Gator_PriceLimitLevel),
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
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_Gator_Params>(_params, _tf, stg_gator_m1, stg_gator_m5, stg_gator_m15, stg_gator_m30,
                                      stg_gator_h1, stg_gator_h4, stg_gator_h4);
    }
    // Initialize strategy parameters.
    GatorParams gator_params(_params.Gator_Period_Jaw, _params.Gator_Period_Teeth, _params.Gator_Period_Lips,
                              _params.Gator_Shift_Jaw, _params.Gator_Shift_Teeth, _params.Gator_Shift_Lips,
                              _params.Gator_MA_Method, _params.Gator_Applied_Price);
    gator_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Gator(gator_params), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Gator_SignalOpenMethod, _params.Gator_SignalOpenLevel, _params.Gator_SignalCloseMethod,
                       _params.Gator_SignalOpenFilterMethod, _params.Gator_SignalOpenBoostMethod,
                       _params.Gator_SignalCloseLevel);
    sparams.SetMaxSpread(_params.Gator_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Gator(sparams, "Gator");
    return _strat;
  }

  /**
   * Check if Gator Oscillator is on buy or sell.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR].value[LINE_LOWER_HISTOGRAM] < _indi[PREV].value[LINE_LOWER_HISTOGRAM];
          if (METHOD(_method, 0)) _result &= _indi[PREV].value[LINE_LOWER_HISTOGRAM] < _indi[PPREV].value[LINE_LOWER_HISTOGRAM]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 1)) _result &= _indi[PPREV].value[LINE_LOWER_HISTOGRAM] < _indi[3].value[LINE_LOWER_HISTOGRAM]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 2)) _result &= _indi[3].value[LINE_LOWER_HISTOGRAM] < _indi[4].value[LINE_LOWER_HISTOGRAM]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 3)) _result &= _indi[PREV].value[LINE_LOWER_HISTOGRAM] > _indi[PPREV].value[LINE_LOWER_HISTOGRAM]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 4)) _result &= _indi[PPREV].value[LINE_LOWER_HISTOGRAM] > _indi[3].value[LINE_LOWER_HISTOGRAM]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 5)) _result &= _indi[3].value[LINE_LOWER_HISTOGRAM] < _indi[4].value[LINE_LOWER_HISTOGRAM]; // ... 4 consecutive columns are green.
          if (METHOD(_method, 6)) _result &= _indi[PREV].value[LINE_UPPER_HISTOGRAM] < _indi[PPREV].value[LINE_UPPER_HISTOGRAM]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 7)) _result &= _indi[PPREV].value[LINE_UPPER_HISTOGRAM] < _indi[3].value[LINE_UPPER_HISTOGRAM]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 8)) _result &= _indi[3].value[LINE_UPPER_HISTOGRAM] < _indi[4].value[LINE_UPPER_HISTOGRAM]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 9)) _result &= _indi[PREV].value[LINE_UPPER_HISTOGRAM] > _indi[PPREV].value[LINE_UPPER_HISTOGRAM]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 10)) _result &= _indi[PPREV].value[LINE_UPPER_HISTOGRAM] > _indi[3].value[LINE_UPPER_HISTOGRAM]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 11)) _result &= _indi[3].value[LINE_UPPER_HISTOGRAM] < _indi[4].value[LINE_UPPER_HISTOGRAM]; // ... 4 consecutive columns are green.
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR].value[LINE_UPPER_HISTOGRAM] > _indi[PREV].value[LINE_UPPER_HISTOGRAM];
          if (METHOD(_method, 0)) _result &= _indi[PREV].value[LINE_LOWER_HISTOGRAM] < _indi[PPREV].value[LINE_LOWER_HISTOGRAM]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 1)) _result &= _indi[PPREV].value[LINE_LOWER_HISTOGRAM] < _indi[3].value[LINE_LOWER_HISTOGRAM]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 2)) _result &= _indi[3].value[LINE_LOWER_HISTOGRAM] < _indi[4].value[LINE_LOWER_HISTOGRAM]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 3)) _result &= _indi[PREV].value[LINE_LOWER_HISTOGRAM] > _indi[PPREV].value[LINE_LOWER_HISTOGRAM]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 4)) _result &= _indi[PPREV].value[LINE_LOWER_HISTOGRAM] > _indi[3].value[LINE_LOWER_HISTOGRAM]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 5)) _result &= _indi[3].value[LINE_LOWER_HISTOGRAM] < _indi[4].value[LINE_LOWER_HISTOGRAM]; // ... 4 consecutive columns are green.
          if (METHOD(_method, 6)) _result &= _indi[PREV].value[LINE_UPPER_HISTOGRAM] < _indi[PPREV].value[LINE_UPPER_HISTOGRAM]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 7)) _result &= _indi[PPREV].value[LINE_UPPER_HISTOGRAM] < _indi[3].value[LINE_UPPER_HISTOGRAM]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 8)) _result &= _indi[3].value[LINE_UPPER_HISTOGRAM] < _indi[4].value[LINE_UPPER_HISTOGRAM]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 9)) _result &= _indi[PREV].value[LINE_UPPER_HISTOGRAM] > _indi[PPREV].value[LINE_UPPER_HISTOGRAM]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 10)) _result &= _indi[PPREV].value[LINE_UPPER_HISTOGRAM] > _indi[3].value[LINE_UPPER_HISTOGRAM]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 11)) _result &= _indi[3].value[LINE_UPPER_HISTOGRAM] < _indi[4].value[LINE_UPPER_HISTOGRAM]; // ... 4 consecutive columns are green.
          break;
      }
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0:
        // @todo: GH-160
        //_indi.GetPeak()
        break;
    }
    return _result;
  }
};