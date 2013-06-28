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
#    - Digest::MD5
#    - LWP::UserAgent
#


### [ Modules ] ###
use strict;
use Digest::MD5;
use LWP::UserAgent;
use warnings;
### [ /Modules ] ###


### [ Script configuration ] ###
our $VERSION    = '2011.12.05';
my $user_agent  = 'Mozilla/5.0 (X11; Linux x86_64; rv:8.0) Gecko/20100101 Firefox/8.0 Iceweasel/8.0';
my @forms = (
	['get', ['md5.bobotig.fr', 'http://md5.bobotig.fr/index.php?hash={hash}', '&rsaquo;&rsaquo;&rsaquo;<xmp class="result">(.+)</xmp>&lsaquo;&lsaquo;&lsaquo;']],
	['get', ['api.dev.c0llision.net', 'http://api.dev.c0llision.net/crack/md5/{hash}', '<raw>(.+)</raw>']],
	['get', ['md5.gromweb.com', 'http://md5.gromweb.com/?md5={hash}', '<td><input type="text" name="string" value="(.+)" id="form_string" maxlength="255" size="40" /></td>']],
	['get', ['md5.darkbyte.ru', 'http://md5.darkbyte.ru/api.php?q={hash}', '(.+)']],
	['get', ['www.stringfunction.com', 'http://www.stringfunction.com/md5-decrypter.html?s={hash}', '<textarea class="textarea-input-tool-b" rows="10" cols="50" name="result" id="textarea_md5_decrypter">(.+)</textarea>\n\t{10}']],
	['get', ['md5.hashcracking.com', 'http://md5.hashcracking.com/search.php?md5={hash}', 'Cleartext of [A-Fa-f0-9]{32} is (.+)']],
	['get', ['md5.rednoize.com', 'http://md5.rednoize.com/?q={hash}', '<div id="result" >(.+)</div>\n\t{3}']],
	['post', ['www.onlinehashcrack.com', 'http://www.onlinehashcrack.com/free-hash-reverse.php', '\sPlain text : <b style="letter-spacing:1.2px">(.+)</b><br />\s', 2, ['hashToSearch', '{hash}'], ['searchHash', 'Search']]],
	['post', ['www.md5decryption.com', 'http://www.md5decryption.com/index.php', '<font size=\'2\'>Decrypted Text: </b>(.+)</font><br/><center>', 2, ['hash', '{hash}'], ['submit', 'Decrypt It!']]],
	['post', ['www.cloudcracker.net', 'http://www.cloudcracker.net/index.php', 'Word: <input type="text" class="word" name="theword" readonly="" onclick="(.*)" value="(.+)" />', 1, ['inputbox', '{hash}']]],
	['post', ['www.md5hood.com', 'http://md5hood.com/index.php/cracker/crack', '<div class="result_true">(.+)</div>\s*</fieldset>', 2, ['md5', '{hash}'], ['submit', 'Go']]],
);
### [ /Script configuration ] ###


#-----------------------------------------------------------------------
# Fonction	: request
# Objectif	: launch the server resquest for one hash
# Entries	:
#		- (string)form method
#		- (string)hash
#		- (string)server_name
#		- (string)server_link
#		- (string)server_regexp
#		- (array)POST arguments
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
	if ( $@ =~ /Can't connect to/ || $requete->is_error ) { return; }
	$requete->content =~ m/($regexp)/ms;
	my ($result) = $+ || undef;
	if ( defined $result ) {
		if ( $hash eq Digest::MD5::md5_hex($result) ) {
			print $result;
			exit 0;
		}
	}
	return;
} # end request --------------------------------------------------------


#-----------------------------------------------------------------------
# Fonction	: search
# Objectif	: try to crack one hash using one server
# Entries	:
#		- (string)hash
#		- (int)key
# Returns	: void
# Update	: 20111205
#
sub search {
	my ($hash, $i) = @_;
	my $method     = $forms[$i][0];
	my $server     = $forms[$i][1][0];
	my $link       = $forms[$i][1][1];
	my $regexp     = $forms[$i][1][2];
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
	return request($method, $hash, $server, $link, $regexp, %arguments);
} # end search ---------------------------------------------------------


###
# C'est parti mon kiki !
my $hash = lc shift || undef;
if ( $hash =~ m/^[0-9a-f]{32}$/ms ) {
	my $n = $#forms;
	for my $i ( 0 .. $n ) {
		search($hash, $i);
	}
}
exit 0;
