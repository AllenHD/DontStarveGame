   anim      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                STATIC_WORLD_MATRIX                                                                                SAMPLER    +         AMBIENT                            LIGHTMAP_WORLD_EXTENTS                                TINT_ADD                             	   TINT_MULT                                PARAMS                        EROSION_PARAMS                            anim.vs�  #define FADE_OUT
uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;
uniform mat4 STATIC_WORLD_MATRIX;

attribute vec3 POSITION;
attribute vec3 TEXCOORD0;

varying vec3 PS_TEXCOORD;
varying vec3 PS_POS;

#if defined( FADE_OUT )
    varying vec2 FADE_UV;
#endif

void main()
{
	mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
	gl_Position = mtxPVW * vec4( POSITION.xyz, 1.0 );

	vec4 world_pos = MatrixW * vec4( POSITION.xyz, 1.0 );

	PS_TEXCOORD = TEXCOORD0;
	PS_POS = world_pos.xyz;

#if defined( FADE_OUT )
	vec4 static_world_pos = STATIC_WORLD_MATRIX * vec4( POSITION.xyz, 1.0 );
    vec3 forward = normalize( vec3( MatrixV[2][0], 0.0, MatrixV[2][2] ) );
    float d = dot( static_world_pos.xyz, forward );
    vec3 pos = static_world_pos.xyz + ( forward * -d );
    vec3 left = cross( forward, vec3( 0.0, 1.0, 0.0 ) );

    FADE_UV = vec2( dot( pos, left ) / 4.0, static_world_pos.y / 8.0 );
#endif
}

    anim.ps=  #define FADE_OUT
#if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[4];

#ifndef LIGHTING_H
#define LIGHTING_H

// Lighting
varying vec3 PS_POS;
uniform vec3 AMBIENT;

// xy = min, zw = max
uniform vec4 LIGHTMAP_WORLD_EXTENTS;

#define LIGHTMAP_TEXTURE SAMPLER[3]

#ifndef LIGHTMAP_TEXTURE
	#error If you use lighting, you must #define the sampler that the lightmap belongs to
#endif

vec3 CalculateLightingContribution()
{
	vec2 range = LIGHTMAP_WORLD_EXTENTS.zw - LIGHTMAP_WORLD_EXTENTS.xy;
	vec2 uv = ( PS_POS.xz - LIGHTMAP_WORLD_EXTENTS.xy ) / range.xy;

	vec3 colour = texture2D( LIGHTMAP_TEXTURE, uv.xy ).rgb + AMBIENT.rgb;

	return clamp( colour.rgb, vec3( 0, 0, 0 ), vec3( 1, 1, 1 ) );
}

vec3 CalculateLightingContribution( vec3 normal )
{
	return vec3( 1, 1, 1 );
}

#endif //LIGHTING.h


varying vec3 PS_TEXCOORD;

uniform vec4 TINT_ADD;
uniform vec4 TINT_MULT;
uniform vec2 PARAMS;

#define ALPHA_TEST PARAMS.x
#define LIGHT_OVERRIDE PARAMS.y

#if defined( FADE_OUT )
	uniform vec3 EROSION_PARAMS; 
    varying vec2 FADE_UV;

	#define ERODE_SAMPLER SAMPLER[2]
	#define EROSION_MIN EROSION_PARAMS.x
	#define EROSION_RANGE EROSION_PARAMS.y
	#define EROSION_LERP EROSION_PARAMS.z
#endif

void main()
{
	vec4 colour;
	if( PS_TEXCOORD.z < 0.5 )
	{
		colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
	}
	else
	{
		colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
	}

	if( colour.a >= ALPHA_TEST )
	{
		gl_FragColor.rgba = colour.rgba;
		gl_FragColor.rgba *= TINT_MULT.rgba;
		gl_FragColor.rgb += vec3( TINT_ADD.rgb * colour.a );

#if defined( FADE_OUT )
		float height = texture2D( ERODE_SAMPLER, FADE_UV.xy ).a;
		float erode_val = clamp( ( height - EROSION_MIN ) / EROSION_RANGE, 0.0, 1.0 );
		gl_FragColor.rgba = mix( gl_FragColor.rgba, gl_FragColor.rgba * erode_val, EROSION_LERP );
#endif

		vec3 light = CalculateLightingContribution();
		gl_FragColor.rgb *= max( light.rgb, vec3( LIGHT_OVERRIDE, LIGHT_OVERRIDE, LIGHT_OVERRIDE ) );
	}
	else
	{
		discard;
	}
}

                                   	   
   