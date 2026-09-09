import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls as QQC
import qs.Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool busy: false
  property string resultText: ""
  property bool autoTranslateOnPaste: false
  property int translateGen: 0
  property int runningGen: 0
  property string pendingTranslateText: ""

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(520), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(560), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.opened = true
    root.busy = false
    root.resultText = ""
    root.translateGen += 1
    root.autoTranslateOnPaste = true
    sourceArea.text = ""
    pasteProc.running = true
  }

  function applySourceText(value) {
    sourceArea.text = value
    sourceArea.cursorPosition = sourceArea.text.length
    sourceArea.forceActiveFocus()
    sourceArea.cursorPosition = sourceArea.text.length
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "dawei.ocr-translate")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function startTranslate() {
    var src = sourceArea.text
    if (!src || src.length === 0) {
      root.busy = false
      root.resultText = "原文为空"
      return
    }
    root.translateGen += 1
    var gen = root.translateGen
    root.pendingTranslateText = src
    root.busy = true
    root.resultText = ""
    if (translateProc.running) {
      translateProc.running = false
      Qt.callLater(function() {
        if (root.translateGen !== gen) return
        translateProc.stdinEnabled = true
        translateProc.running = true
      })
      return
    }
    translateProc.stdinEnabled = true
    translateProc.running = true
  }

  Process {
    id: pasteProc
    command: ["wl-paste", "--no-newline", "--type", "text"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.applySourceText(text)
        if (root.autoTranslateOnPaste && text.length > 0) {
          root.autoTranslateOnPaste = false
          Qt.callLater(function() { root.startTranslate() })
        } else {
          root.autoTranslateOnPaste = false
        }
      }
    }
    onExited: function(code, status) {
      if (sourceArea.text.length === 0) {
        if (code !== 0)
          root.applySourceText("")
        root.autoTranslateOnPaste = false
        return
      }
      if (root.autoTranslateOnPaste) {
        root.autoTranslateOnPaste = false
        Qt.callLater(function() { root.startTranslate() })
      }
    }
  }

  Process {
    id: translateProc
    command: [Quickshell.env("HOME") + "/.local/bin/omarchy-ocr-translate"]
    stdinEnabled: true
    stdout: StdioCollector { id: outCol; waitForEnd: true }
    stderr: StdioCollector { id: errCol; waitForEnd: true }
    onStarted: {
      root.runningGen = root.translateGen
      write(root.pendingTranslateText)
      stdinEnabled = false
    }
    onExited: function(code, status) {
      if (root.runningGen !== root.translateGen) return
      root.busy = false
      if (code === 0) root.resultText = outCol.text
      else root.resultText = (errCol.text || ("翻译失败 (exit " + code + ")")).trim()
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-ocr-translate"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Text {
          width: parent.width
          text: "原文"
          color: root.foreground
          opacity: 0.7
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }

        Rectangle {
          width: parent.width
          height: Math.floor((parent.height - root.contentSpacing * 4 - Style.font.bodySmall * 2 - Style.font.title) / 2)
          radius: root.cornerRadius
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)

          TextEdit {
            id: sourceArea
            anchors.fill: parent
            anchors.margins: Style.spacing.sm
            wrapMode: TextEdit.Wrap
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            activeFocusOnPress: true
            selectByMouse: true
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                root.dismiss()
                event.accepted = true
              } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                         && !(event.modifiers & Qt.ShiftModifier)) {
                root.startTranslate()
                event.accepted = true
              }
            }
          }
        }

        Text {
          width: parent.width
          text: root.busy ? "翻译中…" : "译文"
          color: root.foreground
          opacity: root.busy ? 1 : 0.7
          font.family: root.fontFamily
          font.pixelSize: root.busy ? Style.font.title : Style.font.bodySmall
        }

        Rectangle {
          width: parent.width
          height: parent.height - y
          radius: root.cornerRadius
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)

          QQC.TextArea {
            id: resultArea
            anchors.fill: parent
            anchors.margins: Style.spacing.sm
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: root.busy ? "翻译中…" : root.resultText
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            background: Item {}
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                root.dismiss()
                event.accepted = true
              }
            }
          }
        }
      }
    }
  }
}
