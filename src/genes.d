import properties;
import std.json;
import std.stdio;
import dsfml.graphics;

class Gene
{
	this( JSONValue[string] data )
	{
		assert(data != null);
		m_name = data["name"].str;
		m_texture = new Texture();
		m_texture.loadFromFile( "content/" ~ data["image"].str );
		// Load save: when a value does not exist keep the standard 0
		JSONValue* val = "velocityWater" in data;
		if( val != null ) m_properties.velocityWater	= cast(int)val.integer;
		val = "velocityLand" in data;
	    if( val != null ) m_properties.velocityLand		= cast(int)val.integer;
		val = "vitalityWater" in data;
	    if( val != null ) m_properties.vitalityWater	= cast(int)val.integer;
		val = "vitalityLand" in data;
	    if( val != null ) m_properties.vitalityLand		= cast(int)val.integer;
		val = "poisonous" in data;
	    if( val != null ) m_properties.poisonous		= cast(int)val.integer;
		val = "melee" in data;
	    if( val != null ) m_properties.melee			= cast(int)val.integer;
		val = "herbivore" in data;
	    if( val != null ) m_properties.herbivore		= cast(int)val.integer;
		val = "carnivore" in data;
	    if( val != null ) m_properties.carnivore		= cast(int)val.integer;
		val = "viewDistance" in data;
	    if( val != null ) m_properties.viewDistance		= cast(int)val.integer;
	}

	@property string name() const { return m_name; }
	@property Texture texture() { return m_texture; }
	@property Properties properties() { return m_properties; }

	static Gene zeroGene;

private:
	string m_name;
	Texture m_texture;
	Properties m_properties;
}