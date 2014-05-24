module screenmanager;
import dsfml.system;

class ScreenManager
{
    this(Vector2f resolution)
    {
		m_resolution = resolution;
		m_cameraPosition = Vector2f(0.0f, 0.0f);
    }

    Vector2f relativeCorToScreenCor(Vector2f relativeCor)
    {
        return (relativeCor - m_cameraPosition) * m_pixelsPerUnit;
    }

    Vector2f screenCorToRelativeCor(Vector2f screenCor)
    {
        return screenCor / m_pixelsPerUnit + m_cameraPosition;
    }

    float relativeLengthToScreenLength(float l)
    {
        return l * m_pixelsPerUnit;
    }

	@property ref Vector2f cameraPosition()			{ return m_cameraPosition; }
	@property void cameraPosition(Vector2f value)	{ m_cameraPosition = value; }

	@property void resolution(Vector2f value)		{ m_resolution = value; }


	static immutable uint m_leftBarWidth = 200;
	static immutable uint m_lowerBarHeight = 50;

private:
	static immutable uint m_pixelsPerUnit = 20;

	Vector2f m_resolution;

	Vector2f m_cameraPosition; // Camera position in units.
}
