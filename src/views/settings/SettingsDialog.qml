import QtQuick 
import QtQml 

import QtQuick.Controls
import QtQuick.Layouts 

import org.mauikit.controls as Maui

import org.maui.clip as Clip

Maui.SettingsDialog
{
    id: control

    Maui.SectionGroup
    {
        title: i18n("General")
        //        description: i18n("Configure the app behavior.")

        Maui.FlexSectionItem
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
    }

    Maui.SectionGroup
    {
        title: i18n("Collection")
        //        description: i18n("Sorting order and behavior.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sorting by")
            label2.text: i18n("Change the sorting key.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.Text

                Action
                {
                    text: i18n("Title")
                    onTriggered: settings.sortBy =  "label"
                    checked: settings.sortBy ===  "label"
                }

                Action
                {
                    text: i18n("Date")
                    onTriggered: settings.sortBy = "modified"
                    checked: settings.sortBy ===  "modified"
                }

                Action
                {
                    text: i18n("Size")
                    onTriggered: settings.sortBy = "size"
                    checked: settings.sortBy ===  "size"
                }

                Action
                {
                    text: i18n("Type")
                    onTriggered: settings.sortBy = "type"
                    checked: settings.sortBy ===  "type"
                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sort order")
            label2.text: i18n("Change the sorting order.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.IconOnly

                Action
                {
                    text: i18n("Ascending")
                    icon.name: "view-sort-ascending"
                    onTriggered: settings.sortOrder = Qt.AscendingOrder
                    checked: settings.sortOrder === Qt.AscendingOrder
                }

                Action
                {
                    text: i18n("Descending")
                    icon.name: "view-sort-descending"
                    onTriggered: settings.sortOrder = Qt.DescendingOrder
                    checked: settings.sortOrder === Qt.DescendingOrder
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Playback")
        //        description: i18n("Configure the player settings.")
        enabled: Clip.Clip.mpvAvailable
        Maui.FlexSectionItem
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

    Maui.SectionGroup
    {
        title: i18n("Audio")
        //        description: i18n("Configure the player audio behaviour.")
        enabled: Clip.Clip.mpvAvailable

        Maui.SectionItem
        {
            label1.text: i18n("Preferred Language")
            label2.text: i18n("Preferred language if available.")

            TextField
            {
                Layout.fillWidth: true
                text: settings.preferredLanguage
                onAccepted: settings.preferredLanguage = text
            }
        }
    }

    //    Maui.SectionGroup
    //    {
    //        title: i18n("Subtitles")
    //        description: i18n("Configure the app UI.")
    //        enabled: Clip.Clip.mpvAvailable

    //        Maui.SectionItem
    //        {
    //            label1.text: i18n("Directory")
    //            label2.text: i18n("Folder path containing the subtitle files.")
    //            wide: false

    //            Maui.TextField
    //            {
    //                Layout.fillWidth: true
    //                text: settings.subtitlesPath
    //                onAccepted: settins.subtitlesPath = text

    //                Action
    //                {
    //                    icon.name: "folder-open"
    //                    onTriggered:
    //                    {
    //                        dialogLoader.sourceComponent = fmDialogComponent
    //                        dialog.mode = dialog.modes.OPEN
    //                        dialog.settings.onlyDirs = true
    //                        dialog.callback = function(paths)
    //                        {
    //                            settings.subtitlesPath = paths[0]
    //                        }

    //                        dialog.open()
    //                    }
    //                }
    //            }
    //        }

    //        Maui.SectionItem
    //        {
    //            label1.text: i18n("Font Family")

    //            Maui.ComboBox
    //            {
    //                Layout.fillWidth: true
    //                model: Qt.fontFamilies()
    //                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
    //                onActivated: settings.font.family = currentText
    //            }
    //        }

    //        Maui.SectionItem
    //        {
    //            label1.text: i18n("Font Size")

    //            SpinBox
    //            {
    //                from: 0; to : 500
    //                value: settings.font.pointSize
    //                onValueChanged: settings.font.pointSize = value
    //            }
    //        }
    //    }

    //    Maui.SectionGroup
    //    {
    //        title: i18n("YouTube")
    //        description: i18n("Configure YouTube details.")

    //        Maui.SectionItem
    //        {
    //            label1.text: i18n("Key")
    //            label2.text: i18n("Personal key for limitless browsing.")
    //            wide: false

    //            Maui.TextField
    //            {
    //                Layout.fillWidth: true
    //                text: settings.youtubeKey
    //                onAccepted: settings.youtubeKey = text
    //            }

    //            template.leftLabels.data: Label
    //            {
    //                Layout.fillWidth: true
    //                text: i18n("<a href='https://console.developers.google.com/apis/credentials'>Get your personal key.</a>")

    //                onLinkActivated: Qt.openUrlExternally(link)
    //            }
    //        }
    //    }

    Maui.SectionGroup
    {
        title: i18n("Sources")
        //        description: i18n("Add new sources to manage and browse your video collection")

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.medium

            Repeater
            {
                id: _sourcesList

                model: Clip.Clip.sourcesModel
                delegate: Maui.ListDelegate
                {
                    Layout.fillWidth: true
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

                onClicked:
                {
                    var props = ({'browser.settings.onlyDirs' : true,
                                     'callback' : function(urls)
                                     {
                                         Clip.Clip.addSources(urls)
                                     }})
                    var dialog = fmDialogComponent.createObject(root, props)
                    dialog.open()
                }
            }
        }
    }

    Maui.InfoDialog
    {
        id: confirmationDialog
        property string url : ""

        title : i18n("Remove source")
        message : i18n("Are you sure you want to remove the source: \n %1", url)
        template.iconSource: "emblem-warning"

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted:
        {
            if(url.length>0)
                Clip.Clip.removeSources(url)
            confirmationDialog.close()
        }
        onRejected: confirmationDialog.close()
    }
}
