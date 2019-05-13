# The Appetizer

This is the Elm (v0.19) code for running http://appetizer.hurwitzlab.org. The Appetizer is a web interface for creating and editing the `app.json` file needed by the Agave API (http://agaveapi.co/) to create an app that will run on the Stampede2 HPC at TACC.

# Install

````
$ brew install npm
$ npm install -g elm
$ npm install -g elm-live
$ npm install -g elm-format
$ npm install
$ npm start
````

Ubuntu and similar:

````
$ curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
$ sudo apt install -y nodejs
$ sudo npm install --unsafe-perm -g elm
$ sudo npm install --unsafe-perm -g elm-live
$ sudo npm install --unsafe-perm -g elm-format
$ sudo npm install
$ npm start
````

# Author

Ken Youens-Clark <kyclark@email.arizona.edu>
