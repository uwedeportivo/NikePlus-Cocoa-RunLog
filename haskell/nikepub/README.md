# nikepub

## INTRODUCTION

nikepub is a simple commandline program that given a Nike+ user id will fetch the
most recent Nike+ run and publish it to any blog and/or Twitter account.
Assumes the Nike+ user profile is public. Supports customizable templates
for the blog entry title, body and Twitter status update. Any blogging
system with XML-RPC support for metaWeblog.newPost (like WordPress or MovableType)
is supported.

A description of the implementation can be found here:

* [Haskell Part 1](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs-part1:-numeric-lists)
* [Haskell Part 2](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs,-part-2:-google-charts)
* [Haskell Intermission](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs,-intermission:-flip-id)
* [Haskell Part 3](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs,-part-3:-handling-xml)
* [Haskell Part 4](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs,-part-4:-string-templates)
* [Haskell Part 5](https://github.com/uwedeportivo/NikePlus-Cocoa-RunLog/wiki/publishing-nike-runs,-part-5:-blogging-and-twitter)

## INSTALLATION

nikepub comes as a cabal package so doing 

$ runhaskell Setup configure --prefix=$HOME --user
$ runhaskell Setup build
$ runhaskell Setup install

in the untarred package directory will install nikepub in $HOME/bin.

## USAGE

Example command line flags (fill in values where you see <value description>s):

nikepub
 --id=<your nike+ id> \
 --templates=<path to a templates dir> \
 --mtUrl=<url to your blog xml-rpc> \
 --mtUser=<your blog username> \ 
 --mtPassword=<path to a file containing your blog api password> \ 
 --message=<any additional message you want in blog entry> \ 
 --twitterUser=<your twitter username> \
 --twitterPassword=<path to a file containing your twitter password>

The distribution package contains an example template directory. It can be used directly or customized.
The example template files have all the supported $fields$ in them. All three files must be present in
a template directory. You might want to copy the template directory into a more convenient place.
Templates can contain special comments with JSON strings configuring the desired chart size 
(more configuration properties to follow in later versions).

Your Nike+ profile is assumed to be public. nikepub doesn't work with non-public profiles (if you publish
your runs with nikepub you might as well have your profile public). Your Nike+ id is an integer. The simplest way
to find it out is to share a run or your profile in the Flash UI on the Nike+ website by choosing to grab
the link to the run you want to share in the Share menu.
The pasteboard now has a URL with your Nike+ user id in the URL params.

The --message flag on the nikepub commandline lets you append an arbitrary message to the body of the generated
blog entry.

If the --draft flag is present then the blog entry is not published but sent as a draft to the blogging system.

The flag --airport allows for the specification of an airport code. It is used to fetch the weather conditions
during the run. nikepub must be executed within 90 minutes of the run start time for it to fetch the weather.

