import QtQuick 2.14
import QtQml 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.clip 1.0 as Clip

Maui.SettingsDialog
{
    id: control

    Maui.SettingsSection
    {
        //        alt: true
        title: i18n("General")
        description: i18n("Configure the app behavior.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Volume Step")

            SpinBox
            {
                value: settings.volumeStep
                from: 0
                to: 20
                onValueChanged: settings.volumeStep = value
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Player Tag Bar")
            label2.text: i18n("Display tags bar to quickly tag videos being played.")

            Switch
            {
                checkable: true
                checked:  settings.playerTagBar
                onToggled: settings.playerTagBar = !settings.playerTagBar
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Color Scheme")

            Maui.ComboBox
            {
                model: 20
                displayText: modelData
                onAccepted: settings.colorScheme = currentText
            }
        }
    }

    Maui.SettingsSection
    {
        //        alt: false
        title: i18n("Collection")
        description: i18n("Sorting order and behavior.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Sorting by")
            label2.text: i18n("Change the sorting key.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Binding on currentIndex
                {
                    value:  switch(settings.sortBy)
                            {
                            case "label": return 0;
                            case "date": return 1;
                            case "modified": return 2;
                            case "mimetype": return 3;
                            default: return -1;
                            }
                    restoreMode: Binding.RestoreValue
                }

                Action
                {
                    text: i18n("Title")
                    onTriggered: settings.sortBy =  "label"
                }

                Action
                {
                    text: i18n("Date")
                    onTriggered: settings.sortBy = "modified"
                }

                Action
                {
                    text: i18n("Size")
                    onTriggered: settings.sortBy = "size"
                }

                Action
                {
                    text: i18n("Type")
                    onTriggered: settings.sortBy = "type"
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Sort order")
            label2.text: i18n("Change the sorting order.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.IconOnly

                Binding on currentIndex
                {
                    value:  switch(settings.sortOrder)
                            {
                            case Qt.AscendingOrder: return 0;
                            case Qt.DescendingOrder: return 1;
                            default: return -1;
                            }
                    restoreMode: Binding.RestoreValue
                }

                Action
                {
                    text: i18n("Ascending")
                    icon.name: "view-sort-ascending"
                    onTriggered: settings.sortOrder = Qt.AscendingOrder
                }

                Action
                {
                    text: i18n("Descending")
                    icon.name: "view-sort-descending"
                    onTriggered: settings.sortOrder = Qt.DescendingOrder
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Playback")
        description: i18n("Configure the player settings.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Hardware Decoding")
            label2.text: i18n("Use the sorting preferences globally for all the tabs and splits.")

            Switch
            {
                checkable: true
                checked:  settings.hardwareDecoding
                onToggled: settings.hardwareDecoding = !settings.hardwareDecoding
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Audio")
        description: i18n("Configure the player audio behaviour.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Preferred Language")
            label2.text: i18n("Preferred language if available.")
            wide: false

            Maui.TextField
            {
                Layout.fillWidth: true
                text: settings.preferredLanguage
                onAccepted: settings.preferredLanguage = text
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Subtitles")
        description: i18n("Configure the app UI.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Directory")
            label2.text: i18n("Folder path containing the subtitle files.")
            wide: false

            Maui.TextField
            {
                Layout.fillWidth: true
                text: settings.subtitlesPath
                onAccepted: settins.subtitlesPath = text

                Action
                {
                    icon.name: "folder-open"
                    onTriggered:
                    {
                        dialogLoader.sourceComponent = fmDialogComponent
                        dialog.mode = dialog.modes.OPEN
                        dialog.settings.onlyDirs = true
                        dialog.callback = function(paths)
                        {
                            settings.subtitlesPath = paths[0]
                        }

                        dialog.open()
                    }
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Font Family")

            Maui.ComboBox
            {
                Layout.fillWidth: true
                model: Qt.fontFamilies()
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Font Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }

    }


    Maui.SettingsSection
    {
        title: i18n("YouTube")
        description: i18n("Configure YouTube details.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Key")
            label2.text: i18n("Personal key for limitless browsing.")
            wide: false

            Maui.TextField
            {
                Layout.fillWidth: true
                text: settings.youtubeKey
                onAccepted: settings.youtubeKey = text
            }

            template.leftLabels.data: Label
            {
                Layout.fillWidth: true
                text: i18n("<a href='https://console.developers.google.com/apis/credentials'>Get your personal key.</a>")

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add new sources to manage and browse your video collection")
        lastOne: true

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.big

            Maui.ListBrowser
            {
                id: _sourcesList
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: Math.min(500, contentHeight)
                model: Clip.Clip.sourcesModel
                delegate: Maui.ListDelegate
                {
                    width: ListView.view.width
                    implicitHeight: Maui.Style.rowHeight * 1.5
                    leftPadding: 0
                    rightPadding: 0
                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path
                    onClicked: _sourcesList.currentIndex = index

                    template.content: ToolButton
                    {
                        icon.name: "edit-clear"
                        flat: true
                        onClicked:
                        {
                            confirmationDialog.url = modelData.url
                            confirmationDialog.open()
                        }
                    }
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Add")
                flat: true

                onClicked:
                {
                    dialogLoader.sourceComponent = fmDialogComponent
                    dialog.settings.onlyDirs = true
                    dialog.mode = dialog.modes.OPEN
                    dialog.callback = function(urls)
                    {
                        Clip.Clip.addSources(urls)
                    }
                    dialog.open()
                }
            }
        }
    }

    Maui.Dialog
    {
        id: confirmationDialog
        property string url : ""

        title : i18n("Remove source")
        message : i18n("Are you sure you want to remove the source: \n %1", url)
        template.iconSource: "emblem-warning"
        page.margins: Maui.Style.space.big

        onAccepted:
        {
            if(url.length>0)
                Clip.Clip.removeSources(url)
            confirmationDialog.close()
        }
        onRejected: confirmationDialog.close()
    }
}
