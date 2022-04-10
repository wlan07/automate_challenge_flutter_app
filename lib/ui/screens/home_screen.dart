import 'package:automate_challenge_flutter_app/providers/drag_provider.dart';
import 'package:automate_challenge_flutter_app/ui/screens/widgets/drag_zone.dart';
import 'package:automate_challenge_flutter_app/ui/screens/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MyAppBar(),
            Expanded(
                child: ChangeNotifierProvider<DragProvider>(
                    create: (context) => DragProvider()..init(),
                    child: const MyHomeScreenDragZone())),
          ],
        ),
      ),
    );
  }
}
