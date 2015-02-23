import java.awt.Graphics;
import java.awt.Image;

public class Log 
{
	int x,y,speed = 20;
	Image log;
	public Log(int _x,int _y,int s) 
	{
			// TODO Auto-generated constructor stub
		x = _x;
		y = _y;
		speed = s;
		log = FPictures.log;
		//System.out.print(x+" ");
	}
	
	public void update() 
	{
		// TODO Auto-generated method stub
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
		/*g.setColor(Color.GRAY);
		g.fillRect(x, y, 100, 50);*/
		g.drawImage(log, x, y, FPictures.m);
	}

}

