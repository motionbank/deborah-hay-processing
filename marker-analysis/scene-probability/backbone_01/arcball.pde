/*
 Replaced Vec3 with internal PVector. Added rotateAround() to 
 handle missing rotate(a,v0,v1,v2) in Processing.js 1.4.1
 fjenett - 2012-11
 
 Adapted into Processing library 5th Feb 2006 Tom Carden
 from "simple arcball use template" 9.16.03 Simon Greenwold
 
 Copyright (c) 2003 Simon Greenwold
 Copyright (c) 2006 Tom Carden
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General
 Public License along with this library; if not, write to the
 Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA  02111-1307  USA
 */

public class ArcBall 
{
    PGraphics graphics;

    float center_x, center_y, center_z, radius;
    PVector v_down, v_drag;
    Quat q_now, q_down, q_drag;
    PVector[] axisSet;
    int axis;

    /** defaults to radius of min(width/2,height/2) and center_z of -radius */
    public ArcBall( PApplet parent ) 
    {
        this( parent.g );
    }
    
    /** defaults to radius of min(width/2,height/2) and center_z of -radius */
    public ArcBall( PGraphics g ) 
    {
        this( g.width/2.0f, g.height/2.0f, -min( g.width/2.0f, g.height/2.0f ), min( g.width/2.0f, g.height/2.0f ), g );
    }

    public ArcBall( float center_x, float center_y, float center_z, float radius, PGraphics g ) 
    {
        graphics = g;

        this.center_x = center_x;
        this.center_y = center_y;
        this.center_z = center_z;
        this.radius = radius;

        v_down = new PVector();
        v_drag = new PVector();

        q_now = new Quat();
        q_down = new Quat();
        q_drag = new Quat();

        axisSet = new PVector[] { 
            new PVector(1.0f, 0.0f, 0.0f), 
            new PVector(0.0f, 1.0f, 0.0f), 
            new PVector(0.0f, 0.0f, 1.0f)
        };
        axis = -1;  // no constraints...
        
        // this is a hack to initialize it with something .. we can do better
        mousePressed( center_x, center_y );
        mouseDragged( center_x-0.0001, center_y-0.0001 );
    }

    public void mousePressed ( float mx, float my ) 
    {
        v_down = mouse_to_sphere( mx, my );
        q_down.set(q_now);
        q_drag.reset();
    }

    public void mouseDragged ( float mx, float my )
    {
        v_drag = mouse_to_sphere( mx, my );
        q_drag.set( v_down.dot(v_drag), v_down.cross(v_drag) );
    }

    public void apply ()
    {
        graphics.translate(center_x, center_y, center_z);
        q_now = Quat.mul(q_drag, q_down);
        applyQuat2Matrix(q_now);
        graphics.translate(-center_x, -center_y, -center_z);
    }

    PVector mouse_to_sphere ( float x, float y ) 
    {
        PVector v = new PVector();
        v.x = (x - center_x) / radius;
        v.y = (y - center_y) / radius;

        float m = v.x * v.x + v.y * v.y;
        if (m > 1.0f) 
        {
            v.normalize();
        }
        else 
        {
            v.z = sqrt(1.0f - m);
        }

        return (axis == -1) ? v : constrain_vector(v, axisSet[axis]);
    }

    PVector constrain_vector(PVector vector, PVector axis) 
    {
        PVector res = new PVector();
        axis.mult(axis.dot(vector));
        res.sub(vector, axis);
        res.normalize();
        return res;
    }

    void applyQuat2Matrix(Quat q) 
    {
        // instead of transforming q into a matrix and applying it...

        float[] aa = q.getValue();
        rotateAround( aa[0], aa[1], aa[2], aa[3] );
    }
    
    void rotateAround ( float angle, float v0, float v1, float v2 )
    {
        float norm2 = v0 * v0 + v1 * v1 + v2 * v2;
        
        if (Math.abs(norm2 - 1) > EPSILON) {
            float norm = sqrt(norm2);
            v0 /= norm;
            v1 /= norm;
            v2 /= norm;
        }
    
        float cx = 0;
        float cy = 0;
        float cz = 0;
    
        float c = cos(angle);
        float s = sin(angle);
        float t = 1.0f - c;
        float[] m = new float[9];
        m[0] = (t*v0*v0) + c;          // 0, 0
        m[1] = (t*v0*v1) - (s*v2);     // 0, 1
        m[2] = (t*v0*v2) + (s*v1);     // 0, 2
        
        m[3] = (t*v0*v1) + (s*v2);     // 1, 0
        m[4] = (t*v1*v1) + c;          // 1, 1
        m[5] = (t*v1*v2) - (s*v0);     // 1, 2
        
        m[6] = (t*v0*v2) - (s*v1);     // 2, 0
        m[7] = (t*v1*v2) + (s*v0);     // 2, 1
        m[8] = (t*v2*v2) + c;          // 2, 2
    
        graphics.applyMatrix( m[0], m[1], m[2], 0, m[3], m[4], m[5], 0, m[6], m[7], m[8], 0, 0, 0, 0, 1 );
    }
}

class Quat 
{
    float w, x, y, z;

    Quat() {
        reset();
    }

    Quat(float w, float x, float y, float z) 
    {
        this.w = w;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    void reset() 
    {
        w = 1.0f;
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
    }

    void set ( float w, PVector v ) 
    {
        this.w = w;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    void set( Quat q) 
    {
        w = q.w;
        x = q.x;
        y = q.y;
        z = q.z;
    }

    static Quat mul ( Quat q1, Quat q2 ) 
    {
        Quat res = new Quat();
        res.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
        res.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
        res.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
        res.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
        return res;
    }

    float[] getValue() 
    {
        // transforming this quat into an angle and an axis vector...

        float[] res = new float[4];

        float sa = (float) Math.sqrt(1.0f - w * w);
        if (sa < EPSILON) {
            sa = 1.0f;
        }

        res[0] = (float) Math.acos(w) * 2.0f;
        res[1] = x / sa;
        res[2] = y / sa;
        res[3] = z / sa;

        return res;
    }
} // Quat

