import mapobject;
import genes;
import properties;
import species;
import utils;
import plant;
import game;

import dsfml.graphics;
import std.math;
import std.random;

class Entity: MapObject
{
	this(Species species, Vector2f position, ref Gene[4] genes)
	{
		this();
		m_species = species;
		m_position = position;
		m_geneSlots = genes;
		m_vitality = uniform(50.0f, 90.0f);
		updatePropertiesAndReportGenes();
	}

	this(Entity parent0, Entity parent1)
	{
		assert(parent0.m_species == parent1.m_species);
		m_species = parent0.m_species;
		m_position = (parent0.position + parent1.position) / 2;
		this();
		
		// Transfere 1/4 of each parent's energy.
		m_vitality = parent0.m_vitality / 4.0f + parent1.m_vitality / 4.0f;
		parent0.m_vitality *= 3.0f / 4.0f;
		parent1.m_vitality *= 3.0f / 4.0f;

		// fill genes by inheritance
		Gene[] parentGenePool = parent0.m_geneSlots ~ parent1.m_geneSlots;
		Gene[] parentGenes = chooseGenes(parentGenePool, m_geneSlots.length-1);
		for(int i=0; i<parentGenes.length-1; ++i)
			m_geneSlots[i] = parentGenes[i];

		// choose last gene
		m_geneSlots[m_geneSlots.length-1] = chooseGenes(Game.globalGenePool().values(), 1)[0];

		updatePropertiesAndReportGenes();
	}

	Gene[] chooseGenes(Gene[] genePool, int numGenesToChoose)
	{
		Gene[] genePoolCpy;
		Gene[] outputGenes = new Gene[numGenesToChoose];

		float totalPriority = 0.0f;
		for(int pgene=0; pgene<genePool.length; ++pgene)
		{
			// add if not duplicated
			float contained = false;
			for(int xgene=0; xgene<genePoolCpy.length; ++xgene)
				if( genePool[pgene] == genePoolCpy[xgene] )
					contained = true;
			if( !contained )
			{
				genePoolCpy ~= genePool[pgene];
				totalPriority += m_species.genes()[genePool[pgene]].priority.y;
			}
		}
		for(int i=0; i<numGenesToChoose; ++i)
		{
			float choosenGene = uniform(0.0f, totalPriority);

			float currentPrioritySum = 0.0f;
			for(int pgene=0; pgene<genePoolCpy.length; ++pgene)
			{
				if(genePoolCpy[pgene] is null)
					continue;
				float currentPrio = m_species.genes()[genePoolCpy[pgene]].priority.y;
				currentPrioritySum += currentPrio;
				if(currentPrioritySum >= choosenGene)
				{
					outputGenes[i] = genePoolCpy[pgene];
					genePoolCpy[pgene] = null;
					totalPriority -= currentPrio;
				}
			}
		}
		return outputGenes;
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

	float getRadius() const	{ return m_entityRadius * (1.0f + log(m_vitality / 100.0f + 1.0f)); }


	override void render(RenderWindow window, const ScreenManager screenManager)
	{
		m_displayRadius = getRadius();
		auto circleShape = new CircleShape(screenManager.relativeLengthToScreenLength(m_displayRadius),
										   m_species.isPlayer ? 3 : 10);
		circleShape.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(m_displayRadius, m_displayRadius));
		circleShape.fillColor = m_species.color;
		if( canHaveSex() )
		{
			circleShape.outlineColor = m_species.color * 1.2f;
			circleShape.outlineThickness = 2.5f;
		}
		window.draw(circleShape);
	}

