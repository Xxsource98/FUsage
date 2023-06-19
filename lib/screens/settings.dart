import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fusage/extra/load_file_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/components/page_template.dart';
import 'package:fusage/components/setting_component.dart';
import 'package:fusage/components/modal_bottom_sheet.dart';
import 'package:fusage/components/dialog/dialog_box.dart';

import 'package:fusage/extra/enums.dart';

class Settings extends PageTemplateBase {
  Settings({Key? key})
      : super(
            pageTitle: 'Settings',
            navigationData: NavigationData(
                navigationIcon: Icons.settings, navigationLabel: 'Settings'),
            key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends PageTemplate {
  Map<String, String> currenciesList = {};
  SummaryTimeRangeEnum currentSummaryRange = SummaryTimeRangeEnum.total;
  MetricTypeEnum currentMetric = MetricTypeEnum.metric;
  String currentCurrency = 'EUR';

  String findCurrency = '';

  void showSnackBar(String label) {
    SnackBar snackBar = SnackBar(
        content: Text(label),
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void selectSummaryTimeRange(BuildContext ctx) {
    void selectTimeRange(SummaryTimeRangeEnum newRange) {
      Provider.of<SettingsProvider>(ctx, listen: false)
          .updateSummaryRangeTime(newRange);

      setState(() {
        currentSummaryRange = newRange;
      });
    }

    showDialog(
        context: ctx,
        builder: (builderCtx) {
          return DialogBox(
              title: 'Select Time Range',
              type: DialogBoxType.choose,
              chooseElements: [
                DialogBoxChooseElement(
                    label: 'Total',
                    onSelect: () =>
                        selectTimeRange(SummaryTimeRangeEnum.total)),
                DialogBoxChooseElement(
                    label: 'Month',
                    onSelect: () =>
                        selectTimeRange(SummaryTimeRangeEnum.month)),
                DialogBoxChooseElement(
                    label: 'Last Month',
                    onSelect: () =>
                        selectTimeRange(SummaryTimeRangeEnum.lastMonth)),
                DialogBoxChooseElement(
                    label: 'Week',
                    onSelect: () => selectTimeRange(SummaryTimeRangeEnum.week)),
                DialogBoxChooseElement(
                    label: 'Last Week',
                    onSelect: () =>
                        selectTimeRange(SummaryTimeRangeEnum.lastWeek)),
              ]);
        });
  }

  void showCurrenciesSelectBox(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (builderCtx) {
          return StatefulBuilder(builder: (stateContext, newState) {
            var list = generateCurrenciesList(builderCtx, findCurrency);

            return ModalBottomSheet(
              type: ModalBottomSheetType.column,
              searchInput: true,
              onSearchChange: (input) {
                newState(() {
                  findCurrency = input;
                });
              },
              sheetElements: list,
            );
          });
        });
  }

  Iterable<MapEntry<String, String>> findElementsInMap(
      Map<String, String> input, String findValue) {
    Map<String, String> values = {};
    RegExp regExp = RegExp(findValue, caseSensitive: false);

    for (var element in input.entries) {
      if (element.key.contains(regExp) || element.value.contains(regExp)) {
        values.addAll({element.key: element.value});
      }
    }

    return values.entries;
  }

  List<SettingBottomSheetElement> generateCurrenciesList(
      BuildContext ctx, String findValue) {
    List<SettingBottomSheetElement> elements = [];
    Iterable<MapEntry<String, String>> foundCurrencies =
        findElementsInMap(currenciesList, findValue);

    for (var line in foundCurrencies) {
      String key = line.key;
      String value = line.value;

      elements.add(SettingBottomSheetElement(
          label: '$key ($value)',
          onTap: () {
            Provider.of<SettingsProvider>(ctx, listen: false)
                .updateCurrency(key);

            setState(() {
              currentCurrency = key;
            });

            Navigator.pop(ctx);
          }));
    }

    return elements;
  }

  void selectMetricType(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return ModalBottomSheet(
            type: ModalBottomSheetType.column,
            sheetElements: [
              SettingBottomSheetElement(
                  label: 'Metric',
                  onTap: () {
                    Provider.of<SettingsProvider>(ctx, listen: false)
                        .updateMetricts(MetricTypeEnum.metric);

                    setState(() {
                      currentMetric = MetricTypeEnum.metric;
                    });

                    Navigator.pop(ctx);
                  }),
              SettingBottomSheetElement(
                  label: 'Imperial (US)',
                  onTap: () async {
                    Provider.of<SettingsProvider>(ctx, listen: false)
                        .updateMetricts(MetricTypeEnum.imperial);

                    setState(() {
                      currentMetric = MetricTypeEnum.imperial;
                    });

                    Navigator.pop(ctx);
                  }),
            ],
          );
        });
  }

  void convertMetrics(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (builderCtx) {
          return DialogBox(
            title: 'Are You Sure?',
            onConfirm: () {
              MetricTypeEnum metricToSet =
                  EnumConverter.isMetricTypeEnum(enumValue: currentMetric)
                      ? MetricTypeEnum.imperial
                      : MetricTypeEnum.metric;
              Provider.of<VehicleProvider>(ctx, listen: false)
                  .convertTanksMetric(metricToSet);

              showSnackBar('Metrics Converted to: $currentMetric');
            },
          );
        });
  }

