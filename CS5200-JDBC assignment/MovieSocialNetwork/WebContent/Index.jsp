<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import = "edu.neu.cs5200.msn.ds.dao.*, edu.neu.cs5200.msn.ds.entity.*,java.sql.Date, java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

<% 	MovieManager movieManager = new MovieManager();
	/*Movie movie = new Movie();
	movie.setTitle("300");
	movie.setPosterImage("This is sparta!!!");
	movie.setReleaseDate(Date.valueOf("2011-10-12"));
	
	movieManager.createMovie(movie);
	*/
	
	List<Movie> movies = movieManager.readAllMovies();
	
	for(Movie m : movies){
		out.println(m.getTitle());
		%>
		<br>
		<% 
	}
	
	CommentManager commentManager = new CommentManager();
	List<Comment> comm = commentManager.readAllComments();
	
	for(Comment c : comm){
		out.println(c.getComment());
		%>
		<br>
		<% 
	}
	
	CastManager castManager = new CastManager();
	List<Cast> ca = castManager.readAllCast();
	
	for(Cast c : ca){
		out.println(c.getCharacterName());
	} 
	
/* 	Movie movie = movieManager.readMovie(2);
	out.println(movie.getTitle());
	
	movie.setTitle("Batman Begins");
	movieManager.updateMovie(1, movie);
	
	movie = movieManager.readMovie(1);
	out.println("THis is the title " + movie.getTitle());
	out.println(movie.getPosterImage());
 */
	//movieManager.deleteMovie(3);	
 	ActorManager actorManager = new ActorManager();
 	Actor act = new Actor();
 	act.setFirstName("Liam");
 	act.setLastName("Neeson");
 	act.setDateOfBirth(Date.valueOf("1960-01-25")); 	
 
 	actorManager.updateActor(5, act);
 	List<Actor> actor = actorManager.readAllActors();
 	
 	for(Actor a : actor){
 		out.println(a.getFirstName());
 		out.println(a.getLastName());
 	}
	
%>
</body>
</html>