import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class Connections {
  final String loginApi;
  final String eventsApi;
  final String imagesApi;

  const Connections({this.loginApi, this.eventsApi, this.imagesApi});

  factory Connections.fromJson(Map<String, dynamic> json) {
    return new Connections(
      loginApi:  json['loginApi'],
      eventsApi: json['eventsApi'],
      imagesApi: json['imagesApi']
    );
  }

  static Future<Connections> initConnections() async {
    String connectionsString = await rootBundle.loadString('data/connections.json');
  
    Map<String, dynamic> json = (new JsonCodec()).decode(connectionsString);
    
    return new Connections.fromJson (json);
  }
}


