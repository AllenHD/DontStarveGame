	   triplanar      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                TEXTURESIZE                        SAMPLER    +         MASK_ON                     AMBIENT                            LIGHTMAP_WORLD_EXTENTS                                triplanar.vs:	  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec2 TEXCOORD1;


varying vec2 PS_TEXCOORD0;
varying vec2 PS_TEXCOORD1;
varying vec2 PS_TEXCOORD2;

varying vec3 PS_NORMAL;
//varying vec3 PS_POSITION;
varying vec3 PS_POS;

//varying float TILE_TYPE;
varying vec2 TILE_UV0;
varying vec2 TILE_UV1;

varying vec4 PS_DEPTH;

// vec2 GetAtlasUV(vec2 uv, float material, float numMatsX, float numMatsY)
// {
//    // First make sure u/v are between 0 and 1.
//    while (uv.x > 1.0)
//    {
//       uv.x -= 1.0;
//    }

//    while (uv.x < 0.0)
//    {
//       uv.x += 1.0;
//    }

//    while (uv.y > 1.0)
//    {
//       uv.y -= 1.0;
//    }

//    while (uv.y < 0.0)
//    {
//       uv.y += 1.0;
//    }

//    // Divide by the number of materials to get proper texture UV coordinates
//    uv.x /= numMatsX;
//    uv.y /= numMatsY;

//    float yPos = 0.0;

//    while (material >= numMatsX)
//    {
//       yPos += 1.0;
//       material -= numMatsX;
//    }

//    uv.x += 1.0 / numMatsX * material;
//    uv.y += 1.0 / numMatsY * yPos;

//    return uv;
// }

// vec2 GetAtlasUV(vec2 uv, vec2 uv1, vec2 uv2)
// {
//    uv = mod(abs(uv), 1.0);

//    // Divide by the number of materials to get proper texture UV coordinates
//    uv.x = uv1.x + (uv.x*(uv2.x-uv1.x));
//    uv.y = uv1.y + (uv.y*(uv2.y-uv1.y));

//    return uv;
// }

void main ()
{
    float texure_scale = 0.125;

    TILE_UV0 = TEXCOORD0;
    TILE_UV1 = TEXCOORD1;

    // CEILING
    PS_TEXCOORD0 = POSITION.xz*texure_scale;

    PS_TEXCOORD1 = POSITION.zy*texure_scale;
    PS_TEXCOORD2 = POSITION.xy*texure_scale;

    // PS_TEXCOORD0 = GetAtlasUV(POSITION.xz*texure_scale, TILE_UV0, TILE_UV1);
    // PS_TEXCOORD1 = GetAtlasUV(POSITION.zy*texure_scale, TILE_UV0, TILE_UV1);
    // PS_TEXCOORD2 = GetAtlasUV(POSITION.xy*texure_scale, TILE_UV0, TILE_UV1); // Y - CEILING

    //PS_POSITION = POSITION;
    PS_NORMAL = NORMAL;
    
	mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
	gl_Position = mtxPVW * vec4( POSITION.xyz, 1.0 );
 
    //PS_DEPTH =  gl_Position.z;
    PS_DEPTH = gl_Position;

	vec4 world_pos = MatrixW * vec4( POSITION.xyz, 1.0 );
	PS_POS.xyz = world_pos.xyz;
}    triplanar.ps�  #if defined( GL_ES )
precision mediump float;
#endif

uniform vec2 TEXTURESIZE;
uniform sampler2D SAMPLER[5]; 

#define ATLAS_TEXTURE_0     SAMPLER[0]
//                          SAMPLER[3] used in lighting.h
#define DEPTH_TEXTURE       SAMPLER[4]

varying vec2 PS_TEXCOORD0;
varying vec2 PS_TEXCOORD1;
varying vec2 PS_TEXCOORD2;

varying vec3 PS_NORMAL;
//varying vec3 PS_POSITION;

varying vec4 PS_DEPTH;
// 0 is first pass, 1 - first wall alpha pass, 2 - cieling alpha pass
uniform float MASK_ON; 
#define BG_WALL_PASS        0.0
#define ALPHA_WALL_PASS     1.0
#define ALPHA_CEILING_PASS  2.0

#define PLAYER_MASK_SIZE    300.0*300.0

varying vec2 TILE_UV0;
varying vec2 TILE_UV1;

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

// BACKUP PLAN:
// Make tall textures that dont need modulous


float DecodeFloatRGBA( vec4 rgba ) 
{
  return dot( rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/160581375.0) );
}

vec2 GetAtlasUV(vec2 uv, vec2 uv1, vec2 uv2)
{
   // First make sure u/v are between 0 and 1. Problem is that when we do this in the
   // shader it causes some wierd sampling errors
   // while (uv.x > 1.0)
   // {
   //    uv.x -= 1.0;
   // }

   // while (uv.x < 0.0)
   // {
   //    uv.x += 1.0;
   // }

   // while (uv.y > 1.0)
   // {
   //    uv.y -= 1.0;
   // }

   // while (uv.y < 0.0)
   // {
   //    uv.y += 1.0;
   // }
 
   //uv = fract(uv);
   uv = mod(uv, 1.0);

   uv.x = uv1.x + (uv.x*(uv2.x-uv1.x));
   uv.y = uv1.y + (uv.y*(uv2.y-uv1.y));

   return uv;
}


