import 'package:rlf/rlf.dart';
import 'package:rlf/routing.dart';

class ExampleApplication implements Application {
  @override
  Type get routeDefinition => ExampleRouteDefinition;
}

class ExampleRouteDefinition extends RouteDefinition {
  void routes () {
    namespace('api/v1', () {
      get('/simple', SimpleController, #blah);
      resource(TestController, () {
        resource(OtherController);
      });
    });
  }
}

class TestController {
  Response index(Request req) {
    return new Response.ok("Test Controllers");
  }
}

class OtherController {
  Response index(Request req) {
    return new Response.ok(
        'Other Controller: ${req.getPathParameterAsInt('testId')}');
  }
}

class SimpleController {
  Response blah(Request req) {
    return new Response.ok('simple kk');
  }
}