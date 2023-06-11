import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/screens/createScreen/create_shift_table.dart';
import 'package:shift/src/screens/inputScreen/input_request.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {

    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: appBarHeight, right: screenSize.width/20),
        child: FloatingActionButton(
          foregroundColor: MyFont.backgroundColor,
          backgroundColor: MyFont.primaryColor,
          child: const Icon(Icons.add, size: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateShiftTableWidget()));
          },
        ),
      ),

      extendBody: true,
      extendBodyBehindAppBar: true,

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height/10 + appBarHeight),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('shift-request')
                  .where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('SteremBuilder でエラーが発生しました: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: MyFont.primaryColor);
                  }
                  return FutureBuilder<Widget>(
                    future: buildMyShift(),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: MyFont.primaryColor);
                      } else if (snapshot.hasError) {
                        return Text('FeatureBuilderでエラーが発生しました: ${snapshot.error}');
                      } else {
                        return snapshot.data!;
                      }
                    },
                  );
                },
              ),
              SizedBox(height: screenSize.height/10 + appBarHeight),
            ],
          ),
        ),
      )
    );
  }

  Future<Widget> buildMyShift() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    var snapshot = await firestore.collection('shift-request').where('user-id', isEqualTo: uid).get();

    List<DocumentSnapshot> shifts = [];

    for(var doc in snapshot.docs){
      DocumentReference ref = doc.get('table-refarence');
      DocumentSnapshot table = await ref.get();
      shifts.add(table);
    }
    
    if(snapshot.docs.isEmpty){
      return Text("登録されているシフト表はありません", style: MyFont.defaultStyleGrey15);
    }else{
      return Column(
        children: [
          for(var shift in shifts)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: MyFont.secondaryBackgroundColor,
                    foregroundColor: MyFont.secondaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(shift.get('name'), style: MyFont.headlineStyleGreen20, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                        ),
                        Text("リクエスト期間 : ${DateFormat('yyyy/MM/dd').format(shift.get('request-start').toDate())} - ${DateFormat('yyyy/MM/dd').format(shift.get('request-end').toDate())}", style: MyFont.defaultStyleGrey15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                        Text("　シフト期間　 : ${DateFormat('yyyy/MM/dd').format(shift.get('work-start').toDate())} - ${DateFormat('yyyy/MM/dd').format(shift.get('work-end').toDate())}", style: MyFont.defaultStyleGrey15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const InputRequestWidget()));
                  },
                  onLongPress: () {
                    removeTable(firestore, shift.id);
                  },
                ),
                if(shift.get('user-id') == uid)
                const Positioned(
                  right: 20,
                  top: 20,
                  child: Icon(Icons.admin_panel_settings, size: 30.0, color: MyFont.primaryColor),
                ),
              ],
            ),
          ),
        ]
      );
    }
  }

  removeTable(FirebaseFirestore firestore, String tableId) async {
    firestore.collection('shift-table').doc(tableId).delete().then((_) {
    print("Document successfully deleted!");
    }).catchError((error) {
      print("Error removing document: $error");
    });
    
    firestore.collection('shift-request').where('table-refarence', isEqualTo: firestore.collection('shift-table').doc(tableId)).get().then((querySnapshot) {
      // 各ドキュメントに対して削除操作を行う
      for(var doc in querySnapshot.docs){
        doc.reference.delete().then((_) {
          print("Document successfully deleted!");
        }).catchError((error) {
          print("Error removing document: $error");
        });
        setState(() {});
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }
}