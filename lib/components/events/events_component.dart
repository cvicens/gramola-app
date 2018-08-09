import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:gramola/model/event.dart';

import 'package:http/http.dart' as http;

import 'package:gramola/config/connections.dart';
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
  EventsStore eventsStore;
  LoginStore loginStore;

  @override
  void initState() {
    super.initState();

    eventsStore = listenToStore(eventStoreToken);
    loginStore = listenToStore(loginStoreToken);

    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      fetchEventsRequestAction('');
      dynamic response = await http.get(Connections.eventsApi + "/" + eventsStore.currentCountry + "/" + eventsStore.currentCity);
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('List of events'),
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
                itemBuilder: (_, index) => new EventRow(Connections.imagesApi, eventsStore.events[index], loginStore.username),
              ),
            ),
          )
        ]
      )
    );
  }
}