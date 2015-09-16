<!DOCTYPE html>
<%@page import="com.couchflix.entity.*"%>
<%@page import="com.couchflix.manager.*"%>
<%@page import="java.util.List"%>
<%@page import="com.couchflix.Utils"%>
<%@page import="com.couchflix.api.MovieAPI" import="java.util.Date"%>
<html lang="en">
<%@ page language="java" contentType="text/html; charset=utf-8"%>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=1000px, initial-scale=1">
<meta name="description" content="">
<meta name="author" content="">
<title>List details</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
<link
	href="http://netdna.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css"
	rel="stylesheet">
<link href="css/star-rating.min.css" media="all" rel="stylesheet"
	type="text/css" />
<script
	src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="js/star-rating.min.js" type="text/javascript"></script>
</head>
<body style="background-color: #000000">

	<!-- Navigation -->
	<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
		<div class="container">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse"
					data-target="#bs-example-navbar-collapse-1">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
			</div>
			<div class="collapse navbar-collapse"
				id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav">
					<li><a href="http://localhost:8080/CouchFlix/index.jsp"><img
							src="images/logo-100.png"></a></li>
					<li><a href="http://localhost:8080/CouchFlix/aboutUs.jsp">About Us</a></li>
					<%
						if(session.getAttribute("user") == null) {
					%>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><a href="http://localhost:8080/CouchFlix/login.jsp">Login</a></li>
					<li><a href="http://localhost:8080/CouchFlix/register.jsp">Register</a></li>
					<%
						} else {
					%>
					<%
						if(session.getAttribute("admin") != null) {
					%>

					<li><a
						href="http://localhost:8080/CouchFlix/commentManager.jsp">Comment
							Manager</a></li>

					<%
						} else {
					%>
					<li><img width="100px"></li>
					<%
						}
					%>
					<li><a
						href="http://localhost:8080/CouchFlix/profile.jsp?action=view&email=<%=(String)session.getAttribute("user")%>">Timeline</a>
					<li><a href="http://localhost:8080/CouchFlix/Lists.jsp">My
							Lists</a></li>
					<li><a href="http://localhost:8080/CouchFlix/following.jsp">Following</a></li>
					<li><a href="http://localhost:8080/CouchFlix/update.jsp">Update
							Profile</a></li>
					<li><a href="http://localhost:8080/CouchFlix/index.jsp">Welcome,
							<%=session.getAttribute("userFname")%></a></li>

					<li><a
						href="http://localhost:8080/CouchFlix/index.jsp?action=logout">Logout</a></li>
					<%
						}
					%>
				</ul>
			</div>
		</div>
	</nav>

	<br>
	<br>
	<br>
	<div class="container">
		<h3 style="color: white;">
			My list of watched movies are <br>
			<%
				String email = (String) session.getAttribute("user");
				UserListManager listManager = new UserListManager();
				MovieManager movieManager = new MovieManager();
				MediaManager mediaManager = new MediaManager();

				List<User_list> lists = listManager.readListsByUserWhere(email,
						"watched");
				for (User_list list : lists) {
			%>
			<%
				Integer id = list.getMedia_id();
					Media media1 = mediaManager.readMediaById(id);
					Movie watchedMovie = movieManager.readMovieById(id);
					if (watchedMovie != null) {
			%>

			<a
				href="http://localhost:8080/CouchFlix/movie.jsp?movieId=<%=media1.getMoviedb_id()%>&action=display"><%=watchedMovie.getTitle()%></a><br>
			<%
				}
				}
			%>
		</h3>
	</div>

	<div class="container">
		<h3 style="color: white;">
			My wishlist of movies are <br>
			<%
				List<User_list> wishlist = listManager.readListsByUserWhere(email,
						"wish");
				for (User_list entry : wishlist) {
			%>
			<%
				Integer id = entry.getMedia_id();
					Media media1 = mediaManager.readMediaById(id);
					Movie wishMovie = movieManager.readMovieById(id);
					if (wishMovie != null) {
			%>
			<a
				href="http://localhost:8080/CouchFlix/movie.jsp?movieId=<%=media1.getMoviedb_id()%>&action=display"><%=wishMovie.getTitle()%></a><br>
			<%
				}
				}
			%>
		</h3>
	</div>

	<div class="container">
		<h3 style="color: white;">
			My list of watched tv shows are <br>
			<%
				TVManager tvManager = new TVManager();
				List<User_list> tvShowWatched = listManager.readListsByUserWhere(
						email, "watched");
				for (User_list list : lists) {
			%>
			<%
				Integer id = list.getMedia_id();
					Media media1 = mediaManager.readMediaById(id);
					TV watchedTV = tvManager.readTVById(id);
					if (watchedTV != null) {
			%>

			<a
				href="http://localhost:8080/CouchFlix/tv.jsp?tvId=<%=media1.getMoviedb_id()%>&action=display"><%=watchedTV.getName()%></a><br>
			<%
				}
				}
			%>
		</h3>
	</div>

	<div class="container">
		<h3 style="color: white;">
			My wishlist of tv shows are <br>
			<%
				List<User_list> wishlistTV = listManager.readListsByUserWhere(
						email, "wish");
				for (User_list entry : wishlistTV) {
			%>
			<%
				Integer id = entry.getMedia_id();
					Media media1 = mediaManager.readMediaById(id);
					TV wishTV = tvManager.readTVById(id);
					if (wishTV != null) {
			%>
			<a
				href="http://localhost:8080/CouchFlix/tv.jsp?tvId=<%=media1.getMoviedb_id()%>&action=display"><%=wishTV.getName()%></a><br>
			<%
				}
				}
			%>
		</h3>
	</div>

	<div class="container">

		<hr>
		<footer>
			<div class="row">
				<div class="col-lg-12">
					<p style="color: white;">Copyright &copy; CouchFlix 2015</p>
				</div>
			</div>
		</footer>
	</div>
	<%
		
	%>

</body>
</html>