import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Maui.ListBrowserDelegate
{
    id: control

    implicitHeight: Maui.Style.rowHeight * 2

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

iconSizeHint: height * 0.9
label1.text: model.label
label2.text: model.url
label3.text: model.mime
label4.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
imageSource: model.thumbnail
template.fillMode: Image.PreserveAspectCrop

}
