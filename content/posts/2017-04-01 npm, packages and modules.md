---
date: 2017-04-01
title: npm, packages and modules
author: Vinicius Isola
tags: node.js, npm, package, module, javascript, beginner
---
Node.js is a powerful Javascript runtime that can be used to build general purpose applications. npm extends Node.js capabilities with packages built by 3rd parties. These packages provide a variety of functionalities that you might need when building your application.

Let's learn a little bit more about npm is and how it can help us.

<!--
<iframe id="ytplayer" type="text/html" width="640" height="360"
  src="https://www.youtube.com/embed/ln5pM4S2NvU?autoplay=0&origin=https://visola.org"
  frameborder="0"></iframe>
-->

<!-- more -->

## packages and modules

Before diving into npm lets first understand what are packages and modules.

A package is a node.js application described by a `package.json` file that lives somewhere that npm can access and make it available for your application. This _somewhere_ can be a folder in your computer, a local or remote tarball file or a name/version combination that maps to one of the previous and was published to https://npmjs.com. A git url that when cloned results in a folder containing a `package.json` file can also be used.

_npmjs.com_ is npm's public registry. People can make packages available there for others to use. And that's where you'll probably get your packages from.

But what's inside a package? Any Node.js application can live inside a package. That means that full blown applications can be packaged. But the most common thing that people create packages for are modules.

A module is anything that can be loaded with the `require` function, which includes packages that have a `main` field declared in their `package.json`, a javascript file or folders that contain an `index.js` file.

Modules are, in my opinion, the main reason why Node.js community grew so fast in the last few years. npm provides a simple way for you to include 3rd party modules into your application. You just tell npm what packages you want and it will download and make them available to you next time you start your node.js application.

## npm

So what's npm? _npm_ is a command line application that get's installed when you install Node.js. It provides you with a simple way of installing 3rd party modules so that they are available inside your Node.js application.

For a simple example, let's install and use a simple `request` package that's available in the registry.

[request](https://www.npmjs.com/package/request) is a package that contains a module used to make HTTP requests in a simple way. Imagine that you want to download a file from the web in your application. Node.js provides APIs for you to do that, but they're lower level and a bit cumbersome to deal with. That's where `request` comes in.

The first step is to install the module and for that, you just run the `npm install` command passing the name of the module:

```
$ npm install request
/Users/visola/temp
└─┬ request@2.81.0
  ├── aws-sign2@0.6.0
  ├── aws4@1.6.0
...
  │ └── punycode@1.4.1
  ├── tunnel-agent@0.6.0
  └── uuid@3.0.1

npm WARN enoent ENOENT: no such file or directory, open '/.../package.json'
npm WARN temp No description
npm WARN temp No repository field.
npm WARN temp No README data
npm WARN temp No license field.
```

You can see that npm picked a version for you (the latest) and installed that package locally. It created a folder `node_modules` and put the downloaded package in there. You can check that directory and its `package.json` to see what's inside:

```
$ ls -ls node_modules/request/
total 352
136 -rw-r--r--   1 visola  staff  65653 Mar  9 10:55 CHANGELOG.md
 24 -rw-r--r--   1 visola  staff   9140 Nov 18 07:20 LICENSE
 88 -rw-r--r--   1 visola  staff  43747 Mar  9 10:52 README.md
  8 -rwxr-xr-x   1 visola  staff   3993 Nov 18 07:20 index.js
  0 drwxr-xr-x  12 visola  staff    408 Mar 31 17:56 lib
  8 -rw-r--r--   1 visola  staff   4043 Mar 31 17:56 package.json
 88 -rw-r--r--   1 visola  staff  44706 Mar  9 10:52 request.js

 $ cat node_modules/request/package.json
 {
...
   "dependencies": {
     "aws-sign2": "~0.6.0",
     "aws4": "^1.2.1",
     "caseless": "~0.12.0",
     "combined-stream": "~1.0.5",
     "extend": "~3.0.0",
     "forever-agent": "~0.6.1",
     "form-data": "~2.1.1",
     "har-validator": "~4.2.1",
     "hawk": "~3.1.3",
     "http-signature": "~1.1.0",
     "is-typedarray": "~1.0.0",
     "isstream": "~0.1.2",
     "json-stringify-safe": "~5.0.1",
     "mime-types": "~2.1.7",
     "oauth-sign": "~0.8.1",
     "performance-now": "^0.2.0",
     "qs": "~6.4.0",
     "safe-buffer": "^5.0.1",
     "stringstream": "~0.0.4",
     "tough-cookie": "~2.3.0",
     "tunnel-agent": "^0.6.0",
     "uuid": "^3.0.0"
   },
   "description": "Simplified HTTP request client.",
...
   "main": "index.js",
   "name": "request",
...
 }
```

In the `package.json` there're many details that we don't care right now. The two things that're important to notice are the `main` and `dependencies` properties.

As it was explained before, packages with a `main` attribute contain a module. In this case it's the `lib` folder, which you can see contain a `index.js` file (so it's implicitly loaded).

The `dependencies` attribute allow packages to have runtime dependencies. These runtime dependencies are required to run whatever the package contains and npm will automatically download and make available all dependencies that your dependencies have. You can check that the `node_modules` directory has many other directories in it. Those are `request`'s dependencies:

```
$ ls -la node_modules/
total 0
drwxr-xr-x  64 visola  staff  2176 Feb 13 20:24 .
drwxr-xr-x   3 visola  staff   102 Feb 13 20:16 ..
drwxr-xr-x   7 visola  staff   238 Feb 13 20:24 .bin
drwxr-xr-x   6 visola  staff   204 Feb 13 20:24 ansi-regex
drwxr-xr-x   6 visola  staff   204 Feb 13 20:24 ansi-styles
drwxr-xr-x   9 visola  staff   306 Feb 13 20:24 asn1
...
drwxr-xr-x  15 visola  staff   510 Feb 13 20:24 uuid
drwxr-xr-x  13 visola  staff   442 Feb 13 20:24 verror
drwxr-xr-x  11 visola  staff   374 Feb 13 20:24 xtend
```

So let's use our new installed modules. For that, lets create a file called `downloadImage.js` inside the same directory where we installed the `request` package. Add the following content to it:

```javascript
const request = require('request');
const fs = require('fs');

request('https://farm2.staticflickr.com/1706/25031430855_1f4b306d32_k_d.jpg')
  .pipe(fs.createWriteStream('northern_lights.jpg'))
  .on('close', function () {
    console.log("Finished downloading the image.");
  });
```

When you run your script using Node, you can see that the library did all the heavy lifting of "talking HTTP", copy all bytes directly to a file and augumenting the request with helpful events like `close` which notifies when the download is finished.

Here is how it looks when you run the script above:

```
$ node downloadImage.js
Finished downloading the image.
```

And you can see that now you have the image in the current directory:

```
$ ls
downloadImage.js	node_modules		northern_lights.jpg
```

## References

* What is a package? At [npm's documentation](https://docs.npmjs.com/).
