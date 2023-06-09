   ui_anim      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                SAMPLER    +      	   TINT_MULT                                anim.vs�  uniform mat4 MatrixP;
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

 
   ui_anim.ps
  #if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[2];

varying vec3 PS_TEXCOORD;

uniform vec4 TINT_ADD;
uniform vec4 TINT_MULT;

void main()
{
    vec4 colour;
    
	if( PS_TEXCOORD.z < 1.5 )
	{
		if( PS_TEXCOORD.z < 0.5 )
		{
			colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
		}
		else
		{
			colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
		}
	}
	
	gl_FragColor = vec4( colour.rgb * TINT_MULT.rgb * TINT_MULT.a, colour.a * TINT_MULT.a );
}

                       