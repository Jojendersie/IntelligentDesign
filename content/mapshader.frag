uniform sampler2D texture;

void main()
{
  vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);

  float landWaterIndicator = pixel.a;
  if(landWaterIndicator > 0.5 )
    gl_FragColor = vec4(landWaterIndicator*0.5, landWaterIndicator*0.75, 0, 1);
  else 
    gl_FragColor = vec4(0, 0, landWaterIndicator, 1);
}