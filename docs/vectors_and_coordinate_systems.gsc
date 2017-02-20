/******************************************************************************
    ---- Reign of the Undead, v2.x ----

    Copyright (c) 2012 Mark A. Taff <mark@marktaff.com>
    Dedicated to the public domain.
******************************************************************************/

/**
 * @file vectors_and_coordinate_systems.gsc This file documents vector functions and coordinate systems in cod4
 */

/// This file is *not* meant to be ran as code.  It is only in a *.gsc file for
/// the benefits of highlighting.

/**
cod4 maps use a xyz right-hand coordinate system to describe points in the world-space.
positive z is up.

superimposed on the xyz coordinate system is an odd spherical coordinate system.
Why activision thought this would be a convenient system is a mystery to me.

In the spherical-like coordinate system, the polar angle, theta, is the same as
in a normal sperical coordinate system.  So tan(theta) == (y/x)

Unlike a normal spherical coordinate system, phi is *not* the declination from the
z-axis.  Rather, phi is 360 degrees minus the inclination from the xy-plane.  The
inclination from the xy-plane is arcsin(z/rho), where rho is the magnitude of the
position vector (rho == sqrt(x^2 + y^2 + z^2)).

The vectorToAngles() function takes a 3-d physics vector as input, and returns a
3-d vector as its output.  The first component of it's output is phi, the second
component is theta, and the last component is always zero (because the other component
in speherical components is the radial length, and a length doesn't make sense in
the context of angles).

Putting it all together:

vectorToAngles([x,y,z]) ==> [360-arcsin(z/(sqrt(x^2 + y^2 + z^2))), arctan(y/x), 0]

However, note that arcsin and arctan are only defined for the first interval, so
you need to check the output of those functions to ensure the angle returned is
in the correct quadrant (the function does this itself, I'm talking about if you
are trying to do the math manually).

self.origin returns the position vector of the player (in standard position, of course).

vectorNormalize returns the unit vector for a given input vector, that is, a vector
of unit length in the same direction as the input vector.

for vectors a and b:
    distance(a,b) returns ||a - b|| i.e. the magnitude/norm of the vector a - b
    distanceSquared(a,b) returns ||a - b||^2
    length(b) returns ||b||, i.e. the magnitude/norm of the vector b
    lengthSquared(b) returns ||b||^2
    vectorDot(a,b) returns the dot product, i.e. the scalar (ax*bx) + (ay*by) + (az*bz)

combineAngles(anglesToOriginOfMovingCoordinateSystem, anglesFromMovingCoordinateSystemToEntity)
translates the releative angles of the entity into angles in the world's coordinate system

*/

