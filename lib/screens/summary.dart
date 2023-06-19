import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/extra/load_file_data.dart';
import 'package:fusage/components/page_template.dart';
import 'package:fusage/components/widgets/summary_widget.dart';

import 'package:fusage/extra/enums.dart';

class SummaryPage extends PageTemplateBase {
  final MainAppData appData;

  SummaryPage({Key? key, required this.appData})
      : super(
            pageTitle: 'Summary',
            navigationData: NavigationData(
                navigationIcon: Icons.home, navigationLabel: 'Summary'),
            key: key);

  @override
  SummaryPageState createState() => SummaryPageState();
}

class SummaryPageState extends PageTemplate<SummaryPage> {
  double averageUsage = 0.0;
  double totalDistance = 0.0;
  double totalLiters = 0.0;
  double averageCosts = 0.0;
  int averageTankTime = 0;
  int totalTanks = 0;
  int totalCars = 0;

  @override
  FloatingActionButton? floatingButton(BuildContext context) => null;

  @override
  void initState() {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (vehProvider.firstTimeInit) {
      vehProvider.updateProviderData(widget.appData.vehicles);
      settingsProvider.updateProviderData(widget.appData.settings);

      vehProvider.firstTimeInit = false;
    }

    VehicleElement? primaryVehicle = vehProvider.getPrimaryVehicle();

    if (primaryVehicle != null) {
      SummaryTimeRangeEnum timeRange =
          Provider.of<SettingsProvider>(context, listen: false)
              .summaryTimeRange;

      VehicleElementDataType summaryData =
          primaryVehicle.getSummaryInformation(timeRange);

      averageUsage = summaryData.averageUsage;
      totalLiters = summaryData.totalLiters;
      averageTankTime = summaryData.averageTankTime;
      averageCosts = summaryData.averageCosts;
      totalDistance = summaryData.totalDistance;
      totalTanks = summaryData.totalTanks;
      totalCars = vehProvider.vehicles.length;
    }

    setState(() {});

    super.initState();
  }

  @override
  Widget pageBody(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    String distanceMetric =
        settingsProvider.metricType == MetricTypeEnum.metric ? 'km' : 'miles';
    String metric =
        settingsProvider.metricType == MetricTypeEnum.metric ? 'L' : 'gal';
    String summaryConsumption =
        settingsProvider.metricType == MetricTypeEnum.metric
            ? '${averageUsage}L / 100km'
            : '$averageUsage gal';
    String currency = settingsProvider.currencyType;

    return Container(
        alignment: Alignment.topCenter,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    SvgPicture.asset(
                      'assets/icons/fuel.svg',
                      color: Colors.white,
                      width: 36,
                      height: 36,
                    ),
                    AutoSizeText(summaryConsumption,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                          fontStyle: FontStyle.italic,
                        ))
                  ]))),
          Wrap(
            spacing: 15.0,
            runSpacing: 15.0,
            children: [
              SummaryWidget(
                  type: SummaryWidgetType.widgetKilometers,
                  label: 'Total Distance',
                  value: '$totalDistance $distanceMetric'),
              SummaryWidget(
                  type: SummaryWidgetType.widgetLiters,
                  label: 'Total Liters',
                  value: '$totalLiters $metric'),
              SummaryWidget(
                  type: SummaryWidgetType.widgetTime,
                  label: 'Average Tank',
                  value: '~$averageTankTime Days'),
              SummaryWidget(
                  type: SummaryWidgetType.widgetCosts,
                  label: 'Average Costs',
                  value: '~$averageCosts $currency'),
              SummaryWidget(
                  type: SummaryWidgetType.widgetTanks,
                  label: 'Total Tanks',
                  value: totalTanks.toString()),
              SummaryWidget(
                  type: SummaryWidgetType.widgetCars,
                  label: 'Total Cars',
                  value: totalCars.toString()),
            ],
          ),
        ]));
  }
}
