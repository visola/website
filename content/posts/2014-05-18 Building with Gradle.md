---
date: 2014-05-18
title: Building with Gradle
author: Vinicius Isola
tags: build, gradle, java
---
Gradle is a build system that was build from the lessons learned from Ant and Maven. Similarly with Ant, where you have a XML namespace to write build scripts, Gradle is a [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) on top of Groovy that helps you write build scripts. But it goes further with many plugins and conventions (like Maven) that make it possible to get a build up and running with just a few lines of Groovy.

A Gradle build starts with a `build.gradle` file. This file contains plugins that you apply to your build, dependencies that your project need to compile, package and run, repositories where your dependencies will be loaded from, plugin configurations and custom tasks. All those are written with a cleverly build model that makes your build scripts readable, maintainable and easy to extend.

In this post I'll cover the gradle build from the three sample projects that I worked on to compare the [three mainstream Java build tools](http://bearprogrammer.com/2013/12/17/build-tools-for-java). The code for this post can be found in my [github repository](https://github.com/visola/bearprogrammer-examples/tree/master/build-tools/sample-gradle).

<!-- more -->

## Tasks

Tasks are executable chunks of work. They can have fancy dependency relationship with other tasks, which means that they can depend, always run before or after or be finalized by other tasks. When you run your Gradle build you call for one or more specific tasks. The dependency tree will be calculated and all tasks needed to execute the requested tasks will be run, one by one until all are executed or one of them fails. The following is an example of running the `test` task in the project in github:

```
$ gradle test
:compileJava
:processResources
:classes
:compileTestJava
:processTestResources
:testClasses
:test

BUILD SUCCESSFUL

Total time: 7.569 secs
```

This sounds a lot like what Ant does the major difference being that Gradle automatically caches the inputs and outputs of all tasks executed and comparing those with previous runs can decide if needs to run a specific task again or not. The following is an example of running the same command again, immediately after the first time:

```
$ gradle test
:compileJava UP-TO-DATE
:processResources UP-TO-DATE
:classes UP-TO-DATE
:compileTestJava UP-TO-DATE
:processTestResources UP-TO-DATE
:testClasses UP-TO-DATE
:test UP-TO-DATE

BUILD SUCCESSFUL

Total time: 3.573 secs
```

You can see that it ran the build in half the time because all the tasks were up-to-date. And that's with a project that has just a few classes. This is a huge time saver in larger projects where a clean build takes several minutes. Running a cached build would take only a small fraction of the total build, focusing only on the changes, making the change cycle faster and more reliable because now developers aren't affraid of re-running a build with unit tests and possibly integration tests.

## Plugins and Conventions

Another major difference between this build and the Ant build is the size of the build scripts. A simple project like this one has 200+ lines of XML in Ant (not counting Ivy XMLs), meanwhile the Gradle build script has only 30 lines. That's less than 6 times less code to maintain. That difference comes from the plugins.

In Gradle you apply plugins to your build and you get many tasks for free. These tasks have conventions that, if you follow them, require zero (or almost zero) configuration. If you don't want to follow them, you can just tell the plugins where your files will be or whatever else you want to be different on and it will run the tasks following the new instructions.

To apply a plugin to your build you just have to add a line like the following:

```groovy
apply plugin : 'java'
```

The [Java plugin](http://www.gradle.org/docs/current/userguide/java_plugin.html) will build your project like a Java project. If you add your code to `src/main/java`, your resources to `src/main/resources` and your tests following the same pattern in the `src/test` directory, it will compile and run your unit tests automatically.

The task dependencies will be created automatically for you and you can just go back to the command line and run `gradle build` to get a `.jar` file in `build/libs` with the name of your project (which, by convention, is the name of the folder your build script is in, `sample-gradle` in this case).

In this project I'm using four plugins:

```groovy
apply plugin : 'application'
apply plugin : 'eclipse'
apply plugin : 'jacoco'
apply plugin : 'java'
```

The application plugin builds a runnable java application for you in a zip file. It generates a shell script for unix systems and a batch file for Windows machines (in Ant those would have to be created by hand and updated or processed during build time with classpath information). That script finds the `java` command, setup environment variables and the classpath for your application to run. The plugin also add all your runtime dependencies in the zip file so that it will "just run".

The application plugin also gives you a task to run your java application with the correct dependencies (compile and process resources). Gradle takes care of running only what's needed:

```
$ gradle run
:compileJava <span style="color:green;">UP-TO-DATE</span>
:processResources <span style="color:green;">UP-TO-DATE</span>
:classes <span style="color:green;">UP-TO-DATE</span>
:run
18:04:12.977 [main] DEBUG c.b.blog.buildtool.Application - Initializing application...
18:04:14.283 [main] DEBUG c.b.blog.buildtool.Application - Application is initialized.
18:04:14.283 [Shutdown Hook] DEBUG c.b.blog.buildtool.Application - Destroying application...
18:04:14.294 [Shutdown Hook] INFO  c.b.blog.buildtool.Application - Good bye!

BUILD SUCCESSFUL

Total time: 5.102 secs
```

The eclipse plugin generates Eclipse configuration files. That means that you don't have to add `.classpath` and `.project` files to your version control system anymore. It also means that you don't have to maintain your classpath and dependencies in two places like you have to do with Ant: in Eclipse (or whatever IDE you're using) and in your build script.

The last plugin I haven't talked about yet is Jacoco. This adds test code coverage measurement. It can generate reports that tells you how thoroughly your tests are testing your code, for this project you can see that I'm not doing a good job (run the command `gradle test jacocoTestReport` and check the report in `build/reports/jacoco/test/html/index.html`):

![Sample Gradle test coverage report](/img/blog/)

For all these four plugins, the only one that needs to be configured is the [Application plugin](http://www.gradle.org/docs/current/userguide/application_plugin.html) where you have to say what's your main class, the class where you Java application starts from:

```groovy
mainClassName = 'com.bearprogrammer.blog.buildtool.Application'
```

Everything else is taken care by conventions.

## References

### Wikipedia

- [Gradle](http://en.wikipedia.org/wiki/Gradle)
- [Domain Specific Language](http://en.wikipedia.org/wiki/Domain-specific_language)

### Gradle User Guide

- [Chapter 7, Java Quickstart](http://www.gradle.org/docs/current/userguide/tutorial_java_projects.html)
- [Chapther 23, Java Plugin](http://www.gradle.org/docs/current/userguide/java_plugin.html)
- <a>Chapter 45, The Application plugin</a>
- [Chapter 55, The Build Lifecycle](http://www.gradle.org/docs/current/userguide/build_lifecycle.html)
