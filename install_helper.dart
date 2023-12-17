import "dart:io";
// # Find the Protocol Compiler.

class ProtobufInstallHelper {
  String? findCompiler() {
    Map<String, String> env = Platform.environment;
    if (env.containsKey('PROTOC') && File(env['PROTOC']!).existsSync()) {
      return env['PROTOC'];
    }
    List<String> possiblePaths = [
      '../bazel-bin/protoc',
      '../bazel-bin/protoc.exe',
      'protoc',
      'protoc.exe',
      '../vsprojects/Debug/protoc.exe',
      '../vsprojects/Release/protoc.exe'
    ];

    for (String path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }
    // protoc = find_executable('protoc')

    return "protoc";
  }

  void genProto(String source, {bool required = true}) {
    if (!required && !File(source).existsSync()) {
      return;
    }
    String? protoc = findCompiler();
    Directory("./lib/gen/").create();
    List<String> protocArgs = ['-I.', '--dart_out=./lib/gen/', source];
    print("Generate Protobuf for $source");
    var result = Process.runSync(protoc!, protocArgs);
    if (result.exitCode == 0) {
      print(result.stdout);
    } else {
      print("Error");
      print(result.stderr);
    }
  }

  void build(String directory) {
    List<FileSystemEntity> entries =
        Directory(directory).listSync(recursive: true).toList();
    for (FileSystemEntity file in entries.whereType<File>()) {
      if (file.path.endsWith(".proto")) {
        genProto(file.path);
      }
    }
  }
}

void main() {
  var installHelper = ProtobufInstallHelper();
  installHelper.build("./submodule/temperature_proto");
}
