import 'dart:mirrors';
import 'package:recase/recase.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart';

export 'package:shelf/shelf.dart' show Response;

class _Namespace {
  final String path;
  _Namespace parent;

  _Namespace(this.path);
}

class _RouterBuilder {
  final Router shelfRouter = router();
  _Namespace previousNamespace;

  void get(String path, Type controller, Symbol controllerFunction) {
    setupRoute('GET', path, controller, controllerFunction);
  }

  void put(String path, Type controller, Symbol controllerFunction) {
    setupRoute('PUT', path, controller, controllerFunction);
  }

  void post(String path, Type controller, Symbol controllerFunction) {
    setupRoute('POST', path, controller, controllerFunction);
  }

  void delete(String path, Type controller, Symbol controllerFunction) {
    setupRoute('DELETE', path, controller, controllerFunction);
  }

  void patch(String path, Type controller, Symbol controllerFunction) {
    setupRoute('PATCH', path, controller, controllerFunction);
  }

  void resource(Type controller, [Function nested]) {
    String controllerName = _getControllerName(controller);
    get('/${controllerName}', controller, #index);
    post('/${controllerName}', controller, #create);
    get('/${controllerName}/{${controllerName}Id}', controller, #show);
    put('/${controllerName}/{${controllerName}Id}', controller, #replace);
    patch('/${controllerName}/{${controllerName}Id}', controller, #amend);
    delete('/${controllerName}/{${controllerName}Id}', controller, #destroy);

    if (nested != null) {
      namespace('/${controllerName}/{${controllerName}Id}', nested);
    }
  }

  void namespace(String path, [Function nested]) {
    _Namespace namespace = new _Namespace(_normalizePathSegment(path));
    namespace.parent = previousNamespace;
    previousNamespace = namespace;
    if (nested != null) {
      nested();
    }
    previousNamespace = previousNamespace.parent;
  }

  void setupRoute(
      String verb, String path, Type controller, Symbol controllerFunction) {
    String namespacedPath = _normalizePathSegment(path);
    _Namespace currentNamespace = previousNamespace;
    while (currentNamespace != null) {
      namespacedPath = '${currentNamespace.path}$namespacedPath';
      currentNamespace = currentNamespace.parent;
    }

    shelfRouter.add(namespacedPath, [verb], (shelf.Request shelfRequest) {
      Request request = new Request(shelfRequest);
      ClassMirror cm = reflectClass(controller);
      InstanceMirror controllerInstance =
          cm.newInstance(const Symbol(''), <dynamic>[]);
      return controllerInstance
          .invoke(controllerFunction, <dynamic>[request]).reflectee;
    });
  }

  String _getControllerName(Type controller) {
    String className =
        MirrorSystem.getName(reflectClass(controller).simpleName);
    String path =
        className.substring(0, className.length - 'Controller'.length);
    return new ReCase(path).camelCase;
  }

  String _normalizePathSegment(String pathSegment) {
    String normalizedPathSegment = pathSegment;
    if (!normalizedPathSegment.startsWith('/')) {
      normalizedPathSegment = '/$normalizedPathSegment';
    }
    if (normalizedPathSegment.endsWith('/')) {
      normalizedPathSegment =
          normalizedPathSegment.substring(0, normalizedPathSegment.length - 1);
    }
    return normalizedPathSegment;
  }

  shelf.Handler get handler => shelfRouter.handler;
}

class Request extends shelf.Request {
  Map<String, Object> pathParams;

  Request(shelf.Request request) : super(request.method, request.requestedUri) {
    pathParams = getPathParameters(request);
  }

  String getPathParameterAsString(String param) {
    return pathParams[param] as String;
  }

  bool getPathParameterAsBool(String param) {
    return getPathParameterAsString(param) == 'true';
  }

  int getPathParameterAsInt(String param) {
    return int.parse(getPathParameterAsString(param));
  }

  double getPathParameterAsDouble(String param) {
    return double.parse(getPathParameterAsString(param));
  }

  String getQueryParameterAsString(String param) {
    return requestedUri.queryParameters[param];
  }

  bool getQueryParameterAsBool(String param) {
    return requestedUri.queryParameters[param] == 'true';
  }

  int getQueryParameterAsInt(String param) {
    return int.parse(requestedUri.queryParameters[param]);
  }

  double getQueryParameterAsDouble(String param) {
    return double.parse(requestedUri.queryParameters[param]);
  }

  List<String> getQueryParameterValuesAsStrings(String param) {
    return requestedUri.queryParametersAll[param];
  }

  List<bool> getQueryParameterValuesAsBools(String param) {
    return requestedUri.queryParametersAll[param]
        .map((value) => value == 'true')
        .toList();
  }

  List<int> getQueryParameterValuesAsInts(String param) {
    return requestedUri.queryParametersAll[param].map(int.parse).toList();
  }

  List<double> getQueryParameterValuesAsDoubles(String param) {
    return requestedUri.queryParametersAll[param].map(double.parse).toList();
  }
}

_RouterBuilder routerBuilder = new _RouterBuilder();

/// Defines a route that responds to a `GET` request to the specified [path] and calls the [controllerFunction] on the provided [controller]
///
/// Example: Route a `GET` request to `/addresses` to `AddressesController.fetchAll`
/// ```
///   get('/addresses', AddressesController, #fetchAll)
/// ```
Function get = routerBuilder.get;

/// Defines a route that responds to a `POST` request to the specified [path] and calls the [controllerFunction] on the provided [controller]
///
/// Example: Route a `POST` request to `/addresses` to `AddressesController.createOne`
/// ```
///   post('/addresses', AddressesController, #createOne)
/// ```
Function post = routerBuilder.post;

/// Defines a route that responds to a `PUT` request to the specified [path] and calls the [controllerFunction] on the provided [controller]
///
/// Example: Route a `PUT` request to `/addresses/{id}` to `AddressesController.replaceAll`
/// ```
///   put('/addresses/{id}', AddressesController, #replaceAll)
/// ```
Function put = routerBuilder.put;

/// Defines a route that responds to a `DELETE` request to the specified [path] and calls the [controllerFunction] on the provided [controller]
///
/// Example: Route a `DELETE` request to `/addresses/{id}` to `AddressesController.deleteOne`
/// ```
///   delete('/addresses/{id}', AddressesController, #deleteOne)
/// ```
Function delete = routerBuilder.delete;

/// Defines a route that responds to a `PATCH` request to the specified [path] and calls the [controllerFunction] on the provided [controller]
///
/// Example: Route a `PATCH` request to `/addresses/{id}` to `AddressesController.amendOne`
/// ```
///   patch('/addresses/{id}', AddressesController, #amendOne)
/// ```
Function patch = routerBuilder.patch;

/// Defines a path segment to append to the paths of any [nested] route configurations.
///
/// Example: Route a `GET` request to `/api/addresses/{id}` to `AddressesController.fetchOne`
/// ```
///   namespace('api', () {
///     get('/addresses/{id}', AddressesController, #fetchOne)
///   })
/// ```
///
/// [namespaces] can also include additional path parameters which will be available via the [Request] object passed to the [controllerFunction]:
/// ```
///   namespace('api/{version}', () {
///     get('/addresses/{id}', AddressesController, #fetchOne)
///   })
/// ```
Function namespace = routerBuilder.namespace;

/// The [resource] function wires up a standard set of routes to the specified [controller] class.
///
/// For example, calling `resource(AccountController)` will wire up all standard routes
/// to `AccountsController`.
///
/// The standard routes are as follows (using `'accounts'` as an example):
///
/// | Method | Route                 | Controller Function        | Purpose                                   |
/// | ------ | --------------------- | -------------------------- | ----------------------------------------- |
/// | GET    | /accounts             | AccountsController.index   | List all accounts                         |
/// | POST   | /accounts             | AccountsController.create  | Create a new account                      |
/// | GET    | /accounts/{accountId} | AccountsController.show    | Get a specific account                    |
/// | PUT    | /accounts/{accountId} | AccountsController.replace | Replace a specific account                |
/// | PATCH  | /accounts/{accountId} | AccountsController.amend   | Amend (partial update) a specific account |
/// | DELETE | /accounts/{accountId} | AccountsController.destroy | Delete a specific account                 |
///
///
/// An optional callback can be provided to the [nested] parameter to nest additional routes under a base path.
///
/// For example:
/// ```
///   resource(AccountController, () {
///     resource(EmailsController);
///   });
/// ```
///
/// The above example will define all of the previously mentioned routes for `AccountController` as well as the following additional routes for `EmailsController`:
///
/// | Method | Route                                  | Controller Function      | Purpose                                                           |
/// | ------ | -------------------------------------- | ------------------------ | ----------------------------------------------------------------- |
/// | GET    | /accounts/{accountId}/emails           | EmailsController.index   | List all emails for the specified account                         |
/// | POST   | /accounts/{accountId}/emails           | EmailsController.create  | Create a new email for the specified account                      |
/// | GET    | /accounts/{accountId}/emails/{emailId} | EmailsController.show    | Get a email for the specified account                             |
/// | PUT    | /accounts/{accountId}/emails/{emailId} | EmailsController.replace | Replace a specific email for the specified account                |
/// | PATCH  | /accounts/{accountId}/emails/{emailId} | EmailsController.amend   | Amend (partial update) a specific email for the specified account |
/// | DELETE | /accounts/{accountId}/emails/{emailId} | EmailsController.destroy | Delete a specific email for a specified account                   |
///
/// You can continue to nest [resource] calls as deeply as desired, however it's generally best to avoid nesting more than once to keep your application's routes easy to understand.
/// In addition to nesting other [resource]'s you can also use [namespace] and other route setup functions in a [resource]'s [nested] callback.
Function resource = routerBuilder.resource;
