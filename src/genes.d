import properties;

class Gene
{
	@property string name() { return m_name; }
	@property string sprite() { return m_sprite; }
	@property Properties properties() { return m_properties; }

private:
	string m_name;
	string m_sprite;	// File name of the used picture
	Properties m_properties;
}