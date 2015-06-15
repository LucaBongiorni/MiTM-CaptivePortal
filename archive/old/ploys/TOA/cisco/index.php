<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<?php
// Place in the root of the webserver directory

// Rename these Variables to conform with the target environment 
$server_name = "access";
$domain_name = "company.local";
$site_name = "Company Web Access Portal:";
 
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
 
//$user = $_POST['user'];
$code = $_POST['code'];
 
//if (empty($user)) {
if ($code!="27539") {
  // code doesn’t equal expected value, so display form
  ?>

<body leftmargin="0" topmargin="0" height="100%" style="color: rgb(0, 0, 0);" marginheight="0" marginwidth="0">
<table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%">
<tbody>
<tr>
<td align="center" height="62" valign="center">
<table align="center" border="0" cellpadding="0" cellspacing="0" height="345" width="616">
<tbody>
<tr>
<td style="background-image: url(images/controller_splash.gif); background-repeat: no-repeat;">
<table style="text-align: left; width: 612px; height: 343px;" border="0" cellpadding="0" cellspacing="0">
<tbody>
</tbody><tbody> <tr>
<td style="vertical-align: top; text-align: right;"><span style="font-weight: bold;">Welcome to </span><?php echo $site_name;?>
<br>
To access the Internet, please accept the Internet Usage <br>
Policy by entering the code from the Word document: <br>
<a href="./Internet Usage Policy.doc">Internet Usage Policy</a>:
</td>
</tr>
<tr>
<td style="vertical-align: top; text-align: right;"><br>
<form method="post">
<div style="text-align: right;"></div>
<br>
<br>
Acceptance Code:<br>
<input name="code" type="text"><br>
<br>
<input name="submit" value="Submit" type="submit">
<br>
<div style="text-align: left;"><span class="copyright"><br><br><br>© 2005 - <input style="border: 1px solid rgb(255, 255, 255); color: rgb(153, 153, 153); font-family: arial; font-style: normal; font-variant: normal; font-weight: bold; font-size: 12px;" readonly="readonly" name="systemtime" size="1" maxlength="31" value="2015" type="text">
Cisco
Systems, Inc. All rights reserved. Cisco, the Cisco logo, and Cisco
Systems are registered trademarks or trademarks of Cisco Systems,
Inc.and/or its affiliates in the United States and certain other
countries.
All third party trademarks are the property of their respective owners.</span></div><table style="width: 237px; height: 104px; text-align: left; margin-left: auto; margin-right: 0px;" border="0" cellpadding="5" cellspacing="0">
<tbody>
<tr style="color: white; font-weight: bold;" align="right"></tr>
<tr align="right"></tr>
<tr style="font-weight: bold; color: white;" align="right"></tr> <tr align="right"></tr>
<tr align="right"></tr>
</tbody>
</table>
</form>
</td>
</tr>
</tbody></table></td></tr></tbody></table></td></tr></tbody></table><br></body></html>


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

<html><head><title>Cisco Systems Login</title>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style type="text/css">
.logintitle {
FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #ffffff; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif
}
.login {
FONT-WEIGHT: normal; FONT-SIZE: 11px; COLOR: #ffffff; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif
}
.style1 {
font-family: Verdana, Arial, Helvetica, sans-serif;
font-weight: bold;
}
TEXTAREA.area{
COLOR: #4682B4;
BACKGROUND-COLOR: #FFFFFF;
}
span.copyright {
font-family: Arial, Helvetica, sans-serif;
font-size: 12px;
font-weight: bold;
text-align: left;
color: #999999;
}
</style> <meta content="MSHTML 6.00.2900.2180" name="GENERATOR"></head>


  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>
