
<!--- Kill extra output. --->
<cfsilent>

	<!--- Set up repeat types. --->
	<cfset REQUEST.RepeatTypes = QueryNew( "id, name" ) />
	
	<!--- Set repeat types. --->
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 1 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Daily" />
	
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 2 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Weekly" />
	
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 3 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Bi-Weekly" />
		
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 4 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Monthly" />
	
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 5 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Yearly" />
	
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 6 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Mon - Fri" />
	
	<cfset QueryAddRow( REQUEST.RepeatTypes ) />
	<cfset REQUEST.RepeatTypes[ "id" ][ REQUEST.RepeatTypes.RecordCount ] = 7 />
	<cfset REQUEST.RepeatTypes[ "name" ][ REQUEST.RepeatTypes.RecordCount ] = "Sat - Sun" />
	
	
	<!--- Set up event colors. --->
	<cfset arrColors = ArrayNew( 1 ) />
	<cfset ArrayAppend( arrColors, "000033" ) />
	<cfset ArrayAppend( arrColors, "000066" ) />
	<cfset ArrayAppend( arrColors, "000099" ) />
	<cfset ArrayAppend( arrColors, "0000CC" ) />
	<cfset ArrayAppend( arrColors, "0000FF" ) />
	<cfset ArrayAppend( arrColors, "003300" ) />
	<cfset ArrayAppend( arrColors, "003333" ) />
	<cfset ArrayAppend( arrColors, "003366" ) />
	<cfset ArrayAppend( arrColors, "003399" ) />
	<cfset ArrayAppend( arrColors, "0033CC" ) />
	<cfset ArrayAppend( arrColors, "0033FF" ) />
	<cfset ArrayAppend( arrColors, "006600" ) />
	<cfset ArrayAppend( arrColors, "006633" ) />
	<cfset ArrayAppend( arrColors, "006666" ) />
	<cfset ArrayAppend( arrColors, "006699" ) />
	<cfset ArrayAppend( arrColors, "0066CC" ) />
	<cfset ArrayAppend( arrColors, "0066FF" ) />
	<cfset ArrayAppend( arrColors, "009900" ) />
	<cfset ArrayAppend( arrColors, "009933" ) />
	<cfset ArrayAppend( arrColors, "009966" ) />
	<cfset ArrayAppend( arrColors, "009999" ) />
	<cfset ArrayAppend( arrColors, "0099CC" ) />
	<cfset ArrayAppend( arrColors, "0099FF" ) />
	<cfset ArrayAppend( arrColors, "00CC00" ) />
	<cfset ArrayAppend( arrColors, "00CC33" ) />
	<cfset ArrayAppend( arrColors, "00CC66" ) />
	<cfset ArrayAppend( arrColors, "00CC99" ) />
	<cfset ArrayAppend( arrColors, "00CCCC" ) />
	<cfset ArrayAppend( arrColors, "00CCFF" ) />
	<cfset ArrayAppend( arrColors, "00FF00" ) />
	<cfset ArrayAppend( arrColors, "00FF33" ) />
	<cfset ArrayAppend( arrColors, "00FF66" ) />
	<cfset ArrayAppend( arrColors, "00FF99" ) />
	<cfset ArrayAppend( arrColors, "00FFCC" ) />
	<cfset ArrayAppend( arrColors, "00FFFF" ) />
	<cfset ArrayAppend( arrColors, "330000" ) />
	<cfset ArrayAppend( arrColors, "330033" ) />
	<cfset ArrayAppend( arrColors, "330066" ) />
	<cfset ArrayAppend( arrColors, "330099" ) />
	<cfset ArrayAppend( arrColors, "3300CC" ) />
	<cfset ArrayAppend( arrColors, "3300FF" ) />
	<cfset ArrayAppend( arrColors, "333300" ) />
	<cfset ArrayAppend( arrColors, "333333" ) />
	<cfset ArrayAppend( arrColors, "333366" ) />
	<cfset ArrayAppend( arrColors, "333399" ) />
	<cfset ArrayAppend( arrColors, "3333CC" ) />
	<cfset ArrayAppend( arrColors, "3333FF" ) />
	<cfset ArrayAppend( arrColors, "336600" ) />
	<cfset ArrayAppend( arrColors, "336633" ) />
	<cfset ArrayAppend( arrColors, "336666" ) />
	<cfset ArrayAppend( arrColors, "336699" ) />
	<cfset ArrayAppend( arrColors, "3366CC" ) />
	<cfset ArrayAppend( arrColors, "3366FF" ) />
	<cfset ArrayAppend( arrColors, "339900" ) />
	<cfset ArrayAppend( arrColors, "339933" ) />
	<cfset ArrayAppend( arrColors, "339966" ) />
	<cfset ArrayAppend( arrColors, "339999" ) />
	<cfset ArrayAppend( arrColors, "3399CC" ) />
	<cfset ArrayAppend( arrColors, "3399FF" ) />
	<cfset ArrayAppend( arrColors, "33CC00" ) />
	<cfset ArrayAppend( arrColors, "33CC33" ) />
	<cfset ArrayAppend( arrColors, "33CC66" ) />
	<cfset ArrayAppend( arrColors, "33CC99" ) />
	<cfset ArrayAppend( arrColors, "33CCCC" ) />
	<cfset ArrayAppend( arrColors, "33CCFF" ) />
	<cfset ArrayAppend( arrColors, "33FF00" ) />
	<cfset ArrayAppend( arrColors, "33FF33" ) />
	<cfset ArrayAppend( arrColors, "33FF66" ) />
	<cfset ArrayAppend( arrColors, "33FF99" ) />
	<cfset ArrayAppend( arrColors, "33FFCC" ) />
	<cfset ArrayAppend( arrColors, "33FFFF" ) />
	<cfset ArrayAppend( arrColors, "660000" ) />
	<cfset ArrayAppend( arrColors, "660033" ) />
	<cfset ArrayAppend( arrColors, "660066" ) />
	<cfset ArrayAppend( arrColors, "660099" ) />
	<cfset ArrayAppend( arrColors, "6600CC" ) />
	<cfset ArrayAppend( arrColors, "6600FF" ) />
	<cfset ArrayAppend( arrColors, "663300" ) />
	<cfset ArrayAppend( arrColors, "663333" ) />
	<cfset ArrayAppend( arrColors, "663366" ) />
	<cfset ArrayAppend( arrColors, "663399" ) />
	<cfset ArrayAppend( arrColors, "6633CC" ) />
	<cfset ArrayAppend( arrColors, "6633FF" ) />
	<cfset ArrayAppend( arrColors, "666600" ) />
	<cfset ArrayAppend( arrColors, "666633" ) />
	<cfset ArrayAppend( arrColors, "666666" ) />
	<cfset ArrayAppend( arrColors, "666699" ) />
	<cfset ArrayAppend( arrColors, "6666CC" ) />
	<cfset ArrayAppend( arrColors, "6666FF" ) />
	<cfset ArrayAppend( arrColors, "669900" ) />
	<cfset ArrayAppend( arrColors, "669933" ) />
	<cfset ArrayAppend( arrColors, "669966" ) />
	<cfset ArrayAppend( arrColors, "669999" ) />
	<cfset ArrayAppend( arrColors, "6699CC" ) />
	<cfset ArrayAppend( arrColors, "6699FF" ) />
	<cfset ArrayAppend( arrColors, "66CC00" ) />
	<cfset ArrayAppend( arrColors, "66CC33" ) />
	<cfset ArrayAppend( arrColors, "66CC66" ) />
	<cfset ArrayAppend( arrColors, "66CC99" ) />
	<cfset ArrayAppend( arrColors, "66CCCC" ) />
	<cfset ArrayAppend( arrColors, "66CCFF" ) />
	<cfset ArrayAppend( arrColors, "66FF00" ) />
	<cfset ArrayAppend( arrColors, "66FF33" ) />
	<cfset ArrayAppend( arrColors, "66FF66" ) />
	<cfset ArrayAppend( arrColors, "66FF99" ) />
	<cfset ArrayAppend( arrColors, "66FFCC" ) />
	<cfset ArrayAppend( arrColors, "66FFFF" ) />
	<cfset ArrayAppend( arrColors, "990000" ) />
	<cfset ArrayAppend( arrColors, "990033" ) />
	<cfset ArrayAppend( arrColors, "990066" ) />
	<cfset ArrayAppend( arrColors, "990099" ) />
	<cfset ArrayAppend( arrColors, "9900CC" ) />
	<cfset ArrayAppend( arrColors, "9900FF" ) />
	<cfset ArrayAppend( arrColors, "993300" ) />
	<cfset ArrayAppend( arrColors, "993333" ) />
	<cfset ArrayAppend( arrColors, "993366" ) />
	<cfset ArrayAppend( arrColors, "993399" ) />
	<cfset ArrayAppend( arrColors, "9933CC" ) />
	<cfset ArrayAppend( arrColors, "9933FF" ) />
	<cfset ArrayAppend( arrColors, "996600" ) />
	<cfset ArrayAppend( arrColors, "996633" ) />
	<cfset ArrayAppend( arrColors, "996666" ) />
	<cfset ArrayAppend( arrColors, "996699" ) />
	<cfset ArrayAppend( arrColors, "9966CC" ) />
	<cfset ArrayAppend( arrColors, "9966FF" ) />
	<cfset ArrayAppend( arrColors, "999900" ) />
	<cfset ArrayAppend( arrColors, "999933" ) />
	<cfset ArrayAppend( arrColors, "999966" ) />
	<cfset ArrayAppend( arrColors, "999999" ) />
	<cfset ArrayAppend( arrColors, "9999CC" ) />
	<cfset ArrayAppend( arrColors, "9999FF" ) />
	<cfset ArrayAppend( arrColors, "99CC00" ) />
	<cfset ArrayAppend( arrColors, "99CC33" ) />
	<cfset ArrayAppend( arrColors, "99CC66" ) />
	<cfset ArrayAppend( arrColors, "99CC99" ) />
	<cfset ArrayAppend( arrColors, "99CCCC" ) />
	<cfset ArrayAppend( arrColors, "99CCFF" ) />
	<cfset ArrayAppend( arrColors, "99FF00" ) />
	<cfset ArrayAppend( arrColors, "99FF33" ) />
	<cfset ArrayAppend( arrColors, "99FF66" ) />
	<cfset ArrayAppend( arrColors, "99FF99" ) />
	<cfset ArrayAppend( arrColors, "99FFCC" ) />
	<cfset ArrayAppend( arrColors, "99FFFF" ) />
	<cfset ArrayAppend( arrColors, "CC0000" ) />
	<cfset ArrayAppend( arrColors, "CC0033" ) />
	<cfset ArrayAppend( arrColors, "CC0066" ) />
	<cfset ArrayAppend( arrColors, "CC0099" ) />
	<cfset ArrayAppend( arrColors, "CC00CC" ) />
	<cfset ArrayAppend( arrColors, "CC00FF" ) />
	<cfset ArrayAppend( arrColors, "CC3300" ) />
	<cfset ArrayAppend( arrColors, "CC3333" ) />
	<cfset ArrayAppend( arrColors, "CC3366" ) />
	<cfset ArrayAppend( arrColors, "CC3399" ) />
	<cfset ArrayAppend( arrColors, "CC33CC" ) />
	<cfset ArrayAppend( arrColors, "CC33FF" ) />
	<cfset ArrayAppend( arrColors, "CC6600" ) />
	<cfset ArrayAppend( arrColors, "CC6633" ) />
	<cfset ArrayAppend( arrColors, "CC6666" ) />
	<cfset ArrayAppend( arrColors, "CC6699" ) />
	<cfset ArrayAppend( arrColors, "CC66CC" ) />
	<cfset ArrayAppend( arrColors, "CC66FF" ) />
	<cfset ArrayAppend( arrColors, "CC9900" ) />
	<cfset ArrayAppend( arrColors, "CC9933" ) />
	<cfset ArrayAppend( arrColors, "CC9966" ) />
	<cfset ArrayAppend( arrColors, "CC9999" ) />
	<cfset ArrayAppend( arrColors, "CC99CC" ) />
	<cfset ArrayAppend( arrColors, "CC99FF" ) />
	<cfset ArrayAppend( arrColors, "CCCC00" ) />
	<cfset ArrayAppend( arrColors, "CCCC33" ) />
	<cfset ArrayAppend( arrColors, "CCCC66" ) />
	<cfset ArrayAppend( arrColors, "CCCC99" ) />
	<cfset ArrayAppend( arrColors, "CCCCCC" ) />
	<cfset ArrayAppend( arrColors, "CCCCFF" ) />
	<cfset ArrayAppend( arrColors, "CCFF00" ) />
	<cfset ArrayAppend( arrColors, "CCFF33" ) />
	<cfset ArrayAppend( arrColors, "CCFF66" ) />
	<cfset ArrayAppend( arrColors, "CCFF99" ) />
	<cfset ArrayAppend( arrColors, "CCFFCC" ) />
	<cfset ArrayAppend( arrColors, "CCFFFF" ) />
	<cfset ArrayAppend( arrColors, "FF0000" ) />
	<cfset ArrayAppend( arrColors, "FF0033" ) />
	<cfset ArrayAppend( arrColors, "FF0066" ) />
	<cfset ArrayAppend( arrColors, "FF0099" ) />
	<cfset ArrayAppend( arrColors, "FF00CC" ) />
	<cfset ArrayAppend( arrColors, "FF00FF" ) />
	<cfset ArrayAppend( arrColors, "FF3300" ) />
	<cfset ArrayAppend( arrColors, "FF3333" ) />
	<cfset ArrayAppend( arrColors, "FF3366" ) />
	<cfset ArrayAppend( arrColors, "FF3399" ) />
	<cfset ArrayAppend( arrColors, "FF33CC" ) />
	<cfset ArrayAppend( arrColors, "FF33FF" ) />
	<cfset ArrayAppend( arrColors, "FF6600" ) />
	<cfset ArrayAppend( arrColors, "FF6633" ) />
	<cfset ArrayAppend( arrColors, "FF6666" ) />
	<cfset ArrayAppend( arrColors, "FF6699" ) />
	<cfset ArrayAppend( arrColors, "FF66CC" ) />
	<cfset ArrayAppend( arrColors, "FF66FF" ) />
	<cfset ArrayAppend( arrColors, "FF9900" ) />
	<cfset ArrayAppend( arrColors, "FF9933" ) />
	<cfset ArrayAppend( arrColors, "FF9966" ) />
	<cfset ArrayAppend( arrColors, "FF9999" ) />
	<cfset ArrayAppend( arrColors, "FF99CC" ) />
	<cfset ArrayAppend( arrColors, "FF99FF" ) />
	<cfset ArrayAppend( arrColors, "FFCC00" ) />
	<cfset ArrayAppend( arrColors, "FFCC33" ) />
	<cfset ArrayAppend( arrColors, "FFCC66" ) />
	<cfset ArrayAppend( arrColors, "FFCC99" ) />
	<cfset ArrayAppend( arrColors, "FFCCCC" ) />
	<cfset ArrayAppend( arrColors, "FFCCFF" ) />
	<cfset ArrayAppend( arrColors, "FFFF00" ) />
	<cfset ArrayAppend( arrColors, "FFFF33" ) />
	<cfset ArrayAppend( arrColors, "FFFF66" ) />
	<cfset ArrayAppend( arrColors, "FFFF99" ) />
	<cfset ArrayAppend( arrColors, "FFFFCC" ) />

</cfsilent>