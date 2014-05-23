module screenmanager;
import dsfml.system;

public alias Vector2f = Vector2!float;

class ScreenManager
{
    this(Vector2f resolution)
    {
		m_resolution = resolution;
		m_cameraPosition = Vector2f(0.0f, 0.0f);
    }

    Vector2f RelativeCorToScreenCor(Vector2f relativeCor)
    {
        return (relativeCor - m_cameraPosition) * pixelsPerUnit;
    }

    Vector2f ScreenCorToRelativeCor(Vector2f screenCor)
    {
        return screenCor / pixelsPerUnit + m_cameraPosition;
    }

    float RealtiveLengthToScreenLength(float l)
    {
        return l * pixelsPerUnit;
    }

	@property Vector2f cameraPosition()				{ return m_cameraPosition; }
	@property void cameraPosition(Vector2f value)	{ m_cameraPosition = value; }

private:
	static immutable int leftBarWidth = 200;
	static immutable int lowerBarHeight = 50;
	static immutable int pixelsPerUnit = 30;

	Vector2f m_resolution;

	Vector2f m_cameraPosition; // Camera position in units.
}
