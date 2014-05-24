import screenmanager;
import species;
import genes;

import dsfml.window;

class Player
{
	this(Species species)
	{
		m_species = species;
	}

	void update(ScreenManager screenManager, Window window)
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
		Vector2i currentMouseCoord = Mouse.getPosition(window);
		Vector2i dirPixel = m_lastMouseCoord - currentMouseCoord;
		Vector2f dir = screenManager.screenDirToRelativeDir(dirPixel);
		if( Mouse.isButtonPressed(Mouse.Button.Right) )
		{
			screenManager.cameraPosition += dir;
		}
		
		// Box camera
		// Todo. Not that important... Need additional functions in screenManager for visible area etc.

		// drag and drop stuff
		if(m_currentDraggingGene != null)
		{
			m_currentDraggingGene.priority.x -= cast(float)dirPixel.x / (screenManager.geneBarWidth - screenManager.geneDisplaySize);
			m_currentDraggingGene.priority.y -= cast(float)dirPixel.y / (screenManager.resolution.y - screenManager.geneDisplaySize);

			if(m_currentDraggingGene.priority.x < 0)
				m_currentDraggingGene.priority.x = 0.0f;
			if(m_currentDraggingGene.priority.y < 0)
				m_currentDraggingGene.priority.y = 0.0f;
			if(m_currentDraggingGene.priority.x > 1)
				m_currentDraggingGene.priority.x = 1.0f;
			if(m_currentDraggingGene.priority.y > 1)
				m_currentDraggingGene.priority.y = 1.0f;

			if(Mouse.isButtonPressed(Mouse.Button.Left) == false)
				m_currentDraggingGene = null;
		}
		else if(Mouse.isButtonPressed(Mouse.Button.Left))
		{
			foreach(ref geneUsage; m_species.genes())
			{
				Vector2f displayPos = screenManager.getGeneDisplayScreenPos(geneUsage.priority);
				if(displayPos.x < currentMouseCoord.x && displayPos.x + screenManager.geneDisplaySize > currentMouseCoord.x && 
				   displayPos.y < currentMouseCoord.y && displayPos.y + screenManager.geneDisplaySize > currentMouseCoord.y)
				{
					m_currentDraggingGene = &geneUsage;
					break;
				}
			}
		}


		m_lastMouseCoord = currentMouseCoord;
	}

	@property const(Species) species() const { return m_species; }

private:
	static immutable float m_scrollSpeed = 1.5f;

	Species m_species;
	Vector2i m_lastMouseCoord;
	Species.GeneUsage* m_currentDraggingGene = null;
}