  void openGithubURL(BuildContext ctx) async {
    var url = Uri.parse("https://github.com/Xxsource98");

    try {
      await launchUrl(url);
    } catch (ex) {
      throw 'Error: ${ex.toString()}';
    }
  }

  void updateLocalValues(var jsonObject) {
    var settingsData = jsonObject['settings'];

    if (settingsData != null) {
      setState(() {
        currentCurrency = settingsData['currencyType'];
        currentMetric =
            EnumConverter.stringToMetricTypeEnum(settingsData['metricType']);
        currentSummaryRange = EnumConverter.stringToSummaryRangeEnum(
            settingsData['summaryTimeRange']);
      });
    }
  }

  void saveToFile(String directory) async {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    VehicleProvider vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    CreateBackupDataResult backupData = await createBackupData(directory, vehicleProvider.vehicles,
        settingsProvider.getSettingsData());

    if (backupData.success) {
      showSnackBar('Backup Saved (${backupData.fileName})');
    } else {
      showSnackBar('Failed to Save Backup');
    }
  }

  void loadFromFile(String fileDir) async {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    VehicleProvider vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    var jsonData = await loadBackupData(fileDir);

    try {
      settingsProvider.updateSettings(jsonData);
      vehicleProvider.updateVehicles(jsonData);
      updateLocalValues(jsonData);
      showSnackBar('Backup Loaded');
    } catch (ex) {
      showSnackBar('Failed to Load Backup');
    }
  }

  Future<bool> askForAccess() async {
    bool isAlreadyGranted = await Permission.manageExternalStorage.isGranted;

    if (!isAlreadyGranted) {
      var test = await Permission.manageExternalStorage.request();

      return test.isGranted;
    }

    return true;
  }

  void createSettingsBackup() async {
    bool isGranted = await askForAccess();

    if (isGranted) {
      String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath(dialogTitle: 'Select Directory');

      if (selectedDirectory == null) {
        return;
      }

      saveToFile(selectedDirectory);
    }
  }

  void loadSettingsFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      loadFromFile(result.files[0].path!);
    }
  }

  @override
  void initState() {
    currenciesList = currencies;

    SummaryTimeRangeEnum summaryRange =
        Provider.of<SettingsProvider>(context, listen: false).summaryTimeRange;
    MetricTypeEnum currentMetricType =
        Provider.of<SettingsProvider>(context, listen: false).metricType;
    String currencyType =
        Provider.of<SettingsProvider>(context, listen: false).currencyType;

    setState(() {
      currentSummaryRange = summaryRange;
      currentMetric = currentMetricType;
      currentCurrency =  currencyType;
    });

    super.initState();
  }

  @override
  FloatingActionButton? floatingButton(BuildContext context) => null;

  @override
  Widget pageBody(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        SettingComponent(
          label: 'Summary Range Time',
          onPress: (ctx) => selectSummaryTimeRange(ctx),
          selectValue:
              EnumConverter.summaryRangeEnumToString(currentSummaryRange),
        ),
        SettingComponent(
            label: 'Currency',
            onPress: (ctx) => showCurrenciesSelectBox(ctx),
            selectValue: EnumConverter.currencyTypeToFullString(currentCurrency, currenciesList)),
        SettingComponent(
          label: 'Metric Type',
          onPress: (ctx) => selectMetricType(ctx),
          selectValue: EnumConverter.metricTypeEnumToString(currentMetric),
        ),
        SettingComponent(
            label: 'Convert Current Metrics',
            onPress: (ctx) => convertMetrics(ctx)),
        const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Divider(
              height: 2.0,
              color: Color.fromARGB(80, 7, 7, 7),
              thickness: 1.0,
            )),
        SettingComponent(
          label: 'Create Backup',
          onPress: (context) => createSettingsBackup(),
        ),
        SettingComponent(
          label: 'Load From File',
          onPress: (context) => loadSettingsFile(),
        ),
        const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Divider(
              height: 2.0,
              color: Color.fromARGB(80, 7, 7, 7),
              thickness: 1.0,
            )),
        const SettingComponent(
          label: 'Version',
          selectValue: '1.0.0',
        ),
        SettingComponent(
          label: 'Author',
          selectValue: 'Xxsource98',
          onPress: openGithubURL,
        )
      ],
    );
  }
}

