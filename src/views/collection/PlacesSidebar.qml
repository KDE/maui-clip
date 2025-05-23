import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import QtQuick.Layouts

import org.maui.clip as Clip

Loader
{
    id: control
    asynchronous: true
    sourceComponent:Pane
    {
        background: Rectangle
        {
            color: Maui.Theme.alternateBackgroundColor
            radius: Maui.Style.radiusV
        }

        padding : 0
        contentItem: Maui.ListBrowser
        {
            id: _listBrowser

            model: Maui.BaseModel
            {
                list: Clip.Tags
                {
                    id: _placesList
                }
            }

            delegate: Maui.ListDelegate
            {
                isCurrentItem: urls.indexOf(model.path) >= 0
                width: ListView.view.width
                label: model.tag
                iconSize: Maui.Style.iconSize
                iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                iconVisible: true
                template.isMask: iconSize <= Maui.Style.iconSizes.medium

                onClicked: openFolders([model.path])

            }

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: Maui.LabelDelegate
            {
                width: ListView.view.width
                text: section
                isSection: true
                //                height: Maui.Style.toolBarHeightAlt
            }

            holder.visible: count === 0
            holder.title: i18n("Tags!")
            holder.body: i18n("Your tags will be listed here")

            flickable.topMargin: Maui.Style.contentMargins
            flickable.bottomMargin: Maui.Style.contentMargins
            flickable.header: Loader
            {
                asynchronous: true
                width: parent.width
                visible: active

                sourceComponent: Item
                {
                    implicitHeight: _quickSection.implicitHeight

                    GridLayout
                    {
                        id: _quickSection
                        width: Math.min(parent.width, 180)
                        anchors.centerIn: parent
                        rows: 2
                        columns: 2
                        columnSpacing: Maui.Style.defaultPadding
                        rowSpacing: Maui.Style.defaultPadding

                        Repeater
                        {
                            model: _placesList.quickPlaces

                            delegate: Button
                            {
                                Layout.preferredHeight: Math.min(50, width)
                                Layout.preferredWidth: 50
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                checked: urls.indexOf(modelData.path) >= 0
                                icon.name: modelData.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                                icon.width: Maui.Style.iconSize
                                ToolTip.text: modelData.label
                                ToolTip.visible: true
                                flat: false
                                onClicked:
                                {
                                    //[".cbz", ".cbr"]
                                    openFolders([modelData.path])
                                    if(sideBar.collapsed)
                                        sideBar.close()
                                }
                            }

                        }
                    }
                }
            }
        }
    }
}
