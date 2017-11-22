//
//  MetalImageSphereRefractionFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float2 center;
    float radius;
    float refractiveIndex;
    float aspectRatio;
}SphereParameters;

fragment half4 fragment_SphereRefractionFilter(VertexIO         inFrag  [[ stage_in ]],
                                    texture2d<half>  tex2D   [[ texture(0) ]],
                                    constant SphereParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 textureCoordinate = inFrag.textureCoordinate;
    float2 textureCoordinateToUse = float2(textureCoordinate.x, (textureCoordinate.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    float distanceFromCenter = distance(parameters.center, textureCoordinateToUse);
    float checkForPresenceWithinSphere = step(distanceFromCenter, parameters.radius);
    distanceFromCenter = distanceFromCenter/parameters.radius;
    float normalizedDepth = parameters.radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
    
    float3 sphereNormal = normalize(float3(textureCoordinateToUse - parameters.center, normalizedDepth));
    
    float3 refractedVector = refract(float3(0.0, 0.0, -1.0), sphereNormal, parameters.refractiveIndex);
    
    return tex2D.sample(quadSampler, (refractedVector.xy + 1.0) * 0.5) * checkForPresenceWithinSphere;
}

fragment half4 fragment_GlassSphereFilter(VertexIO         inFrag  [[ stage_in ]],
                                          texture2d<half>  tex2D   [[ texture(0) ]],
                                          constant SphereParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 textureCoordinate = inFrag.textureCoordinate;
    // uniform vec3 lightPosition;
    const float3 lightPosition = float3(-0.5, 0.5, 1.0);
    const float3 ambientLightPosition = float3(0.0, 0.0, 1.0);
    
    float2 textureCoordinateToUse = float2(textureCoordinate.x, (textureCoordinate.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    float distanceFromCenter = distance(parameters.center, textureCoordinateToUse);
    float checkForPresenceWithinSphere = step(distanceFromCenter, parameters.radius);
    
    distanceFromCenter = distanceFromCenter / parameters.radius;
    
    float normalizedDepth = parameters.radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
    float3 sphereNormal = normalize(float3(textureCoordinateToUse - parameters.center, normalizedDepth));
    
    float3 refractedVector = 2.0 * refract(float3(0.0, 0.0, -1.0), sphereNormal, parameters.refractiveIndex);
    refractedVector.xy = -refractedVector.xy;
    
    half3 finalSphereColor = tex2D.sample(quadSampler, (refractedVector.xy + 1.0) * 0.5).rgb;
    
    // Grazing angle lighting
    half lightingIntensity = 2.5 * (1.0 - pow(clamp(dot(ambientLightPosition, sphereNormal), 0.0, 1.0), 0.25));
    finalSphereColor += lightingIntensity;
    
    // Specular lighting
    lightingIntensity  = clamp(dot(normalize(lightPosition), sphereNormal), 0.0, 1.0);
    lightingIntensity  = pow(lightingIntensity, 15.0h);
    finalSphereColor += half3(0.8) * lightingIntensity;
    
    return half4(finalSphereColor, 1.0h) * checkForPresenceWithinSphere;
}
