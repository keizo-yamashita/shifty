import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/google_login_provider.dart';
import 'package:shift/src/functions/font.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var accountProvider = Provider.of<GoogleAccountProvider>(context);
    var screenSize = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: Image.network(accountProvider.user?.photoUrl ?? '').image,
              )
            ),
          ),
          const SizedBox(height: 20),
          Text(accountProvider.user?.displayName ?? ''),
          Text(accountProvider.user?.email ?? ''),
          const SizedBox(height: 20),
          OutlinedButton(
            child: Text('ログアウト', style: MyFont.defaultStyleRed15),
            onPressed: () {
              accountProvider.logout();
            },
          ),
        ],
      )
    );
  }
}
