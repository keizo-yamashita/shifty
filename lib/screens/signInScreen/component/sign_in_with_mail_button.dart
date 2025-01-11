// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:shift/components/form/utility/dialog.dart';
import 'package:shift/components/form/utility/snackbar.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/main.dart';

class SignInWithMailButton extends StatefulWidget {
  const SignInWithMailButton({super.key});

  @override
  State<SignInWithMailButton> createState() => _SignInWithMailButtonState();
}

class _SignInWithMailButtonState extends State<SignInWithMailButton> {
  @override
  Widget build(BuildContext context) {
    final inputMailController = TextEditingController(text: "");
    final inputPasswordController = TextEditingController(text: "");

    return Column(
      children: <Widget>[
        Text('メールアドレスを用いてログイン', style: Styles.defaultStyleWhite20),
        const SizedBox(height: 10),
        _TextField(
          controller: inputMailController,
          hintText: 'メールアドレス',
          autofillHints: const [AutofillHints.email],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'メールアドレスを入力してください';
            }
            return null;
          },
        ),
        const Gap(10),
        _TextField(
          controller: inputPasswordController,
          hintText: 'パスワード',
          autofillHints: const [AutofillHints.password],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'パスワードを入力してください';
            }
            return null;
          },
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SignInButton(
              email: inputMailController.text,
              password: inputPasswordController.text,
              width: 75,
            ),
            const SizedBox(width: 20),
            _SignInButton(
              email: inputMailController.text,
              password: inputPasswordController.text,
              Colors.yellow[100]!,
              75,
              inputMailController.text,
              inputPasswordController.text,
            ),
          ],
        ),
      ],
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.autofillHints,
    this.validator,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final List<String> autofillHints;
  final String? Function(String?)? validator;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.of(context).size.width * 0.8, 300),
      child: TextFormField(
        controller: widget.controller,
        cursorColor: Styles.lightBgColor,
        style: Styles.defaultStyleWhite15,
        autofillHints: widget.autofillHints,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
          prefixIconColor: Styles.primaryColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Styles.lightBgColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Styles.lightBgColor,
            ),
          ),
          prefixIcon: const Icon(Icons.input, color: Colors.white),
          hintText: widget.hintText,
          hintStyle: Styles.defaultStyleWhite15,
          errorText: _errorText,
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          final error = widget.validator?.call(value);
          setState(() {
            _errorText = error;
          });
          return error;
        },
      ),
    );
  }
}

class _SignInButton extends ConsumerStatefulWidget {
  const _SignInButton({
    required this.email,
    required this.password,
    required this.width,
  });

  final String email;
  final String password;
  final double width;

  @override
  ConsumerState<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<_SignInButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.tealAccent,
          side: const BorderSide(color: Colors.transparent),
        ),
        onPressed: () {
          //   ////////////////////////////////////////////////////////////////////////////////////////////
          //   /// メールでログインする場合 (新規登録から)
          //   ////////////////////////////////////////////////////////////////////////////////////////////
          //   if (providerName == "mail-create") {
          //     if (mail == "" || password == "") {
          //       showAlertDialog(context, ref, "エラー",
          //           "メールアドレスとパスワードを\n入力してください。", true);
          //       isDisabled = false;
          //     } else if (password!.length < 6) {
          //       showAlertDialog(
          //           context, ref, "エラー", "パスワードは6文字以上で\n入力してください。", true);
          //       isDisabled = false;
          //     } else {
          //       showConfirmDialog(
          //         context: context,
          //         ref: ref,
          //         title: "確認",
          //         message1: "このメールアドレスとパスワードで\n新規登録しますか？",
          //         message2: "",
          //         onAccept: () {
          //           ref
          //               .read(signInProvider)
          //               .login(providerName, false, mail, password)
          //               .then((message) {
          //             if (message != "") {
          //               showAlertDialog(
          //                   context, ref, "エラー", message, true);
          //               isDisabled = false;
          //             } else {
          //               showSnackBar(
          //                   context: context,
          //                   message: "新規登録しました。",
          //                   type: SnackBarType.info);
          //               context.go('/home');
          //               isDisabled = false;
          //             }
          //           }).catchError((onError) {
          //             isDisabled = false;
          //           });
          //         },
          //         confirm: false,
          //       );
          //     }
          //   }

          ref
              .read(signInProvider)
              .loginWithEmail(email: widget.email, password: widget.password)
              .then((message) {
            if (message != "") {
              showAlertDialog(context, ref, "エラー", message, true);
            } else {
              showSnackBar(
                  context: context,
                  message: "ログインしました。",
                  type: SnackBarType.info);
              context.go('/home');
            }
          }).catchError((onError) {});
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: widget.width,
                  child: const Text("ログイン", textAlign: TextAlign.center),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpButton extends ConsumerStatefulWidget {
  const _SignUpButton({
    required this.email,
    required this.password,
    required this.width,
  });

  final String email;
  final String password;
  final double width;

  @override
  ConsumerState<_SignUpButton> createState() => _SigUpButtonState();
}

class _SigUpButtonState extends ConsumerState<_SignUpButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.tealAccent,
          side: const BorderSide(color: Colors.transparent),
        ),
        onPressed: () {
          showConfirmDialog(
            context: context,
            ref: ref,
            title: "確認",
            message1: "このメールアドレスとパスワードで\n新規登録しますか？",
            message2: "",
            onAccept: () {
              ref
                  .read(signInProvider)
                  .login(providerName, false, mail, password)
                  .then((message) {
                if (message != "") {
                  showAlertDialog(context, ref, "エラー", message, true);
                } else {
                  showSnackBar(
                      context: context,
                      message: "新規登録しました。",
                      type: SnackBarType.info);
                  context.go('/home');
                }
              }).catchError((onError) {});
            },
            confirm: false,
          );
        },
      ),
    );
  }
}
