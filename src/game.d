import dsfml.graphics;
import map;
import screenmanager;
import player;
import gui;
import species;

import std.file;
import std.json;
import std.conv;
import properties;
import genes;

class Game
{
	this(RenderWindow window)
	{
		m_screenManager = new ScreenManager(Vector2f(window.size().x, window.size().y));
		loadGenes();

		for(int i=0; i<m_allSpecies.length; ++i)
			m_allSpecies[i] = new Species(i==0);
		m_player = new Player(m_allSpecies[0]);

		m_map = new Map(m_allSpecies, m_globalGenePool);

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
		m_gui.render(window, m_screenManager, m_player.species);
	}

	void update(RenderWindow window)
	{
		m_player.update(m_screenManager, window);
		m_map.update();
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

private:
	ScreenManager m_screenManager;
	Map m_map;
	Species[] m_allSpecies = new Species[5];
	Gene[string] m_globalGenePool;
	Player m_player;
	GUI m_gui = new GUI();
}