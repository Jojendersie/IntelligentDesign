struct Properties
{
	int velocityWater;		// Movement factor in water
	int velocityLand;		// Movement factor on land
	int vitalityWater;		// Life loss factor in water
	int vitalityLand;		// Life loss factor on land
	int poisonous;			// Damage value if eaten
	int poisonResistence;	// Resistence value if eating
	int spiky;				// Damaga value if eaten
	int spikeResistence;	// Resistence value if eating
	int herbivore;			// Can eat plants
	int carnivore;			// Can eat other animals
	int viewDistance;		// How far can this unit see
	int vitality;			// Consumption ot gain of vitality

	Properties opBinary(string op)(Properties rhs)
	{
		Properties results;
		static if (op == "+")
		{
			results.velocityWater = velocityWater + rhs.velocityWater;
			results.velocityLand = velocityLand + rhs.velocityLand;
			results.vitalityWater = vitalityWater + rhs.vitalityWater;
			results.vitalityLand = vitalityLand + rhs.vitalityLand;
			results.poisonous = poisonous + rhs.poisonous;
			results.poisonResistence = poisonResistence + rhs.poisonResistence;
			results.spiky = spiky + rhs.spiky;
			results.spikeResistence = spikeResistence + rhs.spikeResistence;
			results.herbivore = herbivore + rhs.herbivore;
			results.carnivore = carnivore + rhs.carnivore;
			results.viewDistance = viewDistance + rhs.viewDistance;
			results.vitality = vitality + rhs.vitality;
		}
		else static if (op == "-")
		{
			results.velocityWater = velocityWater - rhs.velocityWater;
			results.velocityLand = velocityLand - rhs.velocityLand;
			results.vitalityWater = vitalityWater - rhs.vitalityWater;
			results.vitalityLand = vitalityLand - rhs.vitalityLand;
			results.poisonous = poisonous - rhs.poisonous;
			results.poisonResistence = poisonResistence - rhs.poisonResistence;
			results.spiky = spiky - rhs.spiky;
			results.spikeResistence = spikeResistence - rhs.spikeResistence;
			results.herbivore = herbivore - rhs.herbivore;
			results.carnivore = carnivore - rhs.carnivore;
			results.viewDistance = viewDistance - rhs.viewDistance;
			results.vitality = vitality - rhs.vitality;
		}
		else
			static assert(0, "Operator "~op~" not implemented");

		return results;
	}
}