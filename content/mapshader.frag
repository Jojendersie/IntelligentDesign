uniform sampler2D texture;
uniform sampler2D noise;

float customStep(float t)
{
  return t * t * (3.0 - 2.0 * t);
}

void main()
{
  vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);
  vec3 noiseVal = texture2D(noise, gl_TexCoord[0].xy*4).rgb;

  gl_FragColor.a = 1;


  float landWaterIndicator = pixel.a;

  vec3 landColor = gl_Color * vec4(landWaterIndicator/2, landWaterIndicator*3/4, 0, 1);
  vec3 waterColor = gl_Color * vec4(0, 0, landWaterIndicator, 1);

  float edge = customStep(landWaterIndicator)*2 - 1.0;
  edge = sqrt(abs(edge)) * sign(edge);
  gl_FragColor.rgb = lerp(waterColor, landColor, edge * 0.5 + 0.5);

  gl_FragColor.rgb *= vec3(0.8) + noiseVal * 0.2;
}