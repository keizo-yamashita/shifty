import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/sing_in/sign_in_provider.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/functions/style.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var signInProvider = Provider.of<SignInProvider>(context);

    var appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    var screenSize   = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenSize.height * 0.04 + appBarHeight),
          (signInProvider.user != null && signInProvider.user!.providerData[0].photoURL != null)
          ? Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: Image.network(signInProvider.user!.providerData[0].photoURL!).image
              )
            ),
          )
          : Container(
            width: 100.0,
            height: 100.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.account_circle_outlined, color: MyStyle.primaryColor, size: 80),
          ),
          (signInProvider.user != null)
          ? Column(
            children: [
              const SizedBox(height: 20),
              Text("ユーザー名 : ${signInProvider.user?.providerData[0].displayName ?? signInProvider.user?.uid ?? ''}", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
              Text("メール : ${signInProvider.user?.providerData[0].email ?? ''}", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
              Text("ユーザーID : ${signInProvider.user?.uid ?? ''}", style: MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  child: Text('ログアウト', style: MyStyle.defaultStyleRed15),
                  onPressed: () {
                    showConfirmDialog(
                      context, "確認", "ログアウトしますか？\n登録したデータは失われません。", "ログアウトしました", (){
                        signInProvider.logout();
                      }
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  child: Text('アカウント削除', style: MyStyle.defaultStyleRed15),
                  onPressed: () {
                    showConfirmDialog(
                      context, "確認", "アカウントを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。", "アカウントを削除しました。", (){
                        signInProvider.deleteUserData();
                        signInProvider.deleteUser();
                      }
                    );
                  },
                ),
              ),
            ],
          )
          : Column(
            children: [
              const SizedBox(height: 20),
              Text("未ログイン状態", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  child: Text('ログイン画面へ', style: MyStyle.headlineStyleGreen15),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInScreen()));
                  },
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
