import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/screens/google_login_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var accountProvider = Provider.of<GoogleAccountProvider>(context);
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Image.network(accountProvider.user?.photoUrl ?? ''),
          Text(accountProvider.user?.displayName ?? ''),
          Text(accountProvider.user?.email ?? ''),
          OutlinedButton(

            child: const Text('ログアウト', style: TextStyle(color: Colors.red)),
            onPressed: () {
              accountProvider.logout();
            },
          ),
        ],
      )
    );
  }
}
