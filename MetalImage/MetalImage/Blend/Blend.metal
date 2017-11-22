//
//  Blend.metal
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_sourceOverBlend(VertexIO2 inFrag[[ stage_in ]],
                                        texture2d<half> texture1[[ texture(0) ]],
                                        texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    return mix(textureColor, textureColor2, textureColor2.a);
}

fragment half4 fragment_colorBurnBlend(VertexIO2 inFrag[[ stage_in ]],
                                       texture2d<half> texture1[[ texture(0) ]],
                                       texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    half4 whiteColor = half4(1.0h);
    return whiteColor - (whiteColor - textureColor) / textureColor2;
}

fragment half4 fragment_colorDodgeBlend(VertexIO2 inFrag[[ stage_in ]],
                                        texture2d<half> texture1[[ texture(0) ]],
                                        texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half3 baseOverlayAlphaProduct = half3(overlay.a * base.a);
    half3 rightHandProduct = overlay.rgb * (1.0h - base.a) + base.rgb * (1.0h - overlay.a);
    
    half3 firstBlendColor = baseOverlayAlphaProduct + rightHandProduct;
    half3 overlayRGB = clamp((overlay.rgb / clamp(overlay.a, 0.01h, 1.0h)) * step(0.0h, overlay.a), 0.0h, 0.99h);
    
    half3 secondBlendColor = (base.rgb * overlay.a) / (1.0h - overlayRGB) + rightHandProduct;
    
    half3 colorChoice = step((overlay.rgb * base.a + base.rgb * overlay.a), baseOverlayAlphaProduct);
    
    return half4(mix(firstBlendColor, secondBlendColor, colorChoice), 1.0h);
}

fragment half4 fragment_darkenBlend(VertexIO2 inFrag[[ stage_in ]],
                                    texture2d<half> texture1[[ texture(0) ]],
                                    texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlayer = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return half4(min(overlayer.rgb * base.a, base.rgb * overlayer.a) + overlayer.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlayer.a), 1.0);
}

fragment half4 fragment_differenceBlend(VertexIO2 inFrag[[ stage_in ]],
                                        texture2d<half> texture1[[ texture(0) ]],
                                        texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return half4(abs(textureColor2.rgb - textureColor.rgb), textureColor.a);
}

fragment half4 fragment_dissolveBlend(VertexIO2 inFrag[[ stage_in ]],
                                        texture2d<half> texture1[[ texture(0) ]],
                                        texture2d<half> texture2[[ texture(1) ]],
                                      constant float &mixturePercent [[ buffer(0) ]] )
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return mix(textureColor, textureColor2, half(mixturePercent));
}

fragment half4 fragment_exclusionBlend(VertexIO2 inFrag[[ stage_in ]],
                                       texture2d<half> texture1[[ texture(0) ]],
                                       texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    //     Dca = (Sca.Da + Dca.Sa - 2.Sca.Dca) + Sca.(1 - Da) + Dca.(1 - Sa)
    
    return half4((overlay.rgb * base.a + base.rgb * overlay.a - 2.0 * overlay.rgb * base.rgb) + overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a), base.a);
}


fragment half4 fragment_hardlightBlend(VertexIO2 inFrag[[ stage_in ]],
                                       texture2d<half> texture1[[ texture(0) ]],
                                       texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half ra;
    if (2.0 * overlay.r < overlay.a) {
        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    }
    
    half ga;
    if (2.0 * overlay.g < overlay.a) {
        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    }
    
    half ba;
    if (2.0 * overlay.b < overlay.a) {
        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    }
    
    return half4(ra, ga, ba, 1.0);
}

