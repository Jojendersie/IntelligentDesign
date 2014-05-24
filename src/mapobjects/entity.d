import mapobject;
import genes;
import properties;
import species;
import utils;

import dsfml.graphics;
import std.math;
import std.random; 

class Entity: MapObject
{
	this(Species species, Vector2f position, ref Gene[5] genes)
	{
		this();
		m_species = species;
		m_position = position;
		m_geneSlots = genes;
		updatePropertiesAndReportGenes();
	}

	this(Entity parent0, Entity parent1, Gene[string] globalGenePool)
	{
		assert(parent0.m_species == parent1.m_species);
		m_species = parent0.m_species;
		m_position = (parent0.position + parent1.position) / 2;
		this();
		
		// fill 4 genes by inheritance
		Gene[] parentGenePool = parent0.m_geneSlots ~ parent1.m_geneSlots;
		float totalPriority = 0.0f;
		for(int pgene=0; pgene<parentGenePool.length; ++pgene)
			totalPriority += m_species.genes()[parentGenePool[pgene]].priority.y;
		for(int i=0; i<m_geneSlots.length; ++i)
		{
			float choosenGene = uniform(0.0f, totalPriority);

			float currentPrioritySum = 0.0f;
			for(int pgene=0; pgene<parentGenePool.length; ++pgene)
			{
				if(parentGenePool[pgene] is null)
					continue;
				float currentPrio = m_species.genes()[parentGenePool[pgene]].priority.y;
				currentPrioritySum += currentPrio;
				if(currentPrioritySum > choosenGene)
				{
					m_geneSlots[i] = parentGenePool[pgene];
					parentGenePool[pgene] = null;
					totalPriority -= currentPrio;
					break;
				}
			}
		}

		// choose last gene randomly
		m_geneSlots[m_geneSlots.length-1] = globalGenePool.values()[uniform(0, globalGenePool.length)];

		updatePropertiesAndReportGenes();
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
	override void update(Map map)
	{
		++m_numStepsSinceAngleChange;

		// interpolate direction and move
		float currentAngle = lerp(m_aimedWalkAngleLast, m_aimedWalkAngleCurrent, cast(float)(m_numStepsSinceAngleChange) / m_numStepsSameWalkAim);
		Vector2f direction = Vector2f(sin(currentAngle), cos(currentAngle)) * m_speedMultiplier;
		if(map.isLand(m_position))
			direction *= m_properties.velocityLand;
		else
			direction *= m_properties.velocityWater;
		m_position += direction;

		// new walk goal?
		if(m_numStepsSinceAngleChange > m_numStepsSameWalkAim)
		{
			m_numStepsSinceAngleChange = 0;
			m_aimedWalkAngleLast = m_aimedWalkAngleCurrent;
			m_aimedWalkAngleCurrent = uniform(0, 2 * PI);
		}

		// Border handling
		if(map.clampToGame(m_position))
		{
			m_aimedWalkAngleLast = uniform(0, 2 * PI);
			m_aimedWalkAngleCurrent = uniform(0, 2 * PI);
		}
	}

	@property Properties properties() { return m_properties; }

private:

	void updatePropertiesAndReportGenes()
	{
		m_properties = Gene.zeroGene.properties;
		foreach(gene; m_geneSlots)
		{
			m_species.increaseGene(gene);
			m_properties = m_properties + gene.properties;
		}
	}

	// shared constructor part
	this()
	{
		m_aimedWalkAngleLast = uniform(0, 2 * PI);
		m_aimedWalkAngleCurrent = uniform(0, 2 * PI);
		m_numStepsSinceAngleChange = uniform(0, m_numStepsSameWalkAim);
	}

	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;

	enum float m_entityRadius = 0.4f;

	float m_aimedWalkAngleLast;
	float m_aimedWalkAngleCurrent;
	int m_numStepsSinceAngleChange;

	enum int m_numStepsSameWalkAim = 100;



	enum float m_speedMultiplier = 1.0f / 60.0f;
}