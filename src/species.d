import genes;
import std.random;
import dsfml.system;

class Species
{
	// updates gene priorities automatically - ONLY FOR NON-HUMAN PLAYERs!
	void updatePriorities()
	{
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

	@property const(GeneUsage[Gene]) genes() const { return m_genes; }
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

private:
	// todo: add used genes and their priorities

	GeneUsage[Gene] m_genes;
}