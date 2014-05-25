public import dsfml.graphics;
public import screenmanager;
public import map;

abstract class MapObject
{
	// Simulate this entity for a fixed time step size
	abstract void update(Map map);

	abstract void render(RenderWindow window, const ScreenManager screenManager, int stepCount);

public:
	@property Vector2f position() const { return m_position; }

	bool removed = false;

	@property float displayRadius() const { return m_displayRadius; }

protected:
	Vector2f m_position;
	float m_displayRadius = 0.0f;
}