	// Observe the environment search a target and go one step.
	override void update(Map map)
	{
		++m_numStepsSinceAngleChange;

		// Die?
		m_vitality += properties.vitality * m_vitalityLossFactor;
		if( map.isLand(m_position) )
			m_vitality += properties.vitalityLand * m_vitalityLossFactor;
		else
			m_vitality += properties.vitalityWater * m_vitalityLossFactor;
		if( m_vitality <= 0.0f )
		{
			removed = true;
			return;
		}

		// Find a nice target in the environment
		float viewDistance = properties.viewDistance * m_viewDistanceMultiplier;
		MapObject[] allVisible = map.queryObjects(position, viewDistance);
		Vector2f targetingDirection = Vector2f(0.0f, 0.0f);
		foreach( other; allVisible )
		{
			if( other != this )
			{
				// Standard attraction weighting
				Vector2f dir = other.position - position;
				float attr = attraction(other);
				float distSq = (dir.x*dir.x + dir.y*dir.y);
				targetingDirection += dir * attr / fmax(1e-10f, distSq);
				// Eat or Sex?
				if( distSq <= 0.3f )
				{
					Entity e = cast(Entity)other;
					if( e !is null )
					{
						if( m_species == m_species )
						{
							// Have sex.
							if( e.canHaveSex() && canHaveSex())
							{
								map.addObject( new Entity(this, e) );
							}
						} else {
							// Fight enemy.
							if( fight(e) == 1 )
							{
								m_vitality += getFoodValue(other);
								other.removed = true;
							} else {
								e.m_vitality += e.getFoodValue(this);
								removed = true;
							}
						}
					} else {
						// Just eat it.
						float foodValue = getFoodValue(other);
						if( foodValue > 0.0f )
						{
							m_vitality += foodValue;
							other.removed = true;
						}
					}
				}
			}
		}

		// Evaluate landscape
		Xorshift rnd;
		// Use some property values to increase the diversity
		rnd.seed(m_properties.vitality + m_properties.vitalityWater + m_properties.vitalityLand);
		float prefersLand = (m_properties.vitalityLand - m_properties.vitalityWater) * 0.5f
			+ (m_properties.velocityLand - m_properties.velocityWater) * 0.15f;
		float maxViewDistance = m_properties.viewDistance * m_viewDistanceMultiplier;
		// Take 16 random samples in a circle and check for land / water
		for( int i = 0; i < 8; ++i )
		{
			float phi = uniform(0.0f, cast(float)PI*2.0f, rnd);
			float radius = sqrt(uniform(0.00001f, 1.0f, rnd)) * maxViewDistance;
			Vector2f direction = Vector2f(sin(phi), cos(phi)) * radius;
			float factor = 0.0f;
			if( map.isOnMap(m_position + direction) && map.isOnMap(m_position - direction) ) 
			{
				factor = map.isLand(m_position + direction) ? prefersLand : -prefersLand;
				factor -= map.isLand(m_position - direction) ? prefersLand : -prefersLand;
			}
			//else factor = 3.0f / (radius + 1e-10f);
			targetingDirection += direction * factor / fmax(radius, 1e-10f);
		}

		// attraction to mouse
		if(m_species.isPlayer && map.attracting)
		{
			Vector2f toAttraction = map.attractionPos - m_position;
			float attractionDist = toAttraction.length();
			if(attractionDist < maxViewDistance*2)
				targetingDirection += toAttraction * (m_attractionPointFactor / attractionDist);
		}

		// interpolate direction and move
		float currentAngle = lerp(m_aimedWalkAngleLast, m_aimedWalkAngleCurrent, cast(float)(m_numStepsSinceAngleChange) / m_numStepsSameWalkAim);
		Vector2f direction = Vector2f(sin(currentAngle), cos(currentAngle));
		direction = normalize(lerp(targetingDirection, direction, m_randomWalkWeight));
		if(map.isLand(m_position))
			direction *= m_properties.velocityLand;
		else
			direction *= m_properties.velocityWater;


		m_position += direction * m_speedMultiplier;
		assert(!isnan(m_position.x));

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
	@property Species species() { return m_species; }

	@property float vitality() const { return m_vitality; }

	@property ref const(Gene[4]) geneSlots() const		{ return m_geneSlots; }
	@property ref const(Properties) properties() const	{ return m_properties; }

	bool canHaveSex() const { return m_vitality > m_sexThreshold; }

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

	// Compute the attraction / repulsion from another unit.
	// A positive value means attraction.
	float attraction(MapObject other)
	{
		// Smoothstep
		float likesSex = (m_vitality - m_sexThreshold) * 0.1f;
		likesSex = fmax(0.0f, fmin(1.0f, likesSex));
		likesSex *= likesSex * (3 - 2 * likesSex);
		Entity e = cast(Entity)other;
		if( e !is null )
		{
			if( e.species != m_species ) return getFoodValue(other) * fight(e);	// Enemy
			return e.canHaveSex() ? likesSex : 0.0f;
		}
		Plant p = cast(Plant)other;
		if( p !is null )
		{
			return getFoodValue(other) * (1.0f - likesSex * 0.75f);
		}
		return 0.0f;
	}

	// Return 1 if 'this' wins and -1 if enemy wins.
	int fight(Entity enemy)
	{
		// Check all properties - if one has more attack -> win
		if( enemy.m_properties.spiky > m_properties.spikeResistence ) return -1;
		if( enemy.m_properties.poisonous > m_properties.poisonResistence) return -1;
		if( m_properties.spiky > enemy.m_properties.spikeResistence ) return 1;
		if( m_properties.poisonous > enemy.m_properties.poisonResistence ) return 1;
		
		// Decide probabilistic
		float winChance = m_properties.carnivore / cast(float)(m_properties.carnivore + enemy.m_properties.carnivore);
		if( winChance < uniform(0.0f, 1.0f) ) return -1;
		else return 1;
	}

	// Compute the gain of eating something
	float getFoodValue(MapObject other)
	{
		Entity e = cast(Entity)other;
		if( e !is null && e.m_species != m_species )
		{
			// todo fight?
			float carnival = m_properties.carnivore / 3.0f;
			return e.m_vitality * carnival;
		}
		Plant p = cast(Plant)other;
		if( p !is null )
		{
			float herbival = m_properties.herbivore / 3.0f;
			return p.getEnergy() * herbival;
		}

		return 0.0f;
	}

	Properties m_properties;
	Gene[4] m_geneSlots;
	float m_vitality;
	Species m_species;

	enum float m_entityRadius = 0.4f;

	float m_aimedWalkAngleLast;
	float m_aimedWalkAngleCurrent;
	int m_numStepsSinceAngleChange;

	enum int m_numStepsSameWalkAim = 100;


	enum float m_sexThreshold = 100.0f;
	enum float m_speedMultiplier = 1.0f / 60.0f;
	enum float m_viewDistanceMultiplier = 1.0f;
	enum float m_randomWalkWeight = 0.3f;
	enum float m_vitalityLossFactor = 0.01f;
	enum float m_attractionPointFactor = 10.0f;
}