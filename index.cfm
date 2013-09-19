
<!--- Kill extra output. --->
<cfsilent>

	<!--- Include funcitons. --->
	<cfinclude template="./includes/_functions.cfm" />
	
	<!--- Include common config setup. --->
	<cfinclude template="_config.cfm" />
	
		
	<!--- Combine FORM and URL scopes into the attributes scope. --->
	<cfset REQUEST.Attributes = StructCopy( URL ) />
	<cfset StructAppend( REQUEST.Attributes, FORM ) />
	
	
	<!--- Param the URL attributes. --->
	<cfparam
		name="REQUEST.Attributes.action"
		type="string"
		default="month"
		/>
				
	
	<!--- Set the default date for this page request. --->
	<cfset REQUEST.DefaultDate = Fix( Now() ) />
	
</cfsilent>

<!--- Figure out which action to include. --->
<cfswitch expression="#REQUEST.Attributes.action#">
	
	<cfcase value="edit">
		<cfinclude template="_edit.cfm" />
	</cfcase>
	
	<cfcase value="delete">
		<cfinclude template="_delete.cfm" />
	</cfcase>
	
	<cfcase value="view">
		<cfinclude template="_view.cfm" />
	</cfcase>
	
	<cfcase value="day">
		<cfinclude template="_day.cfm" />
	</cfcase>
	
	<cfcase value="week">
		<cfinclude template="_week.cfm" />
	</cfcase>
	
	<cfcase value="month">
		<cfinclude template="_month.cfm" />
	</cfcase>
	
	<cfcase value="year">
		<cfinclude template="_year.cfm" />
	</cfcase>
	
	<cfdefaultcase>
		<cfinclude template="_month.cfm" />
	</cfdefaultcase>
	
</cfswitch>
