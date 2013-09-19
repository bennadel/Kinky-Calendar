
<!--- Kill extra output. --->
<cfsilent>

	<!--- Param FORM values. --->
	
	<!--- 
		The following parameters require type checking 
		and might throw errors.
	--->
	<cftry>
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
			repeat_type
		FROM
			event e
		WHERE
			e.id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />
	</cfquery>
	
	
	<!--- Check to make sure we have an event to delete. --->
	<cfif NOT qEvent.RecordCount>
	
		<!--- No event was found - redirect user. --->
		<cflocation 
			url="./index.cfm?action=month&date=#REQUEST.Attributes.viewas#"
			addtoken="false"
			/>
		
	</cfif>
	
		
	
	<!--- Check to see if form has been submitted. --->
	<cfif FORM.submitted>
	
		<!--- 
			Now that the form has been submitted, let's clean 
			up the data a little.
		--->
		
		<!--- 
			Check to see if we have a "viewas" date. If we don't
			then, we have NO choice but to update the entire series.
		--->
		<cfif NOT REQUEST.Attributes.viewas>
		
			<!--- Update entire series. --->
			<cfset FORM.update_type = 1 />
		
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
			
			<!--- 
				We are dealing with an existing event. Now, we 
				have to be careful about the update type.
			--->
			<cfswitch expression="#FORM.update_type#">
			
				<!--- All future instances in series. --->
				<cfcase value="2">
				
					<!--- 
						Since we are deleting all future instances, we basically
						just need to move the end date (if there is one) up until 
						the day just prior to the "viewas" date. The events going
						forward will no longer exist.
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
					
				</cfcase>
				
				<!--- Just this instance. --->
				<cfcase value="3">
				
					<!--- 
						Since we are deleteing just this instance, we are 
						basically creating an event exception on this date.
					--->
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
				
					<!--- 
						Here, we are deleting all instances in series, which 
						basically means we are fully deleting this event. When
						doing this, though, we have to be carefule to delete
						all event exceptions for this as well.						
					--->
					<cfquery name="qDelete" datasource="#REQUEST.DSN.Source#" username="#REQUEST.DSN.Username#" password="#REQUEST.DSN.Password#">
						<!--- Delete event. --->
						DELETE FROM
							event
						WHERE
							id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />
						;
						
						<!--- Delete event exceptions. --->
						DELETE FROM
							event_exception
						WHERE
							event_id = <cfqueryparam value="#REQUEST.Attributes.id#" cfsqltype="CF_SQL_INTEGER" />
						;
					</cfquery>
				
				</cfdefaultcase>
									
			</cfswitch>
			
			
			<!--- Go to month view. --->
			<cfif REQUEST.Attributes.viewas>
			
				<cflocation
					url="#CGI.script_name#?action=month&date=#REQUEST.Attributes.viewas#"
					addtoken="false"
					/>
					
			<cfelse>
					
				<cflocation
					url="#CGI.script_name#?action=month&date=#Fix( qEvent.date_started )#"
					addtoken="false"
					/>
					
			</cfif>
		
		</cfif>
	
	<cfelse>
	
		<!---
			The form has not yet been submitted, so, if 
			we have an event, let's initialize the value.
		--->
		
	</cfif>
	
</cfsilent>

<cfinclude template="./includes/_header.cfm">

<cfoutput>

	<h2>
		Delete Event
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
			<td class="righttext">
				#HtmlEditFormat( qEvent.name )#
				
				<!--- 
					Check to see if we are deleting an event that has a 
					repeat type. This only matters if we also have the 
					"viewas" date. If we don't have that, then we won't
					know what instance we are dealing with and will
					*have* to work on the entire series.
				--->
				<cfif (
					qEvent.repeat_type AND
					REQUEST.Attributes.viewas
					)>
				
					<div class="instancenote">
				
						<strong class="warning">
							Viewing Instance: #DateFormat( REQUEST.Attributes.viewas, "mmmm dd, yyyy" )#
						</strong>
					
						Delete:<br />
						
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
				<br />
			</td>
			<td class="right">
				<input type="submit" value="Delete Event" /><br />
			</td>
		</tr>
		</table>
		
		
		<p>
			<cfif REQUEST.Attributes.viewas>
				
				<a href="./index.cfm?action=month&date=#REQUEST.Attributes.viewas#">Cancel</a>
				
			<cfelse>
			
				<a href="./index.cfm?action=month&date=#Fix( qEvent.date_started )#">Cancel</a>
			
			</cfif>
		</p>
		
	</form>

</cfoutput>

<cfinclude template="./includes/_footer.cfm">