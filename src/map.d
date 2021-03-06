import utils;
import screenmanager;
import mapobjects;
import species;
import genes;

import dsfml.graphics;

import std.algorithm;
import std.random;
import std.array;
import std.stdio;
import std.container;

class Map
{
	// Initializes entites for every species
	this(Species[] species, Gene[string] globalGenePool)
	{
		m_groundTexture = new Texture();
		m_groundTexture.create(m_ground.length, m_ground[0].length);
		m_groundTexture.setSmooth(true);
		m_groundTexture.setRepeated(false);
		m_groundSprite = new Sprite();
		m_groundSprite.setTexture(m_groundTexture);

		valueNoiseSeed = unpredictableSeed();
		generateGround();
		startupSpeciesPopulate(species, globalGenePool);

		// Set some plants
		for( int i = 0; i < 100; ++i )
		{
			m_mapObjects ~= new Plant(Vector2f(uniform(0.0f, nextDown(cast(float)m_ground.length-1)),
											   uniform(0.0f, nextDown(cast(float)m_ground[0].length-1))));
		}

	
		
		m_groundShader = new Shader();
		m_groundShader.loadFromFile("content/mapshader.vert", "content/mapshader.frag");
		m_groundNoise = new Texture();
		m_groundNoise.loadFromFile("content/noise.png");
		m_groundNoise.setRepeated(true);
		m_groundNoise.setSmooth(true);
	}

	void render(RenderWindow window, const ScreenManager screenManager, Vector2f mouseWorldCor)
	{
		immutable FloatRect visibleGameArea = screenManager.visibleAreaRelativeCoor;
		immutable Vector2f visibleGameArea_UnitsMin = Vector2f(max(cast(float)visibleGameArea.left, 0.0f), max(cast(float)visibleGameArea.top, 0.0f));
		immutable Vector2f visibleGameArea_UnitsMax = Vector2f(min(cast(float)(visibleGameArea.left + visibleGameArea.width + 1), m_ground.length-1),
															   min(cast(float)(visibleGameArea.top + visibleGameArea.height + 1), m_ground[0].length-1));

		immutable float cellSize = screenManager.relativeLengthToScreenLength(1.0f);
		m_groundSprite.position = screenManager.relativeCoorToScreenCoor(Vector2f(0.0f, 0.0f));
		m_groundSprite.scale = Vector2f(screenManager.relativeLengthToScreenLength(m_ground.length) / m_groundTexture.getSize().x, 
										screenManager.relativeLengthToScreenLength(m_ground[0].length) / m_groundTexture.getSize().y);
		m_groundShader.setParameter("texture", Shader.CurrentTexture);
		m_groundShader.setParameter("noise", m_groundNoise);

		Shader.bind(m_groundShader);
		window.draw(m_groundSprite);
		Shader.bind(null);

		// draw all entites
		++m_turnCounter;
		int numDrawn = 0;
		foreach(mapObject; m_mapObjects)
		{
			if(visibleGameArea_UnitsMin.x < mapObject.position.x + mapObject.displayRadius &&
			   visibleGameArea_UnitsMin.y < mapObject.position.y + mapObject.displayRadius &&
			   visibleGameArea_UnitsMax.x > mapObject.position.x &&
			   visibleGameArea_UnitsMax.y > mapObject.position.y)
			{
				++numDrawn;
				mapObject.render(window, screenManager, m_turnCounter);

				// draw circles for entities
				Entity entity = cast(Entity)mapObject;
				if(entity !is null && (entity.position - mouseWorldCor).lengthSq() <= entity.maxViewDistance * entity.maxViewDistance)
				{
					CircleShape circle = new CircleShape();
					circle.position = screenManager.relativeCoorToScreenCoor(entity.position - Vector2f(entity.maxViewDistance, entity.maxViewDistance));
					circle.radius = screenManager.relativeLengthToScreenLength(entity.maxViewDistance);
					circle.fillColor = Color(0,0,0,0);
					circle.outlineColor = Color(255,255,255, 50);
					circle.outlineThickness = 1.5f;
					window.draw(circle);
				}
			}
		}

		//writeln("numdrawn: ", numDrawn);
	}

