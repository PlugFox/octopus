#version 460 core
#define SHOW_GRID

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;  // size of the shape
uniform float uSeed; // shader playback time (in seconds)
uniform vec4 uLineColor; // line color of the shape
uniform vec4 uBackgroundColor; // background color of the shape
uniform float uStripeWidth; // width of the stripes

out vec4 fragColor;

void main() {
    // Direction vector for 30 degrees angle (values are precalculated)
    vec2 direction = vec2(0.866, 0.5);

    // Calculate normalized coordinates
    vec2 normalizedCoords = gl_FragCoord.xy / uSize;

    // Generate a smooth moving wave based on time and coordinates
    float waveRaw = 0.5 * (1.0 + sin(uSeed - dot(normalizedCoords, direction) * uStripeWidth * 3.1415));
    float wave = smoothstep(0.0, 1.0, waveRaw);

    // Use the wave to interpolate between the background color and line color
    vec4 color = mix(uBackgroundColor, uLineColor, wave);

    fragColor = color;
}