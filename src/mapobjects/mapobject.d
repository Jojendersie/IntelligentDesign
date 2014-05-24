public import dsfml.graphics;
public import screenmanager;

abstract class MapObject
{
	// Simulate this entity for a fixed time step size
	abstract void update();

	abstract void draw(RenderWindow window, const ScreenManager screenManager);

public:
	@property Vector2f position() const { return m_position; }

protected:
	Vector2f m_position;

}