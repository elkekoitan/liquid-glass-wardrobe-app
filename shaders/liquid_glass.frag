#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

// Input uniforms from Flutter
uniform float u_time;        // Animation time
uniform vec2 u_resolution;   // Screen resolution
uniform vec2 u_mouse;        // Mouse position (for interaction)
uniform float u_intensity;   // Effect intensity (0.0 - 1.0)
uniform float u_distortion;  // Distortion strength

// Output color
out vec4 fragColor;

// Noise function for organic liquid movement
float noise(vec2 p) {
    return sin(p.x * 10.0 + u_time) * sin(p.y * 10.0 + u_time * 0.5) * 0.1;
}

// Generate smooth noise for glass distortion
float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Smooth interpolation
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal noise for complex liquid patterns
float fractalNoise(vec2 p) {
    float value = 0.0;
    float amplitude = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += smoothNoise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

// Create liquid glass refraction effect
vec2 getDistortion(vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    float distanceFromCenter = distance(uv, center);
    
    // Create ripple effect from center
    float ripple = sin(distanceFromCenter * 20.0 - u_time * 5.0) * 0.02;
    
    // Add fractal noise for organic movement
    float noiseVal = fractalNoise(uv * 3.0 + u_time * 0.2);
    
    // Combine ripple and noise for final distortion
    vec2 distortion = vec2(
        ripple + noiseVal * u_distortion,
        ripple * 0.7 + noiseVal * u_distortion * 0.8
    );
    
    return distortion * u_intensity;
}

// Generate glass surface normal for lighting
vec3 getGlassNormal(vec2 uv) {
    vec2 offset = vec2(0.001, 0.0);
    
    float heightL = fractalNoise(uv - offset);
    float heightR = fractalNoise(uv + offset);
    float heightU = fractalNoise(uv - offset.yx);
    float heightD = fractalNoise(uv + offset.yx);
    
    vec3 normal = normalize(vec3(
        (heightR - heightL) * 10.0,
        (heightD - heightU) * 10.0,
        1.0
    ));
    
    return normal;
}

// Create glass material effect
vec4 applyGlassEffect(vec2 uv, vec4 baseColor) {
    // Get glass normal for lighting calculation
    vec3 normal = getGlassNormal(uv);
    
    // Light direction (from top-left)
    vec3 lightDir = normalize(vec3(-0.5, -0.5, 1.0));
    
    // Calculate lighting
    float diffuse = max(dot(normal, lightDir), 0.0);
    float specular = pow(max(dot(reflect(-lightDir, normal), vec3(0.0, 0.0, 1.0)), 0.0), 32.0);
    
    // Glass tint colors
    vec3 glassColor = vec3(0.9, 0.95, 1.0); // Slight blue tint
    vec3 highlightColor = vec3(1.0, 1.0, 1.0);
    
    // Combine base color with glass effect
    vec3 finalColor = baseColor.rgb * glassColor * (0.8 + diffuse * 0.4);
    finalColor += highlightColor * specular * 0.6;
    
    // Add fresnel effect for glass edges
    float fresnel = pow(1.0 - abs(dot(normal, vec3(0.0, 0.0, 1.0))), 2.0);
    finalColor += vec3(0.3, 0.4, 0.6) * fresnel * 0.5;
    
    return vec4(finalColor, baseColor.a);
}

// Create animated liquid background
vec4 createLiquidBackground(vec2 uv) {
    // Multiple layers of animated noise
    float layer1 = fractalNoise(uv * 2.0 + u_time * 0.1);
    float layer2 = fractalNoise(uv * 4.0 - u_time * 0.15);
    float layer3 = fractalNoise(uv * 8.0 + u_time * 0.08);
    
    // Combine layers
    float combined = (layer1 + layer2 * 0.5 + layer3 * 0.25) / 1.75;
    
    // Create gradient colors for liquid effect
    vec3 color1 = vec3(0.0, 0.8, 1.0);  // Cyan
    vec3 color2 = vec3(0.5, 0.0, 1.0);  // Purple
    vec3 color3 = vec3(1.0, 0.2, 0.8);  // Pink
    
    // Interpolate between colors based on noise
    vec3 finalColor;
    if (combined < -0.2) {
        finalColor = mix(color1, color2, (combined + 0.5) * 2.0);
    } else if (combined < 0.2) {
        finalColor = mix(color2, color3, (combined + 0.2) * 2.5);
    } else {
        finalColor = mix(color3, color1, (combined - 0.2) * 2.5);
    }
    
    // Add some brightness variation
    float brightness = 0.3 + combined * 0.4;
    finalColor *= brightness;
    
    return vec4(finalColor, 0.6); // Semi-transparent
}

void main() {
    // Get normalized coordinates
    vec2 uv = FlutterFragCoord() / u_resolution.xy;
    
    // Apply distortion effect
    vec2 distortion = getDistortion(uv);
    vec2 distortedUV = uv + distortion;
    
    // Create liquid background
    vec4 liquidBg = createLiquidBackground(distortedUV);
    
    // Apply glass effect
    vec4 glassEffect = applyGlassEffect(distortedUV, liquidBg);
    
    // Add some glow effect around edges
    float edgeGlow = smoothstep(0.0, 0.1, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    edgeGlow = 1.0 - edgeGlow;
    vec3 glowColor = vec3(0.4, 0.7, 1.0) * edgeGlow * 0.3;
    
    // Final color combination
    fragColor = vec4(glassEffect.rgb + glowColor, glassEffect.a);
    
    // Apply overall intensity
    fragColor.rgb *= 0.8 + u_intensity * 0.4;
    fragColor.a *= 0.7 + u_intensity * 0.3;
}
