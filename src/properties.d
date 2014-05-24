import std.conv;

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

	char[] getTextDescription()
	{
		char[] description;

		if(velocityWater != 0 || velocityLand != 0)
			description ~= "Velocity (Land/Water): " ~ to!string(velocityLand) ~ "/" ~ to!string(velocityWater) ~ " | ";

		if(vitalityLand + vitality != 0 || vitalityWater + vitality != 0)
			description ~= "Vitality (Land/Water): " ~ to!string(vitalityLand + vitality) ~ "/" ~ to!string(vitalityWater + vitality) ~ " | ";

		if(poisonous != 0 || poisonResistence != 0)
			description ~= "Poison (Att/Def): " ~ to!string(poisonous) ~ "/" ~ to!string(poisonResistence) ~ " | ";

		if(spiky != 0 || spikeResistence != 0)
			description ~= "Spike (Att/Def): " ~ to!string(spiky) ~ "/" ~ to!string(spikeResistence) ~ " | ";

		if(herbivore != 0 || carnivore != 0)
			description ~= "Herbivore / Carnivore: " ~ to!string(herbivore) ~ "/" ~ to!string(carnivore) ~ " | ";

		if(viewDistance != 0)
			description ~= "View Range: " ~ to!string(viewDistance) ~ " | ";

		// remove last seperator
		description[description.length - 2] = ' ';

		return description;
	}
}