import 'package:flutter/material.dart';

Widget alertDialog(BuildContext context,
    {required String title, required String text, String? buttonText}) {
  return AlertDialog(
    title: Text(title),
    content: Text(text),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(buttonText ?? 'Close'),
      )
    ],
  );
}

void showAlertDialog(BuildContext context,
    {required String title, required String text, String? buttonText}) {
  showDialog(
      context: context,
      builder: (c) =>
          alertDialog(c, title: title, text: text, buttonText: buttonText));
}

class DialogIcon extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const DialogIcon(this.title, this.text, this.icon, {Key? key})
      : super(key: key);

  const DialogIcon.error(String text, {Key? key})
      : this('Error occurred', text, Icons.error_outline, key: key);

  const DialogIcon.info(String title, String text, {Key? key})
      : this(title, text, Icons.help_outline, key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(icon, color: Colors.black38),
        onPressed: () => showAlertDialog(context, title: title, text: text));
  }
}
