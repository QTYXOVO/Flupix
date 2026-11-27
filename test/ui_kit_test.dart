import 'package:flupix/l10n/l10n.dart';
import 'package:flupix/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('SectionCard 与 TonalIcon 正常渲染', (tester) async {
    await tester.pumpWidget(
      _host(
        const SectionCard(
          child: Row(
            children: [
              TonalIcon(icon: Icons.folder_outlined),
              SizedBox(width: 12),
              Text('工具箱'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('工具箱'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(tester.widget<SectionCard>(find.byType(SectionCard)), isNotNull);
  });

  testWidgets('CopyableValue 显示标签与完整值', (tester) async {
    await tester.pumpWidget(
      _host(const CopyableValue(label: 'PHPSESSID', value: 'abc123')),
    );

    expect(find.text('PHPSESSID'), findsOneWidget);
    expect(find.text('abc123'), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });
}