const Map<String, String> currencies = {
  "AED": "United Arab Emirates Dirham",
  "AFN": "Afghan Afghani",
  "ALL": "Albanian Lek",
  "AMD": "Armenian Dram",
  "ANG": "Netherlands Antillean Guilder",
  "AOA": "Angolan Kwanza",
  "ARS": "Argentine Peso",
  "AUD": "Australian Dollar",
  "AWG": "Aruban Florin",
  "AZN": "Azerbaijani Manat",
  "BAM": "Bosnia-Herzegovina Convertible Mark",
  "BBD": "Barbadian Dollar",
  "BDT": "Bangladeshi Taka",
  "BGN": "Bulgarian Lev",
  "BHD": "Bahraini Dinar",
  "BIF": "Burundian Franc",
  "BMD": "Bermudan Dollar",
  "BND": "Brunei Dollar",
  "BOB": "Bolivian Boliviano",
  "BRL": "Brazilian Real",
  "BSD": "Bahamian Dollar",
  "BTC": "Bitcoin",
  "BTN": "Bhutanese Ngultrum",
  "BWP": "Botswanan Pula",
  "BYN": "Belarusian Ruble",
  "BZD": "Belize Dollar",
  "CAD": "Canadian Dollar",
  "CDF": "Congolese Franc",
  "CHF": "Swiss Franc",
  "CLF": "Chilean Unit of Account (UF)",
  "CLP": "Chilean Peso",
  "CNH": "Chinese Yuan (Offshore)",
  "CNY": "Chinese Yuan",
  "COP": "Colombian Peso",
  "CRC": "Costa Rican Colón",
  "CUC": "Cuban Convertible Peso",
  "CUP": "Cuban Peso",
  "CVE": "Cape Verdean Escudo",
  "CZK": "Czech Republic Koruna",
  "DJF": "Djiboutian Franc",
  "DKK": "Danish Krone",
  "DOP": "Dominican Peso",
  "DZD": "Algerian Dinar",
  "EGP": "Egyptian Pound",
  "ERN": "Eritrean Nakfa",
  "ETB": "Ethiopian Birr",
  "EUR": "Euro",
  "FJD": "Fijian Dollar",
  "FKP": "Falkland Islands Pound",
  "GBP": "British Pound Sterling",
  "GEL": "Georgian Lari",
  "GGP": "Guernsey Pound",
  "GHS": "Ghanaian Cedi",
  "GIP": "Gibraltar Pound",
  "GMD": "Gambian Dalasi",
  "GNF": "Guinean Franc",
  "GTQ": "Guatemalan Quetzal",
  "GYD": "Guyanaese Dollar",
  "HKD": "Hong Kong Dollar",
  "HNL": "Honduran Lempira",
  "HRK": "Croatian Kuna",
  "HTG": "Haitian Gourde",
  "HUF": "Hungarian Forint",
  "IDR": "Indonesian Rupiah",
  "ILS": "Israeli New Sheqel",
  "IMP": "Manx pound",
  "INR": "Indian Rupee",
  "IQD": "Iraqi Dinar",
  "IRR": "Iranian Rial",
  "ISK": "Icelandic Króna",
  "JEP": "Jersey Pound",
  "JMD": "Jamaican Dollar",
  "JOD": "Jordanian Dinar",
  "JPY": "Japanese Yen",
  "KES": "Kenyan Shilling",
  "KGS": "Kyrgystani Som",
  "KHR": "Cambodian Riel",
  "KMF": "Comorian Franc",
  "KPW": "North Korean Won",
  "KRW": "South Korean Won",
  "KWD": "Kuwaiti Dinar",
  "KYD": "Cayman Islands Dollar",
  "KZT": "Kazakhstani Tenge",
  "LAK": "Laotian Kip",
  "LBP": "Lebanese Pound",
  "LKR": "Sri Lankan Rupee",
  "LRD": "Liberian Dollar",
  "LSL": "Lesotho Loti",
  "LYD": "Libyan Dinar",
  "MAD": "Moroccan Dirham",
  "MDL": "Moldovan Leu",
  "MGA": "Malagasy Ariary",
  "MKD": "Macedonian Denar",
  "MMK": "Myanma Kyat",
  "MNT": "Mongolian Tugrik",
  "MOP": "Macanese Pataca",
  "MRU": "Mauritanian Ouguiya",
  "MUR": "Mauritian Rupee",
  "MVR": "Maldivian Rufiyaa",
  "MWK": "Malawian Kwacha",
  "MXN": "Mexican Peso",
  "MYR": "Malaysian Ringgit",
  "MZN": "Mozambican Metical",
  "NAD": "Namibian Dollar",
  "NGN": "Nigerian Naira",
  "NIO": "Nicaraguan Córdoba",
  "NOK": "Norwegian Krone",
  "NPR": "Nepalese Rupee",
  "NZD": "New Zealand Dollar",
  "OMR": "Omani Rial",
  "PAB": "Panamanian Balboa",
  "PEN": "Peruvian Nuevo Sol",
  "PGK": "Papua New Guinean Kina",
  "PHP": "Philippine Peso",
  "PKR": "Pakistani Rupee",
  "PLN": "Polish Zloty",
  "PYG": "Paraguayan Guarani",
  "QAR": "Qatari Rial",
  "RON": "Romanian Leu",
  "RSD": "Serbian Dinar",
  "RUB": "Russian Ruble",
  "RWF": "Rwandan Franc",
  "SAR": "Saudi Riyal",
  "SBD": "Solomon Islands Dollar",
  "SCR": "Seychellois Rupee",
  "SDG": "Sudanese Pound",
  "SEK": "Swedish Krona",
  "SGD": "Singapore Dollar",
  "SHP": "Saint Helena Pound",
  "SLL": "Sierra Leonean Leone",
  "SOS": "Somali Shilling",
  "SRD": "Surinamese Dollar",
  "SSP": "South Sudanese Pound",
  "STD": "São Tomé and Príncipe Dobra (pre-2018)",
  "STN": "São Tomé and Príncipe Dobra",
  "SVC": "Salvadoran Colón",
  "SYP": "Syrian Pound",
  "SZL": "Swazi Lilangeni",
  "THB": "Thai Baht",
  "TJS": "Tajikistani Somoni",
  "TMT": "Turkmenistani Manat",
  "TND": "Tunisian Dinar",
  "TOP": "Tongan Pa'anga",
  "TRY": "Turkish Lira",
  "TTD": "Trinidad and Tobago Dollar",
  "TWD": "New Taiwan Dollar",
  "TZS": "Tanzanian Shilling",
  "UAH": "Ukrainian Hryvnia",
  "UGX": "Ugandan Shilling",
  "USD": "United States Dollar",
  "UYU": "Uruguayan Peso",
  "UZS": "Uzbekistan Som",
  "VEF": "Venezuelan Bolívar Fuerte (Old)",
  "VES": "Venezuelan Bolívar Soberano",
  "VND": "Vietnamese Dong",
  "VUV": "Vanuatu Vatu",
  "WST": "Samoan Tala",
  "XAF": "CFA Franc BEAC",
  "XAG": "Silver Ounce",
  "XAU": "Gold Ounce",
  "XCD": "East Caribbean Dollar",
  "XDR": "Special Drawing Rights",
  "XOF": "CFA Franc BCEAO",
  "XPD": "Palladium Ounce",
  "XPF": "CFP Franc",
  "XPT": "Platinum Ounce",
  "YER": "Yemeni Rial",
  "ZAR": "South African Rand",
  "ZMW": "Zambian Kwacha",
  "ZWL": "Zimbabwean Dollar"
};
