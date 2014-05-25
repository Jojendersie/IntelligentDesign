uniform sampler2D texture;
uniform sampler2D noise;

float customStep(float t)
{
  return t * t * (3.0 - 2.0 * t);
}

void main()
{
  vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);
  vec3 noiseVal = texture2D(noise, gl_TexCoord[0].xy*4.0).rgb;

  gl_FragColor.a = 1.0;


  float landWaterIndicator = pixel.a;

  vec3 landColor = vec3(landWaterIndicator/2.0, landWaterIndicator*3/4, 0.0);
  vec3 waterColor = vec3(0.0, 0.0, landWaterIndicator);

  float edge = customStep(landWaterIndicator)*2 - 1.0;
  edge = pow(abs(edge), 0.35) * sign(edge);
  gl_FragColor.rgb = mix(waterColor, landColor, edge * 0.5 + 0.5);

  gl_FragColor.rgb *= vec3(0.8) + noiseVal * 0.2;
}