void main (void)
{          
    vec4 weights = vec4(1.0, 1.0, 1.0, 1.0);
   
    vec2 Z_TEXCOORD = GetAtlasUV(PS_TEXCOORD2, TILE_UV0, TILE_UV1);
    vec2 X_TEXCOORD = GetAtlasUV(PS_TEXCOORD1, TILE_UV0, TILE_UV1);
    vec2 Y_TEXCOORD = GetAtlasUV(PS_TEXCOORD0, TILE_UV0, TILE_UV1); // Y - CEILING
                       
    // this comes from the gpu gems 3 article:
    // generating complex procedural terrains using the gpu
    // used to determine how much of each planar lookup to use
    // for each texture
    vec3 weighting = abs(PS_NORMAL);
    weighting = (weighting - 0.2) * 7.0;
    weighting = max(weighting, vec3(0.0, 0.0, 0.0));
    weighting /= weighting.x + weighting.y + weighting.z;

    vec4 final_colour = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 tempColor = vec4(0.0, 0.0, 0.0, 1.0);


    tempColor =  weighting.z * texture2D(ATLAS_TEXTURE_0, Z_TEXCOORD);
    tempColor += weighting.x * texture2D(ATLAS_TEXTURE_0, X_TEXCOORD);
    tempColor += weighting.y * texture2D(ATLAS_TEXTURE_0, Y_TEXCOORD);
    final_colour += tempColor;       

    float computed_depth = float(1.0-((PS_DEPTH.z/PS_DEPTH.w)));
    //final_colour = vec4(computed_depth,computed_depth,computed_depth, 1.0);//texture2D(DEPTH_TEXTURE, gl_FragCoord.xy/1280.0)*100.0;
    


     vec2 pos = gl_FragCoord.xy - TEXTURESIZE*0.5;
     float dist_squared = dot(pos, pos);

    vec2 depth_coord = vec2(gl_FragCoord.x/TEXTURESIZE.x, gl_FragCoord.y/TEXTURESIZE.y);
    vec4 intValue = texture2D(DEPTH_TEXTURE, depth_coord);

    // const float fromFixed = 256.0/255;
    // float depthmask = intValue.r*fromFixed/(1) +intValue.g*fromFixed/(255)  +intValue.b*fromFixed/(255*255) +intValue.a*fromFixed/(255*255*255);
    float depthmask = DecodeFloatRGBA(intValue);

    //final_colour.g *= depthmask.x;
    float mask_alpha =  dist_squared / (PLAYER_MASK_SIZE);

    float render = 1.0;
    // If we are withing the kill radius
    if (dist_squared < PLAYER_MASK_SIZE )
    {
        if (MASK_ON == BG_WALL_PASS)
        {
            // Is the wall within the cone and infront of the player?
            if (depthmask>0.0 && depthmask<computed_depth)
            {
               //final_colour.a = mask_alpha; //
               discard;
               // render = 0.0;
            }   

            //final_colour.b=mask_alpha;
        }
        else if (MASK_ON == ALPHA_WALL_PASS)
        {
            // If it is on the alpha wall pass and within the cone... and infront of the player
            // alpha it out
            final_colour.a = mask_alpha;

            if (depthmask<computed_depth+0.2)
            {
               // final_colour.r=mask_alpha;
                discard;
                render = 0.0;
            }

            if (depthmask<0.0|| depthmask>computed_depth)
            {
               //final_colour.a = mask_alpha; //
               discard;
               // render = 0.0;
            }   

       }
        else if(MASK_ON == ALPHA_CEILING_PASS)
        {
            // If it is on the alpha wall pass and within the cone... and infront of the player
            // alpha it out
            if (depthmask>0.0 && depthmask<computed_depth)
            {
               //discard;// final_colour.a = depthmask;//mask_alpha;
               final_colour.a = mask_alpha;//mask_alpha;render = 0.0;
            }   
            //final_colour.g=mask_alpha;
        }   
    }
    else
    {
        // If it is the alpha pass but outside the circle, discard it
        if (MASK_ON == ALPHA_WALL_PASS)
        {
            discard;render = 0.0;

            //final_colour.r = mask_alpha;//mask_alpha;render = 0.0;
            //final_colour.g = mask_alpha;//mask_alpha;render = 0.0;
 
            
        }
    }

    if (render==1.0)
    {
        // if (depthmask>0.8)
        // {
        //     final_colour.rgb = vec3(1.0,0.0,0.0);
        // }
        
        // if (computed_depth>0.8)
        // {
        //     final_colour.rgb = vec3(0.0,1.0,0.0);
        // }
        
        // if (depthmask>computed_depth)
        // {
        //     final_colour.rgb = vec3(0.0,0.0,1.0);
        // }
        // if (depthmask<computed_depth)
        // {
        //     final_colour.rgb = vec3(0.0,1.0,1.0);
        // }

        final_colour.rgb *= CalculateLightingContribution(); 
        gl_FragColor = final_colour;
    }
} 
                                