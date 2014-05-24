import mapobject;
import genes;
import properties;
import species;

import dsfml.graphics;

class Entity: MapObject
{
	this(Species species, Vector2f position, ref Gene[5] genes)
	{
		m_species = species;
		m_position = position;
		m_geneSlots = genes;

		// todo report genes to species
	}

	this(Entity parent0, Entity parent1)
	{
	}

	~this()
	{
		// todo report deleted genes
	}

	// Get one of the N genes
	const(Gene) getGene(int slot) const
	{
		return m_geneSlots[slot];
	}


	override void render(RenderWindow window, const ScreenManager screenManager)
	{
		auto circleShape = new CircleShape(screenManager.relativeLengthToScreenLength(m_entityRadius), 10);
		circleShape.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(m_entityRadius, m_entityRadius));
		circleShape.fillColor = Color.Magenta;
		window.draw(circleShape);
	}

	// Observe the environment search a target and go one step.
	override void update()
	{
	}

	@property Properties properties() { return m_properties; }

private:

	void calculatePropertiesFromGenes()
	{
		foreach(gene; m_geneSlots)
			m_properties = m_properties + gene.properties;
	}

	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;

	enum float m_entityRadius = 0.4f;
}