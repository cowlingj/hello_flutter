import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Page extends StatefulWidget {
  @override
  _PageState createState() {
    return _PageState();
  }
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return Router({
      "/": (ctx, _reg) => Container(color: Colors.red),
      "/cards": (_ctx, _reg) => Padding(
          padding: EdgeInsets.all(30),
          child: Container(color: Colors.green)
      ),
      "/cards/apply": (ctx, _reg) => Padding(
          padding: EdgeInsets.all(90),
          child: Container(
              color: Colors.blue,
              child: GestureDetector(onTap: () {
                Navigator.of(ctx).pushNamed("/cards/sent");
                })
          )
      ),
      "/cards/sent": (ctx, reg) {
        reg((doDefault){
          print("sent intercepted back, should pop: $doDefault");
          return false;
        });
        return WillPopScope(
            onWillPop: ()async {
              log("popping in route :)");
              return false;
            },
            child: Padding(
          padding: EdgeInsets.all(0),
          child: Container(
            color: Colors.yellow,
            child: GestureDetector(onTap: () {
              Navigator.of(ctx).pop();
            }),
          )));
      },
    },
    "/cards/apply",
    "/"
    );
  }
}

class Router extends StatefulWidget {
  final Map<String, WidgetBuilderHandlesBack> routes;
  final String initial;
  final String unknown;

  Router(this.routes, this.initial, this.unknown);

  @override
  State<StatefulWidget> createState() {
    return _RouterState(routes, initial, unknown);
  }
}

typedef WidgetBuilderHandlesBack(BuildContext ctx, Function(Function(bool)) registerOnPop);

class _RouterState extends State<Router> {
  final Map<String, WidgetBuilderHandlesBack> routes;
  final String initial;
  final String unknown;
  Function(bool) _onPop;

  void _registerOnPop(Function(bool) onPop) { _onPop = onPop; }

  _RouterState(this.routes, this.initial, this.unknown);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Navigator(
          initialRoute: initial,
          onUnknownRoute: (settings) => PageRouteBuilder(
              settings: settings,
              pageBuilder: (ctx, animIn, animOut) {
                _onPop = null;
                return routes[unknown](ctx, _registerOnPop);
        }),
          onGenerateRoute: (settings) {
              return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (ctx, animIn, animOut) {
                    print("building page: ${settings.name}");
                    _onPop = null;
                    var route = routes[settings.name];
                    if (route == null) {
                      return routes[unknown](ctx, _registerOnPop);
                    }
                    return route(ctx, _registerOnPop);
                  }
              );
          }),
    );
  }
}