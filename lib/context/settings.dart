import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fusage/extra/enums.dart';

class SettingDataType {
  late SummaryTimeRangeEnum summaryTimeRange = SummaryTimeRangeEnum.total;
  late MetricTypeEnum metricType = MetricTypeEnum.metric;
  late String currencyType = 'EUR';

  static SettingDataType init(
      MetricTypeEnum type, String currency, SummaryTimeRangeEnum timeRange) {
    SettingDataType data = SettingDataType();

    data.metricType = type;
    data.currencyType = currency;
    data.summaryTimeRange = timeRange;

    return data;
  }
}

class SettingsProvider extends ChangeNotifier {
  SummaryTimeRangeEnum summaryTimeRange = SummaryTimeRangeEnum.total;
  MetricTypeEnum metricType = MetricTypeEnum.metric;
  String currencyType = 'EUR';

  void updateSummaryRangeTime(SummaryTimeRangeEnum newRange) {
    summaryTimeRange = newRange;

    notifyListeners();
    saveToFile();
  }

  void updateMetricts(MetricTypeEnum newMetricType) {
    metricType = newMetricType;

    notifyListeners();
    saveToFile();
  }

  void updateCurrency(String newCurrency) {
    currencyType = newCurrency;

    notifyListeners();
    saveToFile();
  }

  void saveToFile() async {
    final prefs = await SharedPreferences.getInstance();

    var json = {
      'summaryRangeTime':
          EnumConverter.summaryRangeEnumToString(summaryTimeRange),
      'metricType':
          metricType == MetricTypeEnum.imperial ? 'Imperial' : 'Metric',
      'currencyType': currencyType
    };

    var jsonText = jsonEncode(json);
    await prefs.setString('settingsData', jsonText);
  }

  void updateSettings(var jsonObject) {
    var settingsData = jsonObject['settings'];

    if (settingsData != null) {
      currencyType = settingsData['currencyType'];
      metricType =
          EnumConverter.stringToMetricTypeEnum(settingsData['metricType']);
      summaryTimeRange = EnumConverter.stringToSummaryRangeEnum(
          settingsData['summaryTimeRange']);

      saveToFile();
    }
  }

  static Future<SettingDataType> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('settingsData');
    SettingDataType settingsData = SettingDataType();

    if (data != null) {
      var jsonObject = jsonDecode(data);

      settingsData.summaryTimeRange = EnumConverter.stringToSummaryRangeEnum(
          jsonObject['summaryRangeTime']);
      settingsData.metricType =
          EnumConverter.stringToMetricTypeEnum(jsonObject['metricType']);
      settingsData.currencyType = jsonObject['currencyType'];
    }

    return settingsData;
  }

  void updateProviderData(SettingDataType newVehiclesList) {
    summaryTimeRange = newVehiclesList.summaryTimeRange;
    metricType = newVehiclesList.metricType;
    currencyType = newVehiclesList.currencyType;
  }

  SettingDataType getSettingsData() {
    return SettingDataType.init(metricType, currencyType, summaryTimeRange);
  }
}
