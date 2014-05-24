import mapobject;
import genes;
import properties;
import species;

class Entity: MapObject
{
	this(Species species)
	{
		m_species = species;
	}

	// Get one of the N genes
	const(Gene) getGene(int slot) const
	{
		return m_geneSlots[slot];
	}

	// Observe the environment search a target and go one step.
	override void update()
	{
	}

	override void draw(RenderWindow window, const ScreenManager screenManager)
	{
	}

	@property Properties properties() { return m_properties; }

private:
	Properties m_properties;
	Gene[5] m_geneSlots;
	float m_vitality;
	Species m_species;
}