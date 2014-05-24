import mapobject;
import genes;
import properties;
import species;

import dsfml.graphics;

class Entity: MapObject
{
	this(Species species, Vector2f position)
	{
		m_species = species;
		m_position = position;
	}

	// Get one of the N genes
	const(Gene) getGene(int slot) const
	{
		return m_geneSlots[slot];
	}


	override void render(RenderWindow window, const ScreenManager screenManager)
	{
		auto circleShape = new CircleShape(screenManager.relativeLengthToScreenLength(m_entityRadius), 10);
		circleShape.position = screenManager.relativeCorToScreenCor(m_position - Vector2f(m_entityRadius, m_entityRadius));
		circleShape.fillColor = Color.Magenta;
		window.draw(circleShape);
	}

	// Observe the environment search a target and go one step.
	override void update()
	{
	}

	@property Properties properties() { return m_properties; }

private:
	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;

	enum float m_entityRadius = 0.4f;
}