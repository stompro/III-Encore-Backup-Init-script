#!/usr/bin/perl
#
#    Copyright 2012 Josh Stompro <code47@stompro.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Automatically initialize Encore backup tapes.
#Author: Josh Stompro, Lake Agassiz Regional Library, Moorhead MN
#Version: 0.1
#
#When this script is run it connects to the encore admin console
#and initializes the tape currently in the tape drive if it isn't
#already initialized.
#
#Changelog:
#1/20/2012: Initial Release Version 0.1
#

#Modify the following variables to match your Encore system.
my $server = "encore.example1.org";
my $username = "username";
my $password = "password";

#This will probably be the same for your system
my $startpage = "http://$server/iii/admin/SignOnPage.html";

#Set init to 1 to enable initializing, 0 to disable for testing.
my $init = 1;

use WWW::Mechanize;
my $mech = WWW::Mechanize->new();

$mech->get( $startpage );
print "Loading $startpage\n";

$mech->submit_form(
		   form_number => 1,
		   fields => {
			j_username => $username,
			j_password => $password,
		   }
		   );
print "Logging In\n";
       
$mech->follow_link( text_regex => qr/Encore Server Admin/i ) && print "->Encore Server Admin\n";
$mech->follow_link( text_regex => qr/Initialize Tape/i ) && print "->Initialize Tape page\n";
#$mech->follow_link( text_regex => qr/Initialize Tape/i ) && print "->Initialize\n";

#If the tape is already initialized, we can exit.
if($mech->content =~ /Initialized:  YES/){
  print "Tape already Initialized, exiting\n";
  exit;
}

#If the tape status is available - we can pull out the name and the date  
if($mech->content =~ /Tape name:    (.*)\</){
  my $tapename = $1;
  $mech->content =~ /Time created: (.*)\</;
  my $tapedate = $1;
  print "Tapename = $tapename , Tapedate = $tapedate\n";
}

#if the tape isn't old enough - exit and send an email.
#Todo - check the tape date, to keep us from initializing yesterdays backup

if($init){
print "Submitting the tape initialization form\n";
$mech->submit_form(
		   form_number => 1,
		   fields => {
			tapeNameTextFieldComponent => "Encore Backup Tape ".`date`,
		   }
		   );
}

print $mech->content if $debug;

#search for various results
# Tape not inserted "Please check that tape is inserted correctly and try again"

# After tape initialized - Unattended backup tape initialization is complete
# Current tape date
# Current tape name
