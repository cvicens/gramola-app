import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:gramola/model/event.dart';
import 'package:gramola/model/subject.dart';

class Location {
  final String country;
  final String city;

  const Location({this.country, this.city});

}

class BaseStore extends Store {
  bool _fetching = false;
  bool _error = false;
  
  String _errorMessage = '';

  bool get isFetching => _fetching;
  bool get isError => _error;

  String get errorMessage => _errorMessage;

  BaseStore();
}

class LoginStore extends BaseStore {
  bool _authenticated = false;
  String _username;
  dynamic _result;
  
  bool get isAuthenticated => _authenticated;
  String get username => _username;
  dynamic get result => _result;

  LoginStore() {
    triggerOnAction(authenticateRequestAction, (String username) {
        _fetching = true;
        _error = false;
        _authenticated = false;
        _username = username;
    });

    triggerOnAction(authenticateSuccessAction, (Subject result) {
        _fetching = false;
        _authenticated = true;
        _result = result;
    });

    triggerOnAction(authenticateFailureAction, (String errorMessage) {
      _fetching = false;
      _error = true;
      _errorMessage = errorMessage;
    });
  }
}

class EventsStore extends BaseStore {
  String _currentCountry = 'SPAIN';
  String _currentCity = 'MADRID';

  String _imagesBaseUrl;

  dynamic _result;

  List<Event> _events = <Event>[];
  Event _currentEvent;
  
  String get currentCountry => _currentCountry;
  String get currentCity => _currentCity;

  String get imagesBaseUrl => _imagesBaseUrl;

  dynamic get result => _result;

  List<Event> get events => new List<Event>.unmodifiable(_events);
  Event get currentEvent => _currentEvent;

  EventsStore() {
    triggerOnAction(fetchEventsRequestAction, (String _) {
        _fetching = true;
        _error = false;
    });

    triggerOnAction(fetchEventsSuccessAction, (List<Event> events) {
        _fetching = false;
        _events = events;
    });

    triggerOnAction(fetchEventsFailureAction, (String errorMessage) {
      _fetching = false;
      _errorMessage = errorMessage;
    });

    triggerOnAction(fetchCloudUrlRequestAction, (String _) {
        _fetching = true;
        _error = false;
    });

    triggerOnAction(fetchCloudUrlSuccessAction, (String result) {
        _fetching = false;
        _imagesBaseUrl = result;
    });

    triggerOnAction(fetchCloudUrlFailureAction, (String errorMessage) {
      _fetching = false;
      _errorMessage = errorMessage;
    });

    triggerOnAction(setLocationAction, (Location location) {
      assert(location != null);
      _currentCountry = location.country;
      _currentCity = location.city;
    });

    triggerOnAction(selectEvent, (Event event) {
      assert(event != null);
      _currentEvent = event;
    });
  }
}

final StoreToken eventStoreToken = new StoreToken(new EventsStore());
final StoreToken loginStoreToken = new StoreToken(new LoginStore());

final Action<String> initPluginRequestAction = new Action<String>();
final Action<String> initPluginSuccessAction = new Action<String>();
final Action<String> initPluginFailureAction = new Action<String>();

final Action<String> initSdkRequestAction = new Action<String>();
final Action<String> initSdkSuccessAction = new Action<String>();
final Action<String> initSdkFailureAction = new Action<String>();

final Action<dynamic> pushNotificationReceivedAction = new Action<dynamic>();

final Action<String>  authenticateRequestAction = new Action<String>();
final Action<Subject> authenticateSuccessAction = new Action<Subject>();
final Action<String>  authenticateFailureAction = new Action<String>();


final Action<String>  fetchEventsRequestAction = new Action<String>();
final Action<List<Event>> fetchEventsSuccessAction = new Action<List<Event>>();
final Action<String>  fetchEventsFailureAction = new Action<String>();

final Action<String> fetchCloudUrlRequestAction = new Action<String>();
final Action<String> fetchCloudUrlSuccessAction = new Action<String>();
final Action<String> fetchCloudUrlFailureAction = new Action<String>();

final Action<Location> setLocationAction = new Action<Location>();
final Action<Event> selectEvent = new Action<Event>();