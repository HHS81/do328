#version 120

uniform sampler2D BaseTex;

float SCANTHICK = 2.0;
float INTENSITY = 0.15;
float BRIGHTBOOST = 0.15;
float DISTORTION = 0.03;
float THRESHOLD = 0.05;

vec2 TextureSize = vec2(800, 950);

vec2 distort(vec2 position)
{
	position = vec2(2.0 * position - 1.0);
	position = position / (1.0 - DISTORTION * length(position));
	position = (position + 1.0) * 0.5;
	return position;
}

vec3 frame(vec2 position, vec3 color)
{
	// intersection between two ellipses and four circles
	position -= vec2(0.5);
	position *= vec2(2.0);

	float x2 = position.x * position.x;
	float y2 = position.y * position.y;

	if( (x2/0.87) + (y2/20) > 1 ||
	    (x2/40) + (y2/0.9) > 1)
	{
		color = vec3(0.0, 0.0, 0.0);
	}

	if( length(position) > 1.24 &&
	    length(abs(position)-vec2(0.82, 0.84)) > 0.1)
	{
		color = vec3(0.0, 0.0, 0.0);
	}
	return color;
}

// crt-nes scanline shader from libretro
vec3 scanline(vec2 position, vec3 color)
{
	vec3 pixelHigh = ((1.0 + BRIGHTBOOST) - (0.2 * color)) * color;
	vec3 pixelLow  = ((1.0 - INTENSITY) + (0.1 * color)) * color;
	float selectY = mod(position.y * SCANTHICK * TextureSize.y, 2.0);
	float selectHigh = step(1.0, selectY);
	float selectLow = 1.0 - selectHigh;
	color = (selectLow * pixelLow) + (selectHigh * pixelHigh);
	return color;
}

vec3 backlight(vec3 color)
{
	if(color.r < THRESHOLD && color.g < THRESHOLD && color.b < THRESHOLD)
	{
		color = vec3(THRESHOLD, THRESHOLD, THRESHOLD);
	}
	return color;
}

void main()
{
	vec3 color = vec3(0.0, 0.0, 0.0);
	vec2 position = distort(gl_TexCoord[0].xy);

	if(position.x > 0.0 && position.y > 0.0 && position.x < 1.0 && position.y < 1.0)
	{
		color = texture2D(BaseTex, position).rgb;
		color = scanline(position, color);
		color = backlight(color);
	}
	color = frame(position, color);
	gl_FragColor = vec4(color, 1.0);
}
