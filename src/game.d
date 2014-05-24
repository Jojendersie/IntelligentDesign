import dsfml.graphics;
import map;
import screenmanager;
import player;
import gui;

class Game
{
	this(RenderWindow window)
	{
		m_screenManager = new ScreenManager(Vector2f(window.size().x, window.size().y));
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

private:
	ScreenManager m_screenManager;
	Map m_map = new Map();
	//Gene[] globalGenePool = new ;
	Player m_player = new Player();
	GUI m_gui = new GUI();
}