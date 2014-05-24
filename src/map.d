import utils;
import screenmanager;
import mapobjects;
import species;

import dsfml.graphics;

import std.algorithm;
import std.random;

class Map
{
	// Initializes entites for every species
	this(Species[] species)
	{
		generateGround();
		startupSpeciesPopulate(species);
	}

	void render(RenderWindow window, const ScreenManager screenManager)
	{
		immutable FloatRect visibleGameArea = screenManager.visibleAreaRelativeCor;
		immutable Vector2i visibleGameArea_UnitsMin = Vector2i(max(cast(int)visibleGameArea.left, 0), max(cast(int)visibleGameArea.top, 0));
		immutable Vector2i visibleGameArea_UnitsMax = Vector2i(min(cast(uint)(visibleGameArea.left + visibleGameArea.width + 1), m_ground.length),
															   min(cast(uint)(visibleGameArea.top + visibleGameArea.height + 1), m_ground[0].length));

		// todo: Use a custom "vertex buffer"
		// todo: set each corner to a a sensible value to get bilinear filtering for FREEEEE :)
		immutable float cellSize = screenManager.relativeLengthToScreenLength(1.0f);
		auto rectangleShape = new RectangleShape(Vector2f(cellSize,cellSize));

		for( int x = visibleGameArea_UnitsMin.x; x < visibleGameArea_UnitsMax.x; ++x )
		{
			for( int y = visibleGameArea_UnitsMin.y; y < visibleGameArea_UnitsMax.y; ++y )
			{
				ubyte greyVal = cast(ubyte)(255.0f * m_ground[x][y]);
				rectangleShape.fillColor = Color(greyVal,greyVal,greyVal);
				rectangleShape.position = screenManager.relativeCorToScreenCor(Vector2f(x,y));
				window.draw(rectangleShape);
			}
		}
	}

	bool isLand(float x, float y) const
	{
		return sampleGround(x, y) > 0.0f;
	}

	bool isWater(float x, float y) const
	{
		return sampleGround(x, y) <= 0.0f;
	}

private:
	// Each cell is one unit large!
	float[100][100] m_ground;
	MapObject[] m_mapObjects;

	// Use bilinear sampling of a height map to get smoother borders
	float sampleGround(float x, float y) const
	{
		int ix = cast(int)x;
		int iy = cast(int)y;
		float fx = x - ix;
		float fy = y - iy;
		assert(ix >= 0 && ix < (m_ground.length-1));
		assert(iy >= 0 && iy < (m_ground[0].length-1));
		return (m_ground[ix][iy] * (1.0f - fx) + m_ground[ix+1][iy] * fx) * (1.0f - fy) +
			   (m_ground[ix][iy+1] * (1.0f - fx) + m_ground[ix+1][iy+1] * fx) * fy;
	}

	void generateGround()
	{
		for( int x = 0; x < m_ground.length; ++x )
		{
			for( int y = 0; y < m_ground[0].length; ++y )
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

	// creates
	void startupSpeciesPopulate(Species[] species)
	{
		auto rnd = Xorshift(unpredictableSeed());
		foreach(s; species)
		{
			uint numEntities = uniform(m_minNum, m_maxNum, rnd);
			for(int i=0; i<numEntities; ++i)
				m_mapObjects ~= new Entity(s);
		}
	}

	enum uint m_minNum = 10;
	enum uint m_maxNum = 20;

}