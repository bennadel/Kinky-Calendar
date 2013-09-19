
<cffunction
	name="GetEvents"
	access="public"
	returntype="struct"
	output="false"
	hint="Gets the events between the given dates (inclusive). Returns a structure that has both the event query and event index.">

	<!--- Define arguments. --->	
	<cfargument
		name="From"
		type="numeric"
		required="true"
		hint="The From date for our date span (inclusive)."
		/>
		
	<cfargument
		name="To"
		type="numeric"
		required="true"
		hint="The To date for our date span (inclusive)."
		/>
		
	<cfargument
		name="GetDescription"
		type="boolean"
		required="false"
		default="false"
		hint="Flag to determine whether or not description is loaded (if not, empty string is passed back)."
		/>
		
	
	<!--- Define the local scope. --->
	<cfset var LOCAL = StructNew() />
	
	
	<!--- 
		Make sure that we are working with numeric dates 
		that are DAY-only dates. 
	--->
	<cfset ARGUMENTS.From = Fix( ARGUMENTS.From ) />
	<cfset ARGUMENTS.To = Fix( ARGUMENTS.To ) />
	
	
	<!--- 
		Query for raw events. This is raw because it does not 
		fully define all events that need to be displayed, but 
		rather defines the events in theory.
	--->
	<cfquery name="LOCAL.RawEvent" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
		SELECT
			e.id,
			e.name,
			<!--- Check to see if description is being sent back. --->
			<cfif ARGUMENTS.GetDescription>
				e.description,
			<cfelse>
				( '' ) AS description,
			</cfif>			
			e.date_started,
			e.date_ended,
			e.time_started,
			e.time_ended,
			e.is_all_day,
			e.repeat_type,
			e.color
		FROM
			event e
		WHERE
			<!--- Check end date constraints. --->
			(
					e.date_ended >= <cfqueryparam value="#ARGUMENTS.From#" cfsqltype="CF_SQL_TIMESTAMP" />
				OR
					e.date_ended IS NULL	
			)
		AND
			<!--- Check start date constraints. --->
			e.date_started <= <cfqueryparam value="#ARGUMENTS.To#" cfsqltype="CF_SQL_TIMESTAMP" />
	</cfquery>
	
	
	<!--- 
		Now that we have our raw events, let's put together 
		a query that will contain all the events that actually
		need to be displayed (repeated events will be repeated
		in this query). Since our raw query may contain events 
		that only display once, let's build this query by 
		performing a query of query to get those single-day 
		events.
	--->
	<cfquery name="LOCAL.Event" dbtype="query">
		SELECT
			*,
			
			<!--- 
				We are going to add a column that will be the 
				lookup index for the day - remember the 
				date_started may be different than the display 
				date for most repeating events.
			--->
			( 0 ) AS day_index
		FROM
			[LOCAL].RawEvent
		WHERE
			repeat_type = 0	
	</cfquery>
	
	
	<!--- 
		Update the day index and event index of the events 
		that we just put into our event query.
	--->
	<cfloop query="LOCAL.Event">
	
		<!--- Update query. --->
		<cfset LOCAL.Event[ "day_index" ][ LOCAL.Event.CurrentRow ] = Fix( LOCAL.Event.date_started ) />
	
	</cfloop>
	
	
	
	<!--- 
		Before we can flesh out the Raw events, we need to 
		get the list of event exceptions. We only need to get 
		exceptions for the events we have in our raw query.
	--->
	<cfquery name="LOCAL.EventException" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
		SELECT
			e.[date],
			e.event_id
		FROM
			event_exception e
		WHERE
			e.[date] >= <cfqueryparam value="#ARGUMENTS.From#" cfsqltype="CF_SQL_TIMESTAMP" />
		AND
			e.[date] <= <cfqueryparam value="#ARGUMENTS.To#" cfsqltype="CF_SQL_TIMESTAMP" />
		AND
			e.event_id IN 
			(
				#ListAppend( ValueList( LOCAL.RawEvent.id ), 0 )#
			)
	</cfquery>
	
	
	<!--- 
		To make the exceptions as fast as possible to use, we 
		are going to create a structure to index them. The key 
		to the sturcture will consist of the event ID and the 
		event date.
	--->
	<cfset LOCAL.Exceptions = StructNew() />
	
	<!--- Loop over exceptions. --->
	<cfloop query="LOCAL.EventException">
	
		<cfset LOCAL.Exceptions[ "#LOCAL.EventException.event_id#:#Fix( LOCAL.EventException.date )#" ] = 1 />
	
	</cfloop>
	
		
	<!--- 
		Now, we will loop over the raw events and populate the 
		calculated events query. This way, when we are rendering
		the calednar itself, we won't have to worry about repeat
		types or anything of that nature.
	--->
	<cfloop query="LOCAL.RawEvent">
	
		<!--- 
			No matter what kind of repeating event type we are 
			dealing with, the TO date will always be calculated 
			in the same manner (it the Starting date that get's 
			hairy). If there is an end date for the event, the 
			the TO date is the minumium of the end date and the 
			end of the time period we are examining. If there 
			is no end date on the event, then the TO date is the
			end of the time period we are examining.
		--->
		<cfif IsDate( LOCAL.RawEvent.date_ended )>
			
			<!--- 
				Since the event has an end date, get what ever 
				is most efficient for the future loop evaluation 
				- the end of the time period or the end date of 
				the event.
			--->
			<cfset LOCAL.To = Min( 
				LOCAL.RawEvent.date_ended,
				ARGUMENTS.To
				) />
			
		<cfelse>
		
			<!--- 
				If there is no end date, then naturally,
				we only want to go as far as the last 
				day of the month.
			--->
			<cfset LOCAL.To = ARGUMENTS.To />
		
		</cfif>
	
	
		<!--- 
			Set the default loop type and increment. We are 
			going to default to 1 day at a time.
		--->
		<cfset LOCAL.LoopType = "d" />
		<cfset LOCAL.LoopIncrement = 1 />
		
		<!--- 
			Set additional conditions to be met. We are going 
			to default to allowing all days of the week.
		--->
		<cfset LOCAL.DaysOfWeek = "" />

		
		<!---
			Check to see what kind of event we have - is 
			it a single day event or an event that repeats. If
			we have an event repeat, we are going to flesh it
			out directly into the event query by adding rows.
			The point of this switch statement is to use the
			repeat type to figure out what the START date, 
			the type of loop skipping (ie. day, week, month),
			and the number of items we need to skip per loop
			iteration.
		--->
		<cfswitch expression="#LOCAL.RawEvent.repeat_type#">
		
			<!--- Repeat daily. --->
			<cfcase value="1">
				
				<!--- 
					Set the start date of the loop. For 
					efficiency's sake, we don't want to loop 
					from the very beginning of the event; we 
					can get the max of the start date and first
					day of the calendar month.
				--->
				<cfset LOCAL.From = Max( 
					LOCAL.RawEvent.date_started,
					ARGUMENTS.From
					) />
					
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "d" />
				<cfset LOCAL.LoopIncrement = 1 />
								
			</cfcase>
			
			<!--- Repeat weekly. --->
			<cfcase value="2">
			
				<!---
					Set the start date of the loop. For 
					efficiency's sake, we don't want to loop 
					from the very beginning of the event; we 
					can get the max of the start date and first
					day of the calendar month.
				--->
				<cfset LOCAL.From = Max(
					LOCAL.RawEvent.date_started,
					ARGUMENTS.From
					) />
					
				<!--- 
					Since this event repeats weekly, we want 
					to make sure to start on a day that might 
					be in the event series. Therefore, adjust 
					the start day to be on the closest day of 
					the week.
				--->
				<cfset LOCAL.From = (
					LOCAL.From - 
					DayOfWeek( LOCAL.From ) + 
					DayOfWeek( LOCAL.RawEvent.date_started )
					) />
				
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "d" />
				<cfset LOCAL.LoopIncrement = 7 />
				
			</cfcase>
			
			<!--- Repeat bi-weekly. --->
			<cfcase value="3">
			
				<!---
					Set the start date of the loop. For 
					efficiency's sake, we don't want to loop 
					from the very beginning of the event; we 
					can get the max of the start date and first
					day of the calendar month.
				--->
				<cfset LOCAL.From = Max(
					LOCAL.RawEvent.date_started,
					ARGUMENTS.From
					) />
					
				<!--- 
					Since this event repeats weekly, we want 
					to make sure to start on a day that might 
					be in the event series. Therefore, adjust 
					the start day to be on the closest day of 
					the week.
				--->
				<cfset LOCAL.From = (
					LOCAL.From - 
					DayOfWeek( LOCAL.From ) + 
					DayOfWeek( LOCAL.RawEvent.date_started )
					) />
				
				<!--- 
					Now, we have to make sure that our start 
					date is NOT in the middle of the bi-week 
					period. Therefore, subtract the mod of 
					the day difference over 14 days.
				--->
				<cfset LOCAL.From = (
					LOCAL.From - 
					((LOCAL.From - LOCAL.RawEvent.date_started) MOD 14)
					) />
				
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "d" />
				<cfset LOCAL.LoopIncrement = 14 />
				
			</cfcase>
			
			<!--- Repeat monthly. --->
			<cfcase value="4">
			
				<!---
					When dealing with the start date of a 
					monthly repeating, we have to be very 
					careful not to try tro create a date that 
					doesnt' exists. Therefore, we are simply 
					going to go back a year from the current 
					year and start counting up. Not the most 
					efficient, but the easist way of dealing 
					with it.
				--->
				<cfset LOCAL.From = Max(
					DateAdd( "yyyy", -1, LOCAL.RawEvent.date_started ),
					LOCAL.RawEvent.date_started
					) />
				
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "m" />
				<cfset LOCAL.LoopIncrement = 1 />
			
			</cfcase>
			
			<!--- Repeat yearly. --->
			<cfcase value="5">
			
				<!---
					When dealing with the start date of a 
					yearly repeating, we have to be very 
					careful not to try tro create a date that 
					doesnt' exists. Therefore, we are simply 
					going to go back a year from the current 
					year and start counting up. Not the most 
					efficient, but the easist way of dealing 
					with it.
				--->
				<cfset LOCAL.From = Max(
					DateAdd( "yyyy", -1, LOCAL.RawEvent.date_started ),
					LOCAL.RawEvent.date_started
					) />
						
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "yyyy" />
				<cfset LOCAL.LoopIncrement = 1 />
			
			</cfcase>
			
			<!--- Repeat monday - friday. --->
			<cfcase value="6">
			
				<!--- 
					Set the start date of the loop. For 
					efficiency's sake, we don't want to loop 
					from the very beginning of the event; we 
					can get the max of the start date and first
					day of the calendar month.
				--->
				<cfset LOCAL.From = Max( 
					LOCAL.RawEvent.date_started,
					ARGUMENTS.From
					) />
					
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "d" />
				<cfset LOCAL.LoopIncrement = 1 />
				<cfset LOCAL.DaysOfWeek = "2,3,4,5,6" />
			
			</cfcase>
			
			<!--- Repeat saturday - sunday. --->
			<cfcase value="7">
			
				<!--- 
					Set the start date of the loop. For 
					efficiency's sake, we don't want to loop 
					from the very beginning of the event; we 
					can get the max of the start date and first
					day of the calendar month.
				--->
				<cfset LOCAL.From = Max( 
					LOCAL.RawEvent.date_started,
					ARGUMENTS.From
					) />
					
				<!--- Set the loop type and increment. --->
				<cfset LOCAL.LoopType = "d" />
				<cfset LOCAL.LoopIncrement = 1 />
				<cfset LOCAL.DaysOfWeek = "1,7" />
				
			</cfcase>
			
			<!--- 
				The default case will be the non-repeating 
				day.Since this event is non-repeating, we 
				don't have to do anything to the envets query
				as these were the events that we gathered in our
				ColdFusion query of queries.
			--->
			<cfdefaultcase>
				<!--- Leave query as-is. --->
			</cfdefaultcase>		
		
		</cfswitch>
		
		
		<!--- 
			Check to see if we are looking at an event that need
			to be fleshed it (ie. it has a repeat type).
		--->
		<cfif LOCAL.RawEvent.repeat_type>
				
			<!--- 
				Set the offset. This is the number of iterations
				we are away from the start date.
			--->
			<cfset LOCAL.Offset = 0 />
			
			<!--- 
				Get the initial date to look at when it comes to 
				fleshing out the events.
			--->
			<cfset LOCAL.Day = Fix( 
				DateAdd(
					LOCAL.LoopType,
					(LOCAL.Offset * LOCAL.LoopIncrement),
					LOCAL.From
					) 
				) />
			
			<!--- 
				Now, keep looping over the incrementing date 
				until we are past the cut off for this time 
				period of potential events.
			--->
			<cfloop condition="(LOCAL.Day LTE LOCAL.To)">
			
				<!--- 
					Check to make sure that this day is in 
					the appropriate date range and that we meet
					any days-of-the-week criteria that have been
					defined. Remember, to ensure proper looping,
					our FROM date (LOCAL.From) may be earlier than
					the window in which we are looking.
				--->
				<cfif (
					<!--- Within window. --->
					(ARGUMENTS.From LTE LOCAL.Day) AND 
					(LOCAL.Day LTE LOCAL.To) AND
					
					<!--- Within allowable days. ---> 
					(
						(NOT Len( LOCAL.DaysOfWeek )) OR
						ListFind( 
							LOCAL.DaysOfWeek, 
							DayOfWeek( LOCAL.Day ) 
							)
					) AND
					
					<!--- There is no exception for event. --->
					(NOT StructKeyExists(
						LOCAL.Exceptions,
						"#LOCAL.RawEvent.id#:#Fix( LOCAL.Day )#"
						)
					))>
			
					<!--- 
						Populate the event query. Add a row to 
						the query and then copy over the data.
					--->
					<cfset QueryAddRow( LOCAL.Event ) />
					
					<!--- Set query data in the event query. --->
					<cfset LOCAL.Event[ "id" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.id />
					<cfset LOCAL.Event[ "name" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.name />
					<cfset LOCAL.Event[ "description" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.description />
					<cfset LOCAL.Event[ "date_started" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.date_started />
					<cfset LOCAL.Event[ "date_ended" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.date_ended />
					<cfset LOCAL.Event[ "time_started" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.time_started />
					<cfset LOCAL.Event[ "time_ended" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.time_ended />
					<cfset LOCAL.Event[ "is_all_day" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.is_all_day />
					<cfset LOCAL.Event[ "repeat_type" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.repeat_type />
					<cfset LOCAL.Event[ "color" ][ LOCAL.Event.RecordCount ] = LOCAL.RawEvent.color />
					
					<!--- 
						Set the date index to this day. This
						is the value we will use to display 
						the same event on different days of 
						the calendar.
					--->
					<cfset LOCAL.Event[ "day_index" ][ LOCAL.Event.RecordCount ] = Fix( LOCAL.Day ) />
				
				</cfif>
				
				
				<!--- Add one to the offset. --->
				<cfset LOCAL.Offset = (LOCAL.Offset + 1) />
				
				<!--- Set the next day to look at. --->
				<cfset LOCAL.Day = Fix( 
					DateAdd(
						LOCAL.LoopType,
						(LOCAL.Offset * LOCAL.LoopIncrement),
						LOCAL.From
						) 
					) />
				
			</cfloop>
			
		</cfif>
	
	</cfloop>
	
	
	<!--- 
		The display of the calendar is going to be based on 
		ColdFusion query of queries. While these rock harder
		than all you can eat buffets, they are not the most
		efficient. Therefore, in order to minimize the query 
		of query acitivity, we are going to maintain an index
		of days that even have events.
	--->
	<cfset LOCAL.EventIndex = StructNew() />
	
	<!--- 
		Loop over the event query to populate the event index
		with the day indexes.
	--->
	<cfloop query="LOCAL.Event">
	
		<cfset LOCAL.EventIndex[ Fix( LOCAL.Event.day_index ) ] = 1 />
	
	</cfloop>
	
	
	
	<!--- Create return structure. --->
	<cfset LOCAL.Return = StructNew() />
	<cfset LOCAL.Return.Index = LOCAL.EventIndex />
	<cfset LOCAL.Return.Events = LOCAL.Event />
	
	<!--- Return structure. --->
	<cfreturn LOCAL.Return />
</cffunction>