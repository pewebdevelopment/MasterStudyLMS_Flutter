import 'package:build/build.dart';

import 'src/build/codegen_builder.dart';
import 'src/build/summary_builder.dart';

/// Create a [Builder] which produces `*.inject.dart` files from `*.dart` files.
InjectCodegenBuilder generateBuilder([_]) => const InjectCodegenBuilder();

class Builder {
}

/// Create a [Builder] which produces summary files used by [generateBuilder].
InjectSummaryBuilder summarizeBuilder([_]) => const InjectSummaryBuilder();
