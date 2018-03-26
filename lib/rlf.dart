import 'dart:mirrors';
import 'dart:async';
import 'dart:io';
import 'package:rlf/routing.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf/shelf_io.dart';

abstract class Application {
  Type get routeDefinition;
}

class Rlf {

  Router _shelfRouter;

  void reloadApplication () {
    MirrorSystem ms = currentMirrorSystem();
    Iterable<LibraryMirror> libraries = ms.libraries.values;
    for (LibraryMirror lib in libraries) {
      Iterable<DeclarationMirror> declarations = lib.declarations.values;
      for (DeclarationMirror dec in declarations) {
        ClassMirror applicationClassMirror = reflectClass(Application);
        if (dec is ClassMirror && dec.superinterfaces.contains(applicationClassMirror)) {
          const constructor = const Symbol('');
          var arguments = <String>[];
          InstanceMirror im = dec.newInstance(constructor, arguments);
          Application application = im.reflectee;
          ClassMirror routesCm = reflectClass(application.routeDefinition);
          RouteDefinition routeDefinition = routesCm.newInstance(constructor, arguments).reflectee;
          _shelfRouter = routeDefinition.shelfRouter;
          return;
        }
      }
    }
  }

  Future<HttpServer> start() async {
    return await serve((shelf.Request req) => _shelfRouter.handler(req), 'localhost', 8080);
  }
}
