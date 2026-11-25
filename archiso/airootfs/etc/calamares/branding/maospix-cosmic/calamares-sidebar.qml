/* MAOSPIX-COSMIC: barra lateral de Calamares (lista de pasos con estado). */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: sideBar
    anchors.fill: parent
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#0d1536" }
        GradientStop { position: 1.0; color: "#150a30" }
    }

    readonly property color cyan: "#20e7f2"
    readonly property color violet: "#9658ff"
    readonly property color text: "#c9d3f2"
    readonly property color muted: "#6f7ba3"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 6

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            sourceSize.width: 104
            sourceSize.height: 104
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "MAOSPIX"
            color: sideBar.cyan
            font.pixelSize: 20
            font.bold: true
            font.letterSpacing: 4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "C O S M I C"
            color: sideBar.violet
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 3
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            height: 2
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: sideBar.cyan }
                GradientStop { position: 0.7; color: sideBar.violet }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Repeater {
            model: ViewManager

            Item {
                id: step
                readonly property bool current: index === ViewManager.currentStepIndex
                readonly property bool done: index < ViewManager.currentStepIndex
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    visible: step.current
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#3320e7f2" }
                        GradientStop { position: 1.0; color: "#339658ff" }
                    }
                    border.width: 1
                    border.color: "#6620e7f2"
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 12

                    Rectangle {
                        width: 24; height: 24; radius: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: step.current ? sideBar.cyan : (step.done ? "#2a9658ff" : "transparent")
                        border.width: step.current ? 0 : 1
                        border.color: step.done ? sideBar.violet : sideBar.muted
                        Text {
                            anchors.centerIn: parent
                            text: step.done ? "✓" : (index + 1)
                            color: step.current ? "#05091f" : (step.done ? sideBar.cyan : sideBar.muted)
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: step.width - 56
                        text: display
                        elide: Text.ElideRight
                        color: step.current ? "#ffffff" : (step.done ? sideBar.text : sideBar.muted)
                        font.pixelSize: 14
                        font.bold: step.current
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            text: "Arch Linux · COSMIC · Tiling"
            color: sideBar.muted
            font.pixelSize: 11
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 6
            text: "Hecho en Paraguay por maospytek"
            color: sideBar.muted
            font.pixelSize: 10
        }
    }
}
