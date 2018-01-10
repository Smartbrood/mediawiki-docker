<?php

$wgExtensionCredits['other'][] = array(
       'name' => 'fail2banlog',
       'author' =>'Laurent Chouraki',
       'url' => 'https://www.mediawiki.org/wiki/Extension:Fail2banlog',
       'description' => 'Writes a text file with IP of failed login as an input for the fail2ban software'
       );

//Modified by Andrey N. Petrov <andreynpetrov@gmail.com> for Mediawiki versions from 1.27.0

$wgHooks['AuthManagerLoginAuthenticateAudit'][] = 'logBadLogin';
 
function logBadLogin($response, $user, $username) {
global $fail2banfile;
global $fail2banid;
        if ( $response->status == "PASS" ) return true; // Do not log success or password send request, continue to next hook
        $time = date ("Y-m-d H:i:s T");
        $ip = $_SERVER['REMOTE_ADDR']; // wfGetIP() may yield different results for proxies

        // append a line to the log
        error_log("$time Authentication error from $ip on $fail2banid\n",3,$fail2banfile);
        return true; // continue to next hook
}
