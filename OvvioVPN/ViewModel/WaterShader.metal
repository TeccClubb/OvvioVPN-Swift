#include <metal_stdlib>
using namespace metal;

// (Keep your 'random' and 'noise' functions exactly as they were)
float random(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

float noise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Main shader function
[[stitchable]] half4 liquidRevealEffect(
    float2 pos,
    float2 size,
    float time,
    float revealProgress,
    // --- FIX ---
    // Accept 6 floats instead of 2 float3 structs
    float colorA_r, float colorA_g, float colorA_b, // skyblue
    float colorB_r, float colorB_g, float colorB_b  // accentPurple
    // --- END FIX ---
) {
    float2 uv = pos / size;
    float animatedTime = time * 0.5;
    float frequency = 10.0;
    
    // --- Reconstruct the colors ---
    half3 colorA = half3(colorA_r, colorA_g, colorA_b);
    half3 colorB = half3(colorB_r, colorB_g, colorB_b);
    // --- End Reconstruct ---

    // --- Wave Distortion (same as before) ---
    float2 waveUv = uv;
    waveUv.x += noise(uv * frequency + animatedTime * 0.1) * 0.05;
    waveUv.y += noise(uv * frequency + animatedTime * 0.1 + float2(10.0, 20.0)) * 0.05;

    // --- Ripple Calculation (same as before) ---
    float rippleFactor = (sin(animatedTime + waveUv.x * frequency * 2.0) + sin(animatedTime * 1.5 + waveUv.y * frequency * 1.5)) * 0.1;
    
    // --- Base Color Gradient (same as before) ---
    half3 gradientColor = mix(colorA, colorB, half(uv.y));
    half4 waterColor = half4(gradientColor, half(0.85));
    
    // --- Lighting Effects (same as before) ---
    float reflection = pow(abs(rippleFactor * 2.0), 5.0) * 0.5;
    waterColor.rgb += reflection * half3(0.8, 0.9, 1.0);
    
    float depthEffect = pow(abs(rippleFactor) * 0.5 + 0.1, 2.0);
    waterColor.rgb -= depthEffect * half3(0.0, 0.1, 0.2);

    // --- Reveal Line (same as before) ---
    float waveAmplitude = 0.03;
    float noise1 = noise(float2(uv.x * 5.0, animatedTime));
    float distortion = noise1 * waveAmplitude;
    float fillLine = (revealProgress * 1.1) + distortion;

    // --- Mask (same as before) ---
    if (uv.y < fillLine) {
        return waterColor;
    }
    return half4(0.0, 0.0, 0.0, 0.0); // Return clear
}
