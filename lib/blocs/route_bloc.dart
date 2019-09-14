import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:lapis_lazuli/blocs/route_state.dart';
import 'package:lapis_lazuli/providers/google_maps_provider.dart';
import 'package:rxdart/rxdart.dart';

class RouteBloc extends BlocBase {
  final _showController = BehaviorSubject<bool>();
  final _stateController = BehaviorSubject<RouteState>();

  Stream<bool> get outShow => _showController.stream;

  bool get showValue => _showController.value;

  Stream<RouteState> get outState => _stateController.stream;

  RouteState get loginState => _stateController.value;

  RouteBloc() {
    _showController.add(false);
    _stateController.add(RouteState.IDLE);
  }

  void visible() {
    _showController.add(true);
  }

  void scrollable() {
    _showController.add(false);
  }

  void routing(GoogleMapsProvider googleMapsProvider)async{
    _stateController.add(RouteState.LOADING);

    try{
      await googleMapsProvider
          .sendRequest(googleMapsProvider.destinationController.text);

      if(googleMapsProvider.pracas.length>0){
        this.visible();
      }
      int pracas = googleMapsProvider.pracas.length;
      _stateController.add(pracas == 0 ? RouteState.IDLE: RouteState.SUCCESS);

    }catch(error){
      print("Localização inválida");
      print(error);
      _stateController.add(RouteState.FAIL );

    }


  }

  @override
  void dispose() {
    super.dispose();
    _showController.close();
    _stateController.close();
  }
}
