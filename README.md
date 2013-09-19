
# Kinky Calendar - Free ColdFusion Calendar System

by [Ben Nadel][1] (on [Google+][2])

__*NOTE: This is a really old project that has not been updated in years.*__

Demo: [View online demo at BenNadel.com][3]

The Kinky Calendar System is a totally free ColdFusion calendar system that 
was designed, not as a stand-alone application, but rather as a module that 
could be easily integrated into an existing piece of ColdFusion software. 
Using only two database tables and extremely simple queries, this system 
should work on just about any database application, event the dreaded 
Microsoft Access.

The Add / Edit interfaces have been kept purposefully simple. It is my 
assumption that any application that integrates with this free ColdFusion 
calendar system will already have widgets for date and time selection. Those
widgets should be inserted in place of my standard text inputs. 

## Features

* Year / Month / Week / Day View
* Repeating events:
	- Daily
	- Weekly
	- Bi-Weekly
	- Monthly
	- Yearly
	- Monday - Friday
	- Saturday - Sunday
* Partial event series manipulation and exception creation:
	- Entire event series
	- All future instances of event
	- Current event instance only
* Color coding of events
* SQL build scripts for event tables

## Known Bugs And Issues

* Invalid years are not handled properly and throw exceptions.
* There is no easy way to click into the details of day.
* Cannot handle times that start one night and end next morning
(Thanks Jeff Self)


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
[3]: http://www.bennadel.com/resources/projects/kinky_calendar/demo/