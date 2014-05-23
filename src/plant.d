import mapobject;
import std.math;

class Plant: MapObject
{
	// Get older
	void update()
	{
		m_age += 1.0f/60.0f;
	}

	float getEnergy()
	{
		return log(m_age + 1.0f);
	}

private:
	float m_age;
}