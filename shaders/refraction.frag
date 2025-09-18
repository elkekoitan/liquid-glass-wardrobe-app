#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

// Input uniforms from Flutter
uniform float u_time;           // Animation time
uniform vec2 u_resolution;      // Screen resolution
uniform float u_refractionIndex; // Glass refraction index (typically 1.5 for glass)
uniform float u_thickness;      // Glass thickness
uniform vec4 u_tintColor;       // Glass tint color
uniform sampler2D u_texture;    // Background texture to refract

// Output color
out vec4 fragColor;

// Noise function for surface irregularities
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Smooth noise for glass surface variations
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Generate normal map for glass surface
vec3 getGlassNormal(vec2 uv) {
    float scale = 3.0;
    float timeOffset = u_time * 0.1;
    
    // Multiple octaves of noise for realistic glass surface
    float n1 = noise(uv * scale + timeOffset);
    float n2 = noise(uv * scale * 2.0 + timeOffset * 1.3) * 0.5;
    float n3 = noise(uv * scale * 4.0 + timeOffset * 0.7) * 0.25;
    
    float height = n1 + n2 + n3;
    
    // Calculate normal from height differences
    float offset = 0.01;
    float heightL = noise((uv + vec2(-offset, 0.0)) * scale + timeOffset);
    float heightR = noise((uv + vec2(offset, 0.0)) * scale + timeOffset);
    float heightU = noise((uv + vec2(0.0, -offset)) * scale + timeOffset);
    float heightD = noise((uv + vec2(0.0, offset)) * scale + timeOffset);
    
    vec3 normal = normalize(vec3(
        (heightR - heightL) * 0.5,
        (heightD - heightU) * 0.5,
        1.0
    ));
    
    return normal;
}

// Calculate refraction using Snell's law
vec2 calculateRefraction(vec3 incident, vec3 normal, float refractionIndex) {
    float cosI = -dot(incident, normal);
    float sinT2 = refractionIndex * refractionIndex * (1.0 - cosI * cosI);
    
    if (sinT2 > 1.0) {
        // Total internal reflection
        return reflect(incident, normal).xy;
    }
    
    float cosT = sqrt(1.0 - sinT2);
    vec3 refracted = refractionIndex * incident + (refractionIndex * cosI - cosT) * normal;
    
    return refracted.xy;
}

// Calculate Fresnel reflectance
float fresnel(vec3 incident, vec3 normal, float refractionIndex) {
    float cosI = abs(dot(incident, normal));
    float sinT2 = refractionIndex * refractionIndex * (1.0 - cosI * cosI);
    
    if (sinT2 > 1.0) {
        return 1.0; // Total internal reflection
    }
    
    float cosT = sqrt(1.0 - sinT2);
    float rs = (refractionIndex * cosI - cosT) / (refractionIndex * cosI + cosT);
    float rp = (cosI - refractionIndex * cosT) / (cosI + refractionIndex * cosT);
    
    return (rs * rs + rp * rp) * 0.5;
}

// Create dispersion effect (chromatic aberration)
vec3 getDispersedColor(vec2 uv, vec2 refraction) {
    float dispersionStrength = 0.01;
    
    // Different refraction indices for RGB
    vec2 redRefraction = refraction * (1.0 + dispersionStrength);
    vec2 greenRefraction = refraction;
    vec2 blueRefraction = refraction * (1.0 - dispersionStrength);
    
    float red = texture(u_texture, uv + redRefraction).r;
    float green = texture(u_texture, uv + greenRefraction).g;
    float blue = texture(u_texture, uv + blueRefraction).b;
    
    return vec3(red, green, blue);
}

// Add caustic light patterns
float caustic(vec2 uv, float time) {
    vec2 pos = uv * 10.0;
    float c = 0.0;
    
    // Multiple sine waves to create caustic patterns
    c += sin(pos.x * 2.0 + time * 2.0) * sin(pos.y * 1.5 + time * 1.5);
    c += sin(pos.x * 1.7 + time * 1.8) * sin(pos.y * 2.3 + time * 2.1);
    c += sin(pos.x * 2.5 + time * 1.2) * sin(pos.y * 1.8 + time * 1.7);
    
    c = c * 0.3 + 0.5;
    c = smoothstep(0.3, 0.7, c);
    
    return c;
}

