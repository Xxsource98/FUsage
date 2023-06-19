import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:fusage/context/settings.dart';

import 'package:fusage/components/dialog/dialog_box.dart';
import 'package:fusage/components/widgets/row_text.dart';
import 'package:fusage/components/widgets/input_field.dart';
import 'package:fusage/components/page_template.dart';

import 'package:fusage/extra/enums.dart';

class CalculateConsumptionData {
  double consumedFuel = 0.0;
  double distance = 0.0;
  double price = 0.0;

  bool notEmpty() => consumedFuel > 0.0 && distance > 0.0;
}

class CalculateRoadData {
  double fuelConsumption = 0.0;
  double distance = 0.0;
  double price = 0.0;

  bool notEmpty() => fuelConsumption > 0.0 && distance > 0.0 && price > 0.0;
}

class ConsumptionCalculator extends PageTemplateBase {
  ConsumptionCalculator({Key? key})
      : super(
            pageTitle: 'Consumption Calculator',
            navigationData: NavigationData(
                navigationIcon: Icons.calculate_outlined,
                navigationLabel: 'Calculator'),
            key: key);

  @override
  CalcUsageState createState() => CalcUsageState();
}

class CalcUsageState extends PageTemplate {
  CalculateConsumptionData consumptionData = CalculateConsumptionData();
  CalculateRoadData roadData = CalculateRoadData();

  bool calculateConsumptionTapped = false;
  bool calculateRoadTapped = false;

  double parseValue(String newValue) {
    double value = double.parse(newValue);

    if (value > 0.0) return value;

    return 0.0;
  }

