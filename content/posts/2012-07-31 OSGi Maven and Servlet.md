---
title: OSGi Maven and Servlet
date: 2012-07-31
author: Vinicius Isola
tags: java, osgi, maven, servlet
---
I tried a few times before to start developing using OSGi but never had a chance to work with it in the real life so it's hard to get all the concepts to stick in my head. This post is my way to change that, meaning that I'm trying to learn OSGi deeper and start getting things done using this platform.

The first thing I wanted to do is to have a good experience with tooling and get Maven to work for me, not against me. This post is showing a simple example on how to configure Maven to generate an OSGi bundle and how to use Declarative Services and Apache Felix Http Whiteboard to quickly deploy a simple servlet.

The code for this post is in my [git repository](https://github.com/visola/bearprogrammer-examples) under the project `osgi-maven-example`.

<!-- more -->

## Project

There are only three files in this project:

- `pom.xml` - Maven project descriptor. Here is where the bundle plugin is added and where all OSGi configuration should go, because Maven completely replaces whatever `MANIFEST.MF` you put in your workspace by default
- `src/main/resources/OSGI-INF/SimpleServlet.xml` - Component descriptor. Used by the SCR (Service Component Runtime) to decide when to instantiate and activate your service implementation and some other things
- `SimpleServlet.java` - Hello world servlet implementation

## Web in OSGi

The `SimpleServlet` is just a normal servlet as expected. There are no differences. I added some `println` statements to output when each event happens. It could be used normally in a non-OSGi application.

The OSGi specification provides an HTTP Service that can be used to register servlets and resources. Normally this would require code to get a reference to the service, register the servlet and because of the dynamic nature of the OSGi platform, make sure to unregister the servlet if the service gets unloaded/uninstalled. To avoid that extra hassle, we'll take advantage of the whiteboard implementation bundle provided by the Apache Felix project.

So instead of writing a *web.xml* file that would register the servlet, we need to write a component descriptor that will register the servlet as a provider of the *Servlet* service. The following is the XML file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<component name="simpleServlet">

	<implementation class="com.bearprogrammer.blog.osgi.SimpleServlet"  />

	<property name="alias" value="/hello" />

	<service>
		<provide interface="javax.servlet.Servlet" />
	</service>

</component>
```

This descriptor register the `SimpleServlet` as an implementation that provides the `javax.servlet.Servlet` service.

## Maven configuration

Maven normally ignores your `MANIFEST.MF` file so to get things in you need to ask it to add it for you. But OSGi not only needs things in the manifest but also needs complex definitions like import and export packages. Maven already handles dependencies so it would make sense to have that calculated for you somehow. And that is when the bundle plugin comes to hand.

That plugin not only helps you to generate a well formatted manifest but also calculates the dependencies and import package declarations using the class import statements from the Java code. If you programmed using OSGi before, you know that it is complicated to manage dependencies and the list can get pretty long pretty fast.

To get the plugin to work, you need to add the following in your `pom.xml`:

```xml
...
<build>
	<plugins>
		<plugin>
			<groupId>org.apache.felix</groupId>
			<artifactId>maven-bundle-plugin</artifactId>
			<extensions>true</extensions>
			<executions>
				<execution>
					<phase>package</phase>
					<goals><goal>bundle</goal></goals>
				</execution>
			</executions>
			<configuration>
				<instructions>
					<Service-Component>
						OSGI-INF/SimpleServlet.xml
					</Service-Component>
				</instructions>
			</configuration>
		</plugin>
	</plugins>
</build>
...
```

There are two important parts here. The first one is that I attached the plugin to the `package` phase, that way, instead of building a simple JAR file, Maven build will generate an OSGi bundle. The second one is that I added the `Service-Component` tag inside the *instructions* to the plugin put inside the manifest file. This is how you get things in. And if you look into the generated jar file, you'll notice that both, Export and Import packages were generated for you. It also generated information about the bundle using information from the pom.xml. Everything else is just plain old Maven stuff. Dependencies, group and artifact id and version, etc.

## Deploying

There are many OSGi implementations available, the two most widely used are Eclipse Equinox and Apache Felix, both open sources. In this case I used Felix because I still don't have a good grip on Equinox.

Felix is very straighforward and you just need to download it and unzip it. Run Maven build to generate the package,  drop the JAR file in the `bundle` directory inside Felix's home folder. You'll also need the HTTP service bundles and the SCR and its dependencies. You can find all of them in the [Apache Felix Downloads page](http://felix.apache.org/site/downloads.cgi). Here is a list of all bundles that I used:

```
org.apache.felix.bundlerepository-1.6.6.jar  -- already there
org.apache.felix.configadmin-1.4.0.jar       -- SCR dependency
org.apache.felix.gogo.command-0.12.0.jar     -- already there
org.apache.felix.gogo.runtime-0.10.0.jar     -- already there
org.apache.felix.gogo.shell-0.10.0.jar       -- already there
org.apache.felix.http.jetty-2.2.0.jar        -- HTTP Service implementation using Jetty
org.apache.felix.http.base-2.2.0.jar         -- HTTP Service API
org.apache.felix.http.whiteboard-2.2.0.jar   -- HTTP Servlet Whiteboard
org.apache.felix.scr-1.6.0.jar               -- SCR (Service Component Runtime)
osgi-maven-example-0.0.1-SNAPSHOT.jar        -- My bundle
```

Then you just need to run it using the command:

```shell
java -jar bin/felix.jar
```

You'll see the following output:

```
[INFO] Http service whiteboard started
Servlet instantiated.
Servlet initialized.
____________________________
Welcome to Apache Felix Gogo

g!
```

This shows that the servlet was instantiated and initialized correctly. Now you can go to http://localhost:8080/hello and see your servlet response.
