import 'package:automate_challenge_flutter_app/enum/state_enum.dart';
import 'package:flutter/material.dart';

import '../../../models/state.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({Key? key}) : super(key: key);

  static const Size etatSize = Size(70, 70);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight * 1.5,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey))),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: StateType.values.length,
        separatorBuilder: (BuildContext context, int index) {
          return const VerticalDivider(
            color: Colors.black,
            width: 2.0,
            thickness: 2.0,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(StateType.values[index]);
        },
      ),
    );
  }

  Widget _buildItem(StateType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Draggable<StateType>(
        data: type,
        feedback: Image.asset(
          Etat.imageByType(type),
          width: MyAppBar.etatSize.width,
          height: MyAppBar.etatSize.height,
        ),
        child: Image.asset(
          Etat.imageByType(type),
          width: MyAppBar.etatSize.width,
          height: MyAppBar.etatSize.height,
        ),
      ),
    );
  }
}
