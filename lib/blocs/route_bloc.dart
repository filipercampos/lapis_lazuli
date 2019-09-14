import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class RouteBloc extends BlocBase {

  final _showController = BehaviorSubject<bool>();

  Stream<bool> get outShow => _showController.stream;
  bool get showValue => _showController.value;

  RouteBloc(){
    _showController.add(false);
  }

  void visible()  {
    _showController.add(true);
  }
  void scrollable()  {
    _showController.add(false);
  }
  
  @override
  void dispose() {
    super.dispose();
    _showController.close();
  }
}