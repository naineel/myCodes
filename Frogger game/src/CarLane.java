import java.awt.Graphics;
import java.awt.Image;

public class CarLane 
{
	int noC;
	int y;
	int dir;
	Car car[];
	int dist;
	int lanespeed;
    boolean isFrogSafe = true;
    int Carno = -1;
    Image road;

	CarLane(int n,int _y,int d)
	{
		noC = n;
		y = _y;
		car = new Car[noC];
		dist = 50*noC;
		dir = d;
		road = FPictures.road;
		for(int i = 0; i<car.length; i++)
		{
			//System.out.print(noC+" ");
			if(dir % 2 == 0)
			{
				if(noC != 1)
				{
					car[i] = new Car(850+200*i+dist*i, y+5, -05, noC%2);
					lanespeed = -05;
				}
				else
				{
					car[i] = new Car(850+200*i+dist*i, y + 5, -10, noC%2);
					lanespeed = -10;
				}
				//car[i]=new Car(850+200*i+dist*i,y+5,-05,0);
				
			}
			else
			{
				if(noC != 1)
				{
					car[i] = new Car(-100-200*i-dist*i, y + 5, 05, noC%2);
					lanespeed = 05;
				}
				else
				{
					car[i] = new Car(-100-200*i-dist*i, y + 5, 10, noC%2);
					lanespeed = 10;
				}
				//car[i]=new Car(850+200*i+dist*i,y+5,05,0);
			}
		}
	}
	
	public void paint(Graphics g)
	{
		
		for(int i = 0;i < car.length; i++)
		{
			car[i].paint(g);
		}
	}
		
	public void update(Frog frog,Start m,int laneNo)
	{
		int i;
		isFrogSafe = true;
		for(i = 0;i < car.length;i++)
		{
			if(noC == laneNo)
			{
				if(frog.checkForCollCar(car[i], i))
				{
					isFrogSafe = false;
				}
			}
			car[i].update();
        }
	}
	public boolean getIsFrogSafe()
	{
		return isFrogSafe;
	}
}
