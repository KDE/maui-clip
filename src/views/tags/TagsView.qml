import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.kirigami 2.2 as Kirigami

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.clip 1.0 as Clip

import ".."

StackView
{
    id: control

    property string currentTag : ""
    property Flickable flickable : currentItem.flickable

    FB.NewTagDialog
    {
        id: newTagDialog
    }

    initialItem: TagsGrid
    {
        id:  _tagsGrid
    }

    Component
    {
        id: _filterViewComponent

        BrowserLayout
        {
            showTitle: false
            title: control.currentTag
            list.urls : ["tags:///"+currentTag]
            list.recursive: false
            holder.title: i18n("No Videos!")
            holder.body: i18n("There's no videos associated with the tag")
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            onItemClicked:
            {
                play(item)
            }
        }
    }

    function populateGrid(myTag)
    {
        control.push(_filterViewComponent)
        currentTag = myTag
    }
}
