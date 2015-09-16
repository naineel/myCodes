<!DOCTYPE html>
<%@page import="com.couchflix.entity.Follows"%>
<%@page import="com.couchflix.manager.FollowsManager"%>
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
				value="search">Search!</button>

		</form>
	</div>

	<br>

	<div class="container" style="padding-top: 20px">

		<%
			String user_email = (String)session.getAttribute("user");
			
			FollowsManager followsManager = new FollowsManager();
			List<Follows> follows = followsManager.readFollowsByUserEmail(user_email);
			UserManager userManager = new UserManager();
			if(follows.size() == 0) {
		%>

		<h3 style="color: white;">Sorry you are not following anyone yet.
			Search for users above.</h3>

		<%
			} else {
		%>

		<ul>
			<%
				for(int i = 0 ; i <follows.size() ; i++) {
							User_info user_info = userManager.readUserByEmail(follows.get(i).getFollow_email());
			%>
			<li><a href="profile.jsp?action=view&email=<%=user_info.getEmail()%>"><%=user_info.getFirstName() + " " + user_info.getLastName()%></a></li>
			<%
				} }
			%>
		</ul>
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