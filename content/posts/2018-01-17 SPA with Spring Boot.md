---
date: 2018-01-17
title: SPA with Spring Boot
author: Vinicius Isola
tags: [spring, spring boot, single page application, spa]
---
Single page applications are becoming more and more common these days. If you work with Spring Boot and want to build your frontend using this architecture, you have two options: build the frontend on a separate repository and serve it using some HTTP server or serve your files from your Java application.

This post explains the basic configuration needed so that you can manage routing on the frontend and still serve your static files from your Java/Spring application.

<!-- more -->

The sample code for this application lives [here](https://github.com/visola/bearprogrammer-examples/tree/master/spa-with-spring-boot).

## API Base

The first step you need to do is decide where your APIs will live and settle on a base path for them. I normally just use `api/v1` as the base path but use a variable in `application.yml` to get it.

Inside `src/main/resources/applcation.yml` I just set:

```yml
api.base.path: /api/v1
```

And then, in my controllers, I always use a relative path passing in that variable as the base:

```
@RequestMapping("${api.base.path}/messages")
@RestController
public class HelloController {

    @ResponseBody
    @RequestMapping("/{name}")
    public HelloVO getMessage(@PathVariable String name) {
        return new HelloVO(name);
    }

}
```

## Always redirect to `index.html`

In a single page application, routing is normally handled by code in the frontend. If you're using Backbone, React, Angular, all provide some kind of routing framework and they all expect that the main javascript entry point will be loaded, doesn't matter what route you load your app from.

Because of that, when your application is loaded from `/` or from `/some/path`, you need to load your `index.html`, call the router and decide what page the user should see. To make that work in Spring, you need to add a `ResourceResolver` that will always load the root page as long as you're not asking for a resource (stylesheet, image, font, etc.) or making an API call.

This is how that code looks like (in `src/main/java/org/visola/springbootspa/config/WebConfiguration.java`):

```java
@Configuration
public class WebConfiguration extends WebMvcConfigurerAdapter {
  ...

  @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
      // All resources go to where they should go
      registry
        .addResourceHandler("/**/*.css", "/**/*.html", "/**/*.js", "/**/*.jsx", "/**/*.png", "/**/*.ttf", "/**/*.woff", "/**/*.woff2")
        .setCachePeriod(0)
        .addResourceLocations("classpath:/static/");

      registry.addResourceHandler("/", "/**")
        .setCachePeriod(0)
        .addResourceLocations("classpath:/static/index.html")
        .resourceChain(true)
        .addResolver(new PathResourceResolver() {
          @Override
          protected Resource getResource(String resourcePath, Resource location) throws IOException {
            if (resourcePath.startsWith(baseApiPath) || resourcePath.startsWith(baseApiPath.substring(1))) {
              return null;
            }

            return location.exists() && location.isReadable() ? location : null;
          }
        });
    }

}
```

There are two important things happening here:

1. The first resource handler will match any font, stylesheet or image in the coming from the `static` folder from the classpath. Those we definitely don't want to redirect to `index.html`
1. The second resource handler matches everything else that is not mapped to a controller or something else using `@RequestMapping`. This resource handler will check if the path was an API call and it fails if it was (because we want to return 404 and not 200 with `index.html` as the body for API path typos).

One detail here is that I'm setting the cache period to zero, which means that it will never cache nor send cache headers for these resources. If you're using caching and generating some type of bundle version like using the `chunkhash` from [Webpack caching](https://webpack.js.org/guides/caching/), then you should set that up to a very long time for your first handler, probably `Integer.MAX_VALUE`. That way your resources will be cached forever and the browser will never reload them, but it will automatically pick a new version from `index.html`.
