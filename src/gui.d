import screenmanager;
import dsfml.graphics;
import species;

class GUI
{
	void render(RenderWindow window, const ScreenManager screenManager, const Species species)
	{
		auto rectangleShape = new RectangleShape();

		// right bar
		rectangleShape.fillColor = Color.Blue;
		rectangleShape.position = Vector2f(window.size.x - screenManager.m_leftBarWidth, 0);
		rectangleShape.size = Vector2f(screenManager.m_leftBarWidth, window.size.y);
		window.draw(rectangleShape);

		// lower bar
		rectangleShape.fillColor = Color.Cyan;
		rectangleShape.position = Vector2f(0, window.size.y - screenManager.m_lowerBarHeight);
		rectangleShape.size = Vector2f(window.size.x, screenManager.m_lowerBarHeight);
		window.draw(rectangleShape);

		// The genes
		//foreach( gene; species )
		//Sprite 
	}
}