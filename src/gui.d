import screenmanager;
import dsfml.graphics;
import species;
import genes;
import std.stdio;
import std.conv;
import std.algorithm;
import mapobjects;
import main;

class GUI
{
	this()
	{
		m_infoFont = new Font();
		m_infoFont.loadFromFile("content/infofont.ttf");

		m_messageTopic = new Text();
		m_messageTopic.setFont(m_infoFont);
		m_messageTopic.setCharacterSize(30);
		m_messageTopic.setColor(Color.White);
		m_messageTopic.setStyle(Text.Style.Bold);

		m_messageInfo = new Text();
		m_messageInfo.setFont(m_infoFont);
		m_messageInfo.setCharacterSize(20);
		m_messageInfo.setColor(Color.White);
	}

	void update(ScreenManager screenManager, Window window, Species species)
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
		Species.GeneUsage* hoveredGeneUsage = null;
		Gene* hoveredGene = null;
		foreach(ref gene; species.genes().keys)
		{
			Vector2f displayPos = screenManager.getGeneDisplayScreenPos(species.genes()[gene].priority);
			if(displayPos.x < currentMouseCoord.x && displayPos.x + screenManager.geneDisplaySize > currentMouseCoord.x && 
			   displayPos.y < currentMouseCoord.y && displayPos.y + screenManager.geneDisplaySize > currentMouseCoord.y)
			{
				hoveredGeneUsage = &species.genes()[gene];
				hoveredGene = &gene;
				break;
			}
		}
		if(m_currentDraggingGene != null)
		{
			m_currentDraggingGene.priority.x -= cast(float)dirPixel.x / (screenManager.geneBarWidth - screenManager.geneDisplaySize);
			m_currentDraggingGene.priority.y += cast(float)dirPixel.y / (screenManager.resolution.y - screenManager.geneDisplaySize);

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
			m_currentDraggingGene = hoveredGeneUsage;
		}


		m_lastMouseCoord = currentMouseCoord;

