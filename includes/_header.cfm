
<cfoutput>

	<!--- Reset buffer and set content type. --->
	<cfcontent
		type="text/html"
		reset="true"
		/>
	
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html>
	<head>
		<title>Kinky Calendar</title>
		
		<!-- Linked files. -->
		<script type="text/javascript" src="./linked/global.js"></script>
		<link rel="stylesheet" type="text/css" href="./linked/content.css"></link>
		<link rel="stylesheet" type="text/css" href="./linked/meta_content.css"></link>
		<link rel="stylesheet" type="text/css" href="./linked/structure.css"></link>
	</head>
	<body>
	
		<!-- BEGIN: Site Header. -->
		<div id="siteheader">
			
			<h1>
				Kinky Calendar - ColdFusion Calendar System
			</h1>
			
			<div class="rule">
				<br />
			</div>
			
			<ul id="primarynav">
				<li class="nav1">
					<a href="./index.cfm?action=year&date=#REQUEST.DefaultDate#" <cfif (REQUEST.Attributes.action EQ "year")>class="on"</cfif>>Year View</a>
				</li>
				<li class="nav2">
					<a href="./index.cfm?action=month&date=#REQUEST.DefaultDate#" <cfif (REQUEST.Attributes.action EQ "month")>class="on"</cfif>>Month View</a>
				</li>
				<li class="nav3">
					<a href="./index.cfm?action=week&date=#REQUEST.DefaultDate#" <cfif (REQUEST.Attributes.action EQ "week")>class="on"</cfif>>Week View</a>
				</li>
				<li class="nav4">
					<a href="./index.cfm?action=day&date=#REQUEST.DefaultDate#" <cfif (REQUEST.Attributes.action EQ "day")>class="on"</cfif>>Day View</a>
				</li>
				<li class="nav5">
					<a href="./index.cfm?action=edit&date=#REQUEST.DefaultDate#" <cfif (REQUEST.Attributes.action EQ "edit")>class="on"</cfif>>Add New Event</a>
				</li>
			</ul>
		
		</div>
		<!-- END: Site Header. -->
	
		
		<!-- BEGIN: Site Content. -->
		<div id="sitecontent">
			<div class="buffer">

</cfoutput>