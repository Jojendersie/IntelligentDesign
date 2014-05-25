import genes;
import std.random;
import dsfml.graphics;
import game;

class Species
{
	this(bool isPlayer)
	{
		// Choose a random color
		if( isPlayer )
			m_color = Color(255, 144, 1);
		else
			m_color = Color(cast(ubyte)uniform(0,255), cast(ubyte)uniform(0,255), cast(ubyte)uniform(0,255));
		m_isPlayer = isPlayer;

		foreach(gene; Game.globalGenePool())
		{
			m_genes[gene] = GeneUsage();

			if(m_isPlayer)
				m_genes[gene].randomizePriority();
			else
				m_genes[gene].priority = Vector2f(0, 1);
		}
	}

	// Entry to define occurence and likelyness for the species
	struct GeneUsage
	{
		Vector2f priority;
		int num = 1;

		void randomizePriority()
		{
			priority.x = uniform(0.0f, 1.0f);
			priority.y = uniform(0.0f, 1.0f);
		}
	}

	@property const(GeneUsage[Gene]) genes() const  { return m_genes; }
	@property GeneUsage[Gene] genes()				{ return m_genes; }


	void increaseGene( Gene gene )
	{
		auto el = gene in m_genes;
		if( el == null )
		{
			m_genes[gene] = GeneUsage();
			m_genes[gene].randomizePriority();
		}
		else el.num++;
	}
	void decreaseGene( Gene gene )
	{
		auto el = gene in m_genes;
		assert( el != null );
		el.num--;
	}

	@property const(Color) color() const { return m_color; }
	@property const(bool) isPlayer() const { return m_isPlayer; }

	Vector2f origin;	// Spawn center

	@property float totalEnergy() const { return m_totalEngergy;}
	@property void totalEnergy(float value) { m_totalEngergy = value; }

private:
	// todo: add used genes and their priorities

	GeneUsage[Gene] m_genes;
	Color m_color;
	bool m_isPlayer;
	float m_totalEngergy = 0;
}