# RunLog.app

## What does it do ?

RunLog.app is a simple Cocoa app that shows your NikePlus runs in a table view and as plots. It lets you tweet your runs. It keeps a local CoreData store of your runs synchronized with the NikePlus servers. That's it.

Please visit [Nikerunning](http://nikerunning.nike.com/nikeplus/) for the official view of your running data. This application is not produced by, endorsed by or in any way connected to Nike, Inc. Nike, Nike+, Nikerunning are trademarks of Nike, Inc.

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

You need to provide CorePlot.framework and ParseKit.framework. Everything else is included.

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



