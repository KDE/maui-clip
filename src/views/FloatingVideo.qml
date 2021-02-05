import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
    id: control
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary


    height: diskBg.height
    width: diskBg.width

    x: root.footer.x + Maui.Style.space.medium
    y: parent.height - height - Maui.Style.space.medium

    parent: ApplicationWindow.overlay
    z: parent.z + 1
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse && !Kirigami.Settings.isMobile
    ToolTip.text: root.title

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true

        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.maximumX: root.width - control.width

        drag.minimumY: 0
        drag.maximumY: root.height - control.height
        onClicked: _appViews.currentIndex = views.player
        //        onDoubleClicked: toggleFocusView()


        ShaderEffectSource
        {
            id: diskBg
            anchors.centerIn: parent
            height: sourceItem.height * 0.35
            width: sourceItem.width * 0.35
            hideSource: visible
            live: true
            textureSize: Qt.size(width,height)
            sourceItem: player.video

        }

        DropShadow
        {
            anchors.fill: diskBg
            horizontalOffset: 0
            verticalOffset: 0
            radius: _mouseArea.containsPress ? 5.0 :8.0
            samples: 17
            color: "#80000000"
            source: diskBg
        }
    }



    layer.enabled: true
    layer.effect: OpacityMask
    {
        maskSource: Item
        {
            width: control.width
            height: control.height
            Rectangle
            {
                anchors.fill: parent
                radius: Maui.Style.radiusV
            }
        }
    }
}
