# re_editor 0.10.0 포크(daylight-editor-flutter)의 고친 점

- 글꼴 기능(OpenType feature)을 줄 수 있게 했다. 원본의 `CodeEditorStyle`에는 `fontFeatures`가 없어서 합자(ligature)를 끌 수 없었다.
  - `lib/src/code_editor.dart`: `CodeEditorStyle.fontFeatures`를 더하고, 편집기 본문 글꼴(`baseStyle`)에 넘긴다.
  - 구문 강조 조각은 이 글꼴을 이어받는다(엔진이 안 정한 값은 부모 것을 쓴다).
- 세로 블록(사각형) 선택: Alt(Option)+드래그. 원본은 선택이 연속된 한 구간뿐이다.
  - `code_line.dart`: `CodeBlockSelection`(줄 범위 + 열 범위)과 `CodeLineEditingController.blockSelection`을 더한다. 선택·글이 바뀌면 지워진다.
  - `_code_selection.dart`: Alt를 누르고 눌렀을 때 시작점을 기억해 드래그하면 `blockSelection`을 정한다.
  - `_code_field.dart`: `_CodeFieldBlockSelectionPainter`가 줄마다 같은 열 범위를 칠한다. `_code_line.dart`: `copy()`는 블록이 있으면 줄마다 잘라 줄바꿈으로 잇는다.
  - 열은 글자 위치(offset)다 — 한글 같은 넓은 글자가 섞이면 화면 열과 어긋날 수 있다. 블록이 있으면 `edit`(타이핑)·`deleteBackward/Forward/deleteSelection`·`cut`·`paste`가 블록을 줄마다 처리한다(`_replaceBlockColumns`) — 짧은 줄과 접힌 줄은 건드리지 않고, 처리 뒤에도 폭 0 블록이 남아 계속 이어 칠 수 있다. 입력기(IME, 한글)는 조합 범위를 알려 주지 않는 경우(macOS)가 있어, 커서 줄의 앞뒤 공통 부분을 비교해 바뀐 구간을 찾고 같은 열에 모든 줄을 같이 바꾼다(`edit`) — 'ㅎ'→'하'처럼 앞 글자를 바꾸는 조합도 된다.
- 원본이 고치면 되돌린다.
