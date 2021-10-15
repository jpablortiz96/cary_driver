import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cary_driver/Models/allUsers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'Models/drivers.dart';

String mapKey = "AIzaSyCcDM4BiG4Ai0hV0c9jXFj1KVnnbaXR_v0";

User firebaseUser;

Users userCurrentInfo;

User currentfirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

Drivers driversInformation;


