import mapobject;
import genes;
import properties;
import species;

import dsfml.graphics;
import std.math;

class Entity: MapObject
{
	this(Species species, Vector2f position, ref Gene[5] genes)
	{
		m_species = species;
		m_position = position;
		overwriteGenes(genes);
	}

	this(Entity parent0, Entity parent1)
	{
		// todo inheritance mechanism
		overwriteGenes(parent0.m_geneSlots);
	}

	~this()
	{
		foreach(gene; m_geneSlots)
			m_species.decreaseGene(gene);
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
	/*	++m_numStepsSinceAngleChange;
		// new goal?
		if(m_numStepsSinceAngleChange < m_numStepsSameWalkAim)
		{
			auto rnd = Xorshift(unpredictableSeed());
			m_numStepsSinceAngleChange = 0;
			m_aimedWalkAngleLast = m_aimedWalkAngleCurrent;
			m_aimedWalkAngleCurrent = uniform(0, PI);
		}
		// interpolate direction
		float currentAngle = 
		Vector2f direction = Vector2f(); */
	}

	@property Properties properties() { return m_properties; }

private:

	void overwriteGenes(ref Gene[5] genes)
	{
		m_properties = Gene.zeroGene.properties;
		m_geneSlots = genes;
		foreach(gene; m_geneSlots)
		{
			m_species.increaseGene(gene);
			m_properties = m_properties + gene.properties;
		}
	}

	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;

	enum float m_entityRadius = 0.4f;

	float m_aimedWalkAngleLast;
	float m_aimedWalkAngleCurrent;
	int m_numStepsSinceAngleChange = 20;
	enum int m_numStepsSameWalkAim = 20;
}