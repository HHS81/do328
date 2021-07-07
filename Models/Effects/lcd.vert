// Author: Nikolai V. Chr.
// License: GPL v2
#version 120

varying	vec3	VNormal;
varying vec3 	eyeVec;

varying float	flogz;

void setupShadows(vec4 eyeSpacePos);//Compositor

void main(void) {
		vec4 ecPosition = gl_ModelViewMatrix * gl_Vertex;
		eyeVec = ecPosition.xyz;

		VNormal = normalize(gl_NormalMatrix * gl_Normal);

		gl_Position = ftransform();
		gl_ClipVertex = ecPosition;
		flogz = 1.0 + gl_Position.w;
		gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
		setupShadows(ecPosition);//Compositor
}
