<!DOCTYPE html>
<%@page import="com.couchflix.entity.Comments"%>
<%@page import="java.util.List"%>
<%@page import="com.couchflix.manager.CommentManager"%>
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
	CommentManager commentManager = new CommentManager();
	if(action != null) {
		if(action.contains("unflag")) {
			int commentId = Integer.parseInt(action.split("_")[1]);
			Comments unFlagComment = commentManager.readCommentById(commentId);
			unFlagComment.setComment_flag(0);
			commentManager.updateComment(unFlagComment);
		}
		if(action.contains("delete")) {
			int commentId = Integer.parseInt(action.split("_")[1]);
			commentManager.deleteComment(commentId);
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

	<div class="container" style="padding-top: 70px" align="center">

		<h1 style="color: white;">Comments Manager</h1>

		<form action="commentManager.jsp">
			<table class="table">
				<tr>
					<th>
						<p style="color: white;">Email</p>
					</th>
					<th>
						<p style="color: white;">Comment</p>
					</th>
					<th>
						<p style="color: white;">Timestamp</p>
					</th>
					<th>
						<p style="color: white;">Flag count</p>
					</th>
					<th>
						<p style="color: white;">Unflag</p>
					</th>
					<th>
						<p style="color: white;">Delete</p>
					</th>
				</tr>
				<%
					
									List<Comments> allComments = commentManager.readAllComments();

									for (int i = allComments.size() - 1; i >= 0; i--) {
										if (allComments.get(i).getComment_flag() > 0) {
				%>
				<tr>
					<td>
						<p style="color: white;">
							<%=allComments.get(i).getUser_email()%>
						</p>
					</td>
					<td>
						<p style="color: white;">
							<%=allComments.get(i).getUser_comment()%>
						</p>
					</td>
					<td>
						<p style="color: white;">
							<%=allComments.get(i).getUser_time()%>
						</p>
					</td>
					<td>
						<p style="color: white;">
							<%=allComments.get(i).getComment_flag()%>
						</p>
					<td>
						<button class="btn btn-success" type="submit" name="action"
							value="unflag_<%=allComments.get(i).getId()%>">UnFlag</button>
					</td>
					<td>
						<button class="btn btn-danger" type="submit" name="action"
							value="delete_<%=allComments.get(i).getId()%>">Delete</button>
					</td>
				</tr>
				<%
					}
									}
				%>
			</table>
		</form>

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