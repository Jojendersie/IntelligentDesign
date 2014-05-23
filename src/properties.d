struct Properties
{
	int velocityWater;		// Movement factor in water
	int velocityLand;		// Movement factor on land
	int damageWater;		// Life loss factor in water
	int damageLand;			// Life loss factor on land
	int poisonous;			// Damage value if eaten
	int poisonResistence;	// Resistence value if eating
	int spiky;				// Damaga value if eaten
	int spikeResistence;	// Resistence value if eating
	int herbivore;			// Can eat plants
	int carnivore;			// Can eat other animals
	int viewDistance;		// How far can this unit see

	Properties opBinary(string op)(Properties rhs)
	{
		Properties result;
		static if (op == "+")
		{
			result.velocityWater = velocityWater + rhs.velocityWater;
			result.velocityLand = velocityLand + rhs.velocityLand;
			result.damageWater = damageWater + rhs.damageWater;
			result.damageLand = damageLand + rhs.damageLand;
			result.poisonous = poisonous + rhs.poisonous;
			result.poisonResistence = poisonResistence + rhs.poisonResistence;
			result.spiky = spiky + rhs.spiky;
			result.spikeResistence = spikeResistence + rhs.spikeResistence;
			result.herbivore = herbivore + rhs.herbivore;
			result.carnivore = carnivore + rhs.carnivore;
			result.viewDistance = viewDistance + rhs.viewDistance;
		}
		else static if (op == "-")
		{
			result.velocityWater = velocityWater - rhs.velocityWater;
			result.velocityLand = velocityLand - rhs.velocityLand;
			result.damageWater = damageWater - rhs.damageWater;
			result.damageLand = damageLand - rhs.damageLand;
			result.poisonous = poisonous - rhs.poisonous;
			result.poisonResistence = poisonResistence - rhs.poisonResistence;
			result.spiky = spiky - rhs.spiky;
			result.spikeResistence = spikeResistence - rhs.spikeResistence;
			result.herbivore = herbivore - rhs.herbivore;
			result.carnivore = carnivore - rhs.carnivore;
			result.viewDistance = viewDistance - rhs.viewDistance;
		}
		else
			static assert(0, "Operator "~op~" not implemented");

		return result;
	}
}