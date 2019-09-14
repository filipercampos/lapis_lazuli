
class GeocodeAddress {
  String formattedAddress;
  String street;
  String number;
  String neighborhood;
  String city;
  String state;
  String stateInitials;
  String country;
  String countryInitials;
  String postalCode;
  double latitude;
  double longitude;

  GeocodeAddress({this.formattedAddress, this.street, this.number,
      this.neighborhood, this.city, this.state, this.stateInitials,
      this.country, this.countryInitials, this.postalCode, this.latitude,this.longitude});

  factory GeocodeAddress.fromJson(Map<String, dynamic> map){

    var results = map["results"][0];
    var a1 = _AddressComponent.fromMap(results["address_components"][0]) ;
    var a2 = _AddressComponent.fromMap(results["address_components"][1]);
    var a3 = _AddressComponent.fromMap(results["address_components"][2]);
    var a4 = _AddressComponent.fromMap(results["address_components"][3]);
    var a5 = _AddressComponent.fromMap(results["address_components"][4]);
    var a6 = _AddressComponent.fromMap(results["address_components"][5]);

    return GeocodeAddress(
      formattedAddress: map["results"][0]["formatted_address"],
      number: a1.longName,
      street: a2.longName,
      neighborhood: a3.longName,
      city: a3.longName,
      state: a4.shortName,
      stateInitials: a4.shortName,
      country: a5.longName,
      countryInitials: a5.shortName,
      postalCode: a6.longName,
      latitude: map["results"][0]["geometry"]["location"]["lat"],
      longitude: map["results"][0]["geometry"]["location"]["lng"],
    );
  }
}

class _AddressComponent {
  String longName;
  String shortName;

  _AddressComponent({
    this.longName,
    this.shortName,
  });

  factory _AddressComponent.fromMap(Map map){

    if(map == null){
      return _AddressComponent();
    }

    return _AddressComponent(
      longName: map["long_name"],
      shortName: map["short_name"]
    );
  }

}