fragment half4 fragment_softlightBlend(VertexIO2 inFrag[[ stage_in ]],
                                       texture2d<half> texture1[[ texture(0) ]],
                                       texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half alphaDivisor = base.a + step(base.a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    return base * (overlay.a * (base / alphaDivisor) + (2.0 * overlay * (1.0 - (base / alphaDivisor)))) + overlay * (1.0 - base.a) + base * (1.0 - overlay.a);
}

fragment half4 fragment_lightenBlend(VertexIO2 inFrag[[ stage_in ]],
                                     texture2d<half> texture1[[ texture(0) ]],
                                     texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return max(textureColor, textureColor2);
}

fragment half4 fragment_addBlend(VertexIO2 inFrag[[ stage_in ]],
                                 texture2d<half> texture1[[ texture(0) ]],
                                 texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half r;
    if (overlay.r * base.a + base.r * overlay.a >= overlay.a * base.a) {
        r = overlay.a * base.a + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    } else {
        r = overlay.r + base.r;
    }
    
    half g;
    if (overlay.g * base.a + base.g * overlay.a >= overlay.a * base.a) {
        g = overlay.a * base.a + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    } else {
        g = overlay.g + base.g;
    }
    
    half b;
    if (overlay.b * base.a + base.b * overlay.a >= overlay.a * base.a) {
        b = overlay.a * base.a + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    } else {
        b = overlay.b + base.b;
    }
    
    half a = overlay.a + base.a - overlay.a * base.a;
    
    return half4(r, g, b, a);
}

fragment half4 fragment_subtractBlend(VertexIO2 inFrag[[ stage_in ]],
                                      texture2d<half> texture1[[ texture(0) ]],
                                      texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return half4(textureColor.rgb - textureColor2.rgb, textureColor.a);
}

fragment half4 fragment_divideBlend(VertexIO2 inFrag[[ stage_in ]],
                                 texture2d<half> texture1[[ texture(0) ]],
                                 texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half ra;
    if (overlay.a == 0.0h || ((base.r / overlay.r) > (base.a / overlay.a)))
        ra = overlay.a * base.a + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    else
        ra = (base.r * overlay.a * overlay.a) / overlay.r + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    
    
    half ga;
    if (overlay.a == 0.0h || ((base.g / overlay.g) > (base.a / overlay.a)))
        ga = overlay.a * base.a + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    else
        ga = (base.g * overlay.a * overlay.a) / overlay.g + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    
    
    half ba;
    if (overlay.a == 0.0h || ((base.b / overlay.b) > (base.a / overlay.a)))
        ba = overlay.a * base.a + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    else
        ba = (base.b * overlay.a * overlay.a) / overlay.b + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    
    half a = overlay.a + base.a - overlay.a * base.a;
    
    return half4(ra, ga, ba, a);
}

fragment half4 fragment_multiplyBlend(VertexIO2 inFrag[[ stage_in ]],
                                      texture2d<half> texture1[[ texture(0) ]],
                                      texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlayer = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    return overlayer * base + overlayer * (1.0h - base.a) + base * (1.0h - overlayer.a);
}

fragment half4 fragment_overlayBlend(VertexIO2 inFrag[[ stage_in ]],
                                     texture2d<half> texture1[[ texture(0) ]],
                                     texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 base = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 overlay = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half ra;
    if (2.0h * base.r < base.a) {
        ra = 2.0h * overlay.r * base.r + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0h * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    }
    
    half ga;
    if (2.0h * base.g < base.a) {
        ga = 2.0h * overlay.g * base.g + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0h * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    }
    
    half ba;
    if (2.0h * base.b < base.a) {
        ba = 2.0h * overlay.b * base.b + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0h * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    }
    
    return half4(ra, ga, ba, 1.0h);
}

fragment half4 fragment_screenBlend(VertexIO2 inFrag[[ stage_in ]],
                                      texture2d<half> texture1[[ texture(0) ]],
                                      texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 textureColor = texture1.sample(qsampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(qsampler, inFrag.textureCoordinate2);
    
    half4 whiteColor = half4(1.0h);
    return whiteColor - ((whiteColor - textureColor2) * (whiteColor - textureColor));
}

typedef struct {
    packed_float3 colorToReplace;
    float smoothing;
    float thresholdSensitivity;
}ChromaKeyParameters;

fragment half4 fragment_chromaKeyBlend(VertexIO2         inFrag  [[ stage_in ]],
                                       texture2d<half> texture1[[ texture(0) ]],
                                       texture2d<half> texture2[[ texture(1) ]],
                                       constant ChromaKeyParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    float3 colorToReplace = parameters.colorToReplace;
    float smoothing = parameters.smoothing;
    float thresholdSensitivity = parameters.thresholdSensitivity;
    
    float maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
    float maskCr = 0.7132 * (colorToReplace.r - maskY);
    float maskCb = 0.5647 * (colorToReplace.b - maskY);
    
    float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
    float Cr = 0.7132 * (textureColor.r - Y);
    float Cb = 0.5647 * (textureColor.b - Y);
    
    //     float blendValue = 1.0 - smoothstep(thresholdSensitivity - smoothing, thresholdSensitivity , abs(Cr - maskCr) + abs(Cb - maskCb));
    float blendValue = 1.0 - smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(float2(Cr, Cb), float2(maskCr, maskCb)));
    
    return mix(textureColor, textureColor2, half(blendValue));
}

fragment half4 fragment_alphaBlend(VertexIO2         inFrag  [[ stage_in ]],
                                   texture2d<half> texture1[[ texture(0) ]],
                                   texture2d<half> texture2[[ texture(1) ]],
                                   constant float &mixturePercent  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a * half(mixturePercent)), textureColor.a);
}

