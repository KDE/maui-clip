import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.mauikit.controls 1.3 as Maui

Maui.ListBrowserDelegate
{
    id: control

    isCurrentItem: ListView.isCurrentItem
    draggable: true
    tooltipText: model.url
    checkable: root.selectionMode
    checked: (selectionBar ? selectionBar.contains(model.url) : false)

    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": filterSelectedItems(model.url)
                       } : {}

//iconSizeHint: Maui.Style.iconSizes.big
label1.text: model.label
label2.text: model.url
label3.text: model.mime
label4.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
imageSource: model.preview
iconSource: model.icon
template.fillMode: Image.PreserveAspectFit
//template.width

}
