import utils;
import screenmanager;
import mapobjects;
import species;
import genes;

import dsfml.graphics;

import std.algorithm;
import std.random;
import std.array;

class Map
{
	// Initializes entites for every species
	this(Species[] species, Gene[string] globalGenePool)
	{
		generateGround();
		startupSpeciesPopulate(species, globalGenePool);

		// Set some plants
		for( int i = 0; i < 100; ++i )
		{
			m_mapObjects ~= new Plant(Vector2f(uniform(0.0f, nextDown(cast(float)m_ground.length-1)),
											   uniform(0.0f, nextDown(cast(float)m_ground[0].length-1))));
		}
	}

	void render(RenderWindow window, const ScreenManager screenManager)
	{
		immutable FloatRect visibleGameArea = screenManager.visibleAreaRelativeCoor;
		immutable Vector2i visibleGameArea_UnitsMin = Vector2i(max(cast(int)visibleGameArea.left, 0), max(cast(int)visibleGameArea.top, 0));
		immutable Vector2i visibleGameArea_UnitsMax = Vector2i(min(cast(uint)(visibleGameArea.left + visibleGameArea.width + 1), m_ground.length-1),
															   min(cast(uint)(visibleGameArea.top + visibleGameArea.height + 1), m_ground[0].length-1));

		// todo: Use a custom "vertex buffer"
		// todo: set each corner to a a sensible value to get bilinear filtering for FREEEEE :)
		immutable float cellSize = screenManager.relativeLengthToScreenLength(1.0f);
		auto rectangleShape = new RectangleShape(Vector2f(cellSize,cellSize));

		for( int x = visibleGameArea_UnitsMin.x; x < visibleGameArea_UnitsMax.x; ++x )
		{
			for( int y = visibleGameArea_UnitsMin.y; y < visibleGameArea_UnitsMax.y; ++y )
			{
				ubyte greyVal = cast(ubyte)(127.5f * m_ground[x][y] + 127.5f);
				if( isLand(Vector2f(x, y)) )
					rectangleShape.fillColor = Color(greyVal/2, greyVal*3/4, 0);
				else 
					rectangleShape.fillColor = Color(0, 0, greyVal);
				rectangleShape.position = screenManager.relativeCoorToScreenCoor(Vector2f(x,y));
				window.draw(rectangleShape);
			}
		}

		// draw all entites
		foreach(mapObject; m_mapObjects)
			mapObject.render(window, screenManager);
	}

	void update()
	{
		// spawn a plant
		++m_turnsSinceLastPlantSpawn;
		if(m_turnsSinceLastPlantSpawn > m_turnsPerPlantSpawn)
		{
			m_turnsSinceLastPlantSpawn = 0;
			m_mapObjects ~= new Plant(Vector2f(uniform(0.0f, nextDown(cast(float)m_ground.length-1)),
											   uniform(0.0f, nextDown(cast(float)m_ground[0].length-1))));
		}

		foreach(mapObject; m_mapObjects)
			if( !mapObject.removed )
				mapObject.update(this);

		removeObjects();
	}

	bool isLand(Vector2f pos) const
	{
		if( pos.x < 0.0f || pos.x >= (m_ground.length-1) ) return false;
		if( pos.y < 0.0f || pos.y >= (m_ground[0].length-1) ) return false;
		return sampleGround(pos) > 0.0f;
	}

	bool isWater(Vector2f pos) const
	{
		if( pos.x < 0.0f || pos.x >= (m_ground.length-1) ) return false;
		if( pos.y < 0.0f || pos.y >= (m_ground[0].length-1) ) return false;
		return sampleGround(pos) <= 0.0f;
	}

	// returns true if something was clamped
	bool clampToGame(ref Vector2f pos) const
	{
		bool result = false;
		if(pos.x < 0)
		{
			pos.x = 0.0f;
			result = true;
		}
		if(pos.y < 0)
		{
			pos.y = 0.0f;
			result = true;
		}
		if(pos.x >= m_ground.length-1)
		{
			pos.x = nextDown(cast(float)m_ground.length-1);
			result = true;
		}
		if(pos.y >= m_ground[0].length-1)
		{
			pos.y = nextDown(cast(float)m_ground[0].length-1);
			result = true;
		}
		return result;
	}

	MapObject[] queryObjects(Vector2f pos, float maxDistance)
	{
		MapObject[] query;
		// Get a rectangle which contains the circle
		/*int minCellX = max(0, cast(int)(pos.x - maxDistance));
		int maxCellX = min(m_ground.length-1, cast(int)(pos.x + maxDistance + 1));
		int minCellY = max(0, cast(int)(pos.y - maxDistance));
		int maxCellY = min(m_ground[0].length-1, cast(int)(pos.y + maxDistance + 1));

		// Iterate over all cells and take the objects in range
		for( int x = minCellX; x < maxCellX; ++x )
		{
			for( int y = minCellY; y < maxCellY; ++y )
			{
				foreach(m_mapObjects)
			}
		}*/

		// Brute force search
		foreach(obj; m_mapObjects)
		{
			if( !obj.removed && length(obj.position - pos) <= maxDistance )
			{
				query ~= obj;
			}
		}

		return query;
	}

	void removeObjects()
	{
		for(int i = 0; i < m_mapObjects.length; ++i )
		{
			if( m_mapObjects[i].removed )
			{
				delete(m_mapObjects[i]);
				m_mapObjects.replaceInPlace(i, i+1, [m_mapObjects.back()]);
				m_mapObjects.popBack();
			}
		}
	}

	void addObject(MapObject object)
	{
		m_mapObjects ~= object;
	}

private:
	// Each cell is one unit large!
	float[100][100] m_ground;
	MapObject[] m_mapObjects;

	// Use bilinear sampling of a height map to get smoother borders
	float sampleGround(Vector2f pos) const
	{
		assert(pos.x >= 0 && pos.y >= 0 && pos.y < m_ground[0].length && pos.x < m_ground.length);

		int ix = cast(int)pos.x;
		int iy = cast(int)pos.y;
		float fx = pos.x - ix;
		float fy = pos.y - iy;
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
	void startupSpeciesPopulate(Species[] species, Gene[string] globalGenePool)
	{
		auto rnd = Xorshift(unpredictableSeed());
		Gene[5] randomGenes;
		foreach(s; species)
		{
			uint numEntities = uniform(m_startPopMinNum, m_startPopMaxNum, rnd);

			// find a home!
			s.origin = Vector2f(uniform(m_startPopDistribution*1.5f, m_ground.length    - m_startPopDistribution * 1.5f, rnd),
								uniform(m_startPopDistribution*1.5f, m_ground[0].length - m_startPopDistribution * 1.5f, rnd));

			for(int i=0; i<numEntities; ++i)
			{
				Vector2f entityPos = s.origin;
				entityPos.x += uniform(-m_startPopDistribution, m_startPopDistribution, rnd);
				entityPos.y += uniform(-m_startPopDistribution, m_startPopDistribution, rnd);

				// choose 5 random genese
				for(int gene=0; gene<randomGenes.length; ++gene)
					randomGenes[gene] = globalGenePool.values[uniform(0, globalGenePool.length, rnd)];

				m_mapObjects ~= new Entity(s, entityPos, randomGenes);
			}
		}
	}

	enum uint m_startPopMinNum = 10;
	enum uint m_startPopMaxNum = 15;
	enum float m_startPopDistribution = 5.0f;
	enum uint m_turnsPerPlantSpawn = 3;

	uint m_turnsSinceLastPlantSpawn = 0;
}