import QtQuick 2.3

Item {
    id: root

    property Item image: image
    property alias source: image.source

    property int imageHue: 0
    property int imageSaturation: 0
    property int imageLightness: 0

    Image {
        id: image
        visible: false
    }

    ShaderEffect {
        id: shaderEffect
        width: image.width
        height: image.height
        property variant src: image
        property vector3d hsl

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }
        "
        fragmentShader: "
            varying highp vec2 coord;
            uniform float qt_Opacity;
            uniform sampler2D src;
            uniform vec3 hsl;

            vec3 rgb2hsl(vec3 c) {
                vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
                vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float l = (q.x + min(q.w, q.y)) / 2.0;
                float e = 1.0e-10;
                return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (1.0 - abs(2.0 * l - 1.0)), l);
            }

            vec3 hsl2rgb(vec3 c) {
                float d = (1.0 - abs(2.0 * c.z - 1.0)) * c.y;
                float qx = d / 2.0 + c.z;
                float e = 1.0e-10;
                vec3 c1 = vec3(c.x, d / (qx + e), qx);
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                vec3 p = abs(fract(c1.xxx + K.xyz) * 6.0 - K.www);
                return c1.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c1.y);
            }

            void main() {
                vec4 tex = texture2D(src, coord);
                vec3 _hsl = rgb2hsl(tex.rgb);
                _hsl.x = mod(_hsl.x + hsl.x, 1.0);
                _hsl.y = clamp(_hsl.y + hsl.y, 0.0, 1.0);
                _hsl.z = clamp(_hsl.z + hsl.z, -1.0, 1.0);
                gl_FragColor = vec4(hsl2rgb(_hsl), tex.w) * qt_Opacity;
            }
        "

    }

    function update_vec3(){
        shaderEffect.hsl = Qt.vector3d(imageHue / 360, imageSaturation / 255, imageLightness / 255)
    }

    onImageHueChanged : update_vec3()
    onImageSaturationChanged : update_vec3()
    onImageLightnessChanged : update_vec3()

}