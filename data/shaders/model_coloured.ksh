   model_coloured      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                SAMPLER    +         DIFFUSE_COLOUR                                AMBIENT                            LIGHTMAP_WORLD_EXTENTS                                model.vs�  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;
attribute vec3 NORMAL;

varying vec2 PS_TEXCOORD;
varying vec3 PS_NORMAL;
varying vec3 PS_POS;

void main()
{
	mat4 mtxPVW = MatrixP * MatrixV * MatrixW;

	gl_Position = mtxPVW * vec4( POSITION.xyz, 1.0 );

	PS_NORMAL.xyz = vec3( mtxPVW * vec4( NORMAL.xyz, 0.0 ) ); // TODO: Look up again whether this needs to be transposed or not. Affine transformations might not need to, I can't remember anymore.
	PS_TEXCOORD.xy = TEXCOORD0.xy;

	vec4 world_pos = MatrixW * vec4( POSITION.xyz, 1.0 );
	PS_POS = world_pos.xyz;
}

    model_coloured.ps  #if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[4];

uniform vec4 DIFFUSE_COLOUR;

varying vec2 PS_TEXCOORD;
varying vec3 PS_NORMAL;

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
	gl_FragColor = DIFFUSE_COLOUR;
	gl_FragColor.rgb *= CalculateLightingContribution();
}

                             