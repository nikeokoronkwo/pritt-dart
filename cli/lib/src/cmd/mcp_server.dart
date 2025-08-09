

import 'dart:async';
import 'dart:io';

import 'package:dart_mcp/stdio.dart';
import 'package:pritt_ai/pritt_ai_cli.dart';

import '../cli/base.dart';

class MCPServerCommand extends PrittCommand {
  @override
  String get name => 'mcp-server';

  @override
  List<String> get aliases => ['mcp', 'ai'];

  @override
  String get summary => "Start the Pritt CLI's MCP Server to communicate with MCP clients";

  @override
  String get description => """
This command starts the MCP server implemented by the CLI, allowing for MCP clients like Claude to easily utilize the CLI with support for autocomplete prompts, tool calls for frequently queried commands, and more.
The MCP server implemented by the CLI is different from the one provided by the registry, however. 

NOTE: We only support instantiating this MCP server over stdio. We may consider adding support for running this as a server on system in the future.
""";

  // experimental
  @override
  bool get hidden => true;

  @override
  FutureOr? run() {
    return PrittCLIMCPServer(
      stdioChannel(input: stdin, output: stdout),
      runner: runner!
    );
  }
}