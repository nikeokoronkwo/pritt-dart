import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dart_mcp/server.dart';
import 'package:meta/meta.dart';

/// The MCP Server for accessing services from the Pritt CLI
base class PrittCLIMCPServer extends MCPServer with ToolsSupport, PromptsSupport {
  final CommandRunner runner;

  PrittCLIMCPServer(super.channel, {required this.runner}) : super.fromStreamChannel(
    implementation: Implementation(
      name: 'The Pritt MCP Server for accessing services from the Pritt CLI', 
      version: '0.1.0'
    ),
  ) {
    addPrompt(cliPrompt, _handleCliPrompt);
  }

  /// A tool for getting a package from Pritt unpacked into a given directory
  static final unpackPackageTool = Tool(
    name: 'pritt_download_package', 
    inputSchema: Schema.object(
      properties: {
        'name': Schema.string(),
        'version': Schema.string(),
        'dest': Schema.string()
      },
      required: ['name', 'dest']
    )
  );

  /// A tool for installing a package via Pritt for a given


  /// A tool for setting up a project for using Pritt
  

  /// A prompt for running a given command with the CLI (unimplemented)
  @experimental
  static final cliPrompt = Prompt(
    name: 'cli',
    description: 'Run a command with the Pritt CLI',
    arguments: [
      PromptArgument(
        name: 'arguments',
        description: 'The arguments to pass to the CLI'
      )
    ]
  );

  FutureOr<GetPromptResult> _handleCliPrompt(GetPromptRequest request) {
    throw UnimplementedError('TODO: Implement _handleCliPrompt');
  }

  
}
