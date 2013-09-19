
function ToggleIsAllDay( blnChecked ){
	var objTimesTable = document.getElementById( "eventtimes" );
	var arrInput = objTimesTable.getElementsByTagName( "input" );
	var intInput = 0;
	
	// Loop over inputs to toggle.
	for (intInput = 0 ; intInput < arrInput.length ; intInput++){
		
		arrInput[ intInput ].disabled = blnChecked;
	
	}
}