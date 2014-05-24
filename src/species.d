import genes;

class Species
{
	// updates gene priorities automatically - ONLY FOR NON-HUMAN PLAYERs!
	void updatePriorities()
	{
	}

	@property const(int[Gene]) genes() const { return m_genes; }
	void increaseGene( Gene gene )			 { m_genes[gene]++; }
	void decreaseGene( Gene gene )			 { m_genes[gene]--; }

private:
	// todo: add used genes and their priorities
	int[Gene] m_genes;
}