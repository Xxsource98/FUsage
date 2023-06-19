import 'package:flutter/material.dart';

abstract class SubpageTemplateBase<T> extends StatefulWidget {
  final T? extraVariable;
  final String pageTitle;

  const SubpageTemplateBase(
      {Key? key, required String title, T? customVariable})
      : pageTitle = title,
        extraVariable = customVariable,
        super(key: key);
}

abstract class SubpageTemplate<T extends SubpageTemplateBase> extends State<T> {
  @protected
  @override
  void initState();

  @protected
  Widget pageBody(BuildContext context);

  @protected
  FloatingActionButton? floatingButton();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromRGBO(20, 30, 48, 1.0),
                  Color.fromRGBO(36, 59, 85, 1.0)
                ])),
            child: SafeArea(
                top: false,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: false,
                  body: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: pageBody(context))),
                  appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      toolbarHeight: 70,
                      leading: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            child: const Icon(Icons.arrow_back_ios, size: 24),
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                          )),
                      leadingWidth: 40,
                      title: Text(widget.pageTitle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 26,
                              fontWeight: FontWeight.w600))),
                  floatingActionButton: floatingButton(),
                ))));
  }
}
