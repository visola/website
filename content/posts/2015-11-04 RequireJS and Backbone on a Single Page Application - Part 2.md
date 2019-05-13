---
date: 2015-11-04T22:00:00-04:00
title: RequireJS and Backbone on a Single Page Application - Part 2
author: Vinicius Isola
tags: [javascript, backbone, requirejs]
---
A Backbone app has three main pieces: routes, models/collections and views. In this part of the two posts I'm going to explain how to setup and use Backbone in a single page application while separating your code in a way that it will be simple to maintain and add new features.

The first part of this tutorial lives [here](/2015/11/04/requirejs-and-backbone-on-a-single-page-application-part-1). The code for this post lives in my Blog's GitHub repository under [require-js-backbone](https://github.com/visola/bearprogrammer-examples/tree/master/require-js-backbone).

<!-- more -->

## Setting up Backbone Router

For single page applications it's important to use push state instead of reloading the whole page again like traditional apps do. The real advantage of SPAs is that you only load the pieces you need for the user to do what s/he wants in a specific moment. The result is that the app looks and feels faster and more responsive because not only there's less things to load, but also the user can still interact with the app while it's loading.

Using push state to handle URLs would be a considerable amount of code. Luckily Backbone has that built in so we don't have to deal with it. The only thing we need to do is setup a [Router](http://backbonejs.org/#Router) to handle the URLs. There are two important parts here: setting up the routes and handling them.

### Routes as App State

A route is a state of your app. For the user, it represents something that s/he is seeing, doing or going to do. Good SPAs have a route for each state that it's possible to be in. This means that the user can bookmark a URL and come back to it later and s/he will see exactly what was there before bookmarking it, unless the data has changed.

