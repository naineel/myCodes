<!DOCTYPE html>
<%@page import="org.jasypt.util.password.BasicPasswordEncryptor"%>
<%@page import="com.couchflix.entity.User_info"%>
<%@page import="com.couchflix.manager.UserManager"%>
<%@page import="com.couchflix.api.TVAPI"%>
<%@page import="com.couchflix.entity.Discover"%>
<%@page import="java.util.List"%>
<%@page import="com.couchflix.api.MovieAPI"%>
<html lang="en">
<%@ page language="java" contentType="text/html; charset=utf-8"%>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=1000px, initial-scale=1">
<meta name="description" content="">
<meta name="author" content="">
<title>CouchFlix</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</head>

<body style="background-color: #000000">

	<%
		String action = request.getParameter("action");
			if(action == null) {
		action = "movies";
			} else if(action.equals("logout")){
		session.removeAttribute("user");
		session.removeAttribute("admin");
		session.removeAttribute("userFname");
		session.removeAttribute("userLname");
		action = "movies";
			} else if(action.equals("login")) {
		   String email = request.getParameter("emailId");
		   String inputPassword = request.getParameter("password");
		   UserManager us = new UserManager();
		   User_info user = new User_info();
		   try{
		   user = us.readUserByEmail(email);
		   String encryptedPassword = user.getPassword();
		   
		   BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
		   if(user.isEnabled()) {
		   	if(passwordEncryptor.checkPassword(inputPassword, encryptedPassword)){
			   	session.setAttribute("user", email);
			   	session.setAttribute("userFname", user.getFirstName());
			   	session.setAttribute("userLname", user.getLastName());
			   	if(user.isAdmin()) {
			   		session.setAttribute("admin", true);
			   	} 
			   	System.out.println(session.getAttribute("user"));
		 	} else {
		   response.sendRedirect("login.jsp?action=invalidPassword");
		 	}
		   } else {
			   response.sendRedirect("login.jsp?action=notEnabled");
		   }
		   }
		   catch(NullPointerException e){
			   response.sendRedirect("login.jsp?action=invalidEmail");
		   }
		
			action = "movies";
			}
			
			MovieAPI movieAPI = new MovieAPI();
			TVAPI tvAPI = new TVAPI();
			List<Discover> list = null;
		
			if(action.contains("movies")) {
	%>

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

	<div class="container" align="center">
		<form method="post" style="padding-top: 70px; padding-bottom: 20px"
			action="search.jsp" role="form">
			<div class="form-group col-lg-4 col-lg-offset-4">
				<input type="text" class="form-control" name="query"
					placeholder="Search for movies or tv shows...">
			</div>	<button name="action" value="search" type="submit"
					class="btn btn-info pull-left">Search</button>
			
		</form>
	</div>

	<div class="container" align="center">
		<form method="post" style="padding-top: 20px; padding-bottom: 20px"
			action="index.jsp">
			<div class="btn-group">
				<button name="action" value="movies" type="submit"
					style="width: 300px;" class="btn btn-primary">Movies</button>
				<button name="action" value="tvshows" type="submit"
					style="width: 300px;" class="btn btn-default">TV Shows</button>
			</div>
			<br>
			<div class="btn-group" style="padding-top: 20px;">
				<%
					if(action.equals("moviesMostPopular")||action.equals("movies")) {
																																																														list = movieAPI.getMostPopularMovies();
				%>
				<button name="action" value="moviesMostPopular" type="submit"
					style="width: 200px;" class="btn btn-success">Most Popular</button>
				<%
					} else {
				%>
				<button name="action" value="moviesMostPopular" type="submit"
					style="width: 200px;" class="btn btn-info">Most Popular</button>
				<%
					}
				%>
				<%
					if(action.equals("moviesRecentReleases")) {
																																																														list = movieAPI.getRecentReleases();
				%>
				<button name="action" value="moviesRecentReleases" type="submit"
					style="width: 200px;" class="btn btn-success">Recent
					Releases</button>
				<%
					} else {
				%>
				<button name="action" value="moviesRecentReleases" type="submit"
					style="width: 200px;" class="btn btn-info">Recent Releases</button>
				<%
					}
				%>
				<%
					if(action.equals("moviesComingSoon")) {
																																																														list = movieAPI.getComingSoon();
				%>
				<button name="action" value="moviesComingSoon" type="submit"
					style="width: 200px;" class="btn btn-success">Coming Soon</button>
				<%
					} else {
				%>
				<button name="action" value="moviesComingSoon" type="submit"
					style="width: 200px;" class="btn btn-info">Coming Soon</button>
				<%
					}
				%>
			</div>
		</form>
	</div>

	<%
		} else {
	%>
	
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

	<div class="container" align="center">
		<form method="post" style="padding-top: 70px; padding-bottom: 20px"
			action="search.jsp" role="form">
			<div class="form-group col-lg-4 col-lg-offset-4">
				<input type="text" class="form-control" name="query"
					placeholder="Search for movies or tv shows...">
			</div>	<button name="action" value="search" type="submit"
					class="btn btn-info pull-left">Search</button>
			
		</form>
	</div>

	<div class="container" align="center">
		<form method="post" style="padding-top: 20px; padding-bottom: 20px"
			action="index.jsp">
			<div class="btn-group">
				<button name="action" value="movies" type="submit"
					style="width: 300px;" class="btn btn-default">Movies</button>
				<button name="action" value="tvshows" type="submit"
					style="width: 300px;" class="btn btn-primary">TV Shows</button>
			</div>
			<br>
			<div class="btn-group" style="padding-top: 20px;">
				<%
					if(action.equals("tvshowsMostPopular")||action.equals("tvshows")) {
																																																														list = tvAPI.getMostPopularTVShows();
				%>
				<button name="action" value="tvshowsMostPopular" type="submit"
					style="width: 200px;" class="btn btn-success">Most Popular</button>
				<%
					} else {
				%>
				<button name="action" value="tvshowsMostPopular" type="submit"
					style="width: 200px;" class="btn btn-info">Most Popular</button>
				<%
					}
				%>
				<%
					if(action.equals("tvshowsRecentReleases")) {
																																																														list = tvAPI.getRecentReleases();
				%>
				<button name="action" value="tvshowsRecentReleases" type="submit"
					style="width: 200px;" class="btn btn-success">Recent
					Releases</button>
				<%
					} else {
				%>
				<button name="action" value="tvshowsRecentReleases" type="submit"
					style="width: 200px;" class="btn btn-info">Recent Releases</button>
				<%
					}
				%>
				<%
					if(action.equals("tvshowsComingSoon")) {
																																																														list = tvAPI.getComingSoon();
				%>
				<button name="action" value="tvshowsComingSoon" type="submit"
					style="width: 200px;" class="btn btn-success">Coming Soon</button>
				<%
					} else {
				%>
				<button name="action" value="tvshowsComingSoon" type="submit"
					style="width: 200px;" class="btn btn-info">Coming Soon</button>
				<%
					}
				%>
			</div>
		</form>
	</div>

	<%
		}
	%>

	<!-- Half Page Image Background Carousel Header -->
	<header id="myCarousel" class="carousel slide">

		<!-- Wrapper for Slides -->
		<div class="carousel-inner">
			<div class="item active">
				<!-- Set the first background image using inline CSS below. -->
				<%
					if(list.get(0).getBackdrop_path() != null) {
				%>
				<div class="fill"
					style="background-image:url('http://image.tmdb.org/t/p/w780<%=list.get(0).getBackdrop_path()%>'); background-size: contain; background-repeat: no-repeat;"></div>
				<%
					} else {
				%>
				<div class="fill"
					style="background-image: url('http://placehold.it/800x600&amp;text=Image+Unavailable'); background-size: contain; background-repeat: no-repeat;"></div>
				<%
					}
				%>
				<div class="carousel-caption">
					<h1 style="color: white; text-shadow: 2px 2px 4px #000000;">
						<%=list.get(0).getTitle()%>
					</h1>
				</div>
			</div>
			<%
				for (int i = 1; i < list.size(); i++) {
			%>
			<div class="item">
				<!-- Set the remaining background image using inline CSS below. -->
				<%
					if(list.get(i).getBackdrop_path() != null) {
				%>
				<div class="fill"
					style="background-image:url('http://image.tmdb.org/t/p/w780<%=list.get(i).getBackdrop_path()%>'); background-size: contain; background-repeat: no-repeat;"></div>
				<%
					} else {
				%>
				<div class="fill"
					style="background-image: url('http://placehold.it/800x600&amp;text=Image+Unavailable'); background-size: contain; background-repeat: no-repeat;"></div>
				<%
					}
				%>
				<div class="carousel-caption">
					<h1 style="color: white; text-shadow: 2px 2px 4px #000000;"><%=list.get(i).getTitle()%></h1>
				</div>

			</div>
			<%
				}
			%>
		</div>

		<!-- Controls -->
		<a class="left carousel-control" href="#myCarousel" data-slide="prev">
			<span class="icon-prev"></span>
		</a> <a class="right carousel-control" href="#myCarousel"
			data-slide="next"> <span class="icon-next"></span>
		</a>

	</header>

	<!-- Page Content -->
	<div class="container">

		<table class="table">
			<%
				for (int i = 0; i < list.size(); i++) {
																																																															if (i % 4 == 0) {
			%>
			<tr>
				<%
					}
				%>

				<%
					if(action.contains("movies")) {
				%>

				<td width="150px" align="center"><a
					href="http://localhost:8080/CouchFlix/movie.jsp?movieId=<%=list.get(i).getId()%>&action=display#">

						<%
							if(list.get(i).getPoster_path() != null) {
						%> <img
						src='http://image.tmdb.org/t/p/w185<%=list.get(i).getPoster_path()%>'
						width="150" height="200" class="img-rounded"> <%
 	} else {
 %> <img src='http://placehold.it/150x200&amp;text=Image+Unavailable'
						width="150" height="200" class="img-rounded"> <%
 	}
 %>

				</a> <a
					href="http://localhost:8080/CouchFlix/movie.jsp?movieId=<%=list.get(i).getId()%>&action=display#"><h3
							style="color: white; text-shadow: 2px 2px 4px #000000;"><%=list.get(i).getTitle()%></h3></a>
				</td>

				<%
					} else {
				%>
				<td width="150px" align="center"><a
					href="http://localhost:8080/CouchFlix/tv.jsp?tvId=<%=list.get(i).getId()%>&action=display#">

						<%
							if(list.get(i).getPoster_path() != null) {
						%> <img
						src='http://image.tmdb.org/t/p/w185<%=list.get(i).getPoster_path()%>'
						width="150" height="200" class="img-rounded"> <%
 	} else {
 %> <img src='http://placehold.it/150x200&amp;text=Image+Unavailable'
						width="150" height="200" class="img-rounded"> <%
 	}
 %>
				</a> <a
					href="http://localhost:8080/CouchFlix/tv.jsp?tvId=<%=list.get(i).getId()%>&action=display#"><h3
							style="color: white; text-shadow: 2px 2px 4px #000000;"><%=list.get(i).getTitle()%></h3></a>
				</td>

				<%
					}
																																																													if (((i + 1) % 4 == 0) || (i == list.size() - 1)) {
				%>
			</tr>
			<%
				}
																																																														}
			%>

		</table>

	</div>

	<hr>

	<!-- Footer -->
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
	<!-- /.container -->


	<!-- Script to Activate the Carousel -->
	<script>
		$('.carousel').carousel({
			interval : 5000
		//changes the speed
		})
	</script>
</body>

</html>