<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<style>
body, ul, li {
font-family:Arial, Helvetica, sans-serif;
font-size:12px;
color:#737373;
margin:0;
padding:0;
}
a:link, a:visited, a:active {
text-decoration: underline;
color:#015589;
}
a:hover {
text-decoration: none;
color:#51A8DE;
}
.content {
padding: 20px 15px 15px 70px;
margin: 0px auto 6px auto;
border: #ebebeb solid 1px;
width: 500px;
}
.blocking, .quotaing, .warning, .message {
background-repeat:no-repeat;
background-position: 9px 9px;
}
.blocking {
border-top: #D52B1E solid 2px;
border-bottom: #D52B1E solid 2px;
background-image:url(images/ico_status_error.png);
}
.quotaing {
border-top: #A4D3EE solid 2px;
border-bottom: #A4D3EE solid 2px;
background-image:url(images/ico_status_quotaing.png);
}
.warning {
border-top: #F0AB00 solid 2px;
border-bottom: #F0AB00 solid 2px;
background-image:url(images/ico_status_warning.png);
}
.message {
border-top: #0076C0 solid 2px;
border-bottom: #0076C0 solid 2px;
background-image:url(images/ico_info.png);
}
.title {
font-size: 24px;
border-bottom: #ccc solid 1px;
padding-bottom:15px;
margin-bottom:15px;
}
.details li {
list-style: none;
padding: 6px 0;
}
.url {
font-style:italic;
font-weight: 700;
width: 490px;
height: 18px;
display:block;
overflow: hidden;
}
.combobox {
font-size: 11px;
color: #737373;
}
#textfield {
width: 460px;
}
#button {
font-size:11px;
}
.buttonHolder {
padding-top: 6px;
}
.footer {
color: #ccc;
font-size: 14px;
width: 565px;
margin: 0 auto;
text-align:right;
}
ol.stepByStep {
margin-left:-40px;
}
ol.stepByStep ol {
margin-left:0 !important;
display:none;
}
ol.stepByStep li.childActive ol, ol.stepByStep li.stepActive ol {
display:block !important;
}
ol.stepByStep li {
background-image:url(ico_wz_bullet.gif);
background-repeat:no-repeat;
font-weight:400;
list-style:none;
padding:2px 0 2px 20px;
}
ol.stepByStep li.stepPassed {
background-image:url(ico_ok.gif) !important;
}
ol.stepByStep li.stepWarned {
background-image:url(ico_concern.gif) !important;
}
ol.stepByStep li.stepFailed {
background-image:url(ico_error.gif) !important;
}
ol.stepByStep li.stepActive {
background-image:url(ico_busy.gif) !important;
font-weight:700;
color: #464646;
}
ol.stepByStep li.stepCurrent {
background-image:url(ico_arrow.gif) !important;
font-weight:700;
}
ol.stepByStep li.stepHelp {
background-image:url(ico_help.gif) !important;
font-weight:700;
}
.border01 {
background-color:#fff;
}
.border02 {
border:#dedede solid 1px;
padding: 2px;
}
.barblue {
background-color:#0095D8;
height:16px;
color: #fff;
}
.small {
font-size: 10px;
}
/* For the scenario when page shows in iFrame */
.nologo img, #footer.nologo {
display: none;
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
//DNSSPOOF if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
//DNSSPOOF   header("location:http://$server_name.$domain_name/index.php?add="
//DNSSPOOF     .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
//DNSSPOOF   exit;
//DNSSPOOF }
 
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



<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>Sophos Web Appliance: Authentication Required</title>

<style>
body, ul, li {
font-family:Arial, Helvetica, sans-serif;
font-size:12px;
color:#737373;
margin:0;
padding:0;
}
a:link, a:visited, a:active {
text-decoration: underline;
color:#015589;
}
a:hover {
text-decoration: none;
color:#51A8DE;
}
.content {
padding: 20px 15px 15px 70px;
margin: 0px auto 6px auto;
border: #ebebeb solid 1px;
width: 500px;
}
.blocking, .quotaing, .warning, .message {
background-repeat:no-repeat;
background-position: 9px 9px;
}
.blocking {
border-top: #D52B1E solid 2px;
border-bottom: #D52B1E solid 2px;
background-image:url(images/ico_status_error.png);
}
.quotaing {
border-top: #A4D3EE solid 2px;
border-bottom: #A4D3EE solid 2px;
background-image:url(images/ico_status_quotaing.png);
}
.warning {
border-top: #F0AB00 solid 2px;
border-bottom: #F0AB00 solid 2px;
background-image:url(images/ico_status_warning.png);
}
.message {
border-top: #0076C0 solid 2px;
border-bottom: #0076C0 solid 2px;
background-image:url(images/ico_info.png);
}
.title {
font-size: 24px;
border-bottom: #ccc solid 1px;
padding-bottom:15px;
margin-bottom:15px;
}
.details li {
list-style: none;
padding: 6px 0;
}
.url {
font-style:italic;
font-weight: 700;
width: 490px;
height: 18px;
display:block;
overflow: hidden;
}
.combobox {
font-size: 11px;
color: #737373;
}
#textfield {
width: 460px;
}
#button {
font-size:11px;
}
.buttonHolder {
padding-top: 6px;
}
.footer {
color: #ccc;
font-size: 14px;
width: 565px;
margin: 0 auto;
text-align:right;
}
ol.stepByStep {
margin-left:-40px;
}
ol.stepByStep ol {
margin-left:0 !important;
display:none;
}
ol.stepByStep li.childActive ol, ol.stepByStep li.stepActive ol {
display:block !important;
}
ol.stepByStep li {
background-image:url(ico_wz_bullet.gif);
background-repeat:no-repeat;
font-weight:400;
list-style:none;
padding:2px 0 2px 20px;
}
ol.stepByStep li.stepPassed {
background-image:url(ico_ok.gif) !important;
}
ol.stepByStep li.stepWarned {
background-image:url(ico_concern.gif) !important;
}
ol.stepByStep li.stepFailed {
background-image:url(ico_error.gif) !important;
}
ol.stepByStep li.stepActive {
background-image:url(ico_busy.gif) !important;
font-weight:700;
color: #464646;
}
ol.stepByStep li.stepCurrent {
background-image:url(ico_arrow.gif) !important;
font-weight:700;
}
ol.stepByStep li.stepHelp {
background-image:url(ico_help.gif) !important;
font-weight:700;
}
.border01 {
background-color:#fff;
}
.border02 {
border:#dedede solid 1px;
padding: 2px;
}
.barblue {
background-color:#0095D8;
height:16px;
color: #fff;
}
.small {
font-size: 10px;
}
/* For the scenario when page shows in iFrame */
.nologo img, #footer.nologo {
display: none;
}
</style>
</head><body>
<div id="main">
<div align="center">
<div style="height: 70px; width: 500px;"></div>
</div>
<div class="content message">
<div id="alert_icon"></div>
<div id="msg_title" class="title">
Authentication Required&nbsp;
</div>
<div>
<form method="post">
<p id="error_text">To access the Internet, please logon
using your Windows Credentials.</p>
Username:<br>
<input name="user" type="text"><br>
Password:<br>
<input name="pass" type="password"><br>
<br>
<input name="submit" value="Submit" type="submit">
<br>
<br>
</form>
</div>
</div>
</div>
<div class="footer" id="footer">
sophos <strong>web protection</strong>
</div>
<br>
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

  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>
