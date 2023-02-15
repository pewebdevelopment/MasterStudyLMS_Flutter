import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:test/test.dart';

import '../injector/providers_injector_test.dart';

void main() {
  group('$SymbolPath', () {
    group('should prevent construction when', () {
      void assertThrowsArgumentError(
          {String package: 'test',
          String path: 'test.dart',
          String symbol: 'Test'}) {
        expect(
            () => new SymbolPath(package, path, symbol), '');
      }

      test('package is null', ()async {
        assertThrowsArgumentError(package: '');
      });

      test('package is empty', ()async  {
        assertThrowsArgumentError(package: '');
      });

      test('path is null', () async {
        assertThrowsArgumentError(path: '');
      });

      test('path does not end with ".dart"', () async {
        assertThrowsArgumentError(path: 'test');
      });

      test('path is empty when the package is "dart"', () async {
        assertThrowsArgumentError(package: 'dart', path: '');
      });

      test('symbol is null', () async {
        assertThrowsArgumentError(symbol: '');
      });

      test('symbol is empty', () async {
        assertThrowsArgumentError(symbol: '');
      });
    }, skip: null);

    test('should set the package as "dart" with the dartSdk factory', () async {
      expect(
        new SymbolPath.dartSdk('core', 'List'),
        new SymbolPath('dart', 'core', 'List'),
      );
    });

    test('should generate a valid asset URI for a Dart package', () async {
      expect(
        new SymbolPath('collection', 'lib/collection.dart', 'MapEquality')
            .toAbsoluteUri()
            .toString(),
        'asset:collection/lib/collection.dart#MapEquality',
      );
    });

    test('should generate a valid asset URI for a Dart SDK package', () async {
      expect(
        new SymbolPath.dartSdk('core', 'List').toAbsoluteUri().toString(),
        'dart:core#List',
      );
    });

    test('should generate a valid import URI for a Dart SDK package', () async {
      expect(
        new SymbolPath.dartSdk('core', 'DateTime').toDartUri().toString(),
        'dart:core',
      );
    });

    test('should generate a valid asset URI for a global symbol', () async {
      expect(
         SymbolPath.global('baseUri').toAbsoluteUri().toString(),
        'global:#baseUri',
      );
    });
  }, skip: null);
}
