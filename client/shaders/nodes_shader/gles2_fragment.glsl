// Native OpenGL ES 2.0 fragment shader for voxel terrain.
uniform sampler2D baseTexture;
uniform vec4 skyBgColor;
uniform float fogDistance;

varying vec4 vColor;
varying vec2 vTexCoord;
varying float vFogDepth;

void main()
{
    vec4 texel = texture2D(baseTexture, vTexCoord);
    vec4 color = texel * vColor;

    if (fogDistance > 0.0) {
        float fog = clamp(vFogDepth / fogDistance * 1.5 - 0.6, 0.0, 1.0);
#if MATERIAL_TYPE == TILE_MATERIAL_LIQUID_TRANSPARENT
        color.a = mix(vColor.a, 0.0, fog);
#else
        color = mix(color, skyBgColor, fog);
#endif
    }
    gl_FragColor = color;
}
