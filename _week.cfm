
<!--- Kill extra output. --->
<cfsilent>

	<!--- Param the URL attributes. --->
	<cftry>
		<cfparam
			name="REQUEST.Attributes.date"
			type="numeric"
			default="#REQUEST.DefaultDate#"
			/>
			
		<cfcatch>
			<cfset REQUEST.Attributes.date = REQUEST.DefaultDate />
		</cfcatch>
	</cftry>
	
	
	<!--- Based on the date, let's get the first day of this week. --->
	<cftry>
		<cfset dtThisWeek = (
			REQUEST.Attributes.date - 
			DayOfWeek( REQUEST.Attributes.date ) +
			1 
			) />
		
		<cfcatch>
		
			<!--- 
				If there was an error, just default the week 
				view to be the current week.
			--->
			<cfset dtThisWeek = (
				REQUEST.DefaultDate -
				DayOfWeek( REQUEST.DefaultDate ) +
				1
				) />
				
		</cfcatch>
	</cftry>
	
	
	<!--- Get the next and previous weeks. --->
	<cfset dtPrevWeek = DateAdd( "ww", -1, dtThisWeek ) />
	<cfset dtNextWeek = DateAdd( "ww", 1, dtThisWeek ) />
	
	
	<!--- Get the last day of the week. --->
	<cfset dtLastDayOfWeek = (dtNextWeek - 1) />
	
	<!--- 
		Now that we have the first day of the week, let's get
		the first day of the calendar month - this is the first
		graphical day of the calendar page, which may be in the
		previous month (date-wise).
	--->
	<cfset dtFirstDay = dtThisWeek />
	<cfset dtLastDay = dtLastDayOfWeek />
		
	
	<!--- Get the events for this time span. --->
	<cfset objEvents = GetEvents(
		dtFirstDay,
		dtLastDay
		) />
		
		
	<!--- 
		Check to see if this week contains the default date. 
		If not, then set the default date to be this week.
	--->
	<cfif (
		(Year( dtThisWeek ) NEQ Year( REQUEST.DefaultDate )) OR
		(Month( dtThisWeek ) NEQ Month( REQUEST.DefaultDate )) OR
		(Week( dtThisWeek ) NEQ Week( REQUEST.DefaultDate ))
		)>
	
		<!--- This we be used when building the navigation. --->
		<cfset REQUEST.DefaultDate = Fix( dtThisWeek ) />
		
	</cfif>
		
</cfsilent>

<cfinclude template="./includes/_header.cfm">

