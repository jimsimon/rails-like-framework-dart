import 'dart:async';
import 'package:rlf/routing.dart';
import 'package:rlf/rlf.dart';

void main() {
  runZoned(() {
    Rlf rlf = new Rlf();
    rlf.start();
  }, zoneValues: <Symbol, dynamic>{
    #RlfZoneData: <Symbol, dynamic>{}
  });
}

class ExampleApplication implements Application {
  @override
  void setupRoutes () {
    namespace('api/v1', () {
      resource(TestController, () {
        resource(OtherController);
      });
    });
  }
}

class TestController {
  Response index(Request req) {
    return new Response.ok("Test Controller");
  }
}

class OtherController {
  Response index(Request req) {
    return new Response.ok(
        'Other Controller: ${req.getPathParameterAsInt('testId')}');
  }
}
