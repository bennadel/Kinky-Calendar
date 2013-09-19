
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
	
	
	<!--- Just get a pointer to the given date. --->
	<cfset dtThisDay = REQUEST.Attributes.date />
		
	
	<!--- Get the next and previous days. --->
	<cfset dtPrevDay = (dtThisDay - 1) />
	<cfset dtNextDay = (dtThisDay + 1) />
	
	
	<!--- Get the events for this time span. --->
	<cfset objEvents = GetEvents(
		dtThisDay,
		dtThisDay,
		true
		) />
		
		
	<!--- 
		Check to see if this is the default date. If 
		not, then set the default date to be this day.
	--->
	<cfif (dtThisDay NEQ REQUEST.DefaultDate)>
	
		<!--- This we be used when building the navigation. --->
		<cfset REQUEST.DefaultDate = Fix( dtThisDay ) />
		
	</cfif>
		
</cfsilent>

<cfinclude template="./includes/_header.cfm">

<cfoutput>
		
	<h2>
		#DateFormat( dtThisDay, "mmmm d, yyyy" )# Events
	</h2>

	<p id="calendarcontrols">
		&laquo;
		<a href="./index.cfm?action=day&date=#Fix( dtPrevDay )#">#DateFormat( dtPrevDay, "mmmm d, yyyy" )#</a> &nbsp;|&nbsp;
		<a href="./index.cfm?action=day&date=#Fix( dtNextDay )#">#DateFormat( dtNextDay, "mmmm d, yyyy" )#</a>
		&raquo;
	</p>
	
	<form id="calendarform" action="#CGI.script_name#" method="get">
		
		<input type="hidden" name="action" value="day" />
	
		<select name="date">
			<cfloop 
				index="intOffset" 
				from="-20" 
				to="20"
				step="1">
				
				<option value="#Fix(dtThisDay + intOffset)#"
					<cfif (Fix( (dtThisDay + intOffset) ) EQ dtThisDay)>selected="true"</cfif>
					>#DateFormat( Fix(dtThisDay + intOffset), "mmm d, yyyy" )#</option>
					
			</cfloop>
		</select>
		
		<input type="submit" value="Go" />
		
	</form>
	
	
	<table id="calendar" width="100%" cellspacing="1" cellpadding="0" border="0">
	<colgroup>
		<col />
		<col width="100%" />
	</colgroup>
	<tr class="header">
		<td>
			<br />
		</td>
		<td>
			#DateFormat( dtThisDay, "dddd, mmmm d, yyyy" )#
		</td>
	</tr>
	
	
	<!--- 
		Since so much our code depends on the "dtDay" variable,
		and I did copy and paste most of this, just set a pointer
		using the current date.
	--->
	<cfset dtDay = dtThisDay />
				
	
	<tr class="days">
		<td class="header">
			<a href="./index.cfm?action=week&date=#dtDay#">&raquo;</a>
		</td>
		<td 
			<cfif (dtDay EQ Fix( Now() ))>
				class="today"
			</cfif>
			>
			
			<a 
				href="./index.cfm?action=edit&viewas=#dtDay#" 
				title="#DateFormat( dtDay, "mmmm d, yyyy" )#" 
				class="daynumber"
				>#Day( dtDay )#</a>
							
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
						description,
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
						
						<!--- Check for event description. --->
						<cfif Len( qEventSub.description )>
						
							<br />
							<br />
							#ToString( qEventSub.description ).ReplaceAll( "\r\n?", "<br />" )#
						
						</cfif>
					</a>
					
					<br />
				
				</cfloop>
			</cfif>
		</td>
	</tr>
	<tr class="footer">
		<td colspan="2">
			<br />
		</td>
	</tr>
	</table>
		
</cfoutput>

<cfinclude template="./includes/_footer.cfm" />
