import mapobject;

class Entity: MapObject
{
	// Get one of the N genes
	const Gene getGene(int slot)
	{
		return m_geneSlots[slot];
	}

	// Observe the environment search a target and go one step.
	void update()
	{
	}

	@property Properties properties() { return m_properties; }

private:
	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;
}