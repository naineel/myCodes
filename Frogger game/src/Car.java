import java.awt.Graphics;
import java.awt.Image;

public class Car 
{
	int x,y,speed = 20;
	Image car;
	public Car(int _x,int _y,int s,int flag) 
	{
		if(flag == 0)
		{
			if(s < 0)
				car = FPictures.carleft;
			else
				car = FPictures.carright;
		}
		else
		{
			if(s < 0)
				car = FPictures.redcarleft;
			else
				car = FPictures.redcarright;
		}
		x = _x;
		y = _y;
		speed = s;
		//System.out.print(x+" ");
	}
	public void update() 
	{
		if(x < -100 && speed < 0)
		{
			x = 900;
		}
		else if(x > 850 && speed > 0)
		{
			x = -100;
		}
		x += speed;
	}
	
	public void paint(Graphics g)
	{	
		// test a virtual log before using the actual image.
		/*g.setColor(Color.BLUE);
		g.fillRect(x, y, 100, 50);*/
		g.drawImage(car,x,y,FPictures.m);
	}
}
