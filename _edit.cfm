
<!--- Kill extra output. --->
<cfsilent>

	<!--- Param FORM values. --->
	<cfparam
		name="FORM.name"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.description"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.date_started"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.date_ended"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.time_started"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.time_ended"
		type="string"
		default=""
		/>
		
	<cfparam
		name="FORM.color"
		type="string"
		default=""
		/>
		
	<!--- 
		The following parameters require type checking 
		and might throw errors.
	--->
	<cftry>
		<cfparam
			name="FORM.is_all_day"
			type="numeric"
			default="0"
			/>
			
		<cfparam
			name="FORM.repeat_type"
			type="numeric"
			default="0"
			/>
			
		<cfparam
			name="FORM.update_type"
			type="numeric"
			default="1"
			/>
			
		<cfparam
			name="FORM.submitted"
			type="numeric"
			default="0"
			/>
	
		<cfcatch>
			<cfset FORM.is_all_day = 0 />
			<cfset FORM.repeat_type = 0 />
			<cfset FORM.update_type = 1 />
			<cfset FORM.submitted = 0 />
		</cfcatch>
	</cftry>
	
	
	<!---
		When paraming the ID and ViewAs values, param the 
		Attributes since they might be coming from URL or 
		FORM scope.
	--->
	<cftry>
		<cfparam
			name="REQUEST.ATTRIBUTES.id"
			type="numeric"
			default="0"
			/>
			
		<cfparam
			name="REQUEST.ATTRIBUTES.viewas"
			type="numeric"
			default="0"
			/>
			
		<cfcatch>
			<cfset REQUEST.ATTRIBUTES.id = 0 />
			<cfset REQUEST.ATTRIBUTES.viewas = 0 />
		</cfcatch>
	</cftry>
	
	
	<!--- Set up an array to hold form errors. --->
	<cfset arrErrors = ArrayNew( 1 ) />

	
	<!--- 
		Get the event information. Get this before the 
		form processing because it will be used both during
		initialization as well as processing.
	--->
	<cfquery name="qEvent" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
		SELECT
			id,
			name,
			description,
			date_started,
			date_ended,
			time_started,
			time_ended,
			is_all_day,
			repeat_type,
			color
		FROM
			event e
		WHERE
			e.id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />
	</cfquery>
	
	
	<!--- Loop over all form values to prevent HTML formatting. --->
	<cfloop
		item="REQUEST.Key"
		collection="#FORM#">
		
		<!--- Escape values. --->
		<cfset FORM[ REQUEST.Key ] = HtmlEditFormat( FORM[ REQUEST.Key ] ) />
		
	</cfloop>
	
		
	
	<!--- Check to see if form has been submitted. --->
	<cfif FORM.submitted>
	
		<!--- 
			Now that the form has been submitted, let's clean 
			up the data a little.
		--->
		<cfif FORM.is_all_day>
			
			<!--- Make sure an all day event has no time. --->
			<cfset FORM.time_started = "" />
			<cfset FORM.time_ended = "" />
			
		</cfif>
		
		<!--- Make sure date contains only date. --->
		<cfif IsDate( FORM.date_started )>
		
			<cfset FORM.date_started = DateFormat(
				Fix( FORM.date_started ),
				"mm/dd/yyyy"
				) />
			
		</cfif>
		
		<!--- Make sure date contains only date. --->
		<cfif IsDate( FORM.date_ended )>
		
			<cfset FORM.date_ended = DateFormat(
				Fix( FORM.date_ended ),
				"mm/dd/yyyy"
				) />
			
		</cfif>
		
		<!--- Make sure time contains only time. --->
		<cfif IsDate( FORM.time_started )>
		
			<cfset FORM.time_started = TimeFormat(
				FORM.time_started,
				"hh:mm TT"
				) />
			
		</cfif>
		
		<!--- Make sure time contains only time. --->
		<cfif IsDate( FORM.time_ended )>
		
			<cfset FORM.time_ended = TimeFormat(
				FORM.time_ended,
				"hh:mm TT"
				) />
			
		</cfif>
		
		<!--- 
			Check to see if we have a "viewas" date. If we don't
			then, we have NO choice but to update the entire series.
		--->
		<cfif NOT REQUEST.Attributes.viewas>
		
			<!--- Update entire series. --->
			<cfset FORM.update_type = 1 />
		
		</cfif>
	
		
		<!--- 
			Now that the form has been submitted, let's 
			validate the data.
		--->
		<cfif NOT Len( FORM.name )>
			<cfset ArrayAppend( 
				arrErrors,
				"Please enter an event name"
				) />
		</cfif>
		
		<cfif NOT IsDate( FORM.date_started )>
			<cfset ArrayAppend( 
				arrErrors,
				"Please enter a start date"
				) />
		</cfif>
		
		<cfif (
			Len( FORM.date_ended ) AND 
			(NOT IsDate( FORM.date_ended ))
			)>
			<cfset ArrayAppend( 
				arrErrors,
				"Please enter a valid end date"
				) />
		</cfif>
		
		<cfif (
			IsDate( FORM.date_ended ) AND 
			IsDate( FORM.date_started ) AND
			(FORM.date_ended LT FORM.date_started)
			)>
			<cfset ArrayAppend( 
				arrErrors,
				"Please enter an end date that is greater than or equal to the start date"
				) />
		</cfif>
		
		<!--- We only need to check time if it is NOT an all day event. --->
		<cfif NOT FORM.is_all_day>
		
			<cfif (
				(NOT Len( FORM.time_started )) OR
				(NOT IsDate( FORM.time_started ))
				)>
				<cfset ArrayAppend( 
					arrErrors,
					"Please enter a valid start time"
					) />
			</cfif>
			
			<cfif (
				(NOT Len( FORM.time_ended )) OR
				(NOT IsDate( FORM.time_ended ))
				)>
				<cfset ArrayAppend( 
					arrErrors,
					"Please enter a valid end time"
					) />
			</cfif>
			
			<cfif (
				IsDate( FORM.time_ended ) AND 
				IsDate( FORM.time_started ) AND
				(FORM.time_ended LTE FORM.time_started)
				)>
				<cfset ArrayAppend( 
					arrErrors,
					"Please enter an end time that is greater than the start time"
					) />
			</cfif>
		
		</cfif>
		
		<!--- 
			Check for repeat type. We need it if we have 
			anything more than one day.
		--->
		<cfif (
			IsDate( FORM.date_started ) AND
			IsDate( FORM.date_ended ) AND
			(Fix( FORM.date_started ) NEQ Fix( FORM.date_ended )) AND
			(NOT FORM.repeat_type)
			)>
			<cfset ArrayAppend( 
				arrErrors,
				"Please select a repeat type for this event"
				) />			
		</cfif>
		
		<!--- Check to make sure are "Viewas" date is valid. --->
		<cfif (
			qEvent.RecordCount AND
			REQUEST.Attributes.viewas AND
			(
				(REQUEST.Attributes.viewas LT qEvent.date_started) OR
				(
					IsDate( qEvent.date_ended ) AND
					(REQUEST.Attributes.viewas GT qEvent.date_ended)
				)
			))>
			<cfset ArrayAppend( 
				arrErrors,
				"The event instance date does not appear to be valid"
				) />			
		</cfif>
		
	
		<!--- Check to see if there are any form errors. --->
		<cfif NOT ArrayLen( arrErrors )>
		
			<!--- Clean up the form data before update. --->
			<cfif NOT FORM.repeat_type>
			
				<!--- Its a one-day event. --->
				<cfset FORM.date_ended = FORM.date_started />
			
			</cfif>
			
			<cfif (
				IsDate( FORM.date_started ) AND 
				IsDate( FORM.date_ended ) AND
				(Fix( FORM.date_started ) EQ Fix( FORM.date_ended ))
				)>
			
				<!--- No repeat date for single-day events. --->
				<cfset FORM.repeat_type = 0 />
			
			</cfif>
			
			<!--- Make 24-hour times. --->
			<cfif IsDate( FORM.time_started )>

				<cfset FORM.time_started = TimeFormat( FORM.time_started, "HH:mm" ) />
				
			</cfif>
			
			<!--- Make 24-hour times. --->
			<cfif IsDate( FORM.time_ended )>

				<cfset FORM.time_ended = TimeFormat( FORM.time_ended, "HH:mm" ) />
				
			</cfif>
			
			
			<!--- Check to see if we are dealing with an existing event or a new event. --->
			<cfif qEvent.RecordCount>
			
				<!--- 
					We are dealing with an existing event. Now, we 
					have to be careful about the update type.
				--->
				<cfswitch expression="#FORM.update_type#">
				
					<!--- All future instances in series. --->
					<cfcase value="2">
					
						<!--- 
							Since we are updating all future instances, we are 
							going to split this event in half. The previous half 
							will be all the days that prior to "viewas". The new 
							event will be everthing going forward.
						--->
						
						<!--- Update existing event. --->
						<cfquery name="qUpdate" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
							UPDATE
								event
							SET
								date_ended = <cfqueryparam value="#(REQUEST.Attributes.viewas - 1)#" cfsqltype="CF_SQL_TIMESTAMP" />,
								date_updated = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" />
							WHERE
								id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />						
						</cfquery>
						
						
						<!--- Now, let's insert the new event. --->
						<cfquery name="qInsert" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
							INSERT INTO event
							(
								name,
								description,
								date_started,
								date_ended,
								time_started,
								time_ended,
								is_all_day,
								repeat_type,
								color,
								date_updated,
								date_created
							) VALUES (
								<cfqueryparam value="#FORM.name#" cfsqltype="CF_SQL_VARCHAR" />, 				<!--- name --->
								<cfqueryparam value="#FORM.description#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- description --->
								<cfqueryparam value="#FORM.date_started#" cfsqltype="CF_SQL_TIMESTAMP" />, 		<!--- date_started --->
								<cfqueryparam value="#FORM.date_ended#" cfsqltype="CF_SQL_TIMESTAMP" null="#NOT IsNumericDate( FORM.date_ended )#" />, 		<!--- date_ended --->
								<cfqueryparam value="#FORM.time_started#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- time_started --->
								<cfqueryparam value="#FORM.time_ended#" cfsqltype="CF_SQL_VARCHAR" />, 			<!--- time_ended --->
								<cfqueryparam value="#FORM.is_all_day#" cfsqltype="CF_SQL_TINYINT" />, 			<!--- is_all_day --->
								<cfqueryparam value="#FORM.repeat_type#" cfsqltype="CF_SQL_TINYINT" />, 		<!--- repeat_type --->
								<cfqueryparam value="#FORM.color#" cfsqltype="CF_SQL_VARCHAR" />, 				<!--- color --->
								<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" />, 					<!--- date_updated --->
								<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" /> 					<!--- date_created --->
							);
						</cfquery>
					
					</cfcase>
					
					<!--- Just this instance. --->
					<cfcase value="3">
					
						<!--- 
							Since we are updating just this instance, we are 
							basically creating an event exception and a new event.
						--->
						
						<!--- Insert new, single-day event. --->
						<cfquery name="qInsert" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
							INSERT INTO event
							(
								name,
								description,
								date_started,
								date_ended,
								time_started,
								time_ended,
								is_all_day,
								repeat_type,
								color,
								date_updated,
								date_created
							) VALUES (
								<cfqueryparam value="#FORM.name#" cfsqltype="CF_SQL_VARCHAR" />, 				<!--- name --->
								<cfqueryparam value="#FORM.description#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- description --->
								<cfqueryparam value="#FORM.date_started#" cfsqltype="CF_SQL_TIMESTAMP" />, 		<!--- date_started --->
								<cfqueryparam value="#FORM.date_ended#" cfsqltype="CF_SQL_TIMESTAMP" null="#NOT IsNumericDate( FORM.date_ended )#" />, 		<!--- date_ended --->
								<cfqueryparam value="#FORM.time_started#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- time_started --->
								<cfqueryparam value="#FORM.time_ended#" cfsqltype="CF_SQL_VARCHAR" />, 			<!--- time_ended --->
								<cfqueryparam value="#FORM.is_all_day#" cfsqltype="CF_SQL_TINYINT" />, 			<!--- is_all_day --->
								<cfqueryparam value="0" cfsqltype="CF_SQL_TINYINT" />, 							<!--- repeat_type --->
								<cfqueryparam value="#FORM.color#" cfsqltype="CF_SQL_VARCHAR" />, 				<!--- color --->
								<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" />, 					<!--- date_updated --->
								<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" /> 					<!--- date_created --->
							);
						</cfquery>
						
						<!--- Insert exception. --->
						<cfquery name="qInsertException" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
							INSERT INTO event_exception
							(
								[date],
								event_id
							) VALUES (
								<cfqueryparam value="#REQUEST.Attributes.viewas#" cfsqltype="CF_SQL_TIMESTAMP" />,
								<cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />
							);
						</cfquery>
					
					</cfcase>
					
					<!--- All instances in series. --->
					<cfdefaultcase>
					
						<!--- Since this is a straight forward update, just update the record. --->
						<cfquery name="qUpdate" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
							UPDATE
								event
							SET
								name = <cfqueryparam value="#FORM.name#" cfsqltype="CF_SQL_VARCHAR" />, 					<!--- name --->
								description = <cfqueryparam value="#FORM.description#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- description --->
								date_started = <cfqueryparam value="#FORM.date_started#" cfsqltype="CF_SQL_TIMESTAMP" />, 	<!--- date_started --->
								date_ended = <cfqueryparam value="#FORM.date_ended#" cfsqltype="CF_SQL_TIMESTAMP" null="#NOT IsNumericDate( FORM.date_ended )#" />, 		<!--- date_ended --->
								time_started = <cfqueryparam value="#FORM.time_started#" cfsqltype="CF_SQL_VARCHAR" />, 	<!--- time_started --->
								time_ended = <cfqueryparam value="#FORM.time_ended#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- time_ended --->
								is_all_day = <cfqueryparam value="#FORM.is_all_day#" cfsqltype="CF_SQL_TINYINT" />, 		<!--- is_all_day --->
								repeat_type = <cfqueryparam value="#FORM.repeat_type#" cfsqltype="CF_SQL_TINYINT" />, 		<!--- repeat_type --->
								color = <cfqueryparam value="#FORM.color#" cfsqltype="CF_SQL_VARCHAR" />, 					<!--- color --->
								date_updated = <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" /> 				<!--- date_updated --->
							WHERE
								id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />						
						</cfquery>
					
					</cfdefaultcase>
										
				</cfswitch>
			
			
			<cfelse>
			
			
				<!--- This is a new event. --->
			
				<!--- Insert event. --->
				<cfquery name="qInsert" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
					INSERT INTO event
					(
						name,
						description,
						date_started,
						date_ended,
						time_started,
						time_ended,
						is_all_day,
						repeat_type,
						color,
						date_updated,
						date_created
					) VALUES (
						<cfqueryparam value="#Left( FORM.name, 80 )#" cfsqltype="CF_SQL_VARCHAR" />, 	<!--- name --->
						<cfqueryparam value="#FORM.description#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- description --->
						<cfqueryparam value="#FORM.date_started#" cfsqltype="CF_SQL_TIMESTAMP" />, 		<!--- date_started --->
						<cfqueryparam value="#FORM.date_ended#" cfsqltype="CF_SQL_TIMESTAMP" null="#NOT IsNumericDate( FORM.date_ended )#" />, 		<!--- date_ended --->
						<cfqueryparam value="#FORM.time_started#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- time_started --->
						<cfqueryparam value="#FORM.time_ended#" cfsqltype="CF_SQL_VARCHAR" />, 		<!--- time_ended --->
						<cfqueryparam value="#FORM.is_all_day#" cfsqltype="CF_SQL_TINYINT" />, 			<!--- is_all_day --->
						<cfqueryparam value="#FORM.repeat_type#" cfsqltype="CF_SQL_TINYINT" />, 		<!--- repeat_type --->
						<cfqueryparam value="#FORM.color#" cfsqltype="CF_SQL_VARCHAR" />, 				<!--- color --->
						<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" />, 					<!--- date_updated --->
						<cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP" /> 					<!--- date_created --->
					);
				</cfquery>
			
			</cfif>
		
			<!--- Go to month view. --->
			<cfif REQUEST.Attributes.viewas>
			
				<cflocation
					url="#CGI.script_name#?action=month&date=#REQUEST.Attributes.viewas#"
					addtoken="false"
					/>
			
			<cfelse>
			
				<cflocation
					url="#CGI.script_name#?action=month&date=#Fix( FORM.date_started )#"
					addtoken="false"
					/>
					
			</cfif>
		
		</cfif>
	
	<cfelse>
	
		<!---
			The form has not yet been submitted, so, if 
			we have an event, let's initialize the value.
		--->
		<cfif qEvent.RecordCount>
		
			<!--- Populate form fields. --->
			<cfset FORM.name = qEvent.name />
			<cfset FORM.description = qEvent.description />
			<cfset FORM.date_started = qEvent.date_started />
			<cfset FORM.date_ended = qEvent.date_ended />
			<cfset FORM.time_started = qEvent.time_started />
			<cfset FORM.time_ended = qEvent.time_ended />
			<cfset FORM.is_all_day = qEvent.is_all_day />
			<cfset FORM.repeat_type = qEvent.repeat_type />
			<cfset FORM.color = qEvent.color />
		
		<cfelse>
		
			<!--- Make sure we have no id set. --->
			<cfset REQUEST.Attributes.id = 0 />
						
			<!--- Default to all day event. --->
			<cfset FORM.is_all_day = 1 />
			
			<!--- Check to see if we have a default date. --->
			<cfif REQUEST.Attributes.viewas>
				<cfset FORM.date_started = DateFormat( REQUEST.Attributes.viewas, "mm/dd/yyyy" ) />
			<cfelse>
				<cfset FORM.date_started = DateFormat( REQUEST.DefaultDate, "mm/dd/yyyy" ) />
			</cfif>
			
		</cfif>	
	
	</cfif>
	
	
	<!--- 
		Check to see if we have a "Viewas" date. If we do,
		then we are goinna set that do be the default date.
	--->
	<cfif REQUEST.Attributes.viewas>
	
		<!--- This we be used when building the navigation. --->
		<cfset REQUEST.DefaultDate = Fix( REQUEST.Attributes.viewas ) />
		
	</cfif>
	
	
	<!--- 
		Loop over the form fields to make sure they are 
		display-ready. Without this, we might break out
		input fields with embedded quotes.
	--->
	<cfloop
		item="strKey"
		collection="#FORM#">
		
		<!--- Escape values. --->
		<cfset FORM[ strKey ] = HtmlEditFormat(
			FORM[ strKey ]
			) />
		
	</cfloop>
	
