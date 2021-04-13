library native_dialogs;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NativeDialogsAction {
  Widget? child;
  Widget? leading;
  Function? onPressed;
  bool isDefaultAction;
  bool isDestructiveAction;

  NativeDialogsAction(
      {this.child,
      this.leading,
      this.onPressed,
      this.isDefaultAction = false,
      this.isDestructiveAction = false});
}

class NativeDialogs {
  static Future<T?> confirm<T>(
      {required BuildContext context,
      Widget? title,
      Widget? content,
      Function? onOk,
      Function? onCancel,
      String okText = "Подтвердить",
      String cancelText = "Отмена"}) {
    return NativeDialogs.displayDialog(
        context: context,
        title: title,
        content: content,
        actions: [
          NativeDialogsAction(
              child: Text(cancelText),
              onPressed: onCancel,
              isDefaultAction: true),
          NativeDialogsAction(child: Text(okText), onPressed: onOk),
        ]);
  }

  static Future<T?> displaySheet<T>(
      {required BuildContext context,
      String? title,
      String? message,
      List<NativeDialogsAction> actions = const []}) {
    if (Platform.isIOS) {
      return showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: title != null ? Text(title) : null,
              message: message != null ? Text(message) : null,
              actions: actions.map((action) {
                return CupertinoActionSheetAction(
                  child: action.child!,
                  onPressed: () {
                    Navigator.of(context).pop();
                    action.onPressed!();
                  },
                  isDefaultAction: false,
                  isDestructiveAction: true,
                );
              }).toList(),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () => {Navigator.of(context).pop()},
                  isDefaultAction: true,
                  child: Text("Отмена")),
            );
          });
    }

    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              child: new Wrap(
            children: actions.map((action) {
              return ListTile(
                title: action.child,
                onTap: () {
                  Navigator.of(context).pop();
                  action.onPressed!();
                },
                leading: action.leading,
              );
            }).toList(),
          ));
        });
  }

  static Future<T?> displayAlert<T>(
      {required BuildContext context,
      Widget? title,
      Widget? content,
      bool isDismissible = true,
      String actionTitle = "Отмена"}) {
    return NativeDialogs.displayDialog(
        context: context,
        title: title,
        content: content,
        actions: [NativeDialogsAction(child: Text(actionTitle))]);
  }

  static Future<T?> displayDialog<T>(
      {required BuildContext context,
      Widget? title,
      Widget? content,
      bool isDismissible = true,
      List<NativeDialogsAction> actions = const []}) {
    Widget dialog;

    void onPressed(NativeDialogsAction action) {
      Navigator.of(context).pop();

      if (action.onPressed != null) {
        action.onPressed!();
      }
    }

    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions
            .map((action) => CupertinoDialogAction(
                  child: action.child!,
                  onPressed: () {
                    onPressed(action);
                  },
                  isDefaultAction: action.isDefaultAction,
                  isDestructiveAction: action.isDestructiveAction,
                ))
            .toList(),
      );
    } else {
      dialog = AlertDialog(
        title: title,
        content: content,
        actions: actions
            .map((action) => TextButton(
                onPressed: () {
                  onPressed(action);
                },
                child: action.child!))
            .toList(),
      );
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        },
        barrierDismissible: isDismissible);
  }
}
