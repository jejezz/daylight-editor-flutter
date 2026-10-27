import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('블록 편집', () {
    CodeLineEditingController make() {
      final ctl = CodeLineEditingController.fromText('abcdef\nghijkl\nmn\nopqrst');
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 1, extentIndex: 3, extentColumn: 3);
      ctl.selection = const CodeLineSelection.collapsed(index: 3, offset: 3);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 1, extentIndex: 3, extentColumn: 3);
      return ctl;
    }

    test('삭제는 사각형만 지우고 열을 유지한다', () {
      final ctl = make();
      ctl.deleteBackward();
      expect(ctl.text, 'adef\ngjkl\nm\norst');
      expect(ctl.blockSelection.value, isNotNull);
      ctl.undo();
      expect(ctl.text, 'abcdef\nghijkl\nmn\nopqrst');
      ctl.dispose();
    });

    test('잘라내기는 복사한 뒤 지운다', () async {
      final ctl = make();
      ctl.cut();
      expect(ctl.text, 'adef\ngjkl\nm\norst');
      ctl.dispose();
    });

    test('폭 0 블록의 백스페이스는 앞 한 글자를, Delete는 뒤 한 글자를 지운다', () {
      final ctl = CodeLineEditingController.fromText('abc\nabc\nabc');
      ctl.selection = const CodeLineSelection.collapsed(index: 2, offset: 2);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 2, extentIndex: 2, extentColumn: 2);
      ctl.deleteBackward();
      expect(ctl.text, 'ac\nac\nac');
      ctl.deleteForward();
      expect(ctl.text, 'a\na\na');
      ctl.dispose();
    });

    test('붙여넣기는 줄 수가 맞으면 줄마다, 한 줄이면 모든 줄에 넣는다', () async {
      String? clip;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') return {'text': clip};
        return null;
      });
      final ctl = make();
      clip = '1\n2\n3\n4\n';
      ctl.paste();
      await Future<void>.delayed(Duration.zero);
      expect(ctl.text, 'a1def\ng2jkl\nm3\no4rst');
      clip = 'Z';
      final ctl2 = make();
      ctl2.paste();
      await Future<void>.delayed(Duration.zero);
      expect(ctl2.text, 'aZdef\ngZjkl\nmZ\noZrst');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
      ctl.dispose();
      ctl2.dispose();
    });

    test('타이핑은 모든 줄 같은 열에 들어가고 계속 이어진다', () {
      final ctl = make();
      // 커서 줄(opqrst, 열 3)에 X를 친 모양.
      ctl.edit(const TextEditingValue(text: 'opqXrst', selection: TextSelection.collapsed(offset: 4)));
      expect(ctl.text, 'aXdef\ngXjkl\nmX\noXrst');
      expect(ctl.blockSelection.value!.startColumn, 2);
      ctl.edit(const TextEditingValue(text: 'oXYrst', selection: TextSelection.collapsed(offset: 3)));
      expect(ctl.text, 'aXYdef\ngXYjkl\nmXY\noXYrst');
      ctl.dispose();
    });

    test('한글 조합(조합 범위를 알려 주지 않는 입력기 포함)은 모든 줄에서 같이 바뀐다', () {
      TextEditingValue v(String text, int caret, [TextRange composing = TextRange.empty]) =>
        TextEditingValue(text: text, selection: TextSelection.collapsed(offset: caret), composing: composing);
      final ctl = CodeLineEditingController.fromText('abc\nabc\nabc');
      ctl.selection = const CodeLineSelection.collapsed(index: 2, offset: 2);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 2, extentIndex: 2, extentColumn: 2);
      ctl.edit(v('abㅎc', 3));
      expect(ctl.text, 'abㅎc\nabㅎc\nabㅎc');
      ctl.edit(v('ab하c', 3));
      ctl.edit(v('ab한c', 3));
      expect(ctl.text, 'ab한c\nab한c\nab한c');
      ctl.edit(v('ab한c', 3)); // 확정
      ctl.edit(v('ab한ㄱc', 4));
      ctl.edit(v('ab한글c', 4));
      expect(ctl.text, 'ab한글c\nab한글c\nab한글c');
      expect(ctl.blockSelection.value, isNotNull);
      ctl.dispose();
    });
  });
}
