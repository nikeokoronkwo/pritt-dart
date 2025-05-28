import 'package:mockito/annotations.dart';
import 'package:pritt_cli/src/client.dart';

import 'client.mocks.dart';

@GenerateNiceMocks([MockSpec<PrittClient>()])
export 'client.mocks.dart';
