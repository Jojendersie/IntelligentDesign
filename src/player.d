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

		// Box camera
		// Todo. Not that important... Need additional functions in screenManager for visible area etc.
	}

	@property const(Species) species() const { return m_species; }

private:
	static immutable float m_scrollSpeed = 1.5f;

	Species m_species;
}