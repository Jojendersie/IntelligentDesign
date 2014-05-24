import properties;
import std.json;
import std.stdio;

class Gene
{
	this( JSONValue[string] data )
	{
		assert(data != null);
		m_name = data["name"].str;
		m_sprite = data["image"].str;
		// Load save: when a value does not exist keep the standard 0
		JSONValue* val = "velocityWater" in data;
		if( val != null ) m_properties.velocityWater	= cast(int)val.integer;
		val = "velocityLand" in data;
	    if( val != null ) m_properties.velocityLand		= cast(int)val.integer;
		val = "vitatlityWater" in data;
	    if( val != null ) m_properties.vitatlityWater	= cast(int)val.integer;
		val = "vitatlityLand" in data;
	    if( val != null ) m_properties.velocityLand		= cast(int)val.integer;
		val = "poisonous" in data;
	    if( val != null ) m_properties.poisonous		= cast(int)val.integer;
		val = "poisonResistence" in data;
	    if( val != null ) m_properties.poisonResistence	= cast(int)val.integer;
		val = "spiky" in data;
	    if( val != null ) m_properties.spiky			= cast(int)val.integer;
		val = "spikeResistence" in data;
	    if( val != null ) m_properties.spikeResistence	= cast(int)val.integer;
		val = "herbivore" in data;
	    if( val != null ) m_properties.herbivore		= cast(int)val.integer;
		val = "carnivore" in data;
	    if( val != null ) m_properties.carnivore		= cast(int)val.integer;
		val = "viewDistance" in data;
	    if( val != null ) m_properties.viewDistance		= cast(int)val.integer;
		val = "vitatlity" in data;
		if( val != null ) m_properties.vitatlity		= cast(int)val.integer;
	}

	@property string name() { return m_name; }
	@property string sprite() { return m_sprite; }
	@property Properties properties() { return m_properties; }

private:
	string m_name;
	string m_sprite;	// File name of the used picture
	Properties m_properties;
}