import 'dart:async';
import 'package:dart_mcp/server.dart';


/// The MCP Server for the Pritt Registry (requires auth)
/// 
/// Makes use of the [ToolsSupport] mixin for handling tool calls
base class PrittMCPServer extends MCPServer 
  with ToolsSupport, PromptsSupport, CompletionsSupport {
  PrittMCPServer(super.channel) : super.fromStreamChannel(
    implementation: Implementation(
      name: 'The Pritt MCP Server for accessing Pritt Services', 
      version: '0.1.0'
    ),
    instructions: 'Call tools, prompts and other necessary things to access info about packages in the Pritt Registry'
  ) {
    registerTool(packageTool, _packageToolCall);
    registerTool(packageVersionTool, _packageVersionToolCall);
    addPrompt(packageSearchPrompt, _packageSearchPromptCall);
  }

  /// A tool for getting information about a given package
  static final packageTool = Tool(
    name: 'package_info', 
    description: 'Get information about a given package from the registry',
    inputSchema: Schema.object(
      properties: {
        'name': Schema.string(description: 'The name of the package, either as a single package (<name>) or a scoped package (@<scope>/<name>)'),
      },
      required: ['name']
    )
  );

  /// A tool for getting information about a given package version
  static final packageVersionTool = Tool(
    name: 'package_version', 
    description: 'Get information about a given version of a package from the registry',
    inputSchema: Schema.object(
      properties: {
        'name': Schema.string(description: 'The name of the package, either as a single package (<name>) or a scoped package (@<scope>/<name>)'),
        'version': Schema.string(description: 'The specific version of the package. Defaults to the latest package version')
      }
    )
  );

  /// A prompt option for searching for packages from the Pritt Registry
  static final packageSearchPrompt = Prompt(
    name: 'search_package',
    description: 'Search for a given package in the registry',
    arguments: [
      PromptArgument(name: 'name', required: true, description: 'The name of the package'),
      PromptArgument(name: 'language', description: 'The language the package is associated/implemented with')
    ]
  );

  FutureOr<CallToolResult> _packageToolCall(CallToolRequest request) {
    // get the package details
    throw UnimplementedError("TODO: Implement _packageToolCall");
  }

  FutureOr<CallToolResult> _packageVersionToolCall(CallToolRequest request) {
    throw UnimplementedError("TODO: Implement _packageVersionToolCall");
  }

  FutureOr<GetPromptResult> _packageSearchPromptCall(GetPromptRequest request) {
    throw UnimplementedError('TODO: Implement _packageSearchPromptCall');
  }
  
  @override
  FutureOr<CompleteResult> handleComplete(CompleteRequest request) {
    // TODO: implement handleComplete
    throw UnimplementedError();
  }
}