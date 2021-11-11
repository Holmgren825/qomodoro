// Includes relevant modules used by the QML
import QtQuick 2.6
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import Qt.labs.platform 1.1 as Labs
import org.kde.kirigami 2.13 as Kirigami

// Base element, provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // ID provides unique identifier to reference this element
    id: root
    height: 480
    width: 320
    // Window title
    // i18nc is useful for adding context for translators, also lets strings be changed for different languages
    title: i18nc("@title:window", "Qomodoro")
    // Menu drawer.
    globalDrawer: Kirigami.GlobalDrawer {
        id: main_menu
        isMenu: true
        actions: [
          Kirigami.Action {
            text: i18n("Quit")
            icon.name: "gtk-quit"
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
          }
        ]
     }

    Labs.SystemTrayIcon {
        id: sysTray
        visible: true
        icon.source: "icon1.png"
        tooltip: i18n("Wait")
        onActivated: {
            root.show()
        }
        menu: Labs.Menu {
            id: sysMenu
            visible: false
            Labs.MenuItem {
                id: trayControl
                onTriggered: playPause.toggle() 
            }
            Labs.MenuItem {
                text: i18n("Quit")
                onTriggered: Qt.quit()
            }
        }

    }

    // Initial page to be loaded on app load
    pageStack.initialPage: Kirigami.Page {
        id: main
        title: i18nc("@title", "Qomodoro")

        Controls.Label {
            // Center label horizontally and vertically within parent element
            // text: i18n("Kountdown")
        }

        // States. This is controlling the look of the buttons etc.
        states: [
            State {
                name: "wait";
                PropertyChanges{ target: main_title; text: i18n("Begin?") }
                PropertyChanges{ target: playPause; text: i18n("Start") }
                PropertyChanges{ target: trayControl; text: i18n("Start") }
                PropertyChanges{ target: root; visibility: "Windowed" }
                PropertyChanges{ target: sysTray; tooltip: i18n("Wait") }
                PropertyChanges{ target: sysTray; icon.source: "icon1.png" }
            },
            State {
                name: "work";
                PropertyChanges{ target: main_title; text: i18n("Work") }
                PropertyChanges{ target: playPause; text: i18n("Pause") }
                PropertyChanges{ target: trayControl; text: i18n("Pause") }
                PropertyChanges{ target: root; visibility: "Windowed" }
                PropertyChanges{ target: sysTray; tooltip: i18n("Work: " + timerString.text) }
                PropertyChanges{ target: sysTray; icon.source: "qrc:/icon" + timer.trayCount +  ".png" }
            },
            State {
                name: "pause"
                PropertyChanges{ target: main_title; text: i18n("Work paused") }
                PropertyChanges{ target: playPause; text: i18n("Continue") }
                PropertyChanges{ target: trayControl; text: i18n("Continue") }
                PropertyChanges{ target: root; visibility: "Windowed" }
                PropertyChanges{ target: sysTray; tooltip: i18n("Paused: " + timerString.text) }
            },
            State {
                name: "break"
                PropertyChanges{ target: buttons_column; visible: false }
                PropertyChanges{ target: main_title; text: i18n("Break") }
                PropertyChanges{ target: root; visibility: "FullScreen" }
                PropertyChanges{ target: sysTray; icon.source: "icon1.png" }
            },
            State {
                name: "long break"
                PropertyChanges{ target: main_title; text: i18n("Long break") }
                PropertyChanges{ target: buttons_column; visible: false }
                PropertyChanges{ target: root; visibility: "FullScreen" }
                PropertyChanges{ target: sysTray; icon.source: "icon1.png" }
            }
        ]
        state: "wait"

        Timer {
                id: timer
                property int value: workMinutes.value * 60
                property int session: 1
                property int trayCount: 1
                interval: 1000
                repeat: true
                running: false
                onTriggered: {
                    value = (value - 1)
                    minuteProgress.value = timer.value
                    if (main.state == "work") {
                        timer.update_tray()
                    }

                    if (value == 0 && main.state == "work" && session != workRounds.value) {
                        timer.start_break()
                    }
                    else if (value == 1 && main.state == "work") {
                        root.show()
                    }
                    else if (value == 0 && main.state == "break" && session != workRounds.value) {
                        timer.start_work()
                    }
                    else if (value == 0 && session == workRounds.value && main.state == "work") {
                        timer.start_long_break()
                    }
                    else if (value == 0 && main.state == "long break") {
                        timer.start_work()
                        timer.session = 1
                    }
            }
            function update () {
                timer.value = workMinutes.value * 60
                minuteProgress.value = workMinutes.value * 60
                minuteProgress.to =  workMinutes.value * 60
            }
            function start_work () {
                timer.value = workMinutes.value * 60
                minuteProgress.value = workMinutes.value * 60
                minuteProgress.to =  workMinutes.value * 60
                timer.stop()
                main.state = "wait"
                timer.session += 1
                timer.trayCount = 1
            }
            function start_break () {
                timer.value = shortBreakMinutes.value * 60
                minuteProgress.value = shortBreakMinutes.value * 60
                minuteProgress.to = shortBreakMinutes.value * 60
                main.state = "break"
            }
            function start_long_break () {
                timer.value = longBreakMinutes.value * 60
                minuteProgress.value = longBreakMinutes.value * 60
                minuteProgress.to = longBreakMinutes.value * 60
                main.state = "long break"
            }
            function update_tray () {
                if (timer.value % (workMinutes.value * 60 / 10) == 0 && timer.trayCount <= 10) {
                    timer.trayCount += 1

                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit

            Controls.Label {
                id: main_title
                Layout.alignment: Qt.AlignCenter
            }

            GridLayout {
                columns: 2
                Layout.alignment: Qt.AlignCenter
                Controls.Label {
                    id: timerString
                    text: new Date(timer.value * 1000).toLocaleTimeString(Qt.locale(), "mm" +  ":" + "ss")
                    Layout.alignment: Qt.AlignCenter
                }
                Controls.Label {
                    text: timer.session + "/" + workRounds.value
                    Layout.alignment: Qt.AlignCenter
                }
            }

            Controls.ProgressBar {
                id: minuteProgress
                from: 0
                to: workMinutes.value * 60
                value: timer.value
                Layout.maximumWidth: Kirigami.Units.gridUnit * 20
                Layout.alignment: Qt.AlignCenter
            }

            Column {
                id: buttons_column
                Layout.alignment: Qt.AlignCenter
                Controls.Button {
                    id: playPause
                    function toggle () {
                        if (state == "wait") {main.state = "work"; timer.start()}
                        else if (main.state == "work") {main.state = "pause"; timer.stop()}
                        else if (main.state == "break") {}
                        else {main.state = "work"; timer.start()}
                    }

                    Layout.alignment: Qt.AlignCenter
                    Layout.columnSpan: 2

                    onClicked: {
                        playPause.toggle()
                        
                    }
                }
                // Open options sheet 
                Controls.Button {
                    id: openOptions
                    Layout.alignment: Qt.AlignCenter
                    text: i18n("Options")
                    onClicked: options.open()
                }
            }
        }

    Kirigami.OverlaySheet {
        id: options

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.preferredWidth:  Kirigami.Units.gridUnit * 25

            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Work for ") + workMinutes.value + i18n(" minutes")
            }
            Controls.Slider {
                id: workMinutes
                value: 25
                from: 1
                to: 60
                stepSize: 1
                onMoved: timer.update() 
            }

            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Break for ") + shortBreakMinutes.value + i18n(" minutes")
            }
            Controls.Slider {
                id: shortBreakMinutes
                value: 5
                from: 1
                to: 60
                stepSize: 1
                onMoved: { }
            }

            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Long break for ") + longBreakMinutes.value + i18n(" minutes")
            }
            Controls.Slider {
                id: longBreakMinutes
                value: 15
                from: 1
                to: 60
                stepSize: 1
                onMoved: { }
            }

            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Work for ") + workRounds.value + i18n(" rounds before long break")
            }
            Controls.Slider {
                id: workRounds
                value: 4
                from: 1
                to: 10
                stepSize: 1
                onMoved: { }
            }
        }
    }


    }
}