fragment half4 fragment_normalBlend(VertexIO2         inFrag  [[ stage_in ]],
                                   texture2d<half> texture1[[ texture(0) ]],
                                   texture2d<half> texture2[[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 c2 = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 c1 = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    half4 outputColor;
    
    //     outputColor.r = c1.r + c2.r * c2.a * (1.0 - c1.a);
    //     outputColor.g = c1.g + c2.g * c2.a * (1.0 - c1.a);
    //     outputColor.b = c1.b + c2.b * c2.a * (1.0 - c1.a);
    //     outputColor.a = c1.a + c2.a * (1.0 - c1.a);
    
    half a = c1.a + c2.a * (1.0 - c1.a);
    half alphaDivisor = a + step(a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    outputColor.r = (c1.r * c1.a + c2.r * c2.a * (1.0 - c1.a))/alphaDivisor;
    outputColor.g = (c1.g * c1.a + c2.g * c2.a * (1.0 - c1.a))/alphaDivisor;
    outputColor.b = (c1.b * c1.a + c2.b * c2.a * (1.0 - c1.a))/alphaDivisor;
    outputColor.a = a;
    
    return outputColor;
}

half lum(half3 c) {
    return dot(c, half3(0.3h, 0.59h, 0.11h));
}

half3 clipcolor(half3 c) {
    half l = lum(c);
    half n = min(min(c.r, c.g), c.b);
    half x = max(max(c.r, c.g), c.b);
    
    if (n < 0.0) {
        c.r = l + ((c.r - l) * l) / (l - n);
        c.g = l + ((c.g - l) * l) / (l - n);
        c.b = l + ((c.b - l) * l) / (l - n);
    }
    if (x > 1.0) {
        c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
        c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
        c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
    }
    
    return c;
}

half3 setlum(half3 c, half l) {
    half d = l - lum(c);
    c = c + half3(d);
    return clipcolor(c);
}

half sat(half3 c) {
    half n = min(min(c.r, c.g), c.b);
    half x = max(max(c.r, c.g), c.b);
    return x - n;
}

half mid(half cmin, half cmid, half cmax, half s) {
    return ((cmid - cmin) * s) / (cmax - cmin);
}

half3 setsat(half3 c, half s) {
    if (c.r > c.g) {
        if (c.r > c.b) {
            if (c.g > c.b) {
                /* g is mid, b is min */
                c.g = mid(c.b, c.g, c.r, s);
                c.b = 0.0;
            } else {
                /* b is mid, g is min */
                c.b = mid(c.g, c.b, c.r, s);
                c.g = 0.0;
            }
            c.r = s;
        } else {
            /* b is max, r is mid, g is min */
            c.r = mid(c.g, c.r, c.b, s);
            c.b = s;
            c.r = 0.0;
        }
    } else if (c.r > c.b) {
        /* g is max, r is mid, b is min */
        c.r = mid(c.b, c.r, c.g, s);
        c.g = s;
        c.b = 0.0;
    } else if (c.g > c.b) {
        /* g is max, b is mid, r is min */
        c.b = mid(c.r, c.b, c.g, s);
        c.g = s;
        c.r = 0.0;
    } else if (c.b > c.g) {
        /* b is max, g is mid, r is min */
        c.g = mid(c.r, c.g, c.b, s);
        c.b = s;
        c.r = 0.0;
    } else {
        c = half3(0.0);
    }
    return c;
}

/**
 * Color blend mode based upon pseudo code from the PDF specification.
 */
fragment half4 fragment_colorBlend(VertexIO2         inFrag  [[ stage_in ]],
                                   texture2d<half> texture1 [[ texture(0) ]],
                                   texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 baseColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 overlayColor = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(baseColor.rgb * (1.0h - overlayColor.a) + setlum(overlayColor.rgb, lum(baseColor.rgb)) * overlayColor.a, baseColor.a);
}

/**
 * Hue blend mode based upon pseudo code from the PDF specification.
 */
fragment half4 fragment_hueBlend(VertexIO2         inFrag  [[ stage_in ]],
                                 texture2d<half> texture1 [[ texture(0) ]],
                                 texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 baseColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 overlayColor = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(baseColor.rgb * (1.0h - overlayColor.a) + setlum(setsat(overlayColor.rgb, sat(baseColor.rgb)), lum(baseColor.rgb)) * overlayColor.a, baseColor.a);
}


/**
 * Saturation blend mode based upon pseudo code from the PDF specification.
 */
fragment half4 fragment_saturationBlend(VertexIO2         inFrag  [[ stage_in ]],
                                        texture2d<half> texture1 [[ texture(0) ]],
                                        texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 baseColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 overlayColor = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(baseColor.rgb * (1.0h - overlayColor.a) + setlum(setsat(baseColor.rgb, sat(overlayColor.rgb)), lum(baseColor.rgb)) * overlayColor.a, baseColor.a);
}

/**
 * Luminosity blend mode based upon pseudo code from the PDF specification.
 */
fragment half4 fragment_luminosityBlend(VertexIO2         inFrag  [[ stage_in ]],
                                        texture2d<half> texture1 [[ texture(0) ]],
                                        texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 baseColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 overlayColor = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(baseColor.rgb * (1.0h - overlayColor.a) + setlum(baseColor.rgb, lum(overlayColor.rgb)) * overlayColor.a, baseColor.a);
}

fragment half4 fragment_linearBurnBlend(VertexIO2         inFrag  [[ stage_in ]],
                                        texture2d<half> texture1 [[ texture(0) ]],
                                        texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    return half4(clamp(textureColor.rgb + textureColor2.rgb - half3(1.0h), half3(0.0h), half3(1.0h)), textureColor.a);
}

fragment half4 fragment_maskFilter(VertexIO2         inFrag  [[ stage_in ]],
                                   texture2d<half> texture1 [[ texture(0) ]],
                                   texture2d<half> texture2 [[ texture(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    half4 textureColor2 = texture2.sample(quadSampler, inFrag.textureCoordinate2);
    
    
    //Averages mask's the RGB values, and scales that value by the mask's alpha
    //
    //The dot product should take fewer cycles than doing an average normally
    //
    //Typical/ideal case, R,G, and B will be the same, and Alpha will be 1.0
    half newAlpha = dot(textureColor2.rgb, half3(0.33333334h)) * textureColor.a;
    
    return half4(textureColor.xyz, newAlpha);
}


