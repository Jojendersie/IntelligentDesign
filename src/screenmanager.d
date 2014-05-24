module screenmanager;
import dsfml.system;
import dsfml.graphics;

class ScreenManager
{
    this(Vector2f resolution)
    {
		m_resolution = resolution;
		m_cameraPosition = Vector2f(0.0f, 0.0f);
    }

    Vector2f relativeCoorToScreenCoor(Vector2f relativeCoor) const
    {
        return (relativeCoor - m_cameraPosition) * m_pixelsPerUnit;
    }

    Vector2f screenCoorToRelativeCoor(Vector2f screenCoor) const
    {
        return screenCoor / m_pixelsPerUnit + m_cameraPosition;
    }

	Vector2f screenDirToRelativeDir(Vector2i screenCoor) const
    {
        return Vector2f(screenCoor.x, screenCoor.y) / m_pixelsPerUnit;
    }

    float relativeLengthToScreenLength(float l) const
    {
        return l * m_pixelsPerUnit;
    }

	@property ref Vector2f cameraPosition()				{ return m_cameraPosition; }
	@property void cameraPosition(Vector2f value)		{ m_cameraPosition = value; }

	@property void resolution(Vector2f value)			{ m_resolution = value; }

	@property FloatRect visibleAreaRelativeCoor() const
	{
		return FloatRect(m_cameraPosition, screenCoorToRelativeCoor(m_resolution - Vector2f(m_leftBarWidth, m_lowerBarHeight)) - m_cameraPosition );
	}
	@property FloatRect visibleAreaScreenCoor() const
	{
		immutable Vector2f cameraScreenCoor = relativeCoorToScreenCoor(m_cameraPosition);
		return FloatRect(cameraScreenCoor, m_resolution - Vector2f(m_leftBarWidth, m_lowerBarHeight) - cameraScreenCoor);
	}

	enum uint m_leftBarWidth = 200;
	enum uint m_lowerBarHeight = 50;

private:
	enum uint m_pixelsPerUnit = 20;

	Vector2f m_resolution;

	Vector2f m_cameraPosition; // Camera position in units.
}
