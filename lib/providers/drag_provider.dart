import 'package:automate_challenge_flutter_app/models/state.dart';
import 'package:flutter/widgets.dart';

class DragProvider extends ChangeNotifier {
  late List<Etat> listOfDraggedStates;

  void init() {
    listOfDraggedStates = List.empty(growable: true);
  }

  void addState(Etat state) {
    listOfDraggedStates.add(state);
    notifyListeners();
  }

  void editState(Etat etat) {
    listOfDraggedStates[etat.id] = etat;
    notifyListeners();
  }
  void clean(){
    listOfDraggedStates.clear();
    notifyListeners();
  }
  void deleteState(int id) {
    listOfDraggedStates.removeAt(id);
    listOfDraggedStates = List.generate(listOfDraggedStates.length,
        ((index) => listOfDraggedStates[index].copyWith(id: index)));
    notifyListeners();
  }

  void updateLabelbyId(int id, String label) {
    listOfDraggedStates[id] = listOfDraggedStates[id].copyWith(label: label);
    notifyListeners();
  }
}
