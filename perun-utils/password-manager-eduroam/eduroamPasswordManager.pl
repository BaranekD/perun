#!/usr/bin/perl

######################################################
#
# PASSWORD MANAGER FOR EDUROAM
#
# It takes up to 4 parameters in following order: action, namespace, login, pass
# where action can be "check", "change", "reserve", "validate", "reserve_random", "delete"
# where namespace represents login-namespace used by radius server (eduroam) and should match passed login
# namespace also must match PWDM config file /etc/perun/pwdchange.[namespace].eduroam
# where login is users login to reserve
# where password is users password in plaintext (required only for actions check, change, reserve)
#
#####################################################

use strict;
use warnings FATAL => 'all';
use Switch;
use String::Random qw( random_string );

sub edu_log;
sub getPassword;
sub getEntry;

##########
#
# RUN SCRIPT ITSELF
#
##########

# read input parameters
my $action = $ARGV[0];
my $namespace = $ARGV[1];
my $login = $ARGV[2];

my $filename = "/etc/perun/pwchange.".$namespace.".eduroam";
unless (-e $filename) {
	edu_log("Configuration file for namespace \"" . $namespace . "\" doesn't exist!");
	exit 2; # login-namespace is not supported
}

# load configuration file
open FILE, "<" . $filename;
my @lines = <FILE>;
close FILE;

# remove new-line characters from the end of lines
chomp @lines;

# settings
my $key_path = $lines[0];  # path to the SSH key
my $server = $lines[1];    # radius server hostname/ip
my $command = "";          # command to run on radius server

# do stuff based on password manager action type
switch ($action) {

	case("change"){

		my $entry = getEntry($login, getPassword());

		eval {
			# construct command and passit to the server
			$command = "~/eduroamPwdmgrServer.pl $action \'$entry\'";
			# timeout 60s kill after 60 more sec.
			exec "timeout -k 60 60 ssh -i $key_path $server $command";
		};
		if ( $@ ) {
			# error adding entry
			edu_log("[PWDM] Change of password for $login failed with return code: ".$@);
			exit 3; # setting of new password failed
		} else {
			# entry added
			edu_log("[PWDM] Password for $login changed.");
		}

	}

	case("check"){

		my $entry = getEntry($login, getPassword());

		eval {
			# construct command and passit to the server
			$command = "~/eduroamPwdmgrServer.pl $action \'$entry\'";
			# timeout 60s kill after 60 more sec.
			exec "timeout -k 60 60 ssh -i $key_path $server $command";
		};
		if ( $@ ) {
			# error adding entry
			edu_log("[PWDM] Check of password failed for $login with return code: ".$@);
			exit 6; # checking old password failed
		} else {
			# entry added
			edu_log("[PWDM] Password for $login checked.");
		}

	}

	case("reserve"){

		# TODO - check against AD server

		my $entry = getEntry($login, getPassword());

		eval {
			# construct command and passit to the server
			$command = "~/eduroamPwdmgrServer.pl $action \'$entry\'";
			# timeout 60s kill after 60 more sec.
			exec "timeout -k 60 60 ssh -i $key_path $server $command";
		};
		if ( $@ ) {
			# error adding entry
			edu_log("[PWDM] Creation of password for $login failed with return code: ".$@);
			exit 4; # creation of new password failed
		} else {
			# entry added
			edu_log("[PWDM] Password for $login reserved.");
		}

	}

	case("delete") {

		my $entry = getEntry($login, undef);

		eval {
			# construct command and passit to the server
			$command = "~/eduroamPwdmgrServer.pl $action \'$entry\'";
			# timeout 60s kill after 60 more sec.
			exec "timeout -k 60 60 ssh -i $key_path $server $command";
		};
		if ( $@ ) {
			# error deleting entry
			edu_log("[PWDM] Deletion of password for $login failed with return code: ". $@);
			exit 5; # creation of new password failed
		} else {
			# entry added
			edu_log("[PWDM] Password for $login deleted.");
		}

	}

	case("validate") {

		exit 0;

	}

	case("reserve_random") {

		my $entry = getEntry($login, getPassword(random_string("Cn!CccncCn")));

		eval {
			# construct command and passit to the server
			$command = "~/eduroamPwdmgrServer.pl $action \'$entry\'";
			# timeout 60s kill after 60 more sec.
			exec "timeout -k 60 60 ssh -i $key_path $server $command";
		};
		if ( $@ ) {
			# error adding entry
			edu_log("[PWDM] Creation of random password for $login failed with return code: ".$@);
			exit 4; # creation of new password failed
		} else {
			# entry added
			edu_log("[PWDM] Random password for $login reserved.");
		}

	}

	else {
		edu_log("[PWDM] Unknown action for handling passwords.");
		exit 10;
	}

}

#
# Log any message to pwdm.log file located in same folder as script.
# Each message starts at new line with date.
#
sub edu_log() {

	my $message = (@_)[0];
	open(LOGFILE, ">>./pwdm.log");
	print LOGFILE (localtime(time) . ": " . $message . "\n");
	close(LOGFILE);

}

#
# Reads password from STDIN and converts it to the NTLM hash
# if password is passed as param, value is used instead
#
sub getPassword() {

	my $user_pass;
	my $pass = shift;
	unless($pass) {
		$user_pass = <STDIN>;
	} else {
		$user_pass = $pass;
	}

	chomp($user_pass);

	my $converted_pass = substr `printf '%s' "$user_pass" | iconv -t utf16le | openssl md4` , 10;
	chomp($converted_pass);

	return $converted_pass;

}

#
# Return RADIUS "users" file entry for login and hashed password.
# If password is not passed, partial entry is returned.
#
sub getEntry() {

	my $username = shift;
	my $converted_pass = shift;

	if ($converted_pass) {
		return "\"$username\@vsup.cz\" NT-Password := \"" . $converted_pass . "\"";
	} else {
		return "\"$username\@vsup.cz\" NT-Password := \"";
	}

}