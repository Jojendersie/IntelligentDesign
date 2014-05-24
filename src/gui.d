import screenmanager;
import dsfml.graphics;
import species;
import genes;
import std.stdio;
import std.conv;

class GUI
{
	this()
	{
		Font m_infoFont = new Font();
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
		m_messageTopic.position = (Vector2f(10, screenManager.resolution.y - 50));
		m_messageInfo.position = (Vector2f(100, screenManager.resolution.y - 40));
		if(hoveredGene != null)
		{
			m_messageTopic.setString(to!dstring(hoveredGene.name ~ ":"));
	
			char[] description;
			if(hoveredGene.properties.velocityWater != 0)
				description ~= "Velocity Water " ~ to!string(hoveredGene.properties.velocityWater) ~ " | ";
			if(hoveredGene.properties.velocityLand != 0)
				description ~= "Velocity Land " ~ to!string(hoveredGene.properties.velocityLand) ~ " | ";
			if(hoveredGene.properties.vitalityWater != 0)
				description ~= "Vitality Water " ~ to!string(hoveredGene.properties.velocityWater) ~ " | ";
			if(hoveredGene.properties.vitalityLand != 0)
				description ~= "Vitality Land " ~ to!string(hoveredGene.properties.velocityLand) ~ " | ";
			
			if(hoveredGene.properties.poisonous != 0)
				description ~= "Poison Attack " ~ to!string(hoveredGene.properties.poisonous) ~ " | ";
			if(hoveredGene.properties.poisonResistence != 0)
				description ~= "Poison Resist. " ~ to!string(hoveredGene.properties.poisonResistence) ~ " | ";

			if(hoveredGene.properties.spiky != 0)
				description ~= "Spike Attack " ~ to!string(hoveredGene.properties.spiky) ~ " | ";
			if(hoveredGene.properties.spikeResistence != 0)
				description ~= "Spike Resist. " ~ to!string(hoveredGene.properties.spikeResistence) ~ " | ";

			if(hoveredGene.properties.herbivore != 0)
				description ~= "Herbivore " ~ to!string(hoveredGene.properties.herbivore) ~ " | ";
			if(hoveredGene.properties.carnivore != 0)
				description ~= "Carnivore " ~ to!string(hoveredGene.properties.carnivore) ~ " | ";

			if(hoveredGene.properties.viewDistance != 0)
				description ~= "View Distance " ~ to!string(hoveredGene.properties.viewDistance) ~ " | ";
			if(hoveredGene.properties.vitality != 0)
				description ~= "Vitality " ~ to!string(hoveredGene.properties.vitality) ~ " | ";

			// remove last seperator
			description[description.length - 2] = ' ';

			m_messageInfo.setString(to!dstring(description));
		}
		else
		{
			m_messageTopic.setString(""d);
			m_messageInfo.setString(""d);
		}
	}

	void render(RenderWindow window, const ScreenManager screenManager, const Species species)
	{
		auto rectangleShape = new RectangleShape();

		// right bar
		rectangleShape.fillColor = species.color;
		rectangleShape.position = Vector2f(window.size.x - screenManager.geneBarWidth, 0);
		rectangleShape.size = Vector2f(screenManager.geneBarWidth, window.size.y);
		window.draw(rectangleShape);

		// lower bar
		rectangleShape.fillColor = Color.Black;
		rectangleShape.position = Vector2f(0, window.size.y - screenManager.lowerBarHeight);
		rectangleShape.size = Vector2f(window.size.x, screenManager.lowerBarHeight);
		window.draw(rectangleShape);

		// Info text
		window.draw(m_messageTopic);
		window.draw(m_messageInfo);


		// The genes
		foreach( gene; species.genes.keys )
		{
			const Species.GeneUsage* usage = &species.genes[gene];
			if( usage.num > 0 )
			{
				Sprite sprite = new Sprite(gene.texture());
				//writeln(usage.priority.x * (screenManager.geneBarWidth - 64) + 32 + screenManager.geneBarX);
				sprite.position = screenManager.getGeneDisplayScreenPos(usage.priority);
				sprite.scale = Vector2f(1.0f, 1.0f);
				window.draw(sprite);
			}
		}
	}

private:
	static immutable float m_scrollSpeed = 1.5f;

	Vector2i m_lastMouseCoord;
	Species.GeneUsage* m_currentDraggingGene = null;

	Text m_messageTopic;
	Text m_messageInfo;
}