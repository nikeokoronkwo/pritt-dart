
import 'package:pritt_cli/src/plugins/base.dart';
import 'package:pritt_cli/src/plugins/base/workspace.dart';

final dartHandler = Handler(
  id: 'dart', 
  name: 'dart', 
  language: 'dart', 
  packageManager: PackageManager(name: 'pub', args: ['dart', 'pub']),
  onGetConfig: onGetConfig, 
  onGetWorkspace: onGetWorkspace, 
  onCheckWorkspace: onCheckWorkspace, 
  onConfigure: onConfigure
);