	void update()
	{
		// Recreate ground
		++m_turnsSinceLastGroundUpdate;
		if(m_turnsSinceLastGroundUpdate > m_turnsPerGroundUpdate)
		{
			generateGround();
			m_turnsSinceLastGroundUpdate = 0;
		}

		// spawn a plant
		++m_turnsSinceLastPlantSpawn;
		if(m_turnsSinceLastPlantSpawn > m_turnsPerPlantSpawn)
		{
			m_turnsSinceLastPlantSpawn = 0;
			m_mapObjects ~= new Plant(Vector2f(uniform(0.0f, nextDown(cast(float)m_ground.length-1)),
											   uniform(0.0f, nextDown(cast(float)m_ground[0].length-1))));
		}

		recreateCellGrid();
		for(int i = 0; i < m_mapObjects.length; ++i )
			if( !m_mapObjects[i].removed )
				m_mapObjects[i].update(this);

		removeObjects();
		m_mapObjects ~= m_newObjects;
		m_newObjects.clear();
	}

	bool isLand(Vector2f pos) const
	{
		if( pos.x < 0.0f || pos.x >= (m_ground.length-1) ) return false;
		if( pos.y < 0.0f || pos.y >= (m_ground[0].length-1) ) return false;
		return sampleGround(pos) > 0.0f;
	}

	bool isLand(Vector2i pos) const
	{
		if( pos.x < 0 || pos.x >= m_ground.length ) return false;
		if( pos.y < 0 || pos.y >= m_ground[0].length ) return false;
		return m_ground[pos.x][pos.y] > 0.0f;
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
			pos.x = cast(float)m_ground.length-1.001f;
			result = true;
		}
		if(pos.y >= m_ground[0].length-1)
		{
			pos.y = cast(float)m_ground[0].length-1.001f;
			result = true;
		}
		return result;
	}

	bool isOnMap(Vector2f pos)
	{
		return (pos.x >= 0) && (pos.y >= 0) && (pos.x < m_ground.length-1) && (pos.y < m_ground[0].length-1);
	}

	MapObject[] queryObjects(Vector2f pos, float maxDistance)
	{
		MapObject[] query;
		float maxDistanceSq = maxDistance * maxDistance;
		// Get a rectangle which contains the circle
		int minCellX = max(0, cast(int)((pos.x - maxDistance)/m_unitsPerCell));
		int maxCellX = min(m_cellGrid.length, cast(int)((pos.x + maxDistance)/m_unitsPerCell + 1));
		int minCellY = max(0, cast(int)((pos.y - maxDistance)/m_unitsPerCell));
		int maxCellY = min(m_cellGrid[0].length, cast(int)((pos.y + maxDistance)/m_unitsPerCell + 1));

		// Iterate over all cells and take the objects in range
		for( int x = minCellX; x < maxCellX; ++x )
		{
			for( int y = minCellY; y < maxCellY; ++y )
			{
				foreach(object; m_cellGrid[x][y])
				{
					if( !object.removed && lengthSq(object.position - pos) <= maxDistanceSq)
					{
						query ~= object;
					}
				}
			}
		}

		// Brute force search
		/*
		foreach(obj; m_mapObjects)
		{
			if( !obj.removed && lengthSq(obj.position - pos) <= maxDistanceSq)
			{
				query ~= obj;
			}
		}*/

		return query;
	}

	MapObject queryObjectExact(Vector2f pos)
	{
		// Brute force search
		foreach(obj; m_mapObjects)
		{
			if( !obj.removed && lengthSq(obj.position - pos) <= obj.displayRadius*obj.displayRadius)
			{
				return obj;
			}
		}
		return null;
	}

	void removeObjects()
	{
		for(int i = 0; i < m_mapObjects.length; ++i )
		{
			if( m_mapObjects[i].removed )
			{
				Entity e = cast(Entity)m_mapObjects[i];
				if( e !is null ) e.removeGenes();
				m_mapObjects.replaceInPlace(i, i+1, [m_mapObjects.back()]);
				m_mapObjects.popBack();
			}
		}
	}

	void addObject(MapObject object)
	{
		m_newObjects ~= object;
	}

	void setAttraction(bool attracting, Vector2f attractionPos)
	{
		m_attracting = attracting;
		m_attractionPos = attractionPos;
	}

	@property bool attracting() { return m_attracting;} 
	@property Vector2f attractionPos() {return m_attractionPos;}


	// Use bilinear sampling of a height map to get smoother borders
	float sampleGround(Vector2f pos) const
	{
		clampToGame(pos);

		int ix = cast(int)pos.x;
		int iy = cast(int)pos.y;
		float fx = pos.x - ix;
		float fy = pos.y - iy;
		return (m_ground[ix][iy] * (1.0f - fx) + m_ground[ix+1][iy] * fx) * (1.0f - fy) +
			(m_ground[ix][iy+1] * (1.0f - fx) + m_ground[ix+1][iy+1] * fx) * fy;
	}

