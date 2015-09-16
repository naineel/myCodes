<!DOCTYPE html>
<%@page import="com.couchflix.Utils"%>
<%@page import="com.couchflix.entity.Person"%>
<%@page import="com.couchflix.api.PersonAPI"%>
<html lang="en">
<%@ page language="java" contentType="text/html; charset=utf-8"%>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=1000px, initial-scale=1">
<meta name="description" content="">
<meta name="author" content="">
<title>Person</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</head>

<body style="background-color: #000000">

	<%
		PersonAPI api = new PersonAPI();
		String personId = request.getParameter("personId");
		System.out.println("PersonID - " + personId);
		Person person = api.getPersonByID(Integer.parseInt(personId));
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

		<h1 style="color: white;"><%=person.getName()%></h1>

		<table class="table">

			<tr>
				<td width="50%" align="center">
				<%
					if (person.getProfile_path() == null) {
				%> <img src='images/unknown-person.png' width="300" height="400" class="img-rounded">
				<% } else { %> 
					<img
					src='http://image.tmdb.org/t/p/original<%=person.getProfile_path()%>'
					width="300" height="400" class="img-rounded"> 
					<% } %>
				</td>
				<td width="50%">

					<% if(person.getBirthday() != null) { %>
					<h4 style="color: white;">Birthday</h4>
					<p style="color: #A5A5A5;">
						<%=Utils.dateToString(person.getBirthday())%>
					</p>
					<% } %>
				
					<% if(person.getDeathday() != null) { %>
					<h4 style="color: white;">Deathday</h4>
					<p style="color: #A5A5A5;">
						<%=Utils.dateToString(person.getDeathday())%>
					</p>
					<% } %>

					<% if(!person.getPlace_of_birth().equals("")) { %>
					<h4 style="color: white;">Place of Birth</h4>
					<p style="color: #A5A5A5;">
						<%=person.getPlace_of_birth()%>
					</p>
					<% } %>

					<% if(!person.getHomepage().equals("")) { %>
					<h4 style="color: white;">Homepage</h4>
					<p style="color: #A5A5A5;">
						<%=person.getHomepage()%>
					</p>
					<% } %>

					<% if(!person.getBiography().equals("")) { %>
					<h4 style="color: white;">Biography</h4>
					<p style="color: #A5A5A5; text-align: justify;">
						<%=person.getBiography()%>
					</p>
					<% } %>

				</td>
			</tr>
		</table>
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

</body>

</html>
