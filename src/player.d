import screenmanager;
import dsfml.window;

class Player
{
	void update(ScreenManager screenManager)
	{
		// Camera movement.
		if (Keyboard.isKeyPressed(Keyboard.Key.Up))
			screenManager.cameraPosition.y -= m_scrollSpeed;
		if (Keyboard.isKeyPressed(Keyboard.Key.Down))
			screenManager.cameraPosition.y += m_scrollSpeed;
		if (Keyboard.isKeyPressed(Keyboard.Key.Left))
			screenManager.cameraPosition.x -= m_scrollSpeed;
		if (Keyboard.isKeyPressed(Keyboard.Key.Right))
			screenManager.cameraPosition.x += m_scrollSpeed;

		// Box camera
		// Todo. Not that important... Need additional functions in screenManager for visible area etc.
	}

private:
	static immutable float m_scrollSpeed = 1.5f;
}