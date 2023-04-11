   ground      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                SAMPLER    +         NOISE_REPEAT_SIZE                     BLEND_FACTOR                            AMBIENT                            LIGHTMAP_WORLD_EXTENTS                                PosUV_WorldPos.vs�  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD;
varying vec3 PS_POS;

void main()
{
	mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
	gl_Position = mtxPVW * vec4( POSITION.xyz, 1.0 );
	PS_TEXCOORD.xy = TEXCOORD0;

	vec4 world_pos = MatrixW * vec4( POSITION.xyz, 1.0 );
	PS_POS.xyz = world_pos.xyz;
}

 	   ground.ps�  #if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[4]; // SAMPLER[3] used in lighting.h

#define BASE_TEXTURE SAMPLER[0]
#define NOISE_TEXTURE SAMPLER[1]
#define MULTILAYER_TEXTURE SAMPLER[2]

uniform float NOISE_REPEAT_SIZE;
uniform vec3 BLEND_FACTOR;

#define SRC_BLEND_FACTOR BLEND_FACTOR.x
#define DEST_BLEND_FACTOR BLEND_FACTOR.y

varying vec2 PS_TEXCOORD;

// Already defined by lighting.h
// varying vec3 PS_POS

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


void main()
{
	vec4 base_colour = texture2D( BASE_TEXTURE, PS_TEXCOORD );
	if( base_colour.a > 0.0 )
	{
		vec2 noise_uv = PS_POS.xz / NOISE_REPEAT_SIZE;
		vec4 noise = texture2D( NOISE_TEXTURE, noise_uv );

		base_colour.rgb *= noise.rgb;

		vec3 layers = texture2D( MULTILAYER_TEXTURE, noise_uv ).rgb;
		layers *= BLEND_FACTOR;

		vec3 colour = base_colour.rgb;
		colour.rgb = layers.r + ( 1.0 - layers.r ) * base_colour.rgb;
		colour.rgb = layers.g + ( 1.0 - layers.g ) * colour.rgb;
		colour.rgb = layers.b + ( 1.0 - layers.b ) * colour.rgb;
		colour.rgb *= base_colour.a;
		colour.rgb *= CalculateLightingContribution();

		gl_FragColor = vec4( colour.rgb, base_colour.a );
	}
	else
	{
		discard;
	}
}

                                