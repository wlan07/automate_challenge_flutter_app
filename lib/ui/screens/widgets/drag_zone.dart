import 'dart:developer';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:arrow_path/arrow_path.dart';
import 'package:automate_challenge_flutter_app/enum/state_enum.dart';
import 'package:automate_challenge_flutter_app/models/state.dart';
import 'package:automate_challenge_flutter_app/providers/drag_provider.dart';
import 'package:automate_challenge_flutter_app/ui/screens/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomeScreenDragZone extends StatefulWidget {
  const MyHomeScreenDragZone({Key? key}) : super(key: key);

  @override
  State<MyHomeScreenDragZone> createState() => _MyHomeScreenDragZoneState();
}

class _MyHomeScreenDragZoneState extends State<MyHomeScreenDragZone> {
  int? startingConnectFrom;

  late ScreenshotController screenshotController;

  final List<Map<String, dynamic>> lines = [];

  @override
  void initState() {
    screenshotController = ScreenshotController();
    super.initState();
  }

  void _takeScreenShot() async {
    Permission.storage.request().then((value) {
      if (value == PermissionStatus.granted) {
        screenshotController.capture().then((value) async {
          if (value != null) {
            final result = await ImageGallerySaver.saveImage(
                Uint8List.fromList(value),
                quality: 60,
                name: "automateee" + DateTime.now().toString());
            if (result["isSuccess"]) {
              _showSnackBar("Image Saved Succesfully ${result["filePath"]}");
            }
          }
        });
      }
    });
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Consumer<DragProvider>(builder: (context, model, child) {
          return Screenshot(
            controller: screenshotController,
            child: Container(
              color: Colors.white,
              child: CustomPaint(
                foregroundPainter: LinesPainter(
                  lines,
                  context,
                  (int id) {
                    showDialogAndReturnTapedText(lines[id]["label"])
                        .then((value) {
                      lines[id]["label"] = value;
                      setState(() {});
                    });
                  },
                ),
                child: DragTarget(
                  onWillAccept: (data) => true,
                  onAcceptWithDetails: (data) {
                    if (data.data is StateType) {
                      final id = context
                          .read<DragProvider>()
                          .listOfDraggedStates
                          .length;
                      context.read<DragProvider>().addState(Etat(
                          type: data.data as StateType,
                          id: id,
                          offset: data.offset));
                    } else {
                      context.read<DragProvider>().editState(
                          (data.data as Etat).copyWith(offset: data.offset));
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                        alignment: Alignment.center,
                        children: List.generate(
                          model.listOfDraggedStates.length,
                          (index) =>
                              _buildItem(model.listOfDraggedStates[index]),
                        ));
                  },
                ),
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _restart,
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  child: const Icon(Icons.restart_alt_outlined, size: 40),
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              GestureDetector(
                onTap: _takeScreenShot,
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 40.0,
                  ),
                  color: Colors.grey.withOpacity(0.1),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _restart() {
    lines.clear();
    startingConnectFrom = null;
    context.read<DragProvider>().clean();
  }

  Widget _buildItem(Etat etat) {
    final Color color = startingConnectFrom != null
        ? startingConnectFrom == etat.id
            ? Colors.black
            : Colors.red
        : Colors.black;
    return Positioned(
      top: etat.offset.dy - (kToolbarHeight * 1.5),
      left: etat.offset.dx,
      height: MyAppBar.etatSize.height,
      width: MyAppBar.etatSize.width,
      child: PopupMenuButton(
        tooltip: "",
        onSelected: (_) {
          switch (_) {
            case "add-connection":
              _addConnect(etat);
              break;
            case "accept-connection":
              _acceptConnect(etat);
              break;
            case "cancel-connection":
              _cancelConnect();
              break;
            case "delete":
              _deleteEtat(etat.id);
              break;
            case "rename":
              showtextInputDialog(etat);
              break;
            default:
          }
        },
        itemBuilder: (BuildContext bc) {
          return [
            PopupMenuItem(
              child: Text(startingConnectFrom != null
                  ? startingConnectFrom == etat.id
                      ? "Cancel Connection"
                      : "Accept Connection"
                  : "Add Connection"),
              value: startingConnectFrom != null
                  ? startingConnectFrom == etat.id
                      ? "cancel-connection"
                      : "accept-connection"
                  : "add-connection",
            ),
            const PopupMenuItem(
              child: Text("Rename"),
              value: "rename",
            ),
            const PopupMenuItem(
              child: Text("Delete"),
              value: "delete",
            ),
          ];
        },
        child: Draggable<Etat>(
            data: etat,
            feedback: Image.asset(
              etat.image,
              height: MyAppBar.etatSize.height,
              width: MyAppBar.etatSize.width,
              color: color,
            ),
            child: Image.asset(
              etat.image,
              color: color,
            )),
      ),
    );
  }

  void _addConnect(Etat etat) {
    startingConnectFrom = etat.id;

    setState(() {});
  }

  void _cancelConnect() {
    startingConnectFrom = null;

    setState(() {});
  }

  void _acceptConnect(Etat etat) {
    lines.add({
      "start": startingConnectFrom!,
      "end": etat.id,
      "label": "$startingConnectFrom-${etat.id}"
    });
    _cancelConnect();
    setState(() {});
  }

  void _deleteEtat(int id) {
    _removeFromLinesConnectsbyId(id);
    context.read<DragProvider>().deleteState(id);
  }

  void _removeFromLinesConnectsbyId(int id) {
    log("ID $id");
    lines.removeWhere((element) {
      if (element["start"] == id || element["end"] == id) {
        return true;
      }
      return false;
    });
  }

  void showtextInputDialog(Etat etat) {
    final model = context.read<DragProvider>();
    showDialogAndReturnTapedText((etat.label ?? etat.id).toString())
        .then((value) {
      model.updateLabelbyId(etat.id, value);
//       for (int i=0;i<lines.length;i++){
//  if (lines[i]["start"]==etat.id){
//               lines[i]["label"] = "$label-${lines[i]["end"]}";
//           }
//           if (lines[i]["end"] ==etat.id){

//           }

//       }
    });
  }

  Future<String> showDialogAndReturnTapedText(String defaultValue) async {
    final TextEditingController _controller = TextEditingController();
    return (await showDialog(
            context: context,
            barrierColor: Colors.grey.withOpacity(0.7),
            builder: (_) {
              return Center(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Container(
                      height: 100,
                      width: 150,
                      color: Colors.white,
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        decoration: InputDecoration(hintText: defaultValue),
                        onEditingComplete: () {
                          Navigator.maybePop(
                              context,
                              _controller.text.isNotEmpty
                                  ? _controller.text
                                  : defaultValue);
                        },
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              );
            })) ??
        defaultValue;
  }
}

class LinesPainter extends CustomPainter {
  LinesPainter(this.lines, this.context, this.onConnectionLabelTaped);
  final List<Map<String, dynamic>> lines;
  final BuildContext context;
  final void Function(int id) onConnectionLabelTaped;
  final List<Map<String, dynamic>> connectionLabelsOffsets = [];

  @override
  bool? hitTest(Offset position) {
    final int index = connectionLabelsOffsets.indexWhere((element) {
      return position.dx > element["offset"].dx &&
          position.dx <= element["offset"].dx + 40.0 &&
          position.dy > element["offset"].dy &&
          position.dy <= element["offset"].dy + 40.0;
    });

    if (index >= 0) {
      log("FOUNDDDDDDDDDDDDDDD ${connectionLabelsOffsets[index]["id"]}");
      onConnectionLabelTaped(connectionLabelsOffsets[index]["id"]);
      return true;
    }

    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;
    TextSpan textSpan;
    TextPainter textPainter;
    Path path;

    context.read<DragProvider>().listOfDraggedStates.forEach((element) {
      textSpan = TextSpan(
        text: "${element.label ?? element.id}",
        style: const TextStyle(
            color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
      );
      textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      final dx = element.offset.dx;
      final dy = element.offset.dy;

      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(dx, dy).translate(MyAppBar.etatSize.width / 2 - 5.0,
              -MyAppBar.etatSize.height * .9));
    });

    connectionLabelsOffsets.clear();

    for (int i = 0; i < lines.length; i++) {
      var startOffset = offsetById(lines[i]["start"]!);
      var endOffset = offsetById(lines[i]["end"]!);

      final reverseOffsets = startOffset.dx > endOffset.dx;

      startOffset = startOffset.translate(
          reverseOffsets ? 0.0 : MyAppBar.etatSize.width,
          -MyAppBar.etatSize.height * (reverseOffsets ? .6 : .7));
      endOffset = endOffset.translate(
          reverseOffsets ? MyAppBar.etatSize.width : 0.0,
          -MyAppBar.etatSize.height * (reverseOffsets ? .5 : 0.7));

      final dxStart = startOffset.dx;
      final dyStart = startOffset.dy;
      final dxEnd = endOffset.dx;
      final dyEnd = endOffset.dy;

      final conicDyControl =
          reverseOffsets ? max(dyStart, dyEnd) : min(dyStart, dyEnd) - 40.0;

      path = Path();
      path.moveTo(dxStart, dyStart);
      path.conicTo(
          dxStart + (dxEnd - dxStart) / 2, conicDyControl, dxEnd, dyEnd, 1.5);

      path = ArrowPath.make(path: path, tipAngle: pi * 0.15, tipLength: 10);
      canvas.drawPath(path, paint);

      textSpan = TextSpan(
        text: lines[i]["label"],
        style: const TextStyle(
            color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      connectionLabelsOffsets.add({
        "id": i,
        "offset": Offset(dxStart + (dxEnd - dxStart) / 2, conicDyControl)
      });
      textPainter.paint(
          canvas, Offset(dxStart + (dxEnd - dxStart) / 2, conicDyControl));
    }
  }

  Offset offsetById(int id) {
    return context.read<DragProvider>().listOfDraggedStates[id].offset;
  }

  @override
  bool shouldRepaint(LinesPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LinesPainter oldDelegate) => false;
}
