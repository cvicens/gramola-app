import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:gramola/model/event.dart';

import 'package:http/http.dart' as http;

import 'package:gramola/config/stores.dart';

import 'package:gramola/components/events/events_row_component.dart';

class EventsComponent extends StatefulWidget {

  EventsComponent({String country, String city})
      : this.country = country,
        this.city = city;

  final String country;
  final String city;

  @override
  _EventsComponentState createState() => new _EventsComponentState();
}

class _EventsComponentState extends State<EventsComponent> 
  with StoreWatcherMixin<EventsComponent>{

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();

  // Never write to these stores directly. Use Actions.
  InitStore initStore;
  EventsStore eventsStore;
  LoginStore loginStore;

  @override
  void initState() {
    super.initState();

    initStore = listenToStore(initStoreToken);
    eventsStore = listenToStore(eventStoreToken);
    loginStore = listenToStore(loginStoreToken);

    setLocationAction(new Location(country: 'ANY', city: 'ANY'));
    _fetchAllEvents();
  }

  void _fetchAllEvents() {
    _fetchEvents('ANY', 'ANY');
  }

  void _fetchEvents(String country, String city) async {
    try {
      fetchEventsRequestAction('');
      String _uri = country == 'ANY' || city == 'ANY' ? '' : country + '/' + city;
      dynamic response = await http.get(initStore.connections.eventsApi + '/' + _uri);
      if (response.statusCode == 200) {
        List<Event> events = (json.decode(response.body) as List).map((e) => new Event.fromJson(e)).toList();
        fetchEventsSuccessAction(events);
      } else {
        fetchEventsFailureAction('Error: ' + response.statusCode);
        _showSnackbar('Fetching events failed!');    
      }
    } on PlatformException catch (e) {
      fetchEventsFailureAction(e.message);
      _showSnackbar('Fetching events failed!');
    }
  }

  void _showSnackbar (String message) {
    final snackbar = new SnackBar(
      content: new Text(message),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _setLocationAction(Location location) {
    setLocationAction(location);
    Navigator.pop(context);
    _fetchEvents(location.country, location.city);
  }

  void _showChangeLocationDialog() {
    Container formSection = new Container(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child:  new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new RadioListTile<LocationEnum>(
            title: const Text('Madrid'),
            value: LocationEnum.madrid,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'SPAIN', city: 'MADRID')); },
          ),
          new RadioListTile<LocationEnum>(
            title: const Text('Barcelona'),
            value: LocationEnum.barcelona,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'SPAIN', city: 'BARCELONA')); },
          ),
          new RadioListTile<LocationEnum>(
            title: const Text('Paris'),
            value: LocationEnum.paris,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'FRANCE', city: 'PARIS')); },
          ),
          new RadioListTile<LocationEnum>(
            title: const Text('London'),
            value: LocationEnum.london,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'UK', city: 'LONDON')); },
          ),
          new RadioListTile<LocationEnum>(
            title: const Text('New York'),
            value: LocationEnum.new_york,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'US', city: 'NEW YORK')); },
          ),
          new RadioListTile<LocationEnum>(
            title: const Text('Any'),
            value: LocationEnum.any,
            groupValue: eventsStore.currentLocationEnum,
            onChanged: (LocationEnum value) { _setLocationAction(new Location(country: 'ANY', city: 'ANY')); },
          )
        ],
      )    
    );

    showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
      return new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            formSection
          ]
      );
    });
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String capitalizeWords(String s) {
    return s.splitMapJoin(" ", onMatch: (m) => m.group(0), onNonMatch: (m) => capitalize(m));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('List of events' + (eventsStore.currentCity != null && eventsStore.currentCity != 'ANY'? ' in ' + capitalizeWords(eventsStore.currentCity) : '')),
        leading: new IconButton(
            tooltip: 'Previous choice',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
             Navigator.pop(scaffoldKey.currentContext);
          },
        ),
        centerTitle: true,
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new Container(
              child: new ListView.builder(
                itemCount: eventsStore.events.length,
                itemBuilder: (_, index) => new EventRow(initStore.connections.imagesApi, eventsStore.events[index], loginStore.username),
              ),
            ),
          )
        ]
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: new Icon(Icons.location_city),
        onPressed: _showChangeLocationDialog
      )
    );
  }
}