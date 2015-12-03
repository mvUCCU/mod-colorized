import QtQuick 2.3
import QtQuick.Controls 1.2
import Tkool.rpg 1.0
import "../../../BasicControls"
import "../../../BasicLayouts"
import "../../../Controls"
import "../../../ObjControls"
import "../../../Singletons"
import "../../../Main"

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 8

    property var mod : null

    onModChanged: refresh()

    function refresh() {
        if (!mod) return;
        hBox.value = convertValue(mod.settings.settings.hue);
        sBox.value = convertValue(mod.settings.settings.saturation);
        lBox.value = convertValue(mod.settings.settings.lightness);

        image.source = TkoolAPI.pathToUrl(mod.location) + "/preview.png";
    }

    function convertValue(v) {
        return Number(v) || 0
    }

    DialogBoxHelper { id: helper }

    GroupBox {
        anchors.left: parent.left
        anchors.top: parent.top
        title: "Offset"
        id: offsetBox
        Column {
            SliderSpinBox {
                id: hBox
                title: "Hue"
                minimumValue: 0
                maximumValue: 360
                stepSize: 24
                tickSpan: 48
                minimumLabelWidth: 80
                onValueChanged: {
                    if (!mod) return;
                    if (mod.settings.settings.hue == value) return;
                    mod.settings.settings.hue = value;
                    helper.setModified();
                }
            }
            SliderSpinBox {
                id: sBox
                title: "Saturation"
                minimumValue: -255
                maximumValue: 255
                stepSize: 17
                tickSpan: 34
                minimumLabelWidth: 80
                onValueChanged: {
                    if (!mod) return;
                    if (mod.settings.settings.saturation == value) return;
                    mod.settings.settings.saturation = value;
                    helper.setModified();
                }
            }
            SliderSpinBox {
                id: lBox
                title: "Lightness"
                minimumValue: -255
                maximumValue: 255
                stepSize: 17
                tickSpan: 34
                minimumLabelWidth: 80
                onValueChanged: {
                    if (!mod) return;
                    if (mod.settings.settings.lightness == value) return;
                    mod.settings.settings.lightness = value;
                    helper.setModified();
                }
            }
        }
    }
    GroupBox {
        title: "Preview"
        anchors.left: parent.left
        anchors.top: offsetBox.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        HSLImageClip {
            id: image
            imageHue: hBox.value
            imageSaturation: sBox.value
            imageLightness: lBox.value
        }
    }
}