<cfoutput>
		
	<h2>
		Week Of #DateFormat( dtThisWeek, "mmmm d, yyyy" )# Events
	</h2>

	<p id="calendarcontrols">
		&laquo;
		<a href="./index.cfm?action=week&date=#Fix( dtPrevWeek )#">#DateFormat( dtPrevWeek, "mmmm d, yyyy" )#</a> &nbsp;|&nbsp;
		<a href="./index.cfm?action=week&date=#Fix( dtNextWeek )#">#DateFormat( dtNextWeek, "mmmm d, yyyy" )#</a>
		&raquo;
	</p>
	
	<form id="calendarform" action="#CGI.script_name#" method="get">
		
		<input type="hidden" name="action" value="week" />
	
		<select name="date">
			<cfloop 
				index="intOffset" 
				from="-20" 
				to="20"
				step="1">
				
				<option value="#Fix( DateAdd( "ww", intOffset, dtThisWeek ) )#"
					<cfif (Fix( DateAdd( "ww", intOffset, dtThisWeek ) ) EQ dtThisWeek)>selected="true"</cfif>
					>#DateFormat( DateAdd( "ww", intOffset, dtThisWeek ), "mmm d, yyyy" )#</option>
					
			</cfloop>
		</select>
		
		<input type="submit" value="Go" />
		
	</form>
	
	
	<table id="calendar" width="100%" cellspacing="1" cellpadding="0" border="0">
	<colgroup>
		<col />
		<col width="10%" />
		<col width="16%" />
		<col width="16%" />
		<col width="16%" />
		<col width="16%" />
		<col width="16%" />
		<col width="10%" />
	</colgroup>
	<tr class="header">
		<td>
			<br />
		</td>
		<td>
			Sunday
		</td>
		<td>
			Monday
		</td>
		<td>
			Tuesday
		</td>
		<td>
			Wednesday
		</td>
		<td>
			Thursday
		</td>
		<td>
			Friday
		</td>
		<td>
			Saturday
		</td>
	</tr>
	
	<!--- Loop over all the days. --->
	<cfloop 
		index="dtDay"
		from="#dtFirstDay#"
		to="#dtLastDay#"
		step="1">
	
		<!--- 
			If we are on the first day of the week, then 
			start the current table fow.
		--->
		<cfif ((DayOfWeek( dtDay ) MOD 7) EQ 1)>
			<tr class="days">
				<td class="header">
					<a href="./index.cfm?action=month&date=#dtDay#">&raquo;</a>
				</td>
		</cfif>
		
		<td 
			<cfif (
				(Month( dtDay ) NEQ Month( dtThisWeek )) OR
				(Year( dtDay ) NEQ Year( dtThisWeek ))
				)>
				class="other"
			<cfelseif (dtDay EQ Fix( Now() ))>
				class="today"
			</cfif>
			>
			<a 
				href="./index.cfm?action=edit&viewas=#dtDay#" 
				title="#DateFormat( dtDay, "mmmm d, yyyy" )#" 
				class="daynumber<cfif (Day( dtDay ) EQ 1)>full</cfif>"
				><cfif (Day( dtDay ) EQ 1)>#MonthAsString( Month( dtDay ) )#&nbsp;</cfif>#Day( dtDay )#</a>
							
			<!--- 
				Since query of queries are expensive, we 
				only want to get events on days that we 
				KNOW have events. Check to see if there 
				are any events on this day. 
			--->
			<cfif StructKeyExists( objEvents.Index, dtDay )>
				
				<!--- Query for events for the day. --->
				<cfquery name="qEventSub" dbtype="query">
					SELECT
						id,
						name,
						time_started,
						time_ended,
						date_started,
						date_ended,
						is_all_day,
						repeat_type,
						color
					FROM
						objEvents.Events
					WHERE
						day_index = <cfqueryparam value="#dtDay#" cfsqltype="CF_SQL_INTEGER" />
					ORDER BY
						time_started ASC
				</cfquery>
			
				<!--- Loop over events. --->
				<cfloop query="qEventSub">
				
					<a 
						href="#CGI.script_name#?action=edit&id=#qEventSub.id#&viewas=#dtDay#"
						<cfif Len( qEventSub.color )>
							style="border-left: 3px solid ###qEventSub.color# ; padding-left: 3px ;"
						</cfif>
						class="event">
						
						<cfif qEventSub.is_all_day>
							<strong>All Day Event</strong><br />
						<cfelse>
							<strong>#TimeFormat( qEventSub.time_started, "h:mm TT" )# - #TimeFormat( qEventSub.time_ended, "h:mm TT" )#</strong><br />
						</cfif>
						
						#qEventSub.name#<br />
						
						<!--- Check for repeat type. --->
						<cfif qEventSub.repeat_type>
							<em class="note">
								Repeats
								
								<!--- Check repeat type. --->
								<cfswitch expression="#qEventSub.repeat_type#">
		
									<!--- Repeat daily. --->
									<cfcase value="1">
										daily
									</cfcase>
									
									<!--- Repeat weekly. --->
									<cfcase value="2">
										weekly
									</cfcase>
									
									<!--- Repeat bi-weekly. --->
									<cfcase value="3">
										bi-weekly
									</cfcase>
									
									<!--- Repeat monthly. --->
									<cfcase value="4">
										monthly
									</cfcase>
									
									<!--- Repeat yearly. --->
									<cfcase value="5">
										yearly
									</cfcase>
									
									<!--- Repeat monday - friday. --->
									<cfcase value="6">
										Mon-Fri
									</cfcase>
									
									<!--- Repeat saturday - sunday. --->
									<cfcase value="7">
										Sat-Sun
									</cfcase>
									
								</cfswitch>
								
								<cfif IsDate( qEventSub.date_ended )>
									until #DateFormat( qEventSub.date_ended, "mm/dd/yy" )#
								<cfelse>
									forever
								</cfif>
							</em>
						</cfif>
					</a>
					
					<br />
				
				</cfloop>
			</cfif>
		</td>				
		
		<!--- 
			If we are on the last day, then close the 
			current table row. 
		--->
		<cfif NOT (DayOfWeek( dtDay ) MOD 7)>
			</td>
		</cfif>
		
	</cfloop>
	
	<tr class="footer">
		<td colspan="8">
			<br />
		</td>
	</tr>
	</table>
		
</cfoutput>

<cfinclude template="./includes/_footer.cfm" />
