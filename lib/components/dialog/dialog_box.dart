import 'package:flutter/material.dart';

enum DialogBoxType { confirm, choose, custom }

class DialogBoxChooseElement {
  String label;
  Function() onSelect;

  DialogBoxChooseElement({required this.label, required this.onSelect});
}

class DialogBox extends StatelessWidget {
  final DialogBoxType type;
  final String title;
  final bool centreTitle;
  final String? description;
  final List<DialogBoxChooseElement>? chooseElements;
  final List<Widget>? content;
  final Function()? onConfirm;

  const DialogBox(
      {Key? key,
      this.type = DialogBoxType.confirm,
      required this.title,
      this.centreTitle = false,
      this.description,
      this.chooseElements,
      this.content,
      this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == DialogBoxType.confirm) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600),
        contentPadding:
            const EdgeInsets.only(top: 25, bottom: 25, left: 30, right: 30),
        title: Text(
          title,
          textAlign: centreTitle ? TextAlign.center : TextAlign.start,
        ),
        content: description != null ? Text(description!) : null,
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              onConfirm!();
              Navigator.of(context).pop();
            },
          ),
        ],
        actionsPadding: const EdgeInsets.only(bottom: 15, right: 15),
      );
    } else if (type == DialogBoxType.choose) {
      return SimpleDialog(
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600),
        contentPadding:
            const EdgeInsets.only(top: 25, bottom: 25, left: 30, right: 30),
        title: Text(title,
            textAlign: centreTitle ? TextAlign.center : TextAlign.start),
        children: [
          chooseElements!.map((e) {
            return InkWell(
                onTap: () {
                  e.onSelect();
                  Navigator.pop(context);
                },
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(e.label,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                    )));
          }).toList(),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ]
        ].expand((element) => element).toList(),
      );
    }

    return SimpleDialog(
      backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
      titleTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600),
      contentPadding:
          const EdgeInsets.only(top: 25, bottom: 25, left: 30, right: 30),
      title: Text(title,
          textAlign: centreTitle ? TextAlign.center : TextAlign.start),
      children: content,
    );
  }
}
