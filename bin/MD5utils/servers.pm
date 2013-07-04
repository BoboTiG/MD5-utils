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

Copyright 2009-2013 BoboTiG. All rights reserved.

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
	['www.md5this.com', 'http://www.md5this.com/md5.php?hash={hash}', '<font color=#00CC66> Database 1 : [A-Fa-f0-9]{32} resolves to (.+)<br/>'],
	['www.stringfunction.com', 'http://www.stringfunction.com/md5-decrypter.html?st={hash}', '<textarea class="textarea-input-tool-b" rows="10" cols="50" name="result" id="textarea_md5_decrypter">(.+)</textarea>\s*</form>'],
	['md5.hashcracking.com', 'http://md5.hashcracking.com/search.php?md5={hash}', 'Cleartext of [A-Fa-f0-9]{32} is (.+)'],
	['md5.noisette.ch', 'http://md5.noisette.ch/md5.php?hash={hash}', '<string><!\[CDATA\[(.+)]]></string>'],
	['tobtu.com', 'http://tobtu.com/md5.php?h={hash}', '[A-Fa-f0-9]{32}:[A-Fa-f0-9]+:(.+)\n\ncrack time:'], # /!\ 10 tries, then wait
	#['md5.rednoize.com', 'http://md5.rednoize.com/?q={hash}', '<div id="result" >(.+)</div>'],
	['www.google.com', 'https://www.google.com/search?num=100&q="{hash}:*"', '<em>[A-Fa-f0-9]{32}\s*(=&gt;|:|::|\|)\s*(\w+)</em>'],
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
	['md5.my-addr.com', 'http://md5.my-addr.com/md5_decrypt-md5_cracker_online/md5_decoder_tool.php', '<span class=\'middle_title\'>Hashed string</span>: (.+)</div>\s*<br>', 1, ['md5', '{hash}']],
	['www.onlinehashcrack.com', 'http://www.onlinehashcrack.com/free-hash-reverse.php', '\sPlain text : <b style="letter-spacing:1.2px">(.+)</b><br />\s', 2, ['hashToSearch', '{hash}'], ['searchHash', 'Search']],
	['md5crack.com', 'http://www.md5crack.com/home.php', '<p class="success"><strong>[A-Fa-f0-9]{32}</strong>: (.+)</p>\s*<p>', 2, ['list', '{hash}'], ['crack', 'Crack Hashes']],
	['www.bigtrapeze.com', 'http://www.bigtrapeze.com/md5/', 'The hash <strong>[A-Fa-f0-9]{32}</strong> has been deciphered to: <strong>(.+)</strong>', 2, ['query', '{hash}'], ['submit', 'Crack']],
	['www.md5hood.com', 'http://md5hood.com/index.php/cracker/crack', '<div class="result_true">(.+)</div>\s*</fieldset>', 2, ['md5', '{hash}'], ['submit', 'Go']],
	['netmd5crack.com', 'http://netmd5crack.com/cgi-bin/Crack.py', '<td class="border">[A-Fa-f0-9]{32}</td><td class="border">(.+)</td>', 1, ['InputHash', '{hash}']],
	['www.cloudcracker.net', 'http://www.cloudcracker.net/index.php', 'Word: <input type="text" class="word" name="theword" readonly="" onclick="(.*)" value="(.+)" />', 1, ['inputbox', '{hash}']],
	['www.md5decryption.com', 'http://www.md5decryption.com/index.php', '<font size=\'2\'>Decrypted Text: </b>(.+)</font><br/><center>', 2, ['hash', '{hash}'], ['submit', 'Decrypt It!']],
	['md5pass.info', 'http://md5pass.info/', 'Password - <b>(.+)</b>\s*<p align="center">', 2, ['hash', '{hash}'], ['get_pass', 'Get Pass']],
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
	'md5.hashcracking.com' => 'No results returned.',
	'netmd5crack.com' => 'Sorry, we don\'t have that hash in our database.',
	'www.google.com' => '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">',
);

1;
