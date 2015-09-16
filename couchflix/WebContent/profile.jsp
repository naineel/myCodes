<!DOCTYPE html>
<%@page import="com.couchflix.entity.User_list"%>
<%@page import="com.couchflix.manager.UserListManager"%>
<%@page import="com.couchflix.entity.TV"%>
<%@page import="com.couchflix.entity.Movie"%>
<%@page import="com.couchflix.manager.TVManager"%>
<%@page import="com.couchflix.manager.MovieManager"%>
<%@page import="com.couchflix.entity.Follows"%>
<%@page import="com.couchflix.manager.FollowsManager"%>
<%@page import="com.couchflix.entity.Comments"%>
<%@page import="com.couchflix.entity.Ratings"%>
<%@page import="com.couchflix.manager.CommentManager"%>
<%@page import="com.couchflix.manager.RatingManager"%>
<%@page import="com.couchflix.entity.User_info"%>
<%@page import="java.util.List"%>
<%@page import="com.couchflix.manager.UserManager"%>
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
		String email = request.getParameter("email");
		RatingManager ratingManager = new RatingManager();
		CommentManager commentManager = new CommentManager();
		UserManager userManager = new UserManager();
		FollowsManager followsManager = new FollowsManager();
		MovieManager movieManager = new MovieManager();
		TVManager tvManager = new TVManager();
		UserListManager listManager = new UserListManager();
		
		if("follow".equals(action)) {
			Follows newFollows = new Follows();
			newFollows.setUser_email((String)session.getAttribute("user"));
			newFollows.setFollow_email(email);
			followsManager.createFollows(newFollows);	
		}
		
		List<Follows> allFollowsBeforeUnfollow = followsManager.readFollowsByUserEmail((String)session.getAttribute("user"));
		User_info user = userManager.readUserByEmail(email);
		List<Ratings> allRatings =  ratingManager.readRatingsByUser(email);
		List<Comments> allComments = commentManager.readCommentsByUser(email);
		List<User_list> allList = listManager.readListsByUser(email);
		
		if("unfollow".equals(action)) {
			for(int i = 0 ; i < allFollowsBeforeUnfollow.size() ; i++) {
		if(allFollowsBeforeUnfollow.get(i).getFollow_email().equals(email)) {
			Follows follow = allFollowsBeforeUnfollow.get(i);
			followsManager.deleteFollows(follow.getId());
		}
			}
		}
		
		List<Follows> allFollows = followsManager.readFollowsByUserEmail((String)session.getAttribute("user"));
		
		boolean isFollowing = false;
		
		for (int i = 0 ; i < allFollows.size() ; i++) {
			if(allFollows.get(i).getFollow_email().equals(email)) {
		isFollowing = true;
		break;
			}
		}
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
	
	<div class="container" style="padding-top: 70px">

		<form action="searchUsers.jsp" method="POST" role="form">

			<div class="col-lg-4 col-lg-offset-4">
				<input id="fname" type="text"
					placeholder="Search user by first name" autofocus name="fname"
					class="form-control">
			</div>
			<button type="submit" name="action" class="btn btn-primary"
				value="login">Search!</button>

		</form>
	</div>

	<br>

	<div class="container" style="padding-top: 20px" align="center">

		<h1 style="color: white;"><%=user.getFirstName() + " " + user.getLastName()%></h1>
		<br>
		<% if(!email.equals((String)session.getAttribute("user"))) { %>
		<form action="profile.jsp" method="POST" role="form">
			<input type="hidden" name="email" value="<%=user.getEmail()%>">
			<%
				if(isFollowing) {
			%>
			<button type="submit" name="action" class="btn btn-primary"
				value="unfollow">
				UnFollow
				<%=user.getFirstName()%>!
			</button>
			<%
				} else {
			%>
			<button type="submit" name="action" class="btn btn-primary"
				value="follow">
				Follow
				<%=user.getFirstName()%>!
			</button>
			<%
				}
			%>
		</form>
		<% } %>
		<div style="padding-top: 20px">
			<h3 style="color: white;">Ratings</h3>
			<table>
				<%
					for(int i = allRatings.size()-1 ; i >= 0 ; i--) { 
						int mediaId = allRatings.get(i).getMedia_id();
						Movie movie = movieManager.readMovieById(mediaId);
						if(movie != null) {
				%>
				<tr>
					<td>
						<p style="color: white;">
							<%=user.getFirstName()%>
							rated the movie
							<%=movie.getTitle()%>
							with a rating of
							<%=allRatings.get(i).getUser_rating()%>
							stars.
						</p>
					</td>
				</tr>
				<%
					} else {
						TV tvshow = tvManager.readTVById(mediaId);
				%>
				<tr>
					<td>
						<p style="color: white;">
							<%=user.getFirstName()%>
							rated the tv show
							<%=tvshow.getName()%>
							with a rating of
							<%=allRatings.get(i).getUser_rating()%>
							stars.
						</p>
					</td>
				</tr>

				<%
					} }
				%>
			</table>
		</div>
		<div style="padding-top: 20px">
			<h3 style="color: white;">Comments</h3>
			<table>
				<%
					for(int i = allComments.size()-1 ; i >= 0 ; i--) { 
						int mediaId = allComments.get(i).getMedia_id();
						Movie movie = movieManager.readMovieById(mediaId);
						if(movie != null) {
				%>
				<tr>
					<td>
						<p style="color: white;">
						
						<% if(allComments.get(i).getComment_flag() == 0) { %>
							<%=user.getFirstName()%>
							commented on the movie
							<%=movie.getTitle()%>
							saying that "
							<%=allComments.get(i).getUser_comment()%>
							".
							<% } else { %>
							<%=user.getFirstName()%>
							commented on the movie
							<%=movie.getTitle()%>
							but the comment was flagged.
							<% } %>
						</p>
					</td>
				</tr>
				<%
					} else {
						TV tvshow = tvManager.readTVById(mediaId);
				%>
				<tr>
					<td>
						<p style="color: white;">
						<% if(allComments.get(i).getComment_flag() == 0) { %>
							<%=user.getFirstName()%>
							commented on the tv show
							<%=tvshow.getName()%>
							saying that "
							<%=allComments.get(i).getUser_comment()%>
							".
							<% } else { %>
							<%=user.getFirstName()%>
							commented on the tv show
							<%=tvshow.getName()%>
							but the comment was flagged.
							<% } %>
						</p>
					</td>
				</tr>

				<%
					} }
				%>
			</table>
		</div>
		<div style="padding-top: 20px">
			<h3 style="color: white;">Lists</h3>
			<table>
				<%
					for(int i = allList.size()-1 ; i >= 0 ; i--) { 
						int mediaId = allList.get(i).getMedia_id();
						Movie movie = movieManager.readMovieById(mediaId);
						if(movie != null) {
				%>
				<tr>
					<td>
						<p style="color: white;">
							<%=user.getFirstName()%>
							added the movie
							<%=movie.getTitle()%>
							to his
							<%=allList.get(i).getList_value()%> list.
						</p>
					</td>
				</tr>
				<%
					} else {
						TV tvshow = tvManager.readTVById(mediaId);
				%>
				<tr>
					<td>
						<p style="color: white;">
							<%=user.getFirstName()%>
							added the tv show
							<%=tvshow.getName()%>
							to his
							<%=allList.get(i).getList_value()%> list.
						</p>
					</td>
				</tr>

				<%
					} }
				%>
			</table>
		</div>
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