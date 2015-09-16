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
<title>Movie Details</title>
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

	<%
		UserManager userManager = new UserManager();
			MovieManager movieManager = new MovieManager();
			MediaManager mediaManager = new MediaManager();
			StatusManager statusManager = new StatusManager();
			GenreManager genreManager = new GenreManager();
			MediaGenreManager mediaGenreManager = new MediaGenreManager();
			CompanyManager companyManager = new CompanyManager();
			MediaCompanyManager mediaCompanyManager = new MediaCompanyManager();
			CastManager castManager = new CastManager();
			CrewManager crewManager = new CrewManager();
			CommentManager commentManager = new CommentManager();
			RatingManager ratingManager = new RatingManager();
			UserListManager listManager = new UserListManager();

			MovieAPI api = new MovieAPI();

			String action = request.getParameter("action");
			Integer movieId = Integer.parseInt(request.getParameter("movieId"));
			String comment = request.getParameter("comment");

			Movie movie = api.getMovieByMovieDBId(movieId);
			String email = (String) session.getAttribute("user");

			if ("listing".equals(action)) {
		String list_value = request.getParameter("list");
		User_list userList = new User_list();
		userList.setMedia_id(movie.getId());
		userList.setUser_email(email);
		if (listManager.readListByUserandMedia(email, movie.getId()).getId() == null) {
			if (!"none".equals(list_value)) {
				userList.setList_value(list_value);
				listManager.createUserList(userList);
			}

		} else {
			if("none".equals(list_value)){
				User_list list = listManager.readListByUserandMedia(email, movie.getId());
				listManager.deleteList(list.getId());
			}
			else{
				User_list list = listManager.readListByUserandMedia(email, movie.getId());
				list.setList_value(list_value);
				listManager.updateList(list);
			}
		}
		action = "display";
			}

			if ("rating".equals(action)) {
		Integer user_rating = Integer.parseInt(request
				.getParameter("rating"));
		if (email != null) {
			Ratings rate = ratingManager.readRatingsByMediaIdAndUser(
					movie.getId(), email);
			if (rate.getUser_rating() == 0) {
				Ratings rating = new Ratings(null, email, user_rating,
						movie.getId());
				ratingManager.createRating(rating);
			} else {
				rate.setUser_rating(user_rating);
				ratingManager.updateRating(rate);
			}
		}
		action = "display";
			}
			
			if(action.contains("flag")) {
				int commentId = Integer.parseInt(action.split("_")[1]);
				Comments flaggedComment = commentManager.readCommentById(commentId);
				flaggedComment.setComment_flag(flaggedComment.getComment_flag()+1);
				commentManager.updateComment(flaggedComment);
				action = "display";
			}

			if ("create".equals(action)) {
		if (email != null) {
			Comments newComment = new Comments(null, comment,
					new Date(), 0, email, movie.getId());
			commentManager.createComment(newComment);
			action = "display";
		} else {
			action = "display";
		}
			}

			if ("display".equals(action)) {

		Status status = statusManager.readStatusById(movie
				.getStatus_id());
		List<Genre> allGenres = genreManager.readAllGenre();
		List<Media_Genre> mediaGenres = mediaGenreManager
				.readMediaGenreByMediaId(movie.getId());
		List<Company> allCompanies = companyManager.readAllCompany();
		List<Media_Company> media_Companies = mediaCompanyManager
				.readMediaCompanyByMediaId(movie.getId());
		List<Cast> allCast = castManager.readCastByMediaId(movie
				.getId());
		List<Crew> allCrew = crewManager.readCrewByMediaId(movie
				.getId());
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

	<header id="myCarousel" class="carousel slide">
		<!-- <ol class="carousel-indicators">
            <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
        </ol> -->

		<div class="carousel-inner">
			<div class="item active">
				<!-- Set the first background image using inline CSS below. -->
				<div class="fill"
					style="background-image: url('http://image.tmdb.org/t/p/w780<%=movie.getBackdrop_path()%>'); background-size: contain; background-repeat: no-repeat;"></div>
				<div class="carousel-caption">
					<h1 style="color: white; text-shadow: 2px 2px 4px #000000;"><%=movie.getTitle()%></h1>
					<h3 style="color: white; text-shadow: 2px 2px 4px #000000;"><%=movie.getTagline()%></h3>
				</div>
			</div>
		</div>

	</header>

	<br>

	<div class="container">

		<table class="table">

			<tr>
				<td width="50%" align="center"><img
					src='http://image.tmdb.org/t/p/w185<%=movie.getPoster_path()%>'
					width="300" height="400" class="img-rounded"></td>
				<td width="50%">
					<h4 style="color: white;">Overview</h4>
					<p style="color: #A5A5A5; text-align: justify;">
						<%=movie.getOverview()%>
					</p>

					<h4 style="color: white;">Release Date</h4>
					<p style="color: #A5A5A5;">
						<%=Utils.dateToString(movie.getRelease_date())%>
					</p>

					<h4 style="color: white;">Status</h4>
					<p style="color: #A5A5A5;">
						<%=status.getStatus()%>
					</p>

					<h4 style="color: white;">Genres</h4>
					<p style="color: #A5A5A5;">
						<%
							for (int i = 0; i < mediaGenres.size(); i++) {

													for (int j = 0; j < allGenres.size(); j++) {

														if (allGenres.get(j).getId() == mediaGenres.get(i)
																.getGenre_id()) {
						%>
							<%=allGenres.get(j).getGenre()%> <br>
						<%
							}
													}
												}
						%>
					</p>

					<h4 style="color: white;">Production Companies</h4>
					<p style="color: #A5A5A5;">
						<%
							for (int i = 0; i < media_Companies.size(); i++) {

													for (int j = 0; j < allCompanies.size(); j++) {

														if (allCompanies.get(j).getId() == media_Companies.get(
																i).getId()) {
						%>
						<a
							href="http://localhost:8080/CouchFlix/company.jsp?companyId=<%=allCompanies.get(j).getId()%>"><%=allCompanies.get(j).getName()%></a>
						<br>
						<%
							}
													}
												}
						%>
					</p>
					<p style="color: white;">
						Overall Rating <input type="number" name="rating"
							value="<%=ratingManager.averageRating(movie.getId())%>"
							class="rating" data-size="sm">
					</p>
				</td>
			</tr>

			<tr>
				<td align="center"><p style="color: white;">User
						Ratings:(Please login to rate)</p>
					<form action="movie.jsp" class="">
						<input type="number" name="rating"
							value="<%=ratingManager.readRatingsByMediaIdAndUser(
						movie.getId(), email).getUser_rating()%>"
							class="rating" data-step="1" data-size="sm"> <input
							type="hidden" name="movieId" value="<%=movieId%>" />
						<%
							if (email != null) {
						%>
						<button class="btn btn-primary" type="submit" name="action"
							value="rating" align="center">Rate</button>
						<%
							}
						%>
					</form></td>
				<td align="center">
					<form action="movie.jsp">
						<p style="color: white;">
							Add to Watched list <input name="list" type="radio"
								value="watched" class="">
						</p>
						<p style="color: white;">
							Add to Wish list <input name="list" type="radio" value="wish"
								class="">
						</p>
						<p style="color: white;">
							None <input name="list" type="radio" value="none" class="">
						</p>
						<input type="hidden" name="movieId" value="<%=movieId%>" />
						<%
							if (email != null) {
						%>
						<button class="btn btn-primary" type="submit" name="action"
							value="listing" align="center">Submit</button>
						<%
							}
						%>
					</form>
				</td>
			</tr>

		</table>

		<table class="table">
			<tr>
				<td valign="top" align="center" width="50%">

					<h4 style="color: white;">Cast</h4> <%
 	for (Cast cast : allCast) {
 %>

					<table class="table">
						<tr>
							<td width="100">
								<%
									if (cast.getPoster_path() == null) {
								%> <a
								href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=cast.getPerson_id()%>">
									<img src='images/unknown-person.png' width="75" height="100"
									class="img-rounded">
							</a> <%
 	} else {
 %> <a
								href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=cast.getPerson_id()%>">
									<img
									src='http://image.tmdb.org/t/p/w185<%=cast.getPoster_path()%>'
									width="75" height="100" class="img-rounded">
							</a> <%
 	}
 %>
							</td>
							<td>
								<p>
									<a
										href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=cast.getPerson_id()%>">
										<p style="color: black;"><%=cast.getName()%></p>
									</a>
								<p style="color: #BBBBBB;">
									<%=cast.getCharacter()%>
								</p>
							</td>
						</tr>
					</table> <%
 	}
 %>

				</td>

				<td valign="top" align="center" width="50%">

					<h4 style="color: white;">Crew</h4> <%
 	for (Crew crew : allCrew) {
 %>

					<table class="table">
						<tr>
							<td width="100">
								<%
									if (crew.getPoster_path() == null) {
								%> <a
								href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=crew.getPerson_id()%>">
									<img src='images/unknown-person.png' width="75" height="100"
									class="img-rounded">
							</a> <%
 	} else {
 %> <a
								href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=crew.getPerson_id()%>">
									<img
									src='http://image.tmdb.org/t/p/w185<%=crew.getPoster_path()%>'
									width="75" height="100" class="img-rounded">
							</a> <%
 	}
 %>
							</td>
							<td>
								<p>
									<a
										href="http://localhost:8080/CouchFlix/person.jsp?personId=<%=crew.getPerson_id()%>">
										<p style="color: black;"><%=crew.getName()%></p>
									</a>
								<p style="color: #BBBBBB;">
									<%=crew.getDepartment()%>
								</p>
								<p style="color: #A5A5A5;">
									<%=crew.getJob()%>
								</p>
							</td>
						</tr>
					</table> <%
 	}
 %>

				</td>
			</tr>
		</table>


	</div>

	<div class="container">
		<%
			//Movie movie1 = movieManager.readMovieByMovieDBId(movieId);
				List<Comments> comments = commentManager
						.readCommentsByMediaId(movie.getId());
		%>
		<form action="movie.jsp">
			<table class="table table-striped">
				<tr>
					<th>Comment(Log in to comment)</th>
					<th></th>
					<th></th>
				</tr>
				<%
					if (email != null) {
				%>
				<tr>
					<td width="100%"><input name="comment" class="form-control" />
					<td>
						<button class="btn btn-primary pull-right" type="submit"
							name="action" value="create">Comment</button>
					</td>
				</tr>
				<%
					}
				%>

				<%
					for (Comments comm : comments) {
									User_info user = userManager.readUserByEmail(comm
											.getUser_email());
				%>
				<tr BGCOLOR="#00ff00">
					<% if(comm.getComment_flag()>0) { %>
					<td>Comment Flagged.</td>
					<% } else { %>
					<td><%=comm.getUser_comment()%></td>
					<% } %>
					<td><%=comm.getUser_time()%></td>
					<td><%=user.getFirstName()%> <%=user.getLastName()%></td>
					<td><button class="btn btn-danger pull-right" type="submit"
							name="action" value="flag_<%=comm.getId()%>">Flag</button></td>
				</tr>
				<%
					}
				%>
			</table>
			<input type="hidden" name="movieId" value="<%=movieId%>" />
		</form>
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
		}
	%>

</body>

</html>
