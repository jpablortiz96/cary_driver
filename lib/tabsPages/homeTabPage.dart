import 'dart:async';

import 'package:cary_driver/AllScreens/registerationscreen.dart';
import 'package:cary_driver/Models/drivers.dart';
import 'package:cary_driver/Notifications/pushNotificationService.dart';
import 'package:cary_driver/configMaps.dart';
import 'package:cary_driver/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
{
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  var geoLocator = Geolocator();

  String driverStatusText = "SIN SERVICIO";

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    super.initState();

    getCurrentDriverInfo();
  }

  void locatedPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //String address =  await AssistantMethods.searchCoordinateAddress(position, context);
    //print("Esta es tu dirección :: "+ address);
  }

  void getCurrentDriverInfo() async
  {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;

    driverRef.child(currentfirebaseUser.uid).once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value != null){
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatedPosition();

          },
        ),

        //online offline driver container

        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: ()
                  {

                    if(isDriverAvailable != true)
                    {
                      makeDriverOnlineNow();
                      getLocationLiveUpdate();

                      setState(() {
                        driverStatusColor = Colors.teal;
                        driverStatusText = "EN LÍNEA ";
                        isDriverAvailable = true;
                      });

                      displayToastMessage("Tu estas ahora en línea", context);

                    }else
                    {

                      makeDriverOfflineNow();

                      setState(() {
                        driverStatusColor = Colors.black;
                        driverStatusText = "SIN SERVICIO ";
                        isDriverAvailable = false;
                      });
                      displayToastMessage("Tu estas ahora sin servicio", context);

                    }

                  },
                  color: driverStatusColor,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(driverStatusText, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                        Icon(Icons.phone_android, color: Colors.white, size: 26.0,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    rideRequestRef.set("Buscando...");
    rideRequestRef.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdate()
  {
    homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if(isDriverAvailable == true)
      {
        Geofire.setLocation(currentfirebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;


  }

}
