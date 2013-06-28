#!/usr/bin/perl
#
# $Id       : MD5-utils-lite $
# $Author   : BoboTiG $
# $Revision : 2 $
# $Date     : 2011/12/05 $
# $HeadURL  : http://www.bobotig.fr/ $
#
# MD5-utils Lite version, returns :
#   - nothing if wrong hash or no result ;
#   - the MD5 reverse of the hash if found.
#
# Usage : perl md5-utils-lite.pl <hash>
#
# Dependances :
#    - threads support
#    - Digest::MD5
#    - LWP::UserAgent
#


### [ Modules ] ###
use 5.010;
use strict;
use Cwd qw(abs_path);
use Digest::MD5;
use Parallel::ForkManager;
use LWP::UserAgent;
use warnings;

# Personal modules, we need to locate them
my $location;
# Why -15 in the next line? -> lenght('test-servers.pl') = 15
BEGIN { $location = substr(abs_path($0), 0, -15); }
use lib $location.'/bin';
use MD5utils::servers;
### [ /Modules ] ###


### [ Script configuration ] ###
our $VERSION    = '2013.06.28';
my $max_threads = 10;
my $user_agent  = 'Mozilla/5.0 (X11; Linux x86_64; rv:8.0) Gecko/20100101 Firefox/8.0 Iceweasel/8.0';
my @forms;
### [ /Script configuration ] ###

#
# Fonction	: args
# Objectif	: arguments traitment
# Entries	: (array)arguments
# Returns	: void
# Update	: 20130628
#
sub args {
	# Retrieve all servers
	foreach my $server ( @servers::form_get ) {
		push @forms, ['get', $server];
	}
	foreach my $server ( @servers::form_post ) {
		push @forms, ['post', $server];
	}
	
	my $n = $#forms;
	my $pm = Parallel::ForkManager->new($max_threads);
	say 'Total servers : '.($n + 1);
	for my $i ( 0 .. $n ) {
		$pm->start($i) and next;
		search('202cb962ac59075b964b07152d234b70', $i); # 123
		$pm->finish();
	}
	# Servers with GET method
	$pm->wait_all_children;
	return 0;
}

#
# Fonction	: request
# Objectif	: launch the server resquest for one hash
# Entries	:
#		- (string)form method
#		- (string)hash
#		- (string)server_name
#		- (string)server_link
#		- (string)server_regexp
#		- (array)post arguments
# Returns	: void
# Update	: 20111205
#
sub request {
	my ($method, $hash, $server, $link, $regexp, %arguments) = @_;
	my $ua;
	my $requete;
	
	$ua = LWP::UserAgent->new();
	$ua->agent($user_agent);
	if ( $method eq 'get' ) {
		eval { $requete = $ua->get($link) };
	} else {
		eval { $requete = $ua->post($link, \%arguments) };
	}
	if ( $@ =~ /Can't connect to/ ) {
		printf ' %s : connection imp.'."\n", $server;
		return;
	}
	if ( $requete->is_success ) {
		$requete->content =~ m/($regexp)/ms;
		my ($result) = $+ || undef;
		if ( defined $result ) {
			search_result($hash, $result, $server);
		} else {
			printf ' %s : result undefined.'."\n", $server;
		}
	} else {
		printf ' %s : connection bad.'."\n", $server;
	}
	return;
}


#
# Fonction	: multi-threaded search
# Objectif	: try to crack one hash using one server
# Entries	:
#		- (string)hash
#		- (int)key
# Returns	: void
# Update	: 20111205
#
sub search {
	my ($hash, $i) = @_;
	my $method = $forms[$i][0];
	my $server = $forms[$i][1][0];
	my $link   = $forms[$i][1][1];
	my $regexp = $forms[$i][1][2];
	my %arguments;
	
	if ( $method eq 'get' ) {
		$link =~ s/\{hash\}/$hash/ms;
	} else {
		for my $j ( 1..$forms[$i][1]['3'] ) {
			my $arg0 = $forms[$i][1][(int '3' + $j)][0];
			my $arg1 = $forms[$i][1][(int '3' + $j)][1];
			if ( $arg1 =~ m/\{hash\}/ms ) {
				$arg1 =~ s/\{hash\}/$hash/ms;
			}
			$arguments{$arg0} = $arg1;
		}
	}
	request($method, $hash, $server, $link, $regexp, %arguments);
	return;
}


#
# Fonction	: search_result
# Objectif	: manage results
# Entries	:
#		- (string)hash
#		- (mixed)result
#		- (string)server
# Returns	: void
# Update	: 20111205
#
sub search_result {
	my ($hash, $result, $server) = @_;
	if ( $result ) {
		my $res = Digest::MD5::md5_hex($result);
		printf '%s=%s:%s', $hash, $res, $result;
		if ( $hash eq $res ) {
			printf " %s : %s\n", $server, $result;
		} else {
			printf " %s : bad result\n", $server;
		}
	} else {
		printf " %s : not found\n", $server;
	}
	return;
}
### [ /Subs ] ###


###
# Let's go!
exit args(@ARGV);