When you create an instance of `Router`, Backbone automatically register it's routes for you - you don't have to pass your router any where. To start your app, you only need do call `Backbone.history.start`. Backbone will then read the actual state (from the url) and execute the route for it (if there's one). That means that you can start your app from any registered route and everything will magically be taken care of for you.

Since the router is the main entry point for your app, you need to call it from `main.js`. That means that besides configuring `require` you will also load the router and start everything. This is the piece of code that does that:

```javascript
require(['backbone', 'router'], function (Backbone, router) {
  Backbone.history.start({pushState: true});
});
```

The options object that we're passing to Backbone tells it to use push state. Backbone could work without it, which would make it work with hashes instead of actual states. Hashes are also bookmarkable states and work with the forward/back buttons of the browser. But it may cause problems depending on the backend you're using. For this example, Express seems to handle it pretty well, but I haven't tested it extensively.

### Setting up your routes

Inside the router you'll have:

- route mappings
- common code that takes care of attaching the rendered view to the page
- methods that get called when the routes are activated

Setting up a route is telling Backbone that a path (URL part) maps to a function in your router. This function will get called by Backbone automatically when the user hits that path.

In that function what you have to do is load, prepare, render and attach the view to the DOM. This is the code for the router:

```javascript
define(["backbone", "jquery"],
  function (Backbone, $) {
    function getContentElement() {
      return $('#content');
    };

    function render(view) {
      view.render();
      getContentElement().html(view.$el.get(0));
    };

    var Router = Backbone.Router.extend({
      routes : {
        "(/)" : "contacts",
        "contacts(/)" : "contacts",
        "contacts/:id(/)" : "editContact"
      },

      contacts : function () {
        require(['view/contact/List'], function (ListContactsView) {
          render(new ListContactsView());
        });
      },

      editContact: function (id) {
        require(['view/contact/Edit', 'model/Contact'], function (EditContactView, Contact) {
          var contact = new Contact();
          if (id != 'new') {
            contact.set('id', id);
          }
          render(new EditContactView({model:contact}));
        });
      }
    });

    return new Router();
  }
);
```

Line 14 is where the route root ('/') gets mapped to the `contacts` function, which is declared on line 19. So as soon as someone gets to your page, Backbone will call that method. What that method does is request the `view/contact/List` module (line 20) and create a new instance of that module (line 21) passing it to the `render` method (declared on line 7).

The `render` method assumes that it's receiving a view instance so it calls render on that object and then attaches its [element](http://backbonejs.org/#View-$el) to the page's content element. This is the common code that takes care of attaching the view to the DOM.

It also has a second mapping to the same function. In case the home page changes to something different links to the contact list would still work.

And a third route mapping the add/edit contact functionality. It can edit contacts when the path is like `/contacts/1` or `/contacts/2`, where it's given the ID of the contact to edit. Or it can go to an add contact mode if the path is `/contacts/new`.

## Creating a View

A view in Backbone is a class that knows how to generate HTML and deal with user actions. It has an `$el` property that is a jQuery element that, after render is called, should have the DOM that the view is responsible for. Each view is responsible for a part of the app DOM. It can be as small as a row in a table or as big as the whole page, depending on what makes more sense.

In an app that uses RequireJS, the view is a module and goes into its own file inside the `js/view` directory.

Like every RequireJS module it starts with a call to the define function. Whatever is returned by the callback function will be stored as the module that was defined. That means that the contacts view definition needs to return a `Backbone.View` class (or a subclass of it). The following is the code inside `js/view/contact/List.js` file:

```javascript
define(['backbone', 'router', 'tpl!template/contact/list.html', 'collection/Contacts'],
    function (Backbone, router, ListContactsTemplate, Contacts) {

  return Backbone.View.extend({
    template: ListContactsTemplate,
    events: {
      'click a': 'routeLink'
    },
    initialize: function () {
      var _this = <span class="hiddenGrammarError" pre="var ">this;
      this</span>.loading = true;
      this.collection = new Contacts();
      this.collection.fetch().then(function () {
        _this.loading = false;
        _this.render();
      });
    },
    render: function () {
      if (this.loading) {
        this.$el.html("<p>Loading...</p>");
      } else {
        this.$el.html(this.template({collection:this.collection}));
      }
    },
    routeLink: function (e) {
      e.preventDefault();
      router.navigate(e.target.getAttribute('href'), {trigger:true});
    }
  });

});
```

There are two major pieces inside a `Backbone.View`: events mapping and the render method.

Events mapping map user actions to methods inside the view. In this case we're mapping clicks on any link (`click a`) to the `routeLink` method. That method only gets the `href` attribute on the clicked link and uses the router to navigate to it, setting the application to a new state. It also prevents the link default behavior, which would be to actually navigate to that URL, breaking the push state.

The `render` method, the second important thing inside a view, has to generate the HTML and put it inside of `$el`. That means that after render finishes `$el` should be ready to be appended to the page, wherever it needs to go. jQuery and Backbone will do the magic of attaching event handlers for the event mappings setup for the view.

## Templates with TPL and Underscore

Did you notice the `tpl!` in front of the template file? It also has an extension since the default extension for files loaded by RequiredJS is `js`. The template for this view (the HTML that will generate the DOM) is loaded using the [tpl](https://github.com/dawsontoth/requirejs-tpl) plugin. That means that it will load the text and preprocess before handing it to the callback function. By the time the callback function gets called, `HomeTemplate` is a function that can be called to generate text (in this case HTML), which is what's done in the `render` method, on line 22. Also notice that we pass the collection to the template, which will be used to generate the list of contacts. The following is the part of the template that uses the collection to generate rows in the contacts table:

```html
...
<% for (var i = 0; i < collection.length; i++) { %>
  <tr>
    <td>
        <a href="/contacts/<%= collection.at(i).id %>">
          <%= collection.at(i).get('firstName') %>
        </a>
    </td>
    <td><%= collection.at(i).get('lastName') %></td>
  </tr>
<% } %>
...
```

This code is not simply HTML. You can see some `&lt;%...%&gt;` and `&lt;%=...%&gt;`. These are expressions that will be processed using [Underscore Templates](http://underscorejs.org/#template).

## Creating your models and collections

In Backbone your model layer is set using two types of classes: models and collections.

A model represents an instance of something in your application. You can execute CRUD operations on it and update your app when they change. As everything else in a RequireJS app, each model is a module and goes inside their own file. The following is the code for our Contact model:

```javascript
define(['backbone'], function (Backbone) {
  return Backbone.Model.extend({
    urlRoot : '/api/v1/contacts'
  });
});
```

There isn't much to it. It's just a [urlRoot](http://backbonejs.org/#Model-urlRoot) that will be used to build URLs for each of the CRUD operations. If you have a REST backbend that generates JSON responses, you don't need anything else. Backbone gives you everything for free: save executes a POST or PUT (depending if the model is new or not, has an ID or not), fetch executes a GET and destroy executes a DELETE.

The collection used in the view described in the previous sections has the following code:

```javascript
define(['backbone'], function (Backbone) {
  return Backbone.Collection.extend({
    url: '/api/v1/contacts'
  });
});
```

Almost the same as the model. The only difference is that the collection has a [url](http://backbonejs.org/#Collection-url) property instead of `urlRoot`. Collections don't have an ID so Backbone always use the whole URL to fetch collections. While models are saved independently so ID is appended to the `urlRoot`. What you'll normally do is fetch models from a collection and save them individually.

In this example app there are three places where we use this model and collection. One in the list contacts view, to fetch all contacts and render it, inside the `initialize` method:

```javascript
this.collection.fetch().then(function () {
  _this.loading = false;
  _this.render();
});
```

and two inside the edit contact view, one to load the model as soon as the edit view is initialized, if the model is being edited:

```javascript
this.loading = !this.model.isNew();
if (this.loading) {
  this.model.fetch().then(function () {
    _this.loading = false;
    _this.render();
  });
}
```

and the second one when the user clicks save, the model is saved:

```javascript
this.model.save(data, {wait:true,
  success: function () {
    router.navigate('/contacts', {trigger:true});
  }
});
```

All calls to model/collection CRUD operations follow a pattern where you call the method and do something when the server request completes. When [fetching](http://backbonejs.org/#Collection-fetch) you can use the return of `fetch` as a [promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), chaining to it a call to `then`, which receives a callback that gets executed when the server call returns. It's also a good practice to chain a call to `catch`, which would be called if the server returns an error (non-200 status). When [saving](http://backbonejs.org/#Model-save) you can use the options object being passed in to set a `success` callback function. It's also a good idea to set `wait` to `true` in case some code is depending on events in the model to respond to changes in a more pessimist way.

## Conclusion

Single page applications have many different things to consider comparing to a normal web application. Complex states, files to be loaded, templates to be processed and dependency management. But in general SPAs are a better experience to the end user and with libraries like RequireJS and Backbone, a lot of the burden is taken away from the app developer hands.
