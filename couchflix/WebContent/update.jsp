<%@page import="com.couchflix.Utils"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@page import="com.couchflix.entity.*"%>
<%@page import="com.couchflix.manager.*"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Update Profile</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</head>
<body style="background-color: #000000">
<%
			String email = (String) session.getAttribute("user");
			UserManager userManager = new UserManager();
			User_info user = userManager.readUserByEmail(email);
			String action = request.getParameter("action");
			boolean updateProfile = false;
			if ("updateProfile".equals(action)) {
				updateProfile = true;
			}
			session.setAttribute("userFname", user.getFirstName());
			session.setAttribute("userLname", user.getLastName());
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

	<div class="container" align="center" style="padding-top: 70px">
		<img src="images/logo-1000.png">
		
		<h1 style="color: white">Edit Information</h1>
		<h3 style="color: white"><%=user.getEmail()%></h3>
		<form action="UpdateProfile" method="post" role="form">
			<div style="padding-top: 5px; padding-bottom: 5px"
				class="col-lg-4 col-lg-offset-4">
				<input id="firstName" type="text"
					placeholder="<%=user.getFirstName()%>" name="firstName"
					class="form-control">
			</div>
			<br>
			<div style="padding-top: 5px; padding-bottom: 5px"
				class="col-lg-4 col-lg-offset-4">
				<input id="lastName" type="text"
					placeholder="<%=user.getLastName()%>" name="lastName"
					class="form-control">
			</div>
			<br>
			<div style="padding-top: 5px; padding-bottom: 5px"
				class="col-lg-4 col-lg-offset-4">
				<input id="password" type="password"
					placeholder="Enter New Password" name="password"
					class="form-control">
			</div>
			<br>
			<div style="padding-top: 5px; padding-bottom: 5px"
				class="col-lg-4 col-lg-offset-4">
				<input id="dob" type="text"
					placeholder="<%=Utils.dateToString(user.getDateOfBirth())%>"
					name="dob" class="form-control">
			</div>
			<input type="hidden" name="emailId" value="<%=email%>"> <br>
			<div class="col-lg-4 col-lg-offset-4">
				<button type="submit" name="submission" class="btn btn-primary"
					value="Register">Submit</button>
			</div>
		</form>
	
	<div>
		<%
			if (updateProfile) {
		%>
		<br> <br>
		<div class="col-lg-4 col-lg-offset-4">
			<h3 style="color: white;">Your credentials have been updated successfully.</h3><br>
		</div>
		<%
			}
		%>
		</div>
	</div>

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
</body>
</html>