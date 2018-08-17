import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:fluro/fluro.dart';

import 'package:gramola/config/application.dart';
import 'package:gramola/config/connections.dart';
import 'package:gramola/config/routes.dart';
import 'package:gramola/config/stores.dart';
import 'package:gramola/config/theme.dart';

class AppComponent extends StatefulWidget {

  @override
  State createState() => new AppComponentState();
}

class AppComponentState extends State<AppComponent> 
            with StoreWatcherMixin<AppComponent> {

  // Never write to these stores directly. Use Actions.
  InitStore initStore;
  EventsStore eventsStore;

  AppComponentState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  /// Override this function to configure which stores to listen to.
  ///
  /// This function is called by [StoreWatcherState] during its
  /// [State.initState] lifecycle callback, which means it is called once per
  /// inflation of the widget. As a result, the set of stores you listen to
  /// should not depend on any constructor parameters for this object because
  /// if the parent rebuilds and supplies new constructor arguments, this
  /// function will not be called again.
  @override
  void initState() {
    super.initState();

    initStore = listenToStore(initStoreToken);
    eventsStore = listenToStore(eventStoreToken, handleEventStoreChanged);

    // Init class, resources...
    _init();
  }

  void _init() async {
    try {
      initRequestAction();
      Connections connections = await Connections.initConnections();
      print("Connections: ${connections}");
      if (connections != null) {
        initSuccessAction(connections);
      } else {
        initFailureAction('Error: no connections available');
        //_showSnackbar('Authentication failed!');    
      }
    } on PlatformException catch (e) {
      initFailureAction(e.message);
      //_showSnackbar('Authentication failed!');
    }
  }

    
  void handleEventStoreChanged(Store store) {
    EventsStore eventStore = store;
    if (eventStore.currentEvent == null) {
        // Cleaning
        print('>>>> Sample store-changed handler');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final app = new MaterialApp(
      title: 'Gramola!',
      theme: gramolaTheme,
      onGenerateRoute: Application.router.generator,
    );
    print("initial route = ${app.initialRoute}");
    return app;
  }
}

