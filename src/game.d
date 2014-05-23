import dsfml.graphics;
import map;
import screenmanager;

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
	}

private:
	ScreenManager m_screenManager;
	Map m_map = new Map();
	//Gene[] globalGenePool = new ;
	
}