		// info text
		m_messageTopic.position = (Vector2f(5, screenManager.resolution.y - 50));
		m_messageInfo.position = (Vector2f(160, screenManager.resolution.y - 42));
		if(hoveredGene !is null)
		{
			m_messageTopic.setString(to!dstring(hoveredGene.name ~ ":"));
			m_messageInfo.setString(to!dstring(hoveredGene.properties.getTextDescription()));

			// clear hovered object!
			m_hoveredObject = null;
		}
		else 
		{
			if(m_hoveredObject is null)
			{
				m_messageTopic.setString(""d);
				m_messageInfo.setString(""d);
			}
			else if(cast(Plant)m_hoveredObject !is null)
			{
				m_messageTopic.setString("Plant:"d);
				string description = "Energy: " ~ to!string(cast(int)(cast(Plant)m_hoveredObject).getEnergy());
				m_messageInfo.setString(to!dstring(description));
			}
			else if(cast(Entity)m_hoveredObject !is null)
			{
				Entity entity = cast(Entity)m_hoveredObject;

				m_messageTopic.setString("Entity:"d);

				char[] description;
				description ~= "Energy: " ~ to!string(cast(int)entity.vitality) ~ " -- " ~ entity.properties.getTextDescription();
				m_messageInfo.setString(to!dstring(description));
			}
		}
	}

	void render(RenderWindow window, const ScreenManager screenManager, const Species[] species)
	{
		assert( species[0].isPlayer() );
		auto rectangleShape = new RectangleShape();

		// right bar
		rectangleShape.fillColor = species[0].color;
		rectangleShape.position = Vector2f(window.size.x - screenManager.geneBarWidth, 0);
		rectangleShape.size = Vector2f(screenManager.geneBarWidth, window.size.y);
		window.draw(rectangleShape);

		// lower bar
		rectangleShape.fillColor = Color(species[0].color.a / 4, species[0].color.g / 4, species[0].color.b / 4, 255);
		rectangleShape.position = Vector2f(0, window.size.y - screenManager.lowerBarHeight);
		rectangleShape.size = Vector2f(window.size.x, screenManager.lowerBarHeight);
		window.draw(rectangleShape);

		// Info text
		window.draw(m_messageTopic);
		window.draw(m_messageInfo);

		// The genes
		foreach_reverse( gene; species[0].genes.keys )
		{
			const Species.GeneUsage* usage = &species[0].genes[gene];
			
			Sprite sprite = new Sprite(gene.texture());
			//writeln(usage.priority.x * (screenManager.geneBarWidth - 64) + 32 + screenManager.geneBarX);
			sprite.position = screenManager.getGeneDisplayScreenPos(usage.priority);
			sprite.scale = Vector2f(1.0f, 1.0f);
			sprite.color = (usage.num > 0 ? Color.White : Color(100,100,100,100));

			// mark if hovered! 
			if(m_hoveredObject !is null && cast(Entity)m_hoveredObject !is null)
			{
				Entity entity = cast(Entity)m_hoveredObject;

				foreach(entityGene; entity.geneSlots)
				{
					if(entityGene == gene)
					{
						rectangleShape.fillColor = Color.Yellow;
						rectangleShape.position = sprite.position - Vector2f(5.0f, 5.0f);
						rectangleShape.size = Vector2f(screenManager.geneDisplaySize + 10, screenManager.geneDisplaySize + 10);
						window.draw(rectangleShape);
						break;
					}
				}
			}

			window.draw(sprite);

			Text count = new Text();
			count.setFont(m_infoFont);
			count.setCharacterSize(17);
			count.setColor(Color.Black);
			count.position = sprite.position + Vector2f(screenManager.geneDisplaySize - 10, screenManager.geneDisplaySize - 20);
			count.setString(to!dstring(usage.num));
			window.draw(count);
		}

		// Check
		char[] what;
		float enemyEnergy = 0.0f;
		foreach( spec; species )
		{
			if(spec.isPlayer && spec.totalEnergy <= 0.0f)
				what = "INTELLIGENT DESIGN FAILED".dup;
			else
				enemyEnergy += spec.totalEnergy;
		}
		// Won
		if( enemyEnergy <= 0.0f )
			what = "GOD LIKE".dup;

		// score & Time
		if( species[0].totalEnergy > 0.0f && enemyEnergy > 0.0f )
			++m_passedSteps;
		float passedTime = cast(float)(timePerFrameSeconds* m_passedSteps);
		int minutes = cast(int)(passedTime / 60);
		int seconds = cast(int)(passedTime - minutes * 60);

		Text score = new Text();
		score.setFont(m_infoFont);
		score.setCharacterSize(40);
		score.setColor(Color.White);

		score.position = Vector2f(10, 10);
		score.setString("TOTAL VITALITY: " ~ to!dstring(cast(int)species[0].totalEnergy));
		window.draw(score);

		score.position = Vector2f(10, 55);
		dchar[] timeString = "TIME "d.dup;
		if(minutes < 10)
			timeString ~= "0"d;
		timeString ~= to!dstring(minutes) ~ ":"d;
		if(seconds < 10)
			timeString ~= "0"d;
		timeString ~= to!dstring(seconds);
		score.setString(to!dstring(timeString));
		window.draw(score);

		// Show Game Over / Won
		if( what.length > 0 )
		{
			rectangleShape.fillColor = (enemyEnergy <= 0.0f) ? Color(230, 230, 200, 100) : Color(20, 20, 20, 100);
			rectangleShape.position = Vector2f(0.0f, 0.0f);
			rectangleShape.size = Vector2f(window.size.x, window.size.y);
			window.draw(rectangleShape);

			score.position = Vector2f(window.size.x/2 - 500, window.size.y / 2 - 100);
			score.setCharacterSize(80);
			score.setString(to!dstring(what));
			window.draw(score);
		}
	}

	void updateHoverObject(MapObject obj)
	{
		m_hoveredObject = obj;
	}

private:
	static immutable float m_scrollSpeed = 1.5f;

	MapObject m_hoveredObject = null;

	Vector2i m_lastMouseCoord;
	Species.GeneUsage* m_currentDraggingGene = null;

	Font m_infoFont;
	Text m_messageTopic;
	Text m_messageInfo;

	int m_passedSteps = 0;
}