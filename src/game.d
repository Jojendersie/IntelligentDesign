import dsfml.graphics;
import map;
import screenmanager;
import player;
import gui;
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
	}

	void render(RenderWindow window)
	{
		m_screenManager.resolution = Vector2f(window.size().x, window.size().y); // brain-dead simple: If the resolution change, our game can handle this ;D
		
		m_map.render(window, m_screenManager);
		m_gui.render(window, m_screenManager);
	}

	void update()
	{
		m_player.update(m_screenManager);
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
			globalGenePool[geneData["name"].str] = new Gene(geneData);
		}
	}

private:
	ScreenManager m_screenManager;
	Map m_map = new Map();
	Gene[string] globalGenePool;
	Player m_player = new Player();
	GUI m_gui = new GUI();
}