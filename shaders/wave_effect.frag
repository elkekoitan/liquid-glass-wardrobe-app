#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

// Input uniforms from Flutter
uniform float u_time;        // Animation time
uniform vec2 u_resolution;   // Screen resolution
uniform float u_amplitude;   // Wave amplitude
uniform float u_frequency;   // Wave frequency
uniform float u_speed;       // Wave speed
uniform vec4 u_color;        // Base wave color

// Output color
out vec4 fragColor;

// Generate smooth wave patterns
float wave(vec2 pos, float freq, float amp, float phase) {
    return sin(pos.x * freq + phase) * cos(pos.y * freq * 0.7 + phase * 0.8) * amp;
}

// Create multiple overlapping wave layers
float multiWave(vec2 pos) {
    float time = u_time * u_speed;
    
    // Primary wave
    float wave1 = wave(pos, u_frequency * 2.0, u_amplitude, time);
    
    // Secondary wave (different frequency and phase)
    float wave2 = wave(pos, u_frequency * 1.5, u_amplitude * 0.7, time * 1.3 + 1.0);
    
    // Tertiary wave (high frequency detail)
    float wave3 = wave(pos, u_frequency * 4.0, u_amplitude * 0.3, time * 0.8 + 2.0);
    
    // Combine waves with different weights
    return wave1 + wave2 + wave3;
}

// Create ripple effect from a point
float ripple(vec2 pos, vec2 center, float time, float intensity) {
    float dist = distance(pos, center);
    float ripplePhase = dist * 15.0 - time * 8.0;
    float rippleAttenuation = exp(-dist * 3.0); // Fade with distance
    
    return sin(ripplePhase) * rippleAttenuation * intensity;
}

// Generate multiple ripples at different positions
float multiRipple(vec2 pos) {
    float time = u_time * u_speed;
    
    // Ripple 1 - Center
    float r1 = ripple(pos, vec2(0.5, 0.5), time, u_amplitude);
    
    // Ripple 2 - Top left
    float r2 = ripple(pos, vec2(0.3, 0.3), time * 1.2 + 1.0, u_amplitude * 0.6);
    
    // Ripple 3 - Bottom right
    float r3 = ripple(pos, vec2(0.7, 0.7), time * 0.9 + 2.0, u_amplitude * 0.8);
    
    return r1 + r2 + r3;
}

// Create flowing wave patterns
float flowingWaves(vec2 pos) {
    float time = u_time * u_speed;
    
    // Horizontal flowing waves
    float hWave = sin(pos.y * u_frequency * 3.0 + time) * u_amplitude;
    
    // Vertical flowing waves
    float vWave = cos(pos.x * u_frequency * 2.5 + time * 1.1) * u_amplitude * 0.8;
    
    // Diagonal waves
    float dWave = sin((pos.x + pos.y) * u_frequency * 2.0 + time * 0.7) * u_amplitude * 0.6;
    
    return hWave + vWave + dWave;
}

// Create interference patterns
float interferencePattern(vec2 pos) {
    float time = u_time * u_speed;
    
    // Two wave sources creating interference
    vec2 source1 = vec2(0.3, 0.5);
    vec2 source2 = vec2(0.7, 0.5);
    
    float dist1 = distance(pos, source1);
    float dist2 = distance(pos, source2);
    
    float wave1 = sin(dist1 * u_frequency * 10.0 - time * 3.0);
    float wave2 = sin(dist2 * u_frequency * 10.0 - time * 3.0);
    
    // Interference creates complex patterns
    return (wave1 + wave2) * u_amplitude * 0.5;
}

// Apply color gradient based on wave height
vec4 applyWaveColor(float waveHeight, vec2 pos) {
    // Normalize wave height to 0-1 range
    float normalizedHeight = (waveHeight + u_amplitude * 3.0) / (u_amplitude * 6.0);
    normalizedHeight = clamp(normalizedHeight, 0.0, 1.0);
    
    // Create color variations based on height and position
    vec3 deepColor = vec3(0.0, 0.2, 0.6);    // Deep blue
    vec3 midColor = vec3(0.0, 0.6, 0.9);     // Cyan
    vec3 peakColor = vec3(0.4, 0.9, 1.0);    // Light cyan
    vec3 foamColor = vec3(0.9, 0.95, 1.0);   // White foam
    
    vec3 finalColor;
    
    if (normalizedHeight < 0.3) {
        finalColor = mix(deepColor, midColor, normalizedHeight / 0.3);
    } else if (normalizedHeight < 0.7) {
        finalColor = mix(midColor, peakColor, (normalizedHeight - 0.3) / 0.4);
    } else {
        finalColor = mix(peakColor, foamColor, (normalizedHeight - 0.7) / 0.3);
    }
    
    // Add some sparkle effect on peaks
    if (normalizedHeight > 0.8) {
        float sparkle = sin(pos.x * 50.0 + u_time * 10.0) * sin(pos.y * 50.0 + u_time * 10.0);
        sparkle = max(sparkle, 0.0);
        finalColor += vec3(sparkle * 0.3);
    }
    
    // Blend with the base color from uniform
    finalColor = mix(finalColor, u_color.rgb, 0.3);
    
    // Calculate alpha based on wave intensity
    float alpha = 0.5 + normalizedHeight * 0.5;
    
    return vec4(finalColor, alpha * u_color.a);
}

// Add depth and shadow effects
vec4 addDepthEffect(vec4 color, float waveHeight, vec2 pos) {
    // Calculate shadow based on wave gradient
    vec2 offset = vec2(0.01, 0.01);
    float heightHere = waveHeight;
    float heightOffset = multiWave(pos + offset) + multiRipple(pos + offset) + flowingWaves(pos + offset);
    
    float gradient = heightHere - heightOffset;
    float shadow = 1.0 - clamp(gradient * 5.0, 0.0, 0.3);
    
    // Apply shadow to color
    color.rgb *= shadow;
    
    // Add highlight on wave peaks
    if (waveHeight > u_amplitude * 1.5) {
        float highlight = (waveHeight - u_amplitude * 1.5) / u_amplitude;
        color.rgb += vec3(highlight * 0.2);
    }
    
    return color;
}

void main() {
    // Get normalized coordinates
    vec2 uv = FlutterFragCoord() / u_resolution.xy;
    
    // Generate combined wave effects
    float waveHeight = multiWave(uv) + multiRipple(uv) + flowingWaves(uv) * 0.5 + interferencePattern(uv) * 0.3;
    
    // Apply wave coloring
    vec4 waveColor = applyWaveColor(waveHeight, uv);
    
    // Add depth and shadow effects
    vec4 finalColor = addDepthEffect(waveColor, waveHeight, uv);
    
    // Add subtle vignette effect
    float vignette = smoothstep(0.0, 0.7, 1.0 - length(uv - 0.5));
    finalColor.rgb *= 0.6 + vignette * 0.4;
    
    // Output final color
    fragColor = finalColor;
}