// Create underwater light effect
vec3 addUnderwaterEffect(vec3 color, vec2 uv) {
    float time = u_time * 0.5;
    
    // Caustic patterns
    float causticPattern = caustic(uv, time);
    causticPattern *= caustic(uv * 1.3 + 0.1, time * 0.8 + 1.0);
    
    // Blue-green underwater tint
    vec3 underwaterTint = vec3(0.4, 0.8, 1.0);
    
    // Apply caustic lighting
    color += underwaterTint * causticPattern * 0.3;
    
    // Add depth-based color shift
    float depth = (uv.y + sin(uv.x * 5.0 + time) * 0.1) * 0.5;
    vec3 deepColor = vec3(0.0, 0.3, 0.6);
    vec3 shallowColor = vec3(0.3, 0.7, 1.0);
    
    vec3 depthColor = mix(deepColor, shallowColor, depth);
    color = mix(color, depthColor, 0.2);
    
    return color;
}

// Add bubble effects
float bubbleEffect(vec2 uv, float time) {
    float bubbles = 0.0;
    
    // Generate multiple bubbles
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        vec2 bubblePos = vec2(
            sin(time * 0.5 + fi * 0.7) * 0.3 + 0.5,
            fract(time * 0.3 + fi * 0.1)
        );
        
        float bubbleSize = 0.02 + sin(time + fi) * 0.01;
        float dist = distance(uv, bubblePos);
        
        if (dist < bubbleSize) {
            float bubble = 1.0 - smoothstep(bubbleSize * 0.7, bubbleSize, dist);
            bubbles += bubble;
        }
    }
    
    return min(bubbles, 1.0);
}

void main() {
    // Get normalized coordinates
    vec2 uv = FlutterFragCoord() / u_resolution.xy;
    
    // Get glass surface normal
    vec3 normal = getGlassNormal(uv);
    
    // Incident ray (view direction)
    vec3 incident = normalize(vec3(0.0, 0.0, -1.0));
    
    // Calculate refraction
    vec2 refractionOffset = calculateRefraction(incident, normal, u_refractionIndex) * u_thickness * 0.1;
    
    // Sample background with refraction offset
    vec2 refractedUV = uv + refractionOffset;
    refractedUV = clamp(refractedUV, 0.0, 1.0); // Keep within bounds
    
    // Get dispersed color (chromatic aberration)
    vec3 refractedColor = getDispersedColor(refractedUV, refractionOffset);
    
    // Calculate Fresnel reflectance
    float fresnelFactor = fresnel(incident, normal, u_refractionIndex);
    
    // Create reflection color (simplified)
    vec3 reflectionColor = vec3(0.8, 0.9, 1.0) * 0.1;
    
    // Combine refraction and reflection based on Fresnel
    vec3 finalColor = mix(refractedColor, reflectionColor, fresnelFactor);
    
    // Apply glass tint
    finalColor *= u_tintColor.rgb;
    
    // Add underwater effects
    finalColor = addUnderwaterEffect(finalColor, uv);
    
    // Add bubble effects
    float bubbles = bubbleEffect(uv, u_time);
    finalColor += vec3(bubbles * 0.3);
    
    // Add subtle glow around edges
    float edgeGlow = 1.0 - smoothstep(0.0, 0.1, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    finalColor += vec3(0.2, 0.4, 0.6) * edgeGlow * 0.2;
    
    // Apply overall alpha
    float alpha = u_tintColor.a * (0.8 + fresnelFactor * 0.2);
    
    // Add some shimmer effect
    float shimmer = sin(uv.x * 20.0 + u_time * 3.0) * sin(uv.y * 15.0 + u_time * 2.0);
    shimmer = max(shimmer, 0.0) * 0.1;
    finalColor += vec3(shimmer);
    
    fragColor = vec4(finalColor, alpha);
}
