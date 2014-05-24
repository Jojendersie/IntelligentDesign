import dsfml.graphics;
import map;
import screenmanager;
import gui;
import species;

import std.file;
import std.json;
import std.conv;
import properties;
import genes;
import mapobjects;

class Game
{
	this(RenderWindow window)
	{
		m_screenManager = new ScreenManager(Vector2f(window.size().x, window.size().y));
		loadGenes();

		for(int i=0; i<m_allSpecies.length; ++i)
			m_allSpecies[i] = new Species(i==0);
		m_playerSpecies = m_allSpecies[0];

		m_map = new Map(m_allSpecies, m_globalGenePool);
		m_gui = new GUI();

		// Zoom to player
		Vector2f centering = m_screenManager.resolution - Vector2f(m_screenManager.geneBarWidth,
																   m_screenManager.lowerBarHeight);
		m_screenManager.cameraPosition = m_allSpecies[0].origin
			- m_screenManager.screenDirToRelativeDir(Vector2i(cast(int)centering.x/2,
															  cast(int)centering.y/2));
	}

	void render(RenderWindow window)
	{
		m_screenManager.resolution = Vector2f(window.size().x, window.size().y); // brain-dead simple: If the resolution change, our game can handle this ;D
		
		m_map.render(window, m_screenManager);
		m_gui.render(window, m_screenManager, m_playerSpecies);
	}

	void update(RenderWindow window)
	{
		m_map.update();
		

		MapObject hoverObject = m_map.queryObjectExact(m_screenManager.screenCoorToRelativeCoor(Mouse.getPosition(window)));
		if(Mouse.isButtonPressed(Mouse.Button.Left))
			m_gui.updateHoverObject(hoverObject);

		m_gui.update(m_screenManager, window, m_playerSpecies);
	}

	void loadGenes()
	{
		// Load the gene file as string
		auto content = to!string(read("content/gene.json"));
		JSONValue root = parseJSON(content);
		JSONValue[] geneArray = root.object["genes"].array;

		Properties prop;
		foreach( geneJSON; geneArray )
		{
			JSONValue[string] geneData = geneJSON.object;
			string name = geneData["name"].str;
			if( name == "ZeroGene" ) 
				Gene.zeroGene = new Gene(geneData);
			else
				m_globalGenePool[name] = new Gene(geneData);
		}
	}

	void onMouseWheelMoved(int mouseWheelDelta)
	{
		m_screenManager.zoom(mouseWheelDelta);
	}

	static Gene[string] globalGenePool()
	{
		return m_globalGenePool;
	}

private:
	ScreenManager m_screenManager;
	Map m_map;

	Species[] m_allSpecies = new Species[5];
	Species m_playerSpecies;
	static Gene[string] m_globalGenePool;
	GUI m_gui;
}