</cfsilent>

<cfinclude template="./includes/_header.cfm">

<cfoutput>

	<h2>
		Add Event
	</h2>

	
	<!--- Check to see if there are any form errors. --->
	<cfif ArrayLen( arrErrors )>
	
		<div class="formerrors">
		
			<h3>
				Please review the following:
			</h3>
			
			<ul>
				<!--- Loop over form errors to output. --->
				<cfloop 
					index="intError"
					from="1"
					to="#ArrayLen( arrErrors )#"
					step="1">
					
					<li>
						#arrErrors[ intError ]#
					</li>
					
				</cfloop>
			</ul>
			
		</div>
	
	</cfif>
	
	<form action="#CGI.script_name#" method="post">
	
		<!--- The action of the page (so that we submit back to ourselves). --->
		<input type="hidden" name="action" value="#REQUEST.Attributes.action#" />
		
		<!--- The flag that the form was submitted. --->
		<input type="hidden" name="submitted" value="1" />
		
		<!--- The ID of the event we are editing (if any). --->
		<input type="hidden" name="id" value="#REQUEST.Attributes.id#" />		
		
		<!--- The date on which this instance is being viewed. --->
		<input type="hidden" name="viewas" value="#REQUEST.Attributes.viewas#" />
	
	
		<table width="100%" cellspacing="0" class="dataform">
		<colgroup>
			<col />
			<col width="100%" />
		</colgroup>
		<tr>
			<td class="left">
				<label for="name">
					Name:
				</label>
			</td>
			<td class="right">
				<input type="text" id="name" name="name" value="#FORM.name#" maxlength="100" class="large" /><br />				
				
				<!--- 
					Check to see if we are editing an eixsting event that 
					has a repeat type. This only matters if we also have 
					the "viewas" date. If we don't have that, then we won't
					know what instance we are dealing with.
				--->
				<cfif (
					qEvent.RecordCount AND
					qEvent.repeat_type AND
					REQUEST.Attributes.viewas
					)>
				
					<div class="instancenote">
				
						<strong class="warning">
							Viewing Instance: #DateFormat( REQUEST.Attributes.viewas, "mmmm dd, yyyy" )#
						</strong>
					
						Update:<br />
						
						<input 
							type="radio" 
							name="update_type" 
							value="1" 
							<cfif (FORM.update_type EQ 1)>checked="true"</cfif> 
							/>
						Entire Series<br />
						
						<input 
							type="radio" 
							name="update_type" 
							value="2" 
							<cfif (FORM.update_type EQ 2)>checked="true"</cfif> 
							onclick="this.form.elements.date_started.value = '#DateFormat( REQUEST.Attributes.viewas, "mm/dd/yyyy" )#'; alert( 'Date has been changed' );"
							/>
						All Future Instances<br />
						
						<input 
							type="radio" 
							name="update_type" 
							value="3" 
							<cfif (FORM.update_type EQ 3)>checked="true"</cfif> 
							onclick="this.form.elements.date_started.value = this.form.elements.date_ended.value = '#DateFormat( REQUEST.Attributes.viewas, "mm/dd/yyyy" )#';  alert( 'Date has been changed' );"
							/> 
						Just This Instance<br />
				
					</div>
					
				</cfif>
			</td>
		</tr>
		<tr>
			<td class="left">
				<label for="date_started">
					Date:
				</label>
			</td>
			<td class="right">
				
				<table cellspacing="0" cellpadding="0">
				<tr>
					<td>
						<input 
							type="text" 
							id="date_started" 
							name="date_started" 
							value="<cfif IsDate( FORM.date_started )>#DateFormat( FORM.date_started, "mm/dd/yyyy" )#</cfif>" 
							maxlength="10" 
							class="date" 
							/><br />
					</td>
					<td valign="top" rowspan="2">
						&nbsp;&nbsp;-to-&nbsp;&nbsp;<br />
					</td>
					<td>
						<input 
							type="text" 
							id="date_ended" 
							name="date_ended" 
							value="<cfif IsDate( FORM.date_ended )>#DateFormat( FORM.date_ended, "mm/dd/yyyy" )#</cfif>" 
							maxlength="10" 
							class="date" 
							/><br />
					</td>
				</tr>
				<tr class="fieldnote">
					<td>
						From <em>(mm/dd/yyyy)</em><br />
					</td>
					<td>
						To <em>(mm/dd/yyyy)</em><br />
					</td>
				</tr>
				</table>
				
			</td>
		</tr>
		<tr>
			<td class="left">
				<label for="time_started">
					Time:
				</label>
			</td>
			<td class="right">
				
				<label for="is_all_day">
					<input type="checkbox" id="is_all_day" name="is_all_day" value="1" 
						<cfif FORM.is_all_day>checked="true"</cfif>
						onclick="ToggleIsAllDay( this.checked );"
						/>
					
					This Is An All Day Event
				</label>
								
				<table id="eventtimes" cellspacing="0" cellpadding="0" style="margin-top: 10px ;">
				<tr>
					<td>
						<input 
							type="text" 
							id="time_started" 
							name="time_started" 
							value="<cfif IsDate( FORM.time_started )>#TimeFormat( FORM.time_started, "hh:mm TT" )#</cfif>" 
							maxlength="8" 
							class="time" 
							<cfif FORM.is_all_day>disabled="true"</cfif>
							/><br />
					</td>
					<td valign="top" rowspan="2">
						&nbsp;&nbsp;-to-&nbsp;&nbsp;<br />
					</td>
					<td>
						<input 
							type="text" 
							id="time_ended" 
							name="time_ended" 
							value="<cfif IsDate( FORM.time_ended )>#TimeFormat( FORM.time_ended, "hh:mm TT" )#</cfif>" 
							maxlength="8" 
							class="time" 
							<cfif FORM.is_all_day>disabled="true"</cfif>
							/><br />
					</td>
				</tr>
				<tr class="fieldnote">
					<td>
						From <em>(h:mm AM/PM)</em><br />
					</td>
					<td>
						To <em>(h:mm AM/PM)</em><br />
					</td>
				</tr>
				</table>
				
			</td>
		</tr>
		<tr>
			<td class="left">
				<label for="repeat_type">
					Repeat:		
				</label>
			</td>
			<td class="right">
				<select id="repeat_type" name="repeat_type">
					<option value="0">No repeat</option>
					
					<cfloop query="REQUEST.RepeatTypes">
						<option value="#REQUEST.RepeatTypes.id#"
							<cfif (FORM.repeat_type EQ REQUEST.RepeatTypes.id)>selected="true"</cfif>
							>#REQUEST.RepeatTypes.name#</option>			
					</cfloop>
				</select><br />
			</td>
		</tr>
		<tr>
			<td class="left">
				<label for="color">
					Color:		
				</label>
			</td>
			<td class="right">
				<select id="color" name="color">
					<option value="">No Color</option>
					
					<cfloop 
						index="intI"
						from="1"
						to="#ArrayLen( arrColors )#"
						step="1">
						<option value="#arrColors[ intI ]#" 
							style="background-color: ###arrColors[ intI ]# ;"
							<cfif (FORM.color EQ arrColors[ intI ])>selected="true"</cfif>
							>#arrColors[ intI ]#</option>			
					</cfloop>
				</select><br />
			</td>
		</tr>
		<tr>
			<td class="left">
				<label for="description">
					Description:		
				</label>
			</td>
			<td class="right">
				<textarea name="description" id="description" class="description">#FORM.description#</textarea><br />				
			</td>
		</tr>
		<tr>
			<td class="left">
				<br />
			</td>
			<td class="right">
				<input type="submit" value="Add / Update Event" /><br />
			</td>
		</tr>
		</table>
		
		
		<cfif REQUEST.Attributes.viewas>
		
			<p>	
				<a href="./index.cfm?action=month&date=#REQUEST.Attributes.viewas#">Cancel</a>
			</p>
			
			<!--- Check to see if we have an existing event. --->
			<cfif qEvent.RecordCount>
			
				<p>	
					<a href="./index.cfm?action=delete&id=#qEvent.id#&viewas=#REQUEST.Attributes.viewas#">Delete</a>
				</p>
				
			</cfif>
			
		<cfelse>
			
			<p>
				<a href="./index.cfm?action=month<cfif qEvent.RecordCount>&date=#Fix( qEvent.date_started )#</cfif>">Cancel</a>
			</p>
			
			<!--- Check to see if we have an existing event. --->
			<cfif qEvent.RecordCount>
			
				<p>	
					<a href="./index.cfm?action=delete&id=#qEvent.id#">Delete</a>
				</p>
				
			</cfif>
			
		</cfif>
		
	</form>

</cfoutput>

<cfinclude template="./includes/_footer.cfm">