import java.awt.Graphics;
import java.awt.Image;

public class Frog 
{
	float speed = 0;	
	int startY = 505;
	int x = 400, y = 510;
	int frogHeight = 29;
	int frogWidth = 40;
	Image frogpic,frogCrashed;
	public Frog() {
		// TODO Auto-generated constructor stub
		frogpic = FPictures.frog;
		frogCrashed = FPictures.frogCrashed;
	}
	
	public void update()
	{       
		x=(int) (x+speed);
	}	
		
	public void moveUp() 
	{		
		// TODO Auto-generated method stub		
		y -= 50;                
	}
	
	public void moveDown() 
	{		
		// TODO Auto-generated method stub		
		if(y != 510)
			y += 50;			
	}
		
	public void moveRight()
	{	
		x += 20;
	}
		
	public void moveLeft()
	{	
		x -= 20;
	}
		
	int getX()
	{	
		return x;
	}
		
	int getY()
	{	
		return y;
	}
	
	void setSpeed(float s)
	{       
		speed = s;    
	}
		
	public void resetFrog()
	{
		x = 400;
		y = 510;
		speed = 0;	
		frogpic = FPictures.frog;
	}
	
	public void paint(Graphics g)
	{	
		g.drawImage(frogpic,x,y,FPictures.m);
	}
	
	void updateCrashed()
	{
		frogpic = frogCrashed;
	}
	        
	boolean checkForCollLog(Log l, int i) 
	{ 
		if(l.speed > 0)
		{
			if(x > l.x  && x + frogWidth/2 < l.x + 100 && y > l.y && y + frogHeight < l.y + 50) 
			{				
				return true;			
			}				
			else 
			{                
				return false;                           
			}
		}
		
		else
		{
			if(x + frogWidth/2 > l.x  && x < l.x + 100 && y > l.y && y + frogHeight < l.y + 50) 
			{				
				return true;			
			}				
			else 
			{                
				return false;                           
			}
		}
	}
	
	public boolean checkForCollCar(Car c, int i) 
	{
//		System.out.println("X is " + x + " " + c.x);
//		System.out.println("Y is " + y + " " + c.y);
		if(x + frogWidth/2 > c.x  && x + frogWidth/2 < c.x + 100 && y > c.y && y+frogHeight<c.y +50 ) 
		{			
			//System.out.println("true");
			return true;			
		}				
		else 
		{      
			//System.out.println("FALSE");
			return false;                           
		}
	}
}