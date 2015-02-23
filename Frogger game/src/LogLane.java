import java.awt.Graphics;

public class LogLane 
{
	int noL;
	int y;
	int dir;
	Log log[];
	int dist;
	int lanespeed;
    boolean isFrogOn = false;
    int Logno = -1;

	LogLane(int n,int _y,int d)
	{
		noL = n;
		y = _y;
		log = new Log[noL];
		dist = 50*noL;
		dir = d;
		for(int i = 0; i<log.length; i++)
		{
			//System.out.print(noL+" ");
			if(dir%2 == 0)
			{
				if(noL!= 1)
				{
					log[i] = new Log(850+200*i+dist*i,y,-05);
					lanespeed = -05;
				}
				else
				{
					log[i] = new Log(850+200*i+dist*i,y,-10);
					lanespeed = -10;
				}
				//log[i]=new Log(850+200*i+dist*i,y,-05);
			}
			else
			{
				if(noL!= 1)
				{
					log[i] = new Log(-100-200*i-dist*i,y,05);
					lanespeed = 05;
				}
				else
				{
					log[i] = new Log(-100-200*i-dist*i,y,10);
					lanespeed = 10;
				}
			}
		}
	}
	
	public void paint(Graphics g)
	{
		
		for(int i = 0;i < log.length ; i++)
		{
			log[i].paint(g);
		}
	}
		
	public void update(Frog f,Start m,int laneNo)
	{
		int i;
		isFrogOn = false;
		for(i = 0;i < log.length;i++)
		{
			if(noL == laneNo)
			{
				if(f.checkForCollLog(log[i], i))
				{
					f.setSpeed(lanespeed);
					isFrogOn = true;
					f.update();
				}
			}
			
			log[i].update();
		}
	}
	
	public boolean getIsFrogOn()
	{
		return isFrogOn;
	}
}

