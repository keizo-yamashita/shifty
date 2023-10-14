////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/screens/signInScreen/link_account.dart';
import 'package:shift/src/mylibs/style.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    var appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    var screenSize   = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenSize.height * 0.04 + appBarHeight),
          (ref.read(signInProvider).user != null && !ref.read(signInProvider).user!.isAnonymous && ref.read(signInProvider).user!.providerData[0].photoURL != null)
          ? Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: Image.network(ref.read(signInProvider).user!.providerData[0].photoURL!).image
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
          (ref.read(signInProvider).user != null)
          ? Column(
            children: [
              const SizedBox(height: 20),
              if(!ref.read(signInProvider).user!.isAnonymous) ...[
                Text("ユーザー名 : ${ref.read(signInProvider).user?.providerData[0].displayName ?? ref.read(signInProvider).user?.uid ?? ''}", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
                Text("メール : ${ref.read(signInProvider).user?.providerData[0].email ?? ''}", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
                Text("ユーザーID : ${ref.read(signInProvider).user?.uid ?? ''}", style: MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    child: Text('ログアウト', style: MyStyle.defaultStyleRed15),
                    onPressed: () {
                      showConfirmDialog(
                        context, ref, "確認", "ログアウトしますか？\n登録したデータは失われません。", "ログアウトしました", (){
                        ref.read(signInProvider).logout();
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
                        context, ref, "確認", "アカウントを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。", "", (){
                          ref.read(signInProvider).deleteUserData();
                          ref.read(signInProvider).deleteUser().then(
                            (error){
                              if(error){
                                showAlertDialog(context, ref, "エラー", "ユーザの削除に失敗しました。もう一度お試しく下さい。", error); 
                              }
                              else{
                                showAlertDialog(context, ref, "確認", "ユーザを削除しました。", error); 
                              }
                            }
                          );
                        },
                        false
                      );
                    },
                  ),
                ),
              ]
              else ...[
                Text("ゲストユーザ", style: MyStyle.headlineStyle20, overflow: TextOverflow.ellipsis),
                Text("${ref.read(signInProvider).user?.uid}", style: MyStyle.headlineStyle15, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    child: Text('ゲストユーザの削除', style: MyStyle.defaultStyleRed15),
                    onPressed: () {
                      showConfirmDialog(
                        context, ref, "確認", "ゲストデータを削除しますか？\n登録したデータは全て削除されます。\n管理者である場合、フォロワーのリクエストデータも削除されます。", "", (){
                          ref.read(signInProvider).deleteUserData();
                          ref.read(signInProvider).deleteUser().then(
                            (error){
                              if(error){
                                showAlertDialog(context, ref, "エラー", "ゲストユーザの削除に失敗しました。もう一度お試しく下さい。", error); 
                              }
                              else{
                                showAlertDialog(context, ref, "確認", "ゲストユーザを削除しました。", error); 
                              }
                            }
                          );
                        },
                        false
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    child: Text('アカウント連携', style: MyStyle.headlineStyleGreen15),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const LinkAccountScreen()));
                    },
                  ),
                ),
              ]
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
