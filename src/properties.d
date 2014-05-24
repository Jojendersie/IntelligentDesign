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

		if(velocityWater != 0)
			description ~= "Velocity Water " ~ to!string(velocityWater) ~ " | ";
		if(velocityLand != 0)
			description ~= "Velocity Land " ~ to!string(velocityLand) ~ " | ";
		if(vitalityWater != 0)
			description ~= "Vitality Water " ~ to!string(vitalityWater) ~ " | ";
		if(vitalityLand != 0)
			description ~= "Vitality Land " ~ to!string(vitalityLand) ~ " | ";

		if(poisonous != 0)
			description ~= "Poison Attack " ~ to!string(poisonous) ~ " | ";
		if(poisonResistence != 0)
			description ~= "Poison Resist. " ~ to!string(poisonResistence) ~ " | ";

		if(spiky != 0)
			description ~= "Spike Attack " ~ to!string(spiky) ~ " | ";
		if(spikeResistence != 0)
			description ~= "Spike Resist. " ~ to!string(spikeResistence) ~ " | ";

		if(herbivore != 0)
			description ~= "Herbivore " ~ to!string(herbivore) ~ " | ";
		if(carnivore != 0)
			description ~= "Carnivore " ~ to!string(carnivore) ~ " | ";

		if(viewDistance != 0)
			description ~= "View Distance " ~ to!string(viewDistance) ~ " | ";
		if(vitality != 0)
			description ~= "Vitality " ~ to!string(vitality) ~ " | ";

		// remove last seperator
		description[description.length - 2] = ' ';

		return description;
	}
}