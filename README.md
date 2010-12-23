# RunLog.app

## What ?

RunLog.app is a simple Cocoa app that shows your NikePlus runs in a table view and as plots. It lets you tweet your runs. It keeps a local CoreData store of your runs synchronized with the NikePlus servers. That's it.

Please visit [Nikerunning](http://nikerunning.nike.com/nikeplus/) for the official view of your running data. This application is not produced by, endorsed by or in any way connected to Nike, Inc. Nike, Nike+, Nikerunning are trademarks of Nike, Inc.

Interesting parts of the implementation have been described on my blog:

* [Cocoa Part 1](http://uwedeportivo.tumblr.com/post/1421387356/nikeruns-in-cocoa-part-1)
* [Cocoa Part 2](http://uwedeportivo.tumblr.com/post/1463149809/nikeruns-in-cocoa-part-2)
* [Cocoa Part 3](http://uwedeportivo.tumblr.com/post/1526692405/nikeruns-in-cocoa-part-3)

Parts of the source code is a port of an older incarnation of the same functionality written as a command-line Haskell program. Details are also on my blog:

* [Haskell Part 1](http://uwedeportivo.tumblr.com/post/529205380/publishing-nike-runs-part-1-numeric-lists)
* [Haskell Part 2](http://uwedeportivo.tumblr.com/post/540639058/publishing-nike-runs-part-2-google-charts)
* [Haskell Intermission](http://uwedeportivo.tumblr.com/post/529211202/publishing-nike-runs-intermission-flip-id)
* [Haskell Part 3](http://uwedeportivo.tumblr.com/post/540645847/publishing-nike-runs-part-3-handling-xml)
* [Haskell Part 4](http://uwedeportivo.tumblr.com/post/540655308/publishing-nike-runs-part-4-string-templates)
* [Haskell Part 5](http://uwedeportivo.tumblr.com/post/551822645/publishing-nike-runs-part-5-blogging-and-twitter)

## Why ?

The features here are small enough that I can tackle them as a hobby without burning too much time. But they are interesting enough to let me compare different languages and platforms. They touch on web services, http, xml handling, numerical lists and plotting. I use this as a vehicle to learn new languages and APIs and to compare weaknesses and strengths of these different programming platforms.

## Frameworks used (Thank you!)

* [CorePlot](http://code.google.com/p/core-plot/)
* [MGTwitterEngine](https://github.com/mattgemmell/MGTwitterEngine)
* [MGTemplateEngine](http://mattgemmell.com/2008/05/20/mgtemplateengine-templates-with-cocoa)
* [ParseKit](http://parsekit.com/)
* [OAuth](http://oauth.net/code/)
* [yajl](http://lloyd.github.com/yajl/)
* [RegexKitLite](http://regexkit.sourceforge.net/RegexKitLite/)

## Icons used (Thank you!)

* Runner: [icons.mysitemyway.com](http://icons.mysitemyway.com/free-clipart-icons/1/sports-running-icon-id/43735/style-id/333/blue-tiedyed-cloth-icons/sports-hobbies/)
* Twitter Bird: [Noel Miciano](http://noelmiciano.wordpress.com/2009/03/28/free-twitter-icon/)
* Sync: [Artua](http://www.artua.com/view/icons/name/macosxstyle/)

## Building

You need CorePlot.framework and ParseKit.framework to build the app. The XCode project assumes their location is in /Users/uwe/Library/Frameworks. You need to change that and point it to where you installed the two frameworks. Everything else is included.

You need your own Consumer key and Consumer secret from Twitter, if you want to use the publish feature. Enter those in the file CDMTwitter.m. The values that are currently there are placeholders and won't work.

You need your own Nike ID. Presumably you are interested in this app because you are a runner and use the NikePlus equipment, so you should have your own Nike ID and also make sure your Nike profile is public. Enter your ID in the file RunLogAppDelegate.m. Eventually I will provide user preferences that lets you enter the Nike ID there instead of in code. The current Nike ID is mine. It's ok to leave that in there, but you will only see my runs instead of yours then. 

## Language for filtering runs

The UI provides a search field. It is currently not obvious what can be typed in there. Below are some examples and the grammar that is expected by the app. Grammar is fully implemented but currently not all productions contribute to the resulting NSFetchRequest. 

Examples:
	fastest 2 in May 2010
	slowest 3
	first 2
	last 2
	last month
	last week
	last year
	longer than 5 km
	shorter than 20 min
	all but last 2
	all but slowest, fastest

Grammar:

	date -> "in" <rest of input>

	top -> ("fastest" | "slowest" | "first" | "last") (INT | "month" | "week" | "year")

	rangeleaf -> ("longer" | "shorter") "than" INT ("km" | "min")

	range -> rangeleaf ("and" rangeleaf)*

	leaf -> (top | range)

	composite -> ("all" "but")? leaf ("," leaf)* (date)?


## Licenses

Source code in ./RunLog/third\_party is under the respective license of each third party dependency (included in each subdirectory of third\_party). Rest of the code is under the included MIT license.

## TODO

* error handling
* user prefs (nike id is hard coded for example :-) )
* printing

* * *

[Uwe Hoffmann](http://uwedeportivo.tumblr.com)



