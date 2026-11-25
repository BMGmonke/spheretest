// Native OpenGL ES 2.0 fragment shader for non-node geometry.
uniform sampler2D baseTexture;
varying vec4 vColor;
varying vec2 vTexCoord;
void main()
{
    gl_FragColor = texture2D(baseTexture, vTexCoord) * vColor;
}
