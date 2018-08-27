import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class Connections {
  final String loginApi;
  final String eventsApi;
  final String imagesApi;
  final String timelineApi;

  static Connections _connections;

  const Connections({this.loginApi, this.eventsApi, this.imagesApi, this.timelineApi});

  factory Connections.fromJson(Map<String, dynamic> json) {
    return new Connections(
      loginApi:  json['loginApi'],
      eventsApi: json['eventsApi'],
      imagesApi: json['imagesApi'],
      timelineApi: json['timelineApi']
    );
  }

  static Future<Connections> initConnections() async {
    if (Connections._connections == null) {
      String connectionsString = await rootBundle.loadString('data/connections.json');
      Map<String, dynamic> json = (new JsonCodec()).decode(connectionsString);
        
      Connections._connections = new Connections.fromJson (json);
    }

    return Connections._connections;
  }

  static Connections get connections => Connections._connections;
}