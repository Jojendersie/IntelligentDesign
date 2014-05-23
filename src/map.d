import utils;
import screenmanager;
import dsfml.graphics;


class Map
{
	this()
	{
		generateGround();
	}

	void render(RenderWindow window, ScreenManager screenManager)
	{
		// todo: Draw only visible cells

		float cellSize = screenManager.realtiveLengthToScreenLength(1.0f);
		auto rectangleShape = new RectangleShape(Vector2f(cellSize,cellSize));

		for( int x = 0; x < m_ground.length; ++x )
		{
			for( int y = 0; y < m_ground[0].length; ++y )
			{
				ubyte greyVal = cast(ubyte)(255.0f * m_ground[x][y]);
				rectangleShape.fillColor = Color(greyVal,greyVal,greyVal);
				rectangleShape.position = screenManager.relativeCorToScreenCor(Vector2f(x,y));
				window.draw(rectangleShape);
			}
		}
	}

	bool isLand(float x, float y)
	{
		return sampleGround(x, y) > 0.0f;
	}

	bool isWater(float x, float y)
	{
		return sampleGround(x, y) <= 0.0f;
	}

private:
	// Each cell is one unit large!
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

	void generateGround()
	{
		for( int x = 0; x < 100; ++x )
		{
			for( int y = 0; y < 100; ++y )
			{
				// Generate a value noise value
				float value = 0.0f;
				for( int oct = 0; oct < 5; ++oct )
				{
					// The randomAt-z component can be used to change the landscape over time
					int scale = 1 << oct;
					value += randomAt(x * 0.01f * scale, y * 0.01f * scale, 1.0f) / scale;
				}
				m_ground[x][y] = value;
			}
		}
	}
}