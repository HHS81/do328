#version 120

//varying vec3 VNormal;
//varying vec3 vViewVec;
//varying vec3 reflVec;

uniform sampler2D BaseTex;
uniform sampler2D DirtTex;

uniform int display_enabled;
uniform float display_brightness;

vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	vec3 texel = vec3(0.0, 0.0, 0.0);

	if(display_enabled > 0) {
		// get texel from texture
		texel = texture2D(BaseTex, gl_TexCoord[0].st).rgb;
		
		// the following operations can only be done in hsv scope
		texel = rgb2hsv(texel);

		// apply brightness
		texel.z *= display_brightness;

		// make dark pixels black to avoid problems when making them too bright
		if(texel.z < 0.1) texel.y = 0;

		// reduce intensity
//		texel.z -= 0.1;

		// typical lcd effect (overflow)
		if(texel.z < 0) texel.z += 1.0;

		// back to rgb
		texel = hsv2rgb(texel);
	}

	vec3 dirt = 0.5*texture2D(DirtTex, gl_TexCoord[0].xy).rgb;
	texel += dirt;
	texel = clamp(texel, 0.0, 1.0);

	// store result
	gl_FragColor = vec4(texel, 1.0);
}
