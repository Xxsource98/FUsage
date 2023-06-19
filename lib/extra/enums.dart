enum VehicleFuelTypeEnum { none, gasoline, diesel, lpg }

enum RouteTypeEnum { none, city, highway, combined }

enum SummaryTimeRangeEnum { total, month, lastMonth, week, lastWeek }

enum MetricTypeEnum { metric, imperial }

class EnumConverter {
  // Price
  static String currencyTypeToFullString(
      String valueKey, Map<String, String> currencies) {
    // Return full currency string (short and full name)
    // ex. 'EUR' to 'EUR (Euro)'

    if (currencies.containsKey(valueKey)) {
      String? fullName = currencies[valueKey];

      return '$valueKey ($fullName)';
    }

    return 'Error';
  }

  // Vehicle Fuel Type
  static VehicleFuelTypeEnum stringToVehicleFuelEnum(String value) {
    switch (value) {
      case 'Diesel':
        return VehicleFuelTypeEnum.diesel;
      case 'LPG':
        return VehicleFuelTypeEnum.lpg;

      default:
        return VehicleFuelTypeEnum.gasoline;
    }
  }

  static String vehicleFuelEnumToString(
      VehicleFuelTypeEnum value, bool alternativeNames) {
    switch (value) {
      case VehicleFuelTypeEnum.diesel:
        return 'Diesel'; // ON
      case VehicleFuelTypeEnum.lpg:
        return 'LPG';

      default:
        return alternativeNames ? 'Gas' : 'Gasoline'; // Pb
    }
  }

  // Route Type
  static RouteTypeEnum stringToRouteTypeEnum(String value) {
    switch (value) {
      case 'City':
        return RouteTypeEnum.city;
      case 'Highway':
        return RouteTypeEnum.highway;
      case 'Combined':
        return RouteTypeEnum.combined;

      default:
        return RouteTypeEnum.none;
    }
  }

  static String routeTypeEnumToString(RouteTypeEnum value) {
    switch (value) {
      case RouteTypeEnum.city:
        return 'City';
      case RouteTypeEnum.highway:
        return 'Highway';
      case RouteTypeEnum.combined:
        return 'Combined';

      default:
        return 'None';
    }
  }

  // Summary Time Range
  static SummaryTimeRangeEnum stringToSummaryRangeEnum(String value) {
    switch (value) {
      case 'Month':
        return SummaryTimeRangeEnum.month;
      case 'Last Month':
        return SummaryTimeRangeEnum.lastMonth;
      case 'Week':
        return SummaryTimeRangeEnum.week;
      case 'Last Week':
        return SummaryTimeRangeEnum.lastWeek;

      default:
        return SummaryTimeRangeEnum.total;
    }
  }

  static String summaryRangeEnumToString(SummaryTimeRangeEnum value) {
    switch (value) {
      case SummaryTimeRangeEnum.month:
        return 'Month';
      case SummaryTimeRangeEnum.lastMonth:
        return 'Last Month';
      case SummaryTimeRangeEnum.week:
        return 'Week';
      case SummaryTimeRangeEnum.lastWeek:
        return 'Last Week';

      default:
        return 'Total';
    }
  }

  // Metric Type
  static MetricTypeEnum stringToMetricTypeEnum(String value) {
    switch (value) {
      case 'Metric':
        return MetricTypeEnum.metric;
      case 'Imperial':
        return MetricTypeEnum.imperial;

      default:
        return MetricTypeEnum.metric;
    }
  }

  static String metricTypeEnumToString(MetricTypeEnum value) {
    switch (value) {
      case MetricTypeEnum.metric:
        return 'Metric';
      case MetricTypeEnum.imperial:
        return 'Imperial';

      default:
        return 'Metric';
    }
  }

  static bool isMetricTypeEnum(
      {String? stringValue, MetricTypeEnum? enumValue}) {
    if (stringValue != null) {
      return stringValue == 'Metric';
    }

    if (enumValue != null) {
      return enumValue == MetricTypeEnum.metric;
    }

    return false;
  }
}
