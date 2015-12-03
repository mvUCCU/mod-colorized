var ModAPI = require('modapi')
var _ = require('lodash')
var qml = ModAPI.QMLFile("BasicControls/ImageClip.qml")
var node = qml.root.node

var imageSaturation = node.publicMember("imageSaturation")
imageSaturation.kind = "property"
imageSaturation.returnType = "int"
imageSaturation.statement = '0'

var imageLightness = node.publicMember("imageLightness")
imageLightness.kind = "property"
imageLightness.returnType = "int"
imageLightness.statement = '0'

node.object("onImageSaturationChanged", "canvas.requestPaint()")
node.object("onImageLightnessChanged", "canvas.requestPaint()")

var rotateHue = node.getObjectById("canvas").node.function("rotateHue")
var body = rotateHue.content
body = body.replace('if (offset)', 'if (offset != 0 || imageSaturation != 0 || imageLightness != 0)')
body = body.replace('var s = hsl[1];', 'var s = Math.max(Math.min(1, hsl[1] + imageSaturation / 255), 0);')
body = body.replace('var l = hsl[2];', 'var l = Math.max(Math.min(255, hsl[2] + imageLightness), 0);')
rotateHue.content = body

ModAPI.add("ModManager/Settings/colorized/HSLImageClip.qml", qml.code)
