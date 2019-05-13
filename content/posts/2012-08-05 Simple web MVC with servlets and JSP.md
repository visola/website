---
date: 2012-08-05
title: Simple web MVC with servlets and JSP
author: Vinicius Isola
tags: [web, mvc, java, servlets, jsp]
---
A while ago a friend of mine that is starting with web development in Java asked me what is the best way to write a web application in Java if you can't understand a framework like Spring or JSF or if you just don't want to use them? Well, this project is a simple example on how to get a MVC working with a database using a singleton that will generate a data source for you.

As usual the code is in my [github repository](https://github.com/visola/) under `simple-web-mvc`.

<!-- more -->

## MVC with Servlets and JSPs

Scriptles were very popular when JSPs first arrived and because of the easy to use and fast development model, they were used to do everything. MVC using JSPs is possible but scriptlets make your pages very hard to read and when you start mixing Javascript, CSS, HTML and Java all in one file it's easy to get to the thousand lines, meaning that the output will normally be a long HTML file that will take a lot of time to load, render and execute the javascript code - not to mention the readability problem.

To avoid that and separate Java code from the HTML normally a servlet is used. The servlet do all the heavy lifting - load model data, process and modify it and then save it back - and then add it to the request as attributes and dispatch it to a JSP file that will use [expression language](http://docs.oracle.com/javaee/1.4/tutorial/doc/JSPIntro7.html) and taglibs to generate the HTML code that will be rendered on the client side.

Some people even argue that that makes it easy enough for designers to generate the HTML in those fancy design tools like Dreamweaver or Illustrator but I really don't like automatically generated HTML because the tools still aren't good enough. And designers aren't programmers, most of them don't like to do be responsible for the HTML and they aren't paid to do that - some people think that is part of their job. When I work with a designer, I prefer to get a JPEG file or a PNG with all the specification and write my own HTML/CSS/Javascript.

But back to the MVC stuff. The following is an illustration that shows how the request/response flow is handled in this project. After the illustration is a detailed step-by-step description of each number in the image:

![Simple web MVC architecture](/img/blog/simple-web-mvc-01.png)

1. Tomcat receives the request and passes it to the `BaseServlet`, that is an abstract servlet class that all servlets should extend to get basic request/response functionality
1. `BaseServlet` calls the `execute` method of the subclass
1. The execute method is where the real action happens and all exceptions should not be handled (will be explained later). Here is where the servlet access the data access layer
1. Data access layer handles all conversation with the database and passes only objects back to the servlet
1. After loading/updating the data subclasses of `BaseServlet` only need to return a string that says how the response should be handled. The dispatch method will handle the forwarding to a JSP or a redirect instruction back to the browser. If an exception is thrown by the `execute` method it will be handled and redirected to the `error.jsp` page

This application is using the new (not so new anymore) version 3 of the servlet specification so we don't need to declare and map the servlets in the `web.xml` file. We can use annotations like the following example from the `SaveContactServlet`:

```java
@WebServlet("/contact/save.html")
public class SaveContactServlet extends BaseServlet {
  ...
}
```

One thing that I like to do - that I learned when I started working with the Spring Framework - is to put the JSP files in the `/WEB-INF` folder, so that access to them is controlled through servlet.

## Data Access

Now that we have the C(ontroller) and V(iew) we need the M(odel). To make the application as simple as possible, only one entity will be used: Contact. So let's build a contact manager where you can store many contacts with name and email.

To access the data we'll use a [Data Access Object](http://en.wikipedia.org/wiki/Data_access_object). Normally DAOs are interfaces that have an implementation for a specific data storage type. In this case, to keep things simple I'm using a class that access a [Singleton](http://en.wikipedia.org/wiki/Singleton_pattern) that creates connections from a [Commons DBCP](http://commons.apache.org/dbcp/) `DataSource`.

The `Database` class is a singleton that creates a connection pool with a H2 in memory database. This connection pool will be shared by all application and the only way to get a connection in this application is to follow the pattern:

```java
Connection conn = null;
try {
	conn = Database.getConnection();

	// Use database connection here

} catch (SQLException sqle) {
	// Handle exception or throw a new one here
} finally {
	// Don't forget to close the connection
	// This will return the connection to the pool
	Database.closeConnection(conn);
}
```

To separate the data access layer better, instead of throwing a <em>SQLException</em> we encapsulate any exception in a `DataAccessException` that should be handled by the upper layers (controllers).

Normally we have one *Data Access Object* for each model class and in this case we have only one model class that is `Contact` so we only need the `ContactDAO` that has only three methods:

- `findAll()` - that will return all contacts in the database
- `findOne(Integer)` - that will search for a contact in the database and throws an exception if it doesn't find any
- `save(Contact)` - that saves a new contact if it doesn't exist or update a new one if already in the database

## Servlets

The application contains one base servlet that, as explained above, handles all the dispatching and error handling. It also contains three sub-classes of the base servlet that are responsible for the actual feature that is contact handling: `AllContactsServlet`, `EditContactServlet` and `SaveContactServlet`.

The first two servlets has a JSP file for each. The `AllContactsServlet` loads all contacts from the database and the `EditContactServlet` is used to add a new contact or to edit an existing one and both actions use the same JSP file.

The `SaveContactServlet` is a bit different because it doesn't have a JSP file. It is the action that the form in `contact/edit.jsp` page points to. It is responsible to save the contact and it uses the [Post/Redirect/Get](http://en.wikipedia.org/wiki/Post/Redirect/Get) pattern to avoid duplicating the record in case the user refreshes the page.

## One last detail

There's a listener in the application: `CreateDatabaseListener`. This listener exists only because I didn't want to use a database server or file, so I need to recreate the database every time the application loads because it is a in memory database and it will be destroyed as soon as the application finishes.

## Result

The following is a screenshot of the all contacts page:

![Screenshot 1](/img/blog/simple-web-mvc-all-contacts.png)

And the next one is the add contact page:

![Screenshot 2](/img/blog/simple-web-mvc-add-contact.png)
