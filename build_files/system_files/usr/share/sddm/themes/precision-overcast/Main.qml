// Umizaru — Precision Overcast SDDM theme (Qt6 / SDDM greeter API).
// Dark register: Slate surfaces, one Glacier accent, Geist Mono for fixed text.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#131a26" // slate-900

    // Precision Overcast palette
    readonly property color cSurface:   "#1f2937" // slate-800
    readonly property color cRaised:    "#2a3445"
    readonly property color cText:      "#e2e7ee"
    readonly property color cTextDim:   "#a8b3c4"
    readonly property color cAccent:    "#4a7d9b" // glacier-500 (fills)
    readonly property color cAccentLt:  "#8eb5cc" // glacier-300 (text/links)
    readonly property color cOutline:   "#3e4a60"
    readonly property color cError:     "#b47362" // aurora-rust

    readonly property string fontSans: "Schibsted Grotesk"
    readonly property string fontMono: "Geist Mono"

    function doLogin() {
        errorLabel.text = ""
        sddm.login(username.text, password.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorLabel.text = "Authentication failed."
            password.text = ""
            password.forceActiveFocus()
        }
    }

    // Soft overcast gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16202f" }
            GradientStop { position: 1.0; color: "#131a26" }
        }
    }

    // Thin glacier horizon line (brand motif)
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        opacity: 0.25
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: root.cAccentLt }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Clock
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 120
        spacing: 4
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cText
            font.family: root.fontSans
            font.pixelSize: 72
            font.weight: Font.DemiBold
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cTextDim
            font.family: root.fontMono
            font.pixelSize: 15
            text: Qt.formatDate(new Date(), "dddd, MMMM d").toUpperCase()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "HH:mm")
            dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM d").toUpperCase()
        }
    }

    // Login card
    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: col.implicitHeight + 48
        radius: 12
        color: root.cSurface
        border.color: root.cOutline
        border.width: 1

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "UMIZARU"
                color: root.cAccentLt
                font.family: root.fontMono
                font.pixelSize: 14
                font.letterSpacing: 2
            }

            TextField {
                id: username
                Layout.fillWidth: true
                placeholderText: "Username"
                placeholderTextColor: root.cTextDim
                text: userModel.lastUser
                color: root.cText
                font.family: root.fontSans
                font.pixelSize: 15
                selectByMouse: true
                background: Rectangle {
                    radius: 4
                    color: root.cRaised
                    border.color: username.activeFocus ? root.cAccent : root.cOutline
                    border.width: 1
                }
                onAccepted: password.forceActiveFocus()
            }

            TextField {
                id: password
                Layout.fillWidth: true
                placeholderText: "Password"
                placeholderTextColor: root.cTextDim
                echoMode: TextInput.Password
                color: root.cText
                font.family: root.fontSans
                font.pixelSize: 15
                selectByMouse: true
                background: Rectangle {
                    radius: 4
                    color: root.cRaised
                    border.color: password.activeFocus ? root.cAccent : root.cOutline
                    border.width: 1
                }
                onAccepted: root.doLogin()
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "Sign in"
                font.family: root.fontSans
                font.pixelSize: 15
                onClicked: root.doLogin()
                background: Rectangle {
                    radius: 4
                    color: loginButton.down ? "#2d5773" : root.cAccent
                }
                contentItem: Text {
                    text: loginButton.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: loginButton.font
                }
            }

            Text {
                id: errorLabel
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 14
                color: root.cError
                font.family: root.fontMono
                font.pixelSize: 12
                text: ""
            }
        }
    }

    // Power controls
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 18

        Text {
            visible: sddm.canReboot
            text: "Restart"
            color: root.cTextDim
            font.family: root.fontMono
            font.pixelSize: 13
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "Shut down"
            color: root.cTextDim
            font.family: root.fontMono
            font.pixelSize: 13
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
        }
    }

    // Session indicator (niri-only)
    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 24
        text: "niri"
        color: root.cTextDim
        font.family: root.fontMono
        font.pixelSize: 13
    }

    Component.onCompleted: {
        if (username.text.length > 0)
            password.forceActiveFocus()
        else
            username.forceActiveFocus()
    }
}
