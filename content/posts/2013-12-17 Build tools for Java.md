---
date: 2013-12-17
title: Build tools for Java
author: Vinicius Isola
tags: build, tools, java, ant, maven, gradle
---
More than a year ago [I wrote a post about](/2012/06/03/Beginning with Maven and M2.html "Beginning with Maven and M2") how I started to use Maven to build my Java applications and how much I loved it! Things changed a lot since then and I, like many others, am moving my projects to [Gradle](http://www.gradle.org). In this post - and a few more to come - I'll be talking about build tools for Java and make some comparisons and explain why I moved to Gradle.

This content started from a recent presentation that I gave at work about build tools. The idea was to make a comparison between the three most widespread build tools for Java: [Ant](http://ant.apache.org/), [Maven](http://maven.apache.org/) and Gradle. I thought it would be cool to have a project - simple but with some complex dependencies - built using all three of them. With that it would be easy to compare, apples to apples, how each one works and what are the advantages and disadvantages of each one.

<!-- more -->

The code can be found in my [github repository](https://github.com/visola/bearprogrammer-examples/tree/master/build-tools).

## History

From what I know, Ant was one of the first build tools for Java. It came from one of the developers of Tomcat that wanted a tool to help them build it. After that it became a project from Apache and many companies adopted it because it was really easy to use and understand.

After some years building with Ant it became clear that almost every project followed similar folder structure and used similar dependencies. Maven was born with the idea that you shouldn't need to tell your build tool every little detail about your project. The idea was that somethings could be assumed to be true, for example:

- If you have a source folder, you want it to be compiled
- If you have a test folder, you want it to be compiled and run
- If you are building a WAR, you want your dependencies inside the final artifact

Maven was a major improvement over Ant since you could easily create and build new projects using tens of lines instead of the hundreds of lines an Ant build file would require. The problem with Maven was it's flexibility. Maven is great to do things that everybody does, but when it comes to do specific things for your projects (like using home brew integration and deployment tools) you either end up writing your own plugins or moving on to a mixed build (Maven + some scripting language). Because of that it grew over the 90% of the projects that would benefit from its simplicity, but the flexibility problem is what kept many on the *good ol'* Ant. After the creation of Ivy in 2004 (dependency management for Ant) there were mostly no reason to move to Maven. For those that had a working build the question that they were asking was: Why loose flexibility and not gain anything?

Then, Gradle was born. Started in 2009 but it really boomed in 2012 with a more stable and faster Groovy. Gradle was designed to be flexible, it has all the power of a scripting language (Groovy) combined with the conventions and dependency management system that you prefer (it supports Maven, Ivy and anything else that you could think of).

## The Project

The project that I used for this comparison is relatively simple. It's a command line application that has three Java classes in the source directory, one unit test to make sure that everything is working and some configuration files from which the logging configuration requires input from the build system. This application requires Hibernate, Spring Framework, Spring Data JPA, SLF4J, Logback and JUnit. 4 levels of dependencies: compilation, runtime, test compilation and test runtime. It's a straightforward application setup and it's definitely in those 90% that Maven was built for.

What I wanted from the build:

1. Fetch dependencies automatically
1. Process resources
1. Compile Java classes
1. Process test resources
1. Compile Unit Test classes
1. Run unit tests
1. Calculate unit test code coverage
1. Run the application
1. Generate a zip with all dependencies and scripts that could be used to run the application

If you ever used Gradle you'll feel like I got these requirements from what it gives for free. It wasn't exactly that but it was very close to it! This is the basics that most companies expect their automated builds to do (that's probably why Gradle gives all that *for free* out-of-the-box). Click a button and you have a tested product ready to be deployed.

I am missing integration tests for now. But I want to post something about that in a not so distant future.

## One word about dependencies

Dependency management in Java has become a complex problem to solve. Since it's very easy to drop a `.jar` file into a directory and start using classes from it, most projects nowadays start from importing some basic libraries like the Apache Commons or Hibernate. That's the easy part, the problem starts when you include other libraries' dependencies. That's because sometimes you end up having a common dependency between two (or more) of your dependencies and each one depends on a different version of it. A simple example is better to understand this problem:

- `Library A` version 2.0 depends on `Library C` version 1.2.3
- `Library B` version 1.6 depends on `Library C` version 1.1

Now, your project has version conflict on `Library C`. There are many ways to solve this problem, depending on each specific case. Sometimes it's possible to upgrade (or downgrade) Library A (or B) to some other version that uses the same version of Library C as B (or A). Sometimes C will be backward compatible so it's better to go with the newer version and get all the security and bug fixes.

This &lt;sarcasm&gt;beloved&lt;/sarcasm&gt; scenario is know as [dependency hell](http://en.wikipedia.org/wiki/Dependency_hell) and can be solved with any of the dependency management included with the build tools discussed here. In the code I setup for this example I don't have any example of it but you can find more information on the web.

The last thing I wanted to mention here is that one of the greatest advantages of using a build tool with dependency management is to have it to download all external dependencies for you. This way you don't have to version control code that's not yours, or to go around the web hunting jar files just to learn that your code doesn't work with the latest version of some library and you have to find an older version of it. I've been there and believe me, it's not pretty.

## This is all folks!

For the first post of this series, this is all. You already have the code to start but I'll be working on a post for each one of the builds I created so stay tuned.
