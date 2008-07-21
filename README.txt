= piwik

* http://piwik.rubyforge.org
* http://github.com/riopro/piwik/tree/master

== DESCRIPTION:

A simple Ruby client for the Piwik API.

== FEATURES/PROBLEMS:

* Object-oriented interface to the Piwik API;
* For now, only a small subset of the API is implemented (only basic actions)

== SYNOPSIS:

Piwik is an open source web analytics software, written in PHP. It provides an 
extensive REST-like API, and this gem aims to be a simple Ruby wrapper to access 
this API in a Ruby-friendly way. For example:

  >> require 'rubygems'
  => []
  >> require 'piwik'
  => []
  >> site = Piwik::Site.load(1, 'http://your.piwi.install', 'some_auth_key')
  => #<Piwik::Site:0xb74bf994 @name="Example.com", @config={:auth_token=>"some_auth_key", :piwik_url=>"http://your.piwi.install"}, @id=1, @main_url="http://www.example.com", @created_at=Tue Jul 15 18:55:40 -0300 2008>
  >> site.pageviews(:month, Date.today)
  => 88

See the Piwik::Site RDoc for full documentation.

For more information on Piwik and it's API, see the Piwik website (http://piwik.org) 
and the Piwik API reference (http://dev.piwik.org/trac/wiki/API/Reference).

== REQUIREMENTS:

RubyGems and the following gems (installed automatically if necessary):

  activesupport
  xml-simple
  rest-client

== INSTALL:

From RubyForge: 

  sudo gem install piwik

From Github (with RubyGems >= 1.2.0): 

  sudo gem sources -a http://gems.github.com   # you only have to do this once
  sudo gem install riopro-piwik

== LICENSE:

(The MIT License)

Copyright (c) 2008 Riopro Informatica Ltda

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
