////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:shift/components/form/utility/dialog.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/main.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// App Widget
////////////////////////////////////////////////////////////////////////////////////////////
class AppNavigationBar extends ConsumerWidget {
  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;
  int get currentIndex => navigationShell.currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: navigationShell,
      drawer: isLandscape ? Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          children: [
            ListTile(
              leading: const Icon(Icons.notifications, size: 28),
              title: const Text('お知らせ'),
              onTap: () => navigationShell.goBranch(0),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, size: 28),
              title: const Text('マイシフト'),
              onTap: () => navigationShell.goBranch(1),
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 28),
              title: const Text('設定'),
              onTap: () => navigationShell.goBranch(2),
            ),
          ],
        ),
      ) : null,
      bottomNavigationBar: !isLandscape ? Container(
        height: 56.0 + MediaQuery.of(context).padding.bottom,
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.3,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          onTap: (index) async {
            if(currentIndex == 1 && index == 1 && ref.watch(settingProvider).isEditting) {
              await showConfirmDialog(
                context: context,
                ref: ref,
                title: "注意",
                message1: "データが保存されていません。\n未登録のデータは破棄されます。",
                message2: "",
                onAccept: (){
                  ref.read(settingProvider).isEditting = false;
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                confirm: false,
                error: true,
              );
            }else{
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 24),
              activeIcon: Icon(Icons.notifications, size: 28),
              label: 'お知らせ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month, size: 24),
              activeIcon: Icon(Icons.calendar_month, size: 28),
              label: 'マイシフト',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 24),
              activeIcon: Icon(Icons.settings, size: 28),
              label: '設定',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          fixedColor: Styles.primaryColor,
        ),
      ) : null,
    );
    
  }
}
