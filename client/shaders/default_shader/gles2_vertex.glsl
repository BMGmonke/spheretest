// Native OpenGL ES 2.0 vertex shader for SphereTest.
// Vertex attributes are bound by Irrlicht's OGL-ES driver.
attribute vec3 inVertexPosition;
attribute vec3 inVertexNormal;
attribute vec4 inVertexColor;
attribute vec2 inTexCoord0;

uniform mat4 mWorldViewProj;
uniform mat4 mWorld;
uniform mat4 mWorldView;
uniform vec3 mCameraPos;
uniform float dayNightRatio;
uniform float animationTimer;

varying vec4 vColor;
varying vec2 vTexCoord;
varying float vFogDepth;

void main()
{
    vec3 position = inVertexPosition;
    vec2 uv = inTexCoord0;

#if (MATERIAL_TYPE == TILE_MATERIAL_LIQUID_TRANSPARENT || MATERIAL_TYPE == TILE_MATERIAL_LIQUID_OPAQUE) && ENABLE_WAVING_WATER
    position.y -= 2.0;
    float wavePhase = position.z / WATER_WAVE_LENGTH +
        animationTimer * WATER_WAVE_SPEED * WATER_WAVE_LENGTH;
    position.y -= sin(wavePhase) * WATER_WAVE_HEIGHT +
        sin(wavePhase / 7.0) * WATER_WAVE_HEIGHT;
#endif

#if MATERIAL_TYPE == TILE_MATERIAL_WAVING_LEAVES && ENABLE_WAVING_LEAVES
    float leafPhase = animationTimer * 23.0 + dot(position, vec3(0.001, 0.001, 0.002));
    position.x += (sin(leafPhase) + sin(leafPhase * 0.48)) * 0.4;
    position.z += (sin(leafPhase * 1.35) + sin(leafPhase * 1.26) +
        sin(leafPhase * 0.57)) * 0.5;
#endif

#if MATERIAL_TYPE == TILE_MATERIAL_WAVING_PLANTS && ENABLE_WAVING_PLANTS
    if (uv.y < 0.05) {
        float plantPhase = animationTimer * 19.0 + dot(position, vec3(0.001, 0.001, 0.002));
        position.x += sin(plantPhase) * 0.4;
        position.z += cos(plantPhase * 1.3) * 0.5;
    }
#endif

#ifdef ENABLE_PLANET
    float planetRadius = float(PLANET_RADIUS) * 160.0;
    vec2 radial = position.xz - mCameraPos.xz;
    float planarDistance = length(radial);
    vec2 direction = planarDistance > 0.0001 ?
        radial / planarDistance : vec2(0.0, 1.0);
#ifdef PLANET_KEEP_SCALE
    vec2 plane = vec2(position.y - mCameraPos.y, planarDistance);
    vec2 circle = planetRadius * exp(plane.x / planetRadius) *
        vec2(cos(plane.y / planetRadius), sin(plane.y / planetRadius)) -
        vec2(planetRadius, 0.0);
    position.x = circle.y * direction.x + mCameraPos.x;
    position.z = circle.y * direction.y + mCameraPos.z;
    position.y = circle.x + mCameraPos.y;
#else
    vec2 plane = vec2(position.y + planetRadius, planarDistance);
    vec2 circle = plane.x * vec2(cos(plane.y / planetRadius),
        sin(plane.y / planetRadius)) - vec2(planetRadius, 0.0);
    position.x = circle.y * direction.x + mCameraPos.x;
    position.z = circle.y * direction.y + mCameraPos.z;
    position.y = circle.x;
#endif
#endif

    vec4 localPosition = vec4(position, 1.0);
    vec4 viewPosition = mWorldView * localPosition;
    gl_Position = mWorldViewProj * localPosition;

    vTexCoord = uv;
    vFogDepth = abs(viewPosition.z);

    float day = inVertexColor.r;
    float night = inVertexColor.g;
    float lightSource = inVertexColor.b;
    float light = mix(night, day, dayNightRatio) + lightSource * 2.5;
    float blue = light + (day - night) / 13.0;
    light -= (day - night) / 23.0;
    blue += max(0.0, (1.0 - abs(blue - 0.13) / 0.17) * 0.025);
    light += max(0.0, (1.0 - abs(light - 0.85) / 0.15) * 0.065);
    vColor = clamp(vec4(light, light, blue, inVertexColor.a), 0.0, 1.0);
}
