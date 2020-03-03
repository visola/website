---
date: 2017-01-15
title: What is node.js
author: Vinicius Isola
tags: [node.js, javascript, beginner]
---
Node.js is a runtime environment that can be used to build applications using the Javascript language outside the browser. It runs on top of the V8 engine, which is the engine that runs inside the Chromium and Chrome browsers.

Let's learn more details about what all of this means.

<iframe id="ytplayer" type="text/html"
  src="https://www.youtube.com/embed/ln5pM4S2NvU?autoplay=0&origin=https://visola.org"
  frameborder="0"></iframe>

<!-- more -->

## Piece by Piece

V8 is an engine that interpret Javascript code. That means that you give it some Javascript text and it will execute it. And since it's high performance, it will do it really fast in a very efficient way.

Even though V8 can execute Javascript, it doesn't provide you with any APIs to do anything that's really useful, like reading and writing to files, for example. It only knows how to interpret Javascript code according to the ECMAScript standards.

That's where Node.js comes in. Node provides a set of APIs to do all sorts of useful things, including reading and writing from files in the disk. It also provides a runtime environment where you code can run in. This means that you can write a simple Javascript file and ask Node.js to run it.

Node.js is a command line tool, which means you have to run it from the terminal. That's not a big deal because the command is really simple and there's not a big learning curve there, just some extra typing.

The first thing you'll need to do is go to [nodejs.org](nodejs.org), download and install node for your platform. And that's it, you're ready to go.

## Simple application

So let's just see how building a simple application in Node.js works.

Suppose that you want to write an application that reads text from files and print it on the console. The way it will work is that you'll give a filename as the input and the application will just print out all the text on the console.

For this example, we'll be using the following parts of the Node.js API:

* [FileSystem#createReadStream](https://nodejs.org/dist/latest-v6.x/docs/api/fs.html#fs_fs_createreadstream_path_options) - this function creates a stream that reads bytes from a file.
* [Process#argv](https://nodejs.org/dist/latest-v6.x/docs/api/process.html#process_process_argv) - to get the arguments passed in from the command line to our application.
* [Readline#createInterface](https://nodejs.org/dist/latest-v6.x/docs/api/readline.html#readline_readline_createinterface_options) - used to create a readline interface that read byte streams, convert them to characters and emit an event for each line in the file.
* [Readline line event](https://nodejs.org/dist/latest-v6.x/docs/api/readline.html#readline_event_line) - the line event is the one we'll listen to to get the lines from the text file we're going to read.

The following snippet shows how you combine the API's mentioned above to build this simple application. Save it on a file called `print_output.js`:

```javascript
const fileSystem = require('fs');
const readline = require('readline');

const lineReader = readline.createInterface({
  input: fileSystem.createReadStream(process.argv[2])
});

let counter = 0;
lineReader.on('line', function (line) {
  counter++;
  console.log(counter + ': ' + line);
});
```

In the same directory, create a file called `example.txt` and put the following content inside it:

```
Some example text on the first line.
A second line with some more text.
```

That's going to be the sample text file that our application will read.

After that run the following command from inside that directory:

```
$ node print_file.js example.txt
```

You'll see that the application will print all lines in the file, each one in a new line and also prints the line number before them, using the `counter` variable. Here is an example output:

```
$ node print_file.js example.txt
1: Some example text on the first line.
2: A second line with some more text.
```

A few basic things that you'll need to keep in mind when working with Node.js:

* `require` is used to import modules that you can use. This is how you tap into Node.js' API and other dependencies (more about that in future posts)
* `console.log` is what you use to print to the standard out. Just like you would do in a browser (more details in Node.js' [Console API](https://nodejs.org/dist/latest/docs/api/console.html))
* Node.js does most things asynchronously, mostly I/O operations like reading a file (unless you explicitly ask it not to). If you add a `console.log` after the `line.on` call, you'll see that the output will come before the file lines. That's because, similarly to what happens in the browser, that code will be put on a queue to be executed when the line is actually available.
