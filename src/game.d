import dsfml.graphics;
import map;
import screenmanager;
import player;

class Game
{
	this(RenderWindow window)
	{
		m_screenManager = new ScreenManager(Vector2f(window.getSize().x, window.getSize().y));
	}

	void render(RenderWindow window)
	{
		m_map.render(window, m_screenManager);
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
	
}