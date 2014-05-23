class Map
{
	bool isLand(float x, float y)
	{
		return sampleGround(x, y) > 0.0f;
	}

	bool isWater(float x, float y)
	{
		return sampleGround(x, y) <= 0.0f;
	}

private:
	float[100][100] m_ground;

	// Use bilinear sampling of a height map to get smoother borders
	float sampleGround(float x, float y)
	{
		int ix = cast(int)x;
		int iy = cast(int)y;
		float fx = x - ix;
		float fy = y - iy;
		assert(ix >= 0 && ix < 99);
		assert(iy >= 0 && iy < 99);
		return (m_ground[ix][iy] * (1.0f - fx) + m_ground[ix+1][iy] * fx) * (1.0f - fy) +
			   (m_ground[ix][iy+1] * (1.0f - fx) + m_ground[ix+1][iy+1] * fx) * fy;
	}
}