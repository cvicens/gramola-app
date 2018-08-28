import 'package:flutter_flux/flutter_flux.dart';
import 'package:gramola/config/connections.dart';

import 'package:gramola/model/event.dart';
import 'package:gramola/model/subject.dart';

// At the top level:
enum LocationEnum { madrid, barcelona, paris, london, new_york, any }

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

class InitStore extends BaseStore {
  bool _initialized = false;
  
  Connections _connections;

  bool get isInitialized => _initialized;
  Connections get connections => _connections;

  InitStore() {
    triggerOnAction(initRequestAction, (void _) {
        _fetching = true;
        _error = false;
        _initialized = false;
    });

    triggerOnAction(initSuccessAction, (Connections connections) {
        _fetching = false;
        _initialized = true;
        _connections = connections;
    });

    triggerOnAction(authenticateFailureAction, (String errorMessage) {
      _fetching = false;
      _error = true;
      _errorMessage = errorMessage;
    });
  }
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
  LocationEnum _location = LocationEnum.madrid;

  String _currentCountry = 'ANY';
  String _currentCity = 'ANY';

  String _imagesBaseUrl;

  dynamic _result;

  List<Event> _events = <Event>[];
  Event _currentEvent;
  
  LocationEnum get currentLocationEnum => _location;

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

      switch (location.city) {
        case 'MADRID':
          _location = LocationEnum.madrid;
          break;
        case 'BARCELONA':
          _location = LocationEnum.barcelona;
          break;
        case 'PARIS':
          _location = LocationEnum.paris;
          break;
        case 'LONDON':
          _location = LocationEnum.london;
          break;
        case 'NEW YORK':
          _location = LocationEnum.new_york;
          break;
        default:
          _location = LocationEnum.any;
      }
    });

    triggerOnAction(selectEvent, (Event event) {
      assert(event != null);
      _currentEvent = event;
    });
  }
}

final StoreToken initStoreToken = new StoreToken(new InitStore());
final StoreToken eventStoreToken = new StoreToken(new EventsStore());
final StoreToken loginStoreToken = new StoreToken(new LoginStore());

final Action<void>        initRequestAction = new Action<void>();
final Action<Connections> initSuccessAction = new Action<Connections>();
final Action<String>      initFailureAction = new Action<String>();

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
