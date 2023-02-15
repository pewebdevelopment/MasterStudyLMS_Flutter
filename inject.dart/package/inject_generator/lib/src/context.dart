// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(yjbanov): clean up transitional analyzer API when final API is
//                available. Transitional API is marked with <TRANSITIONAL_API>.
//                See also: http://cl/219513934

import 'dart:async';
import 'package:analyzer/dart/analysis/results.dart';

// <TRANSITIONAL_API>
// </TRANSITIONAL_API>

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/build.dart' as build show log;
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

/// Runs [fn] within a [Zone] with its own [BuilderContext].
Future<E> runInContext<E>(dynamic buildStep, Future<E> fn()) {
  final completer = new Completer<E>();

  Chain.capture(
    () {
      return runZoned(
        () async {
          completer.complete(await fn());
        },
        zoneValues: {#builderContext: new BuilderContext._(buildStep)},
      );
    },
    onError: (e, chain) {
      completer.completeError(e, chain.terse);
    },
  );

  return completer.future;
}

/// Currently active [BuilderContext].
BuilderContext get builderContext {
  final context = Zone.current[#builderContext];
  if (context == null) {
    throw new StateError(
      'No current $BuilderContext is active. Start your build function using '
          '"runInContext" to be able to use "builderContext"',
    );
  }
  return context;
}

/// Contains services related to the currently executing [BuildStep].
class BuilderContext {
  /// The build step currently being processed.
  final dynamic buildStep;

  /// A logger that provides source locations.
  ///
  /// Example:
  ///
  ///     Element sourceElement = ...;
  ///     builderContext.log.warning(sourceElement,
  ///         'is not expected at this location.');
  final BuilderLogger log;

  BuilderContext._(dynamic buildStep)
      : this.buildStep = buildStep,
        log = new BuilderLogger(buildStep.inputId);

  /// The logger scoped to the current [buildStep] and therefore scoped to the
  /// currently processed input file.
  dynamic get rawLogger => build.log;
}

/// A logger that provides human-readable source code locations related to the
/// log messages.
class BuilderLogger {
  /// The primary asset being currently processed by the builder.
  final dynamic _inputId;

  /// Constructor.
  const BuilderLogger(this._inputId);

  /// Logs a warning adding [element]'s source information to the message.
  void warning(dynamic element, String message) {
    builderContext.rawLogger.warning(_constructMessage(element, message));
  }

  /// Logs a warning adding [element]'s source information to the message.
  void info(dynamic element, String message) {
    builderContext.rawLogger.info(_constructMessage(element, message));
  }

  /// Logs a warning adding [element]'s source information to the message.
  void severe(dynamic element, String message) {
    builderContext.rawLogger.severe(_constructMessage(element, message));
  }

  String _constructMessage(dynamic element, String message) {
    // <TRANSITIONAL_API>
    dynamic elementDeclaration;
    var ElementKind;
    if (element.kind != ElementKind.DYNAMIC) {
      var parsedLibrary = element.library?.session.getParsedLibraryByElement(element.library);
      var ResultState;
      if (parsedLibrary.state == ResultState.VALID) {
        elementDeclaration = parsedLibrary.getElementDeclaration(element);
      }
    }
    // </TRANSITIONAL_API>
    String sourceLocation;
    String source;

    if (element.source == null) {
      sourceLocation = 'at unknown source location:';
      source = '.';
    } else {
      var offset = elementDeclaration.node.offset;
      var location = elementDeclaration.parsedUnit.lineInfo.getLocation(offset);
      var code = elementDeclaration.node.toSource();
      sourceLocation = 'at $location:';
      source = ':\n\n$code';
    }

    return '${_inputId} ${sourceLocation} ${message}${source}';
  }
}



class ElementDeclarationResult {
}
