   ui      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                             	   UV_PARAMS                                SAMPLER    +      	   TINT_MULT                             	   ALPHA_MIN                  	   ALPHA_MAX                     PosUVScaled.vsp  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

uniform vec4 UV_PARAMS;

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD;

void main()
{
	mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
	gl_Position = mtxPVW * vec4( POSITION.xyz, 1.0 );
	PS_TEXCOORD.xy = UV_PARAMS.xy + ( TEXCOORD0.xy * UV_PARAMS.zw );
}

    ui.ps  #if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[1];
varying vec2 PS_TEXCOORD;

uniform vec4 TINT_MULT;
uniform float ALPHA_MIN;
uniform float ALPHA_MAX;

void main()
{
	// Some Android shader compilers cannot read from output vars
    vec4 temp = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
    float alpha = TINT_MULT.a*temp.a;
    alpha = clamp( ( alpha - ALPHA_MIN ) / ( ALPHA_MAX - ALPHA_MIN ), 0.0, 1.0 );
      
	gl_FragColor = vec4( temp.rgb * TINT_MULT.rgb * alpha, alpha );
}

                                