  void showDialogBox(List<Widget> rows) {
    showDialog(
        context: context,
        builder: (ctx) {
          return DialogBox(
            type: DialogBoxType.custom,
            title: 'Result',
            centreTitle: true,
            content: [
              rows,
              [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    splashRadius: 15.0,
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                )
              ]
            ].expand((element) => element).toList(),
          );
        });
  }

  void calculateConsumption() {
    if (consumptionData.notEmpty()) {
      List<Widget> rows = [];
      String currentCurrency =
          Provider.of<SettingsProvider>(context, listen: false).currencyType;
      MetricTypeEnum metricType =
          Provider.of<SettingsProvider>(context, listen: false).metricType;

      String fuelUnit2 = metricType == MetricTypeEnum.imperial ? 'gal' : 'dm3';
      String distanceUnit =
          metricType == MetricTypeEnum.imperial ? 'mile' : 'km';
      String calculateConsumptionString = '- L / 100km';
      double calculatedConsumption = 0.0;
      double pricePerUnit = 0.0;
      double pricePer100Unit = 0.0;
      double totalPrice = 0.0;

      if (metricType == MetricTypeEnum.imperial) {
        String consumptiom =
            (consumptionData.distance / consumptionData.consumedFuel)
                .toStringAsFixed(2);

        calculatedConsumption = double.parse(consumptiom);
        calculateConsumptionString = '$calculatedConsumption mpg';

        if (consumptionData.price > 0.0) {
          double calculatedUnitPrice =
              (((consumptionData.distance / calculatedConsumption) *
                      consumptionData.price) /
                  consumptionData.distance);
          String fixedUnitPrice = calculatedUnitPrice.toStringAsFixed(2);

          pricePerUnit = double.parse(fixedUnitPrice);

          String fixedTotalPrice =
              ((calculatedUnitPrice * consumptionData.distance))
                  .toStringAsFixed(2);

          totalPrice = double.parse(fixedTotalPrice);
        }
      } else {
        String consumptiom =
            ((consumptionData.consumedFuel / consumptionData.distance) * 100)
                .toStringAsFixed(2);

        calculatedConsumption = double.parse(consumptiom);
        calculateConsumptionString = '${calculatedConsumption}L / 100km';

        if (consumptionData.price > 0.0) {
          String fixedUnitPrice =
              ((calculatedConsumption * consumptionData.price) / 100)
                  .toStringAsFixed(2);
          String fixedUnitPrice2 =
              ((calculatedConsumption * consumptionData.price))
                  .toStringAsFixed(2);

          pricePerUnit = double.parse(fixedUnitPrice);
          pricePer100Unit = double.parse(fixedUnitPrice2);

          String fixedTotalPrice =
              ((consumptionData.distance * pricePerUnit)).toStringAsFixed(2);

          totalPrice = double.parse(fixedTotalPrice);
        }
      }

      rows = [
        RowText(
            leftSide: 'Consumed Fuel',
            rightSide: '${consumptionData.consumedFuel} $fuelUnit2'),
        RowText(
            leftSide: 'Distance Travelled',
            rightSide: '${consumptionData.distance} $distanceUnit'),
        RowText(
            leftSide: 'Total Price', rightSide: '$totalPrice $currentCurrency'),
        RowText(
            leftSide: 'Price per $distanceUnit',
            rightSide: '~$pricePerUnit $currentCurrency'),
      ];

      if (metricType == MetricTypeEnum.metric) {
        rows.add(RowText(
            leftSide: 'Price per 100km',
            rightSide: '~$pricePer100Unit $currentCurrency'));
      }

      rows.add(RowText(
          leftSide: 'Fuel Consumption',
          rightSide: calculateConsumptionString,
          spaceOnTop: true,
          biggerText: true));

      showDialogBox(rows);
    }

    setState(() {
      calculateConsumptionTapped = true;
    });
  }

  void calculateRoadPrice() {
    if (roadData.notEmpty()) {
      List<Widget> rows = [];
      String currentCurrency =
          Provider.of<SettingsProvider>(context, listen: false).currencyType;
      MetricTypeEnum metricType =
          Provider.of<SettingsProvider>(context, listen: false).metricType;

      String distanceUnit =
          metricType == MetricTypeEnum.imperial ? 'mile' : 'km';

      double roadPrice = 0.0;
      double pricePerUnit = 0.0;

      if (metricType == MetricTypeEnum.imperial) {
        double calculatedUnitPrice =
            (((roadData.distance / roadData.fuelConsumption) * roadData.price) /
                roadData.distance);
        String fixedUnitPrice = calculatedUnitPrice.toStringAsFixed(2);
        pricePerUnit = double.parse(fixedUnitPrice);

        String fixedTotalPrice =
            ((calculatedUnitPrice * roadData.distance)).toStringAsFixed(2);

        roadPrice = double.parse(fixedTotalPrice);
      } else {
        String fixedRoadPrice = ((roadData.distance / 100) *
                (roadData.fuelConsumption * roadData.price))
            .toStringAsFixed(2);
        roadPrice = double.parse(fixedRoadPrice);

        String fixedPricePerUnit =
            ((roadData.fuelConsumption * roadData.price) / 100)
                .toStringAsFixed(2);
        pricePerUnit = double.parse(fixedPricePerUnit);
      }

      rows = [
        RowText(
            leftSide: 'Fuel Consumption',
            rightSide: roadData.fuelConsumption.toStringAsFixed(2)),
        RowText(
            leftSide: 'Travel Distance',
            rightSide: roadData.distance.toStringAsFixed(2)),
        RowText(
            leftSide: 'Fuel Price',
            rightSide: '${roadData.price} $currentCurrency'),
        RowText(
            leftSide: 'Price per $distanceUnit',
            rightSide: '~$pricePerUnit $currentCurrency'),
        RowText(
            leftSide: 'Total Price',
            rightSide: '$roadPrice $currentCurrency',
            spaceOnTop: true,
            biggerText: true),
      ];

      showDialogBox(rows);
    }

    setState(() {
      calculateRoadTapped = true;
    });
  }

  @override
  FloatingActionButton? floatingButton(BuildContext context) => null;

  @override
  Widget pageBody(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Wrap(
          spacing: 15,
          runSpacing: 5,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: Text('Calculate Consumption',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w500)),
                ),
                InputField(
                    initialValue: consumptionData.consumedFuel.toString(),
                    labelText:
                        settingsProvider.metricType == MetricTypeEnum.metric
                            ? 'Consumed Fuel (dm3)'
                            : 'Consumed Fuel (gal)',
                    doubleNumber: true,
                    clearButton: true,
                    isEmpty: calculateConsumptionTapped &&
                        consumptionData.consumedFuel == 0.0,
                    onChanged: (value) {
                      setState(() {
                        consumptionData.consumedFuel = parseValue(value);
                      });
                    }),
                InputField(
                    initialValue: consumptionData.distance.toString(),
                    labelText:
                        settingsProvider.metricType == MetricTypeEnum.metric
                            ? 'Distance (km)'
                            : 'Distance (miles)',
                    doubleNumber: true,
                    isEmpty: calculateConsumptionTapped &&
                        consumptionData.distance == 0.0,
                    onChanged: (value) {
                      setState(() {
                        consumptionData.distance = parseValue(value);
                      });
                    }),
                InputField(
                    initialValue: consumptionData.price.toString(),
                    labelText:
                        'Price (${settingsProvider.currencyType}) (Optional)',
                    doubleNumber: true,
                    isRequired: false,
                    onChanged: (value) {
                      setState(() {
                        consumptionData.price = parseValue(value);
                      });
                    }),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: calculateConsumption,
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(20, 30, 48, 1.0))),
                            child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  'Calculate',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                  ),
                                ))),
                      ],
                    )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 5),
                  child: Text('Calculate Road Price',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w500)),
                ),
                InputField(
                    initialValue: roadData.fuelConsumption.toString(),
                    labelText:
                        settingsProvider.metricType == MetricTypeEnum.metric
                            ? 'Fuel Consumption (dm3)'
                            : 'Fuel Consumption (gal)',
                    doubleNumber: true,
                    isEmpty:
                        calculateRoadTapped && roadData.fuelConsumption == 0.0,
                    onChanged: (value) {
                      setState(() {
                        roadData.fuelConsumption = parseValue(value);
                      });
                    }),
                InputField(
                    initialValue: roadData.distance.toString(),
                    labelText:
                        settingsProvider.metricType == MetricTypeEnum.metric
                            ? 'Distance (km)'
                            : 'Distance (miles)',
                    doubleNumber: true,
                    isEmpty: calculateRoadTapped && roadData.distance == 0.0,
                    onChanged: (value) {
                      setState(() {
                        roadData.distance = parseValue(value);
                      });
                    }),
                InputField(
                    initialValue: roadData.price.toString(),
                    labelText: 'Fuel Price (${settingsProvider.currencyType})',
                    doubleNumber: true,
                    isEmpty: calculateRoadTapped && roadData.price == 0.0,
                    onChanged: (value) {
                      setState(() {
                        roadData.price = parseValue(value);
                      });
                    }),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: calculateRoadPrice,
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(20, 30, 48, 1.0))),
                            child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  'Calculate',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                  ),
                                ))),
                      ],
                    )),
              ],
            ),
          ],
        ));
  }
}
