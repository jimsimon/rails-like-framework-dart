import 'dart:developer';
import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:path/path.dart';
import 'package:rlf/rlf.dart';
import 'package:vm_service_client/vm_service_client.dart';

void main() async {
  Rlf rlf = new Rlf();
  rlf.reloadApplication();
  rlf.start();

  VMServiceClient client =
      new VMServiceClient.connect((await Service.getInfo()).serverUri);
  VM vm = await client.getVM();
  VMRunnableIsolate runnableIsolate =
      await getRunnableIsolate(vm, Isolate.current);

  Stream<FileSystemEvent> fileSystemStream = Directory.current.watch(recursive: true);
  fileSystemStream.listen((FileSystemEvent event) {
    String relativePath = relative(event.path, from: Directory.current.uri.path);
    if (!relativePath.startsWith('.')) {
      print('Detected file change, reloading sources...');
      runnableIsolate.reloadSources(force: true).then((dynamic report) {
        rlf.reloadApplication();
        print(report);
      });
    }
  });
}

Future<VMRunnableIsolate> getRunnableIsolate(VM vm, Isolate isolate) async {
  final isolates = await vm.isolates;

  // Find the isolate that we are running in.
  final isolateId = Service.getIsolateID(isolate);
  final serviceIsolate = isolates.firstWhere(
      (isolate) => 'isolates/${isolate.numberAsString}' == isolateId);

  final runnable = await serviceIsolate.loadRunnable();
  return runnable;
}
