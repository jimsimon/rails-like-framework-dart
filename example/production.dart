import 'dart:developer';
import 'dart:async';
import 'dart:isolate' as i;
import 'dart:io';
import 'package:path/path.dart';
import 'package:rlf/rlf.dart';
import 'package:vm_service_lib/vm_service_lib.dart';
import 'package:vm_service_lib/vm_service_lib_io.dart';
import 'package:rlf/src/application.dart'; // TODO: Figure out how to load this dynamically

void main() async {
  Rlf rlf = new Rlf();
  rlf.reloadApplication();
  rlf.start();

  Uri serviceUri = (await Service.getInfo()).serverUri;
  VmService client = await vmServiceConnect(serviceUri.host, serviceUri.port);

  Stream<FileSystemEvent> fileSystemStream = Directory.current.watch(recursive: true);
  fileSystemStream.listen((FileSystemEvent event) {
    String relativePath = relative(event.path, from: Directory.current.uri.path);
    if (!relativePath.startsWith('.')) {
      String isolatedId = Service.getIsolateID(i.Isolate.current);
      client.reloadSources(isolatedId, force: true).then((ReloadReport report) {
        if (report.success) {
          print('Succesfully hot reloaded application');
          rlf.reloadApplication();
        } else {
          print('Hot reload failed! You may need to restart you application if this keeps happening');
        }
      });
    }
  });
}