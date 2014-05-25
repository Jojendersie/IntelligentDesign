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
	static void loadTextures()
	{
		m_spikeTexture = new Texture();
		m_spikeTexture.loadFromFile("content/entityspikes.png");
		m_spikeTexture.setSmooth(true);

		m_poisonTexture = new Texture();
		m_poisonTexture.loadFromFile("content/entitypoison.png");
		m_poisonTexture.setSmooth(true);
	}

	this(Species species, Vector2f position)
	{
		this();
		m_species = species;
		m_position = position;
		m_geneSlots = chooseGenes(Game.globalGenePool().values(), 4);
		m_vitality = uniform(50.0f, 90.0f);
		updatePropertiesAndReportGenes();
	}

	// Do a cell division
	this(Entity selfParent)
	{
		this();
		m_species = selfParent.species;
		m_position = selfParent.position;
		m_geneSlots = selfParent.m_geneSlots;
		m_vitality = selfParent.vitality * 0.33f;
		selfParent.m_vitality *= 0.33f;
		// Make a gene pool without the 4 existing genes
		Gene[] pool;
		for( int g = 0; g < Game.globalGenePool().values().length; ++g )
		{
			bool contained = false;
			for( int og = 0; og < m_geneSlots.length; ++og )
				if( Game.globalGenePool().values()[g] == m_geneSlots[og] )
					contained = true;
			if( !contained ) pool ~= Game.globalGenePool().values()[g];
		}
		// One mutation for each
		m_geneSlots[uniform(0,m_geneSlots.length-1)] = chooseGenes(pool, 1)[0];
		int slot = uniform(0,m_geneSlots.length-1);
	
		selfParent.removeGenes();
		selfParent.m_geneSlots[slot] = chooseGenes(pool, 1)[0];
		selfParent.updatePropertiesAndReportGenes();

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
		for(int i=0; i<parentGenes.length; ++i)
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
			bool contained = false;
			for(int xgene=0; xgene<genePoolCpy.length; ++xgene)
			{
				if( genePool[pgene] == genePoolCpy[xgene] )
				{
					contained = true;
					break;
				}
			}
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
					break;
				}
			}

			assert(outputGenes[i] !is null);
		}
		return outputGenes;
	}

	void removeGenes()
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

	override void render(RenderWindow window, const ScreenManager screenManager, int stepCount)
	{
		float breath = log(cast(float)fmax(0, m_land ? m_prefersLand : -m_prefersLand) + 1);
		m_displayRadius = getRadius() + sin((++stepCount + cast(int)&this) * 0.2) * breath * 0.1;

		if(m_properties.melee > 0)
		{
			float sizeWorld = m_displayRadius*2 + sqrt(cast(float)m_properties.melee) * 0.5f;
			float sizePix = screenManager.relativeLengthToScreenLength(sizeWorld);
			Sprite spikes = new Sprite();
			spikes.setTexture(m_spikeTexture);
			spikes.scale = Vector2f(sizePix / m_spikeTexture.getSize().x, sizePix / m_spikeTexture.getSize().y);
			spikes.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(sizeWorld/2, sizeWorld/2));
			window.draw(spikes);
		}



		auto circleShape = new CircleShape(screenManager.relativeLengthToScreenLength(m_displayRadius), 10);
				circleShape.fillColor = m_species.color;

		circleShape.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(m_displayRadius, m_displayRadius));
		if( canHaveSex() )
		{
			circleShape.outlineColor = m_species.color * 1.2f;
			circleShape.outlineThickness = 2.5f;
			circleShape.radius = circleShape.radius - circleShape.outlineThickness;
			circleShape.position = circleShape.position + Vector2f( circleShape.outlineThickness, circleShape.outlineThickness);
		}
			
		window.draw(circleShape);


		if(m_properties.poisonous > 0)
		{
			float sizeWorld = m_displayRadius + sqrt(cast(float)m_properties.poisonous) * 0.5f;
			float sizePix = screenManager.relativeLengthToScreenLength(sizeWorld);
			Sprite poison = new Sprite();
			poison.setTexture(m_poisonTexture);
			poison.scale = Vector2f(sizePix / m_poisonTexture.getSize().x, sizePix / m_poisonTexture.getSize().y);
			poison.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(sizeWorld/2, sizeWorld/2));
			window.draw(poison);
	}
	}

	// Observe the environment search a target and go one step.
	override void update(Map map)
	{
		++m_numStepsSinceAngleChange;

		m_land = map.isLand(m_position);

		// Die?
		if( m_land )
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
						if( e.m_species == m_species )
						{
							// Have sex.
							if( e.canHaveSex() && canHaveSex())
							{
								map.addObject( new Entity(this, e) );
							}
						} else {
							// Fight enemy.
							if( fight(e, false) == 1 )
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

		// Self replicate?
		if( m_vitality > m_selfReplicationThreshold )
			map.addObject( new Entity(this) );

		// Evaluate landscape
		Xorshift rnd;
		// Use some property values to increase the diversity
		rnd.seed(m_properties.vitalityWater + m_properties.vitalityLand);
		
		// Take 16 random samples in a circle and check for land / water
		for( int i = 0; i < 8; ++i )
		{
			float phi = uniform(0.0f, cast(float)PI*2.0f, rnd);
			float radius = sqrt(uniform(0.00001f, 1.0f, rnd)) * maxViewDistance;
			Vector2f direction = Vector2f(sin(phi), cos(phi));
			Vector2f directionScaled = direction * radius;
			float factor = 0.0f;
			if( map.isOnMap(m_position + directionScaled) && map.isOnMap(m_position - directionScaled) ) 
			{
				factor = map.sampleGround(m_position + directionScaled) * m_prefersLand;
				factor -= map.sampleGround(m_position - directionScaled) * m_prefersLand;
			}
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
		if(m_land)
			direction *= m_properties.velocityLand + properties.carnivore * 0.1f;
		else
			direction *= m_properties.velocityWater + properties.carnivore * 0.1f;


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

		m_species.totalEnergy = m_species.totalEnergy + m_vitality;
	}

	@property Properties properties() { return m_properties; }
	@property Species species() { return m_species; }

	@property float vitality() const { return m_vitality; }

	@property ref const(Gene[4]) geneSlots() const		{ return m_geneSlots; }
	@property ref const(Properties) properties() const	{ return m_properties; }

	@property float maxViewDistance() const { return m_properties.viewDistance * m_viewDistanceMultiplier; } 

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

		m_prefersLand = (m_properties.vitalityLand - m_properties.vitalityWater) * 0.5f
						+ (m_properties.velocityLand - m_properties.velocityWater) * 0.15f;
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
			if( e.species != m_species ) return getFoodValue(other) * fight(e, true);	// Enemy
			return e.canHaveSex() ? (likesSex * 2.5f) : 0.0f;
		}
		Plant p = cast(Plant)other;
		if( p !is null )
		{
			return getFoodValue(other) * (1.0f - likesSex * 0.85f);
		}
		return 0.0f;
	}

	// Return 1 if 'this' wins and -1 if enemy wins.
	// In simulation mode the result can be 0 in case of a draw.
	int fight(Entity enemy, bool simulate)
	{
		// Check all properties - if one has more attack -> win
		int beats = m_properties.melee - enemy.m_properties.melee;
		beats = m_properties.poisonous - enemy.m_properties.poisonous;

		if( simulate ) return beats;
		if( beats != 0 ) return beats;
		
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
			return e.m_vitality * carnival * 1.7f;
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

	float m_prefersLand = 0.0f;

	bool m_land;

	enum int m_numStepsSameWalkAim = 100;


	enum float m_sexThreshold = 100.0f;
	enum float m_selfReplicationThreshold = 260.0f;
	enum float m_speedMultiplier = 1.0f / 60.0f;
	enum float m_viewDistanceMultiplier = 1.0f;
	enum float m_randomWalkWeight = 0.3f;
	enum float m_vitalityLossFactor = 0.01f;
	enum float m_attractionPointFactor = 14.0f;

	static Texture m_spikeTexture;
	static Texture m_poisonTexture;
}