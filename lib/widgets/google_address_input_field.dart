import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lapis_lazuli/controllers/google_maps_controller.dart';

// ignore: must_be_immutable
class GoogleAddressInputField extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData iconData;
  final googleMapsController = GoogleMapsController();
  final Function(dynamic) onSubmitted;

  Address selectedAddress = Address();
  Address get getSelectedAddress => this.selectedAddress;
  LatLng coordinatesCallback;

  GoogleAddressInputField({
    @required this.controller,
    this.label,
    this.hint,
    this.iconData,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // componente que usa o typeahead para auto completar os lugares
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        cursorColor: Colors.black,
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          icon: Container(
            margin: EdgeInsets.only(left: 10),
            width: 15,
            height: 25,
            child: Icon( iconData,
              color: Theme.of(context).primaryColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
          contentPadding:
          EdgeInsets.only(top: 15, right: 5, bottom: 10, left: 5),
        ),
      ),
      // address available
      suggestionsCallback: (address) async {
        // recupera a lista de endereço
        try {
          var result = await googleMapsController.getAddressList(address);
          return result;
        } catch (error) {
          print(error);
        }
        return null;
      },
      // constói os itens
      itemBuilder: (context, suggestion) {
        var currentAddress = suggestion as Address;
        return ListTile(
          title: Text(currentAddress.addressLine),
        );
      },
      // função chamada quando um item é selecionado
      onSuggestionSelected: (suggestion) {
        var selectedAddress = suggestion as Address;
        controller.text = selectedAddress.addressLine;
        coordinatesCallback = LatLng(
          selectedAddress.coordinates.latitude,
          selectedAddress.coordinates.longitude,
        );
        this.selectedAddress = selectedAddress;
      },
    );
  }
}
