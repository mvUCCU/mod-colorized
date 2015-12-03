var ModAPI = require('modapi')
var _ = require('lodash')
var fs = require('fs')
var path = require('path')
var settings = require('settings')()
var tinycolor = require('mod')('js-tinycolor')

var readLocalFile = function(name) {
  return fs.readFileSync(path.join(__dirname, name))
}

// From Bitmap#rotateHue() in game to be consistent with most users' experience
var RM_rgbToHsl = function (r, g, b) {var cmin = Math.min(r, g, b);var cmax = Math.max(r, g, b);var h = 0;var s = 0;var l = (cmin + cmax) / 2;var delta = cmax - cmin;if (delta > 0) {if (r === cmax) {h = 60 * (((g - b) / delta + 6) % 6);} else if (g === cmax) {h = 60 * ((b - r) / delta + 2);} else {h = 60 * ((r - g) / delta + 4);}s = delta / (255 - Math.abs(2 * l - 255));}return [h, s, l];}
var RM_hslToRgb = function (h, s, l) {var c = (255 - Math.abs(2 * l - 255)) * s;var x = c * (1 - Math.abs((h / 60) % 2 - 1));var m = l - c / 2;var cm = c + m;var xm = x + m;if (h < 60) {return [cm, xm, m];} else if (h < 120) {return [xm, cm, m];} else if (h < 180) {return [m, cm, xm];} else if (h < 240) {return [m, xm, cm];} else if (h < 300) {return [xm, m, cm];} else {return [cm, m, xm];}}

var convertNumber = function(number) {
  var num = Number(number)
  return _.isFinite(num) ? num : 0
}

var hueOffset = convertNumber(settings.hue)
var convertColor = function(color) {
  var argb = tinycolor(color).toRgb()
  var hsl = RM_rgbToHsl(argb.r, argb.g, argb.b)
  var rgb = RM_hslToRgb(((hsl[0] + hueOffset) % 360 + 360) % 360, hsl[1], hsl[2])
  return tinycolor({ r: rgb[0], g: rgb[1], b: rgb[2], a: argb.a}).toHex8String()
}

var colors = {
  window2:         "#d0dbe8",
  focusFrame:      "#648cb4",
  normalText:      "#000000",
  normalBack1:     "#ffffff",
  normalBack2:     "#e4ecf2",
  selectedText:    "#ffffff",
  selectedBack:    "#0064c8",
  selectedEdBack:  "#bbddff",
  disabledText:    "#80000000",
  button1:         "#eef6fc",
  button2:         "#aeb6bc",
  hotButton1:      "#ffffff",
  hotButton2:      "#c0e0ff",
  groupBox1:       "#6090b0d0",
  groupBox2:       "#607090b0",
  groupBoxFrame:   "#ffffff",
  deluxeLabel1:    "#0050a0",
  deluxeLabelText: "#ffffff",
  highlight:       "#80ffffff",
  workArea:        "#224488",
  checkMark:       "#4466aa",
  dropTarget:      "#ffee60",
  progressBar:     "#4499dd",
}

var qml = ModAPI.QMLFile("BasicControls/Palette.qml")
var node = qml.root.node
_.forEach(colors, function(color, key) {
  node.publicMember(key).statement = JSON.stringify(convertColor(color))
})
qml.save()

var qml = ModAPI.QMLFile("BasicControls/ButtonImage.qml")
var gradient = _.find(qml.getObjectsByDescribe("Rectangle"), function(i) {
  var visible = _.find(i.node.objects, {name: "visible"})
  if (!visible) return
  return String(visible.value).indexOf("twinklingVisible") > -1
}).node.object("gradient").node.objects
gradient[0].node.object("color", 'Qt.lighter(' + JSON.stringify(convertColor("#38d")) + ', 1.8)')
gradient[1].node.object("color", 'Qt.lighter(' + JSON.stringify(convertColor("#38d")) + ', 1.5)')
qml.save()
