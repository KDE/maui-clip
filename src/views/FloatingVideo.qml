import QtQuick
import QtQuick.Controls

import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.mauikit.controls as Maui

Rectangle
{
    id: control
    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Complementary

    implicitHeight: diskBg.height
    implicitWidth: diskBg.width

    x: root.footer.x + Maui.Style.space.medium
    y: parent.height - height - Maui.Style.space.medium

    parent: ApplicationWindow.overlay
    z: parent.z + 1
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse && !Maui.Handy.isMobile
    ToolTip.text: root.title

    color: Maui.Theme.backgroundColor
    radius: Maui.Style.radiusV

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
        onClicked: toggleViewer()

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

    Slider
    {
        id: _slider
        padding: 0
        height: Maui.Style.iconSizes.small
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        orientation: Qt.Horizontal
        from: 0
        to: player.video.duration
        value: player.video.position

        onMoved: player.video.seek( _slider.value )

        //            onToChanged: value = player.video.position

        spacing: 0
        focus: true

        background: Rectangle
        {
            implicitWidth: _slider.width
            implicitHeight: _slider.height
            width: _slider.availableWidth
            height: implicitHeight
            color: "transparent"
            opacity: 1

            Rectangle
            {
                width: _slider.visualPosition * parent.width
                height: _slider.height
                color: Maui.Theme.highlightColor
            }
        }

        handle: Rectangle
        {
            x: _slider.leftPadding + _slider.visualPosition
               * (_slider.availableWidth - width)
            y: 0
            implicitWidth: Maui.Style.iconSizes.medium
            implicitHeight: _slider.height
            color: _slider.pressed ? Qt.lighter(Maui.Theme.highlightColor, 1.2) : "transparent"
        }
    }
}
