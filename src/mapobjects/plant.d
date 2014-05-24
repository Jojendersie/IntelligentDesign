import mapobject;
import std.math;

class Plant: MapObject
{
	// Get older
	override void update()
	{
		m_age += 1.0f/60.0f;
	}

	override void render(RenderWindow window, const ScreenManager screenManager)
	{
	}

	float getEnergy()
	{
		return log(m_age + 1.0f);
	}

private:
	float m_age;
}