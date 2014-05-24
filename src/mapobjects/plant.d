import mapobject;
import std.math;
import dsfml.graphics;

class Plant: MapObject
{
	this(Vector2f position)
	{
		m_position = position;
	}

	// Get older
	override void update(Map map)
	{
		m_age += 1.0f/60.0f;
	}

	override void render(RenderWindow window, const ScreenManager screenManager)
	{
		float radius = sizeEnergyScale * getEnergy();
		auto circleShape = new CircleShape(screenManager.relativeLengthToScreenLength(radius), 4);
		circleShape.position = screenManager.relativeCoorToScreenCoor(m_position - Vector2f(radius, radius));
		circleShape.fillColor = Color.Green;
		window.draw(circleShape);
	}

	float getEnergy()
	{
		return log(log(m_age + 1.0f) + 1.0f);
	}

private:
	float m_age = 0.0f;

	enum float sizeEnergyScale = 0.4f;
}