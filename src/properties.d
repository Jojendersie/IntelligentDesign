import std.conv;

struct Properties
{
	int velocityWater;		// Movement factor in water
	int velocityLand;		// Movement factor on land
	int vitalityWater;		// Life loss factor in water
	int vitalityLand;		// Life loss factor on land
	int poisonous;			// Damage value in poison damage class
	int melee;				// Damaga value in melee damaga class
	int herbivore;			// Can eat plants
	int carnivore;			// Can eat other animals
	int viewDistance;		// How far can this unit see

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
			results.melee = melee + rhs.melee;
			results.herbivore = herbivore + rhs.herbivore;
			results.carnivore = carnivore + rhs.carnivore;
			results.viewDistance = viewDistance + rhs.viewDistance;
		}
		else static if (op == "-")
		{
			results.velocityWater = velocityWater - rhs.velocityWater;
			results.velocityLand = velocityLand - rhs.velocityLand;
			results.vitalityWater = vitalityWater - rhs.vitalityWater;
			results.vitalityLand = vitalityLand - rhs.vitalityLand;
			results.poisonous = poisonous - rhs.poisonous;
			results.melee = melee - rhs.melee;
			results.herbivore = herbivore - rhs.herbivore;
			results.carnivore = carnivore - rhs.carnivore;
			results.viewDistance = viewDistance - rhs.viewDistance;
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

		if(vitalityLand != 0 || vitalityWater != 0)
			description ~= "Vitality (Land/Water): " ~ to!string(vitalityLand) ~ "/" ~ to!string(vitalityWater) ~ " | ";

		if(poisonous != 0 || melee != 0)
			description ~= "Attack (Poison/Melee): " ~ to!string(poisonous) ~ "/" ~ to!string(melee) ~ " | ";

		if(herbivore != 0 || carnivore != 0)
			description ~= "Herbivore / Carnivore: " ~ to!string(herbivore) ~ "/" ~ to!string(carnivore) ~ " | ";

		if(viewDistance != 0)
			description ~= "View Range: " ~ to!string(viewDistance) ~ " | ";

		// remove last seperator
		description[description.length - 2] = ' ';

		return description;
	}
}