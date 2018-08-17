import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:gramola/components/login/login_component.dart';
import 'package:gramola/components/events/events_component.dart';

var loginHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new LoginComponent();
});

var eventsRouteHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String country = params["country"]?.first;
  String city = params["city"]?.first;
  return new EventsComponent(country: country, city: city);
});