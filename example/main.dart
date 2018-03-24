import 'package:rlf/routing.dart';
import 'package:shelf/shelf_io.dart';

void main() {
  namespace('api/v1', () {
    resource(TestController, () {
      resource(OtherController);
    });
  });
  serve(routerBuilder.handler, 'localhost', 8080);
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
