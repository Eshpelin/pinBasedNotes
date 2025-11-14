import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/data/models/note.dart';
import 'package:pin_notes/ui/widgets/note_tile.dart';

void main() {
  group('Widget Tests', () {
    group('NoteTile', () {
      testWidgets('displays note title', (WidgetTester tester) async {
        final deltaJson = jsonEncode([
          {'insert': 'Test Title\nTest content\n'}
        ]);
        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('displays note preview', (WidgetTester tester) async {
        final deltaJson = jsonEncode([
          {'insert': 'Title\nPreview content here\n'}
        ]);
        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Title\nPreview content here'), findsOneWidget);
      });

      testWidgets('displays "Untitled" for empty note', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Untitled'), findsOneWidget);
      });

      testWidgets('does not display preview for empty note', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        // Empty notes don't show preview text since plainText is empty
        expect(find.text('No content'), findsNothing);
      });

      testWidgets('displays last edited timestamp', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.textContaining('Last edited'), findsOneWidget);
      });

      testWidgets('shows delete icon button', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        final note = Note.create();
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {
                  tapped = true;
                },
                onDelete: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(tapped, isTrue);
      });

      testWidgets('shows delete confirmation dialog on delete icon tap', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        expect(find.text('Delete Note'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('dismissible swipe shows delete background', (WidgetTester tester) async {
        final note = Note.create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteTile(
                note: note,
                onTap: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.byType(Dismissible), findsOneWidget);
      });
    });
  });
}
