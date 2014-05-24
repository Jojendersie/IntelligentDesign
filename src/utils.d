import std.math;
import dsfml.system;

T lerp(T)(T a, T b, float t)
{
	//return a * (1 - t) + b * t;
	return a + (b - a) * t;
}

// Compute a "random" value at a position in a static white
// noise with values in [0,1].
// Sampling the same position will return the same value.
//
// To create 1D or 2D samples just set the other dimensions to
// a constant value.
float randomAt( int x, int y, int z )
{
	// Use states of xorshift to apply seeding
	x ^= 0x7B4E10DC; y ^= 0x2D7C0472; z ^= 0x6B055F1D;

	int value = (x * 0x9E3719B1 - (z >> 17))
		^ (y * 0xAFFE3141 - (x >> 17))
		^ (z * 0x27f161e8 - (y >> 17));

	return value * 2.328306437e-10f;
}

// Sample the other randomAt-function with trilinear interpolation.
float randomAt( float x, float y, float z )
{
	int ix = cast(int)x;
	int iy = cast(int)y;
	int iz = cast(int)z;
	float fx = x - ix;
	float fy = y - iy;
	float fz = z - iz;
	return lerp(lerp(lerp(randomAt(ix,iy,iz), randomAt(ix+1,iy,iz), fx),
					 lerp(randomAt(ix,iy+1,iz), randomAt(ix+1,iy+1,iz), fx), fy),
				lerp(lerp(randomAt(ix,iy,iz+1), randomAt(ix+1,iy,iz+1), fx),
					 lerp(randomAt(ix,iy+1,iz+1), randomAt(ix+1,iy+1,iz+1), fx), fy), fz);
}

float lerpAngle(float start, float end, float amount)
{
	float shortest_angle = ((((end - start) % (360.0 / (PI*2))) + 540.0 / (PI*2)) % (360.0 / (PI*2))) - (180.0 / (PI*2));
    return shortest_angle * amount;
}

// Compute the length of vector
float length(Vector2f vector)
{
	return sqrt(vector.x * vector.x + vector.y * vector.y);
}

Vector2f normalize(Vector2f vector)
{
	return vector / fmax(length(vector), 1e-10f);
}