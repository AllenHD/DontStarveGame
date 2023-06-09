   postprocessbloomdistort      SAMPLER    +         PARAMS                            DISTORTION_PARAMS                            ndc.vs�   #define ENABLE_BLOOM
#define ENABLE_DISTORTION
attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD;

void main()
{
	gl_Position = vec4( POSITION.xyz, 1.0 );
	PS_TEXCOORD.xy = TEXCOORD0.xy;
}

    postprocess.psC  #define ENABLE_BLOOM
#define ENABLE_DISTORTION
#if defined( GL_ES )
precision highp float;
#endif

#if defined( ENABLE_BLOOM )
// Angle is REALLY anal about this. You can't enable a sampler
// that you aren't going to use or it very quietly asserts in the
// dll with a spectacularly less than informative assert.
uniform sampler2D SAMPLER[6];
#else
uniform sampler2D SAMPLER[5];
#endif

uniform vec3 PARAMS;

#define TIME				PARAMS.x
#define CC_LERP				PARAMS.y
#define CC_LERP2			PARAMS.z

#define SRC_IMAGE			SAMPLER[0]
#define COLOUR_CUBE_SRC		SAMPLER[1]
#define COLOUR_CUBE_DEST	SAMPLER[2]
#define COLOUR_CUBE_SRC2	SAMPLER[3]
#define COLOUR_CUBE_DEST2	SAMPLER[4]
#define BLOOM_BUFFER		SAMPLER[5]

varying vec2 PS_TEXCOORD;

#define CUBE_DIMENSION 32.0
#define CUBE_WIDTH ( CUBE_DIMENSION * CUBE_DIMENSION )
#define CUBE_HEIGHT ( CUBE_DIMENSION )


#if defined( ENABLE_DISTORTION )
	uniform vec3 DISTORTION_PARAMS;

	#define DISTORTION_FACTOR			DISTORTION_PARAMS.x
	#define DISTORTION_INNER_RADIUS		DISTORTION_PARAMS.y
	#define DISTORTION_OUTER_RADIUS		DISTORTION_PARAMS.z
#endif

vec2 GetCCUV( vec3 colour )
{
    vec3 intermediate = colour.rgb * vec3( CUBE_DIMENSION - 1.0, CUBE_DIMENSION, CUBE_DIMENSION - 1.0 / CUBE_WIDTH ); // rgb all 0:31 - cube space
	vec2 uv = vec2( ( min( intermediate.r + 0.5, 31.0 ) + floor( intermediate.b ) * CUBE_DIMENSION ) / CUBE_WIDTH,
                          1.0 - ( min( intermediate.g, 31.0 ) / CUBE_HEIGHT ) );

	return uv;
}

void main()
{
	vec3 base_colour = texture2D( SRC_IMAGE, PS_TEXCOORD.xy ).rgb; // rgb all 0:1 - colour space

#if defined( ENABLE_BLOOM )
	vec3 bloom = texture2D( BLOOM_BUFFER, PS_TEXCOORD.xy ).rgb;
	base_colour.rgb += bloom.rgb;
#endif

#if defined( ENABLE_DISTORTION )
	float range = 0.00625;
	float time_scale = 50.0;
	vec2 small_uv = PS_TEXCOORD.xy * ( 1.0 - 2.0 * range ) + range;
	vec2 offset_vec = vec2( cos( TIME * time_scale + 0.25 ), sin( TIME * time_scale ) );

	vec2 offset_uv = small_uv + offset_vec * range;

	// rotation amount
	vec3 distorted_colour = texture2D( SRC_IMAGE, offset_uv ).xyz;

#if defined( ENABLE_BLOOM )
	distorted_colour.rgb += texture2D( BLOOM_BUFFER, offset_uv ).rgb;
#endif

	float distortion_mask = clamp( ( 1.0 - distance( PS_TEXCOORD.xy, vec2( 0.5, 0.5 ) ) - DISTORTION_INNER_RADIUS ) / ( DISTORTION_OUTER_RADIUS - DISTORTION_INNER_RADIUS ), 0.0, 1.0 );
	distorted_colour.rgb = mix( distorted_colour, base_colour, DISTORTION_FACTOR );
	base_colour.rgb = mix( distorted_colour, base_colour, distortion_mask );
#endif

    // 0:1 - uv space
	vec2 base_cc_uv = GetCCUV( base_colour );

	vec3 cc_src = texture2D( COLOUR_CUBE_SRC, base_cc_uv.xy ).rgb;
	vec3 cc_dest = texture2D( COLOUR_CUBE_DEST, base_cc_uv.xy ).rgb;

	vec3 insane_cc_src = texture2D( COLOUR_CUBE_SRC2, base_cc_uv.xy ).rgb;
	vec3 insane_cc_dest = texture2D( COLOUR_CUBE_DEST2, base_cc_uv.xy ).rgb;

	cc_src = mix( cc_src, insane_cc_src, CC_LERP2 );
	cc_dest = mix( cc_dest, insane_cc_dest, CC_LERP2 );

    gl_FragColor = vec4( mix( cc_src, cc_dest, CC_LERP ), 1.0 );
}

                  