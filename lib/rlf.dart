import 'dart:mirrors';
import 'dart:async';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf/shelf_io.dart';

abstract class Application {
  void setupRoutes();
}

class Rlf {
  Rlf() {
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
          application.setupRoutes();
          return;
        }
      }
    }
  }

  Router get _shelfRouter => Zone.current[#RlfZoneData][#router] as Router;

  void start() {
    serve(_shelfRouter.handler, 'localhost', 8080);
  }
}
