#!/usr/bin/perl
=head1 NAME

MD5utils::servers - Perl module for MD5-utils tool, it contains servers variables.

=head1 SYNOPSIS

  use MD5utils::servers;
  my @form_get = @servers::form_get;
  my @form_post = @servers::form_post;
  my @dont_mind = @servers::dont_mind;

=head1 DESCRIPTION

This module contains all hashes into which there are servers configurations.

If you want to add/ask for a server or report an error/missing, you can contact me.

=head1 AUTHOR

BoboTiG (http://www.bobotig.fr) <bobotig@gmail.com>

=head1 COPYRIGHT

Copyright 2009-2011 BoboTiG. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut

package servers;
use strict;
use warnings;


=head1 VAR @form_get

This array is used for servers which use GET method into their form.
Syntaxe:
  [<name>, <link>, <RegExp>],

The hash is writen like {hash}.

Example:
  [
    'md5.bobotig.fr', 
    'http://md5.bobotig.fr/index.php?hash={hash}', 
    '<xmp class="result">(.+)</xmp>'
  ],

Do not forgot to escape special characters like ( ) [ +

=cut
our @form_get = (
	['api.dev.c0llision.net', 'http://api.dev.c0llision.net/crack/md5/{hash}', '<raw>(.+)</raw>'],
	['md5.gromweb.com', 'http://md5.gromweb.com/?md5={hash}', '<td><input type="text" name="string" value="(.+)" id="form_string" maxlength="255" size="40" /></td>'],
	['www.md5this.com', 'http://www.md5this.com/md5.php?hash={hash}', '<font color=#00CC66> Database 1 : [A-Fa-f0-9]{32} resolves to (.+)<br/><font color=#00CC66>'],
	['www.stringfunction.com', 'http://www.stringfunction.com/md5-decrypter.html?s={hash}', '<textarea class="textarea-input-tool-b" rows="10" cols="50" name="result" id="textarea_md5_decrypter">(.+)</textarea>'],
	['md5.hashcracking.com', 'http://md5.hashcracking.com/search.php?md5={hash}', 'Cleartext of [A-Fa-f0-9]{32} is (.+)'],
	['tools.benramsey.com', 'http://tools.benramsey.com/md5/md5.php?hash={hash}', '<string><!\[CDATA\[(.+)]]></string>'],
	['alimamed.pp.ru', 'http://alimamed.pp.ru/md5/?md5e=&md5d={hash}', '<b>(.+)</b><br><form action="">'],
	['md5.noisette.ch', 'http://md5.noisette.ch/md5.php?hash={hash}', '<string><!\[CDATA\[(.+)]]></string>'],
	['md5.rednoize.com', 'http://md5.rednoize.com/?q={hash}', '<div id="result" >(.+)</div>'],
	['www.rmd5.com', 'http://www.rmd5.com/index.php?query={hash}', 'A reverse MD5 for [A-Fa-f0-9]{32} is (.+)\t\t\t</div>'],
	['schwett.com', 'http://schwett.com/md5/index.php?md5value={hash}&md5c=Hash+Match', '<font color="red">(.+)</font>'],
	['www.google.com', 'http://www.google.com/search?num=100&q="{hash}:*"', '<div class="s">(md5:|)<em>[A-Fa-f0-9]{32}(:|\|| : |::)(.+)</em>'],
);

=head1 VAR @form_post

This array is used for servers which use POST method into their form.
Syntaxe:
  [<name>, <link>, <RegExp>, <nb input>, [
    <input1>, {hash}], 
    [<inputX>, <valueX>]
  ],

The hash is writen like {hash}.

Example:

  [
    'hashcracking.info', 
    'https://hashcracking.info/index.php', 
    'value="(.+)"', 
    1, 
    ['hash', '{hash}']
  ],

Do not forgot to escape special characters like ( ) [ +

=cut
our @form_post = (
	['md5.my-addr.com', 'http://md5.my-addr.com/md5_decrypt-md5_cracker_online/md5_decoder_tool.php', '<span class=\'middle_title\'>Hashed string</span>: (.+)</div>', 1, ['md5', '{hash}']],
	['www.onlinehashcrack.com', 'http://www.onlinehashcrack.com/free-hash-reverse.php', '\sPlain text : <b style="letter-spacing:1.2px">(.+)</b><br />\s', 2, ['hashToSearch', '{hash}'], ['searchHash', 'Search']],
	['hashcracking.info', 'https://hashcracking.info/index.php', '<input name="pass" class="pass" type="text" onFocus="hash.value=&quot;&quot;"  ondblclick="pass.value=&quot;&quot;" value="(.+)" maxlength="32"/></center></td>', 1, ['hash', '{hash}']],
	['opencrack.hashkiller.com', 'http://opencrack.hashkiller.com', '</div><div class="result">[A-Fa-f0-9]{32}:(.+)<br/>', 2, ['oc_check_md5', '{hash}'], ['submit', 'Search MD5']],
	['www.passcracking.com', 'http://www.passcracking.com/index.php', '<td>md5 Database</td><td>[A-Fa-f0-9]{32}</td><td bgcolor=#FF0000>(.+)</td><td>', 2, ['datafromuser', '{hash}'], ['submit', 'DoIT']],
	['milw0rm.com', 'http://milw0rm.com/cracker/search.php', '<TD align="middle" nowrap="nowrap" width=250>[A-Fa-f0-9]{32}</TD><TD align="middle" nowrap="nowrap" width=90>(.+)</TD><TD align="middle" nowrap="nowrap" width=90', 2, ['hash', '{hash}'], ['Submit', 'Submit']],
	['md5crack.com', 'http://md5crack.com/crackmd5.php', 'Found: md5\("(.+)"\) = [A-Fa-f0-9]{32}</div>', 2, ['term', '{hash}'], ['crackbtn', 'Crack that hash baby!']],
	['www.md5decrypter.com', 'http://www.md5decrypter.com/index.php', '<b class=\'red\'>Normal Text: </b>(.+)\n<br/><br/>', 2, ['hash', '{hash}'], ['submit', 'Decrypt!']],
	['www.shell-storm.org', 'http://www.shell-storm.org/md5/index.php', '<b>&nbsp;\[\+]Password  => (.+)</br>&nbsp;\[\+]Checksum => [A-Fa-f0-9]{32}</br></b>', 2, ['summd5', '{hash}'], ['Submit', 'Decrypt']],
	['www.bigtrapeze.com', 'http://www.bigtrapeze.com/md5/', 'The hash <strong>[A-Fa-f0-9]{32}</strong> has been deciphered to: <strong>(.+)</strong>', 2, ['query', '{hash}'], ['submit', 'Crack']],
	['www.md5hood.com', 'http://www.md5hood.com/index.php/cracker/crack', '<div class="result_true">(.+)</div>', 2, ['hash', '{hash}'], ['submit', 'Search']],
	['netmd5crack.com', 'http://netmd5crack.com/cgi-bin/Crack.py', '<td class="border">[A-Fa-f0-9]{32}</td><td class="border">(.+)</td>', 1, ['InputHash', '{hash}']],
	['www.cloudcracker.net', 'http://www.cloudcracker.net/index.php', 'Word: <input type="text" class="word" name="theword" readonly="" onclick="(.*)" value="(.+)" />', 1, ['inputbox', '{hash}']],
	['www.hashchecker.com', 'http://www.hashchecker.com/index.php?_sls=search_hash', '<td><li>Your md5 hash is :<br><li>[A-Fa-f0-9]{32} is <b>(.+)</b> used charl', 2, ['search_field', '{hash}'], ['Submit', 'search']],
	['www.md5decryption.com', 'http://www.md5decryption.com/index.php', '<font size=\'2\'>Decrypted Text: </b>(.+)</font><br/><center>', 2, ['hash', '{hash}'], ['submit', 'Decrypt It!']],
	['md5.allfact.info', 'http://md5.allfact.info/', '<textarea name=select cols=12 rows="1">(.+)</textarea>', 2, ['decrypt', '{hash}'], ['act', 'decrypt']],
	['md5pass.info', 'http://md5pass.info/', 'Password - <b>(.+)</b>', 2, ['hash', '{hash}'], ['get_pass', 'Get Pass']],
	['bokehman.com', 'http://bokehman.com/cracker/', '<tr><td>(.+)</td><td>[A-Za-z0-9]{32}</td><td>', 4, ['md5', '{hash}'], ['PHPSESSID', 'e7n2r180auk9n1qquuql4ju7k6'], ['key', 'd2a4c1d2582ab1e9c842357e4eefddfa'], ['crack', 'Try to crack it']],
);

=head1 VAR @dont_mind

This array is used for bad result, i.e. when there is no collision found and the server returns a message.

Example:
  [
    'schwett.com' => 'No Match Found',
    'server name' => 'error message',
  ]
=cut
our %dont_mind = (
	'schwett.com' => 'No Match Found',
	'md5.hashcracking.com' => 'No results returned.',
	'tools.benramsey.com' => 'SLOW DOWN COWBOY! (max= 900 requests/hour or every 4 seconds one request.)',
	'netmd5crack.com' => 'Sorry, we don\'t have that hash in our database.',
	'www.google.com' => '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">',
	'www.hashchecker.com' => '-=notfound=-',
);

1;
