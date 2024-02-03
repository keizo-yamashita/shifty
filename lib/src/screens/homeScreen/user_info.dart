////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/components/style/style.dart';

class UserInfoPage extends ConsumerWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    User? user = ref.read(signInProvider).user;

    bool isLogedIn = (user != null) &&
        (user.isAnonymous) &&
        (user.providerData.isNotEmpty && user.providerData[0].photoURL != null);

    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー情報', style: Styles.defaultStyle18),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLogedIn) ...[
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: Image.network(
                      user.providerData[0].photoURL!,
                    ).image,
                  ),
                ),
              )
            ] else ...[
              Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.account_circle_outlined,
                  color: Styles.primaryColor,
                  size: 80,
                ),
              ),
            ],
            if (ref.read(signInProvider).user != null) ...[
              Column(
                children: [
                  const SizedBox(height: 20),
                  if (!ref.read(signInProvider).user!.isAnonymous) ...[
                    Text(
                      "ユーザー名 : ${ref.read(signInProvider).user?.providerData[0].displayName ?? ref.read(signInProvider).user?.uid ?? ''}",
                      style: Styles.defaultStyle15,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Eメール : ${ref.read(signInProvider).user?.providerData[0].email ?? ''}",
                      style: Styles.defaultStyle15,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ID : ${ref.read(signInProvider).user?.uid ?? ''}",
                      style: Styles.defaultStyleGrey13,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    Text(
                      "ゲストユーザ",
                      style: Styles.defaultStyle20,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ID : ${ref.read(signInProvider).user?.uid}",
                      style: Styles.defaultStyle15,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                  ]
                ],
              )
            ] else ...[
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "未ログイン状態",
                    style: Styles.defaultStyle15,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      child: Text(
                        'ログイン画面へ',
                        style: Styles.defaultStyleGreen15,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const SignInScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
