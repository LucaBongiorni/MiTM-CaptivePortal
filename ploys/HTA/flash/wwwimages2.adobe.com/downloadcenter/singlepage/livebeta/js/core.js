/*-------------------------------------------------------------------
Name: Single Page PDC - Core JS
$Author: kpalani $
$DateTime: 2014/05/29 06:51:36 $
$Revision: #3 $
-------------------------------------------------------------------*/

$(function() {
	// Special links setup
	$("a[rel='learnmore']").live('click', function(event) {
		event.preventDefault();
		
		$("#learnMorePanel").toggle();
	});
	
	$("a[rel='learnmoregtb']").live('click', function(event) {
		event.preventDefault();
		$('#learnMorePanelChrome').hide();
		$("#learnMorePanelGTB").toggle();
	});
	
	$("a[rel='learnmorechr']").live('click', function(event) {
		event.preventDefault();
		$('#learnMorePanelGTB').hide();
		$("#learnMorePanelChrome").toggle();
	});
	
	$("a[rel='installoptions']").live('click', function(event) {
		event.preventDefault();
		
		var dualOfferWidth = 350;		
		if (locale === "hu" || locale === "hr" || locale === "it") 
			dualOfferWidth = 415;
		else if (locale === "cz" || locale === "sk" || locale === "pl" || locale === "es")
			dualOfferWidth = 485;
		else if (locale === "ua")
			dualOfferWidth = 565;
		
		$("#dualOfferInstallOptions").dialog({
			dialogClass: "close-button", 
			modal: true, 
			minWidth: dualOfferWidth, 
			minHeight: 110,
			open: function() {
				$(".ui-widget-overlay").bind('click', function() {
					$("#dualOfferInstallOptions").dialog('close');
				});
			},
			close: function() {
				$(".ui-widget-overlay").unbind('click');
			}
		});
	});

	$("a[rel='modal']").live('click', function(event) {
		event.preventDefault();

		var destURL = $(this).attr("href");
		
		if ($.string(destURL).startsWith('http') || $.string(destURL).startsWith('//'))  {
			handleModal({width: 860, height: 438, external: true, target: "modal-ui", href: this.href, title: this.title});
		}
		else {
			handleModal({width: "auto", height: "auto", external: false, target: "modal-ui", href: this.href, title: this.title});
		}
	});
	
	// Footer Region text change
	var countryCode = $.cookies.get('international');
    if (countryCode) {
        $('#RegionLinkSet').show();
        $('#RegionLink').hide();
    }
    else {
        $('#RegionLinkSet').hide();
        $('#RegionLink').show();
    }
	
	// Region panel click events
	$('#RegionPanel').bind( "clickoutside focusout", function(){
		$('#RegionPanel').hide();
		return false;
	});
	
	$('#RegionLink a, #RegionLinkSet a, #RegionClose').bind( "click", function(){
		$('#RegionPanel').toggle();
		return false;
	});
	
	// Function for changing the region via the Region Panel
	changeRegion = function(regioncode) {
		// Normalize the storeregion cookies and set the cookies with a duration of 1 year
		if ($.string(regioncode).startsWith('be_')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'be', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else if ($.string(regioncode).startsWith('ca')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'ca', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else if ($.string(regioncode).startsWith('eeur')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'eu', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else if ($.string(regioncode).startsWith('hk_')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'cn', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else if ($.string(regioncode).startsWith('lu_')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'lu', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else if ($.string(regioncode).startsWith('uk')) {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', 'gb', {domain: 'adobe.com', hoursToLive: 8760});
		}
		else {
			$.cookies.set('international', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
			$.cookies.set('storeregion', regioncode, {domain: 'adobe.com', hoursToLive: 8760});
		}
	
		// Get the URL the user is on
		var currURL = window.location.pathname + window.location.search;
		
		// Remove the CQ pathing and EN locale if present to ensure proper locale detection and redirection
		if ( $.string(currURL).startsWith('/content/dotcom/') ) {
			currURL = currURL.replace('/content/dotcom/','/');
		}
		else if ( $.string(currURL).startsWith('/content/help/') ) {
			currURL = currURL.replace('/content/help/','/');
		}	
	
		if ( $.string(currURL).startsWith('/en/') ) {
			currURL = currURL.replace('/en/','/');
		}	
	
		// Set up an array of all the locales on adobe.com in the WCMS
		var geoArray = ["africa","ap","at","au","be_en","be_fr","be_nl","bg","br","ca","ca_fr","ch_de","ch_fr","ch_it","cn","cz","de","dk","eeurope","ee","en","es","fi","fr","hk_en","hk_zh","hr","hu","ie","il_en","il_he","in","it","jp","kr","la","lt","lu_de","lu_en","lu_fr","lv","mena_ar","mena_en","mena_fr","mx","nl","no","nz","pl","pt","ro","ru","si","se","sea","sk","tr","tw","ua","uk"];
	
		// Go through the array and remove the locale folder path, if present, to know what page to check for
		$.each(geoArray, function() {
			if ($.string(currURL).startsWith('/'+this+'/')) {
				currURL = currURL.replace('/'+this+'/','/');
				return false;
			}
		});
			
		// Build the URLs to redirect the user to:
		// newURL = the URL of the page the user is on in the region they selected
		// homeURL = the URL of the homepage in the region they selected
		if (regioncode != 'us') {
			newURL = "/" + regioncode + currURL;
		}
		else {
			newURL = currURL;
		}
	
		// Check to see if the page we want to send the user to actually exists, and if not, go to the homepage instead
		$.ajax({
			url: newURL,
			type: 'HEAD',
			error:
				function() {
					location.reload();
				},
			success:
				function(){
					window.location = newURL;
				}
		});
	};
});