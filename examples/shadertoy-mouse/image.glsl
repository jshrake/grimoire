// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// See also:
//
// Input - Keyboard    : https://www.shadertoy.com/view/lsXGzf
// Input - Microphone  : https://www.shadertoy.com/view/llSGDh
// Input - Mouse       : https://www.shadertoy.com/view/Mss3zH
// Input - Sound       : https://www.shadertoy.com/view/Xds3Rr
// Input - SoundCloud  : https://www.shadertoy.com/view/MsdGzn
// Input - Time        : https://www.shadertoy.com/view/lsXGz8
// Input - TimeDelta   : https://www.shadertoy.com/view/lsKGWV
// Inout - 3D Texture  : https://www.shadertoy.com/view/4llcR4


float distanceToSegment( vec2 a, vec2 b, vec2 p )
{
	vec2 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xx;
    vec4 m = iMouse / iResolution.xxxx;
	
	vec3 col = vec3(0.0);

	if( m.z>0.0 )
	{
		float d = distanceToSegment( m.xy, m.zw, p );
        col = mix( col, vec3(1.0,1.0,0.0), 1.0-smoothstep(.004,0.008, d) );
	}

	col = mix( col, vec3(1.0,0.0,0.0), 1.0-smoothstep(0.03,0.035, length(p-m.xy)) );
    col = mix( col, vec3(0.0,0.0,1.0), 1.0-smoothstep(0.03,0.035, length(p-abs(m.zw))) );

	fragColor = vec4( col, 1.0 );
}

out vec4 fragColor;
void main() { mainImage(fragColor, gl_FragCoord.xy); }
