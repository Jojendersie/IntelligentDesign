import dsfml.graphics;
import map;
import screenmanager;

class Game
{
	void render(RenderWindow window)
	{
		screenmanager = new ScreenManager(Vector2f(window.getSize().x, window.getSize().y));
	}

	void update()
	{
	}

private:
	ScreenManager screenmanager;
	Map map = new Map();
	//Gene[] globalGenePool = new ;
	
}