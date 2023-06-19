import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/components/page_template.dart';
import 'package:fusage/extra/load_file_data.dart';

import 'package:fusage/screens/consumption_calculator.dart';
import 'package:fusage/screens/summary.dart';
import 'package:fusage/screens/cars.dart';
import 'package:fusage/screens/settings.dart';

void main() async {
  Paint.enableDithering = true;

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  MainAppData data = await loadFileData();

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VehicleProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider())
      ],
      child: MaterialApp(
        title: 'FUsage',
        debugShowCheckedModeBanner: false,
        home: MainApp(
          screens: [Cars(), ConsumptionCalculator(), Settings()],
          fileData: data,
        ),
      )));
}

class MainApp extends StatefulWidget {
  final List<PageTemplateBase> screens;
  final MainAppData fileData;

  const MainApp({Key? key, required this.screens, required this.fileData})
      : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int pageIndex = 0;
  late PageTemplateBase currentPage = widget.screens[0];
  late PageTemplateBase summaryElement;

  void changePage(int newIndex, PageTemplateBase newPage) {
    setState(() {
      pageIndex = newIndex;
      currentPage = newPage;
    });
  }

  Widget drawBody() {
    if (pageIndex == 0) {
      PageTemplateBase summaryPage = SummaryPage(
        appData: widget.fileData,
      );

      setState(() {
        summaryElement = summaryPage;
      });
      changePage(0, summaryPage);
    }

    return currentPage;
  }

  List<BottomNavigationBarItem> drawNavigationElements() {
    List<BottomNavigationBarItem> elements = [];

    elements.add(BottomNavigationBarItem(
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
        icon: Icon(summaryElement.navigationData.navigationIcon),
        label: summaryElement.navigationData.navigationLabel,
        tooltip: summaryElement.navigationData.navigationLabel));

    for (var element in widget.screens) {
      NavigationData data = element.navigationData;

      elements.add(BottomNavigationBarItem(
          backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
          icon: Icon(data.navigationIcon),
          label: data.navigationLabel,
          tooltip: data.navigationLabel));
    }

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color.fromRGBO(20, 30, 48, 1.0),
              Color.fromRGBO(36, 59, 85, 1.0)
            ])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: drawBody(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            toolbarHeight: 70,
            title: Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: AutoSizeText(currentPage.pageTitle,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontSize: 34,
                        fontWeight: FontWeight.w600))),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            selectedItemColor: const Color.fromRGBO(180, 202, 242, 1.0),
            showUnselectedLabels: false,
            unselectedItemColor: Colors.white38,
            currentIndex: pageIndex,
            items: drawNavigationElements(),
            onTap: (value) =>
                changePage(value, widget.screens[value > 0 ? value - 1 : 0]),
          ),
        ));
  }
}