private:
	// Each visual cell is one unit large!
	enum int mapSizeX = 100;
	enum int mapSizeY = 100;
	float[mapSizeX][mapSizeY] m_ground;
	// All four units there is a logical grid cell
	enum int m_unitsPerCell = 4;
	SList!MapObject[mapSizeX/m_unitsPerCell][mapSizeY/m_unitsPerCell] m_cellGrid;
	MapObject[] m_mapObjects;
	MapObject[] m_newObjects;
	Texture m_groundTexture;
	Sprite m_groundSprite;

	void generateGround()
	{
		static float maxAmplitude = 2 - 1.0f/(1 << 4);
		for( int x = 0; x < m_ground.length; ++x )
		{
			for( int y = 0; y < m_ground[0].length; ++y )
			{
				// Generate a value noise value
				float value = 0.0f;
				for( int oct = 0; oct < 5; ++oct )
				{
					// The randomAt-z component can be used to change the landscape over time
					int frequency = 1 << oct;
					value += randomAt(x * 0.01f * frequency, y * 0.01f * frequency, m_turnCounter * 0.0002f) / frequency;
				}
				m_ground[x][y] = value / maxAmplitude;
			}
		}

		updateGroundTexture();
	}

	void updateGroundTexture()
	{
		ubyte[] textureValues = new ubyte[m_ground.length * m_ground[0].length * 4];
		for( int x = 0; x < m_ground.length; ++x )
		{
			for( int y = 0; y < m_ground[0].length; ++y )
			{
				ubyte greyVal = cast(ubyte)(127.5f * m_ground[x][y] + 127.5f);
				Color color;
				if( isLand(Vector2i(x, y)) )
					color = Color(greyVal/2, greyVal*3/4, 0);
				else 
					color = Color(0, 0, greyVal);

				textureValues[(y * m_ground[0].length + x) * 4 + 0] = color.r;
				textureValues[(y * m_ground[0].length + x) * 4 + 1] = color.g;
				textureValues[(y * m_ground[0].length + x) * 4 + 2] = color.b;
				textureValues[(y * m_ground[0].length + x) * 4 + 3] = cast(ubyte)(fmax(0, fmin(1, m_ground[x][y]*4 + 0.5f)) * 255);//color.a;
			}
		}
		m_groundTexture.updateFromPixels(textureValues, m_ground.length, m_ground[0].length, 0, 0);
	}

	// creates
	void startupSpeciesPopulate(Species[] species, Gene[string] globalGenePool)
	{
		auto rnd = Xorshift(unpredictableSeed());
		Gene[4] randomGenes;
		foreach(s; species)
		{
			uint numEntities = m_startPopNum;

			// find a home!
			s.origin = Vector2f(uniform(m_startPopDistribution*1.5f, m_ground.length    - m_startPopDistribution * 1.5f, rnd),
								uniform(m_startPopDistribution*1.5f, m_ground[0].length - m_startPopDistribution * 1.5f, rnd));

			for(int i=0; i<numEntities; ++i)
			{
				Vector2f entityPos = s.origin;
				entityPos.x += uniform(-m_startPopDistribution, m_startPopDistribution, rnd);
				entityPos.y += uniform(-m_startPopDistribution, m_startPopDistribution, rnd);

				m_mapObjects ~= new Entity(s, entityPos);
			}
		}
	}

	void recreateCellGrid()
	{
		// Clear all cells
		for( int cx = 0; cx < m_cellGrid.length; ++cx )
			for( int cy = 0; cy < m_cellGrid[0].length; ++cy )
				m_cellGrid[cx][cy].clear();

		// Insert all entities to the grid
		foreach( object; m_mapObjects )
		{
			int ocx = max(0, min(m_cellGrid.length-1, cast(int)(object.position.x / m_unitsPerCell)));
			int ocy = max(0, min(m_cellGrid[0].length-1, cast(int)(object.position.y / m_unitsPerCell)));
			m_cellGrid[ocx][ocy].insert( object );
		}
	}

	enum uint m_startPopNum = 1;
	enum float m_startPopDistribution = 5.0f;
	enum uint m_turnsPerPlantSpawn = 3;
	enum uint m_turnsPerGroundUpdate = 30;

	uint m_turnsSinceLastPlantSpawn = 0;
	uint m_turnsSinceLastGroundUpdate = 0;
	uint m_turnCounter = 0;

	bool m_attracting = false;
	Vector2f m_attractionPos;

	Shader m_groundShader;
	Texture m_groundNoise;
}