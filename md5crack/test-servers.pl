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
use Digest::MD5;
use Parallel::ForkManager;
use LWP::UserAgent;
use warnings;
### [ /Modules ] ###


### [ Script configuration ] ###
our $VERSION    = '2011.12.05';
my $max_threads = 10;
my $user_agent  = 'Mozilla/5.0 (X11; Linux x86_64; rv:8.0) Gecko/20100101 Firefox/8.0 Iceweasel/8.0';
my @forms = (
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
# code error
	#['get', ['md5.noisette.ch', 'http://md5.noisette.ch/md5.php?hash={hash}', '<string><!\[CDATA\[(.+)]]></string>']],
	#['post', ['www.bigtrapeze.com', 'http://www.bigtrapeze.com/md5/', 'The hash <strong>[A-Fa-f0-9]{32}</strong> has been deciphered to: <strong>(.+)</strong>', 2, ['query', '{hash}'], ['submit', 'Crack']]],
# useless
	#['get', ['www.google.com', 'http://www.google.com/search?num=100&q="{hash}:*"', '<div class="s">(md5:|)<em>[A-Fa-f0-9]{32}(:|\|| : |::)(.+)</em>']],
	#['get', ['schwett.com', 'http://schwett.com/md5/index.php?md5value={hash}&md5c=Hash+Match', '<font color="red">(.+)</font>']],
	#['post', ['md5crack.com', 'http://md5crack.com/crackmd5.php', 'Found: md5\("(.+)"\) = [A-Fa-f0-9]{32}</div>', 2, ['term', '{hash}'], ['crackbtn', 'Crack that hash baby!']]],
	#['post', ['bokehman.com', 'http://bokehman.com/cracker/', '<tr><td>(.+)</td><td>[A-Za-z0-9]{32}</td><td>', int '4', ['md5', '{hash}'], ['PHPSESSID', 'e7n2r180auk9n1qquuql4ju7k6'], ['key', 'd2a4c1d2582ab1e9c842357e4eefddfa'], ['crack', 'Try to crack it']]],
	#['post', ['www.hashchecker.com', 'http://www.hashchecker.com/index.php?_sls=search_hash', '<td><li>Your md5 hash is :<br><li>[A-Fa-f0-9]{32} is <b>(.+)</b> used charl', 2, ['search_field', '{hash}'], ['Submit', 'search']]],
	#['post', ['md5pass.info', 'http://md5pass.info/', 'Password - <b>(.+)</b>', 2, ['hash', '{hash}'], ['get_pass', 'Get Pass']]],
	#['post', ['netmd5crack.com', 'http://netmd5crack.com/cgi-bin/Crack.py', '<td class="border">[A-Fa-f0-9]{32}</td><td class="border">(.+)</td>', 1, ['InputHash', '{hash}']]],
	#['get', ['tools.benramsey.com', 'http://tools.benramsey.com/md5/md5.php?hash={hash}', '<string><!\[CDATA\[(.+)]]></string>']],
	#['post', ['md5.my-addr.com', 'http://md5.my-addr.com/md5_decrypt-md5_cracker_online/md5_decoder_tool.php', '<span class=\'middle_title\'>Hashed string</span>: (.+)</div>\n<br>\n<br>', 1, ['md5', '{hash}']]],
# protected
	#['post', ['www.md5decrypter.com', 'http://www.md5decrypter.com/index.php', '<b class=\'red\'>Normal Text: </b>(.+)\n<br/><br/>', 2, ['hash', '{hash}'], ['submit', 'Decrypt!']]],
#out
	#['get', ['alimamed.pp.ru', 'http://alimamed.pp.ru/md5/?md5e=&md5d={hash}', '<b>(.+)</b><br><form action="">']],
	#['get', ['www.md5this.com', 'http://www.md5this.com/md5.php?hash={hash}', '<font color=#00CC66> Database 1 : [A-Fa-f0-9]{32} resolves to (.+)<br/><font color=#00CC66>']],
	#['get', ['www.rmd5.com', 'http://www.rmd5.com/index.php?query={hash}', 'A reverse MD5 for [A-Fa-f0-9]{32} is (.+)\t\t\t</div>']],
	#['post', ['opencrack.hashkiller.com', 'http://opencrack.hashkiller.com', '</div><div class="result">[A-Fa-f0-9]{32}:(.+)<br/>\n', 2, ['oc_check_md5', '{hash}'], ['submit', 'Search MD5']]],
	#['post', ['www.passcracking.com', 'http://www.passcracking.com/index.php', '<td>md5 Database</td><td>[A-Fa-f0-9]{32}</td><td bgcolor=#FF0000>(.+)</td><td>', 2, ['datafromuser', '{hash}'], ['submit', 'DoIT']]],
	#['post', ['www.shell-storm.org', 'http://www.shell-storm.org/md5/index.php', '<b>&nbsp;\[\+]Password  => (.+)</br>&nbsp;\[\+]Checksum => [A-Fa-f0-9]{32}</br></b>', 2, ['summd5', '{hash}'], ['Submit', 'Decrypt']]],
	#['post', ['milw0rm.com', 'http://milw0rm.com/cracker/search.php', '<TD align="middle" nowrap="nowrap" width=250>[A-Fa-f0-9]{32}</TD><TD align="middle" nowrap="nowrap" width=90>(.+)</TD><TD align="middle" nowrap="nowrap" width=90', 2, ['hash', '{hash}'], ['Submit', 'Submit']]],
	#['post', ['hashcracking.info', 'http://hashcracking.info/index.php', '<input name="pass" class="pass" type="text" onFocus="hash.value=&quot;&quot;"  ondblclick="pass.value=&quot;&quot;" value="(.+)" maxlength="32"/></center></td>', 1, ['hash', '{hash}']]],
	#['post', ['md5.allfact.info', 'http://md5.allfact.info/', '<textarea name=select cols=12 rows="1">(.+)</textarea>', 2, ['decrypt', '{hash}'], ['act', 'decrypt']]],
);
### [ /Script configuration ] ###

#
# Fonction	: args
# Objectif	: arguments traitment
# Entries	: (array)arguments
# Returns	: void
# Update	: 20111205
#
sub args {
	my $n = $#forms;
	my $pm = Parallel::ForkManager->new($max_threads);
	say 'Total servers : '.($n + 1);
	for my $i ( 0 .. $n ) {
		$pm->start($i) and next;
		search('ab4f63f9ac65152575886860dde480a1', $i); # azerty
		$pm->finish();
	}
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
