import 'package:flutter_test/flutter_test.dart';
import 'package:flupix/core/update_service.dart';

void main() {
  group('normalizeVersion', () {
    test('去掉 v / V 前缀与空白', () {
      expect(normalizeVersion(' v1.2.3 '), '1.2.3');
      expect(normalizeVersion('V2.0.0'), '2.0.0');
      expect(normalizeVersion('1.0.0'), '1.0.0');
    });
  });

  group('compareVersions', () {
    test('按数字逐段比较', () {
      expect(compareVersions('1.2.3', '1.2.2'), 1);
      expect(compareVersions('1.2.0', '1.10.0'), -1);
      expect(compareVersions('1.0.0', '1.0.0'), 0);
      expect(compareVersions('v2.0.0', '1.99.99'), 1);
    });

    test('段数不同时缺失部分按 0 处理', () {
      expect(compareVersions('1.2', '1.2.0'), 0);
      expect(compareVersions('1.2.1', '1.2'), 1);
    });

    test('忽略预发布后缀与构建号', () {
      expect(compareVersions('1.2.3-beta.1', '1.2.3'), 0);
      expect(compareVersions('1.2.3+5', '1.2.3+1'), 0);
      expect(compareVersions('1.2.4-beta', '1.2.3'), 1);
    });
  });
}
