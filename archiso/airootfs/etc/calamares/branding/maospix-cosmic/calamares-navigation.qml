/* MAOSPIX-COSMIC: botones Atrás / Siguiente / Cancelar. */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: nav
    height: 64
    color: "#0a1029"

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: "#1e2a55"
    }

    component NavButton: Rectangle {
        id: btn
        property string label: ""
        property bool primary: false
        property bool flat: false
        signal clicked()
        implicitWidth: Math.max(120, caption.implicitWidth + 40)
        implicitHeight: 40
        radius: 12
        readonly property bool live: primary && enabled
        opacity: enabled ? 1.0 : 0.45
        color: flat ? (mouse.containsMouse ? "#16224a" : "transparent")
                    : (live ? "transparent" : (mouse.containsMouse && enabled ? "#1a2756" : "#121b40"))
        border.width: live || flat ? 0 : 1
        border.color: "#2f4a86"
        gradient: live ? primaryGradient : null
        Gradient {
            id: primaryGradient
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: mouse.containsMouse ? "#4ff0f8" : "#20e7f2" }
            GradientStop { position: 1.0; color: mouse.containsMouse ? "#ad7dff" : "#9658ff" }
        }
        Text {
            id: caption
            anchors.centerIn: parent
            text: btn.label.replace("&", "")
            color: btn.live ? "#05091f" : "#e6ecff"
            font.pixelSize: 14
            font.bold: btn.primary
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // Última pantalla: Calamares cambia "Cancelar" por "Hecho" y le pone el
    // ícono dialog-ok-apply. Ahí "Hecho" va a la derecha, resaltado, y se
    // ocultan Retroceder/Siguiente (Prueba 6: "Hecho" a la izquierda confundía).
    readonly property bool atEnd: ViewManager.quitIcon === "dialog-ok-apply"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 12

        NavButton {
            label: ViewManager.quitLabel
            flat: true
            enabled: ViewManager.quitEnabled
            visible: ViewManager.quitVisible && !nav.atEnd
            onClicked: ViewManager.quit()
        }

        Item { Layout.fillWidth: true }

        NavButton {
            label: ViewManager.backLabel
            enabled: ViewManager.backEnabled
            visible: ViewManager.backAndNextVisible && !nav.atEnd
            onClicked: ViewManager.back()
        }
        NavButton {
            label: ViewManager.nextLabel
            primary: true
            enabled: ViewManager.nextEnabled
            visible: ViewManager.backAndNextVisible && !nav.atEnd
            onClicked: ViewManager.next()
        }
        NavButton {
            label: ViewManager.quitLabel
            primary: true
            enabled: ViewManager.quitEnabled
            visible: nav.atEnd
            onClicked: ViewManager.quit()
        }
    }
}
