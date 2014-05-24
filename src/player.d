import screenmanager;
import species;

import dsfml.window;

class Player
{
	this(Species species)
	{
		m_species = species;
	}

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
		// Camera movement per drag'n'drop
		Vector2i currentMouseCoord = Mouse.getPosition();
		if( Mouse.isButtonPressed(Mouse.Button.Right) )
		{
			Vector2f dir = screenManager.screenDirToRelativeDir( m_lastMouseCoord - currentMouseCoord );
			screenManager.cameraPosition += dir;
		}
		m_lastMouseCoord = currentMouseCoord;

		// Box camera
		// Todo. Not that important... Need additional functions in screenManager for visible area etc.
	}

	@property const(Species) species() const { return m_species; }

private:
	static immutable float m_scrollSpeed = 1.5f;

	Species m_species;
	Vector2i m_lastMouseCoord;
}