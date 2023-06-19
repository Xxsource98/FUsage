import 'package:flutter/material.dart';

class NavigationData {
  final IconData navigationIcon;
  final String navigationLabel;

  NavigationData({required this.navigationIcon, required this.navigationLabel});
}

abstract class PageTemplateBase extends StatefulWidget {
  final String pageTitle;
  final NavigationData navigationData;

  const PageTemplateBase(
      {Key? key, required this.pageTitle, required this.navigationData})
      : super(key: key);
}

abstract class PageTemplate<T extends PageTemplateBase> extends State<T> {
  @protected
  @override
  void initState();

  @protected
  Widget pageBody(BuildContext context);

  @protected
  FloatingActionButton? floatingButton(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: pageBody(context)))
                    ])),
            floatingActionButton: floatingButton(context),
          ),
        ));
  }
}
