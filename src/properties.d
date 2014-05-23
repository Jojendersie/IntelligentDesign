struct Properties
{
	int velocityWater;		// Movement factor in water
	int velocityLand;		// Movement factor on land
	int damageWater;		// Life loss factor in water
	int damageLand;			// Life loss factor on land
	int poisonous;			// Damaga value if eaten
	int poisonResistence;	// Resistence value if eating
	int spiky;				// Damaga value if eaten
	int spikeResistence;	// Resistence value if eating
	int herbivore;			// Can eat plants
	int carnivore;			// Can eat other animals
	int viewDistance;		// How far can this unit see
}