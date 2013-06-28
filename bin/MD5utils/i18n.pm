#!/usr/bin/perl
=head1 NAME

MD5utils::i18n - Perl module for MD5-utils tool, it contains internationalization subs and array.

=head1 SYNOPSIS

  use MD5utils::i18n;
  my $i18n = i18n::new(
    $VERSION, $language, $microsoft_os, 
    $red, $green, $yellow, $blue, $normal
  );
  print $i18n->text('help_message');
  $i18n->change_language('fr');

=head1 DESCRIPTION

I thought it is better to store string in a module rather than add too lines into the main script.
You will find a big array in text() sub with all strings.

For now, there are these languages:

  en: english
  fr: french

If you want to add/ask for a translation or report an error/missing, you can contact me.

=head1 AUTHOR

BoboTiG (http://www.bobotig.fr) <bobotig@gmail.com>

=head1 COPYRIGHT

Copyright 2009-2013 BoboTiG. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut

package i18n;
use strict;
use warnings;

my %texts;

=head1 FUNCTION new

Example:
  my $i18n = i18n::new(
    $VERSION, $language, $microsoft_os, 
    $red, $green, $yellow, $blue, $normal
  );

This is the first sub to call.

As you can see in example, parameters are:
  $VERSION: MD5-utils version
  $language: current language
  $microsoft_os: 1 or 0 (to solve bad issues with accents)
  $red: red color code
  $green: green color code
  $yellow: yellow color code
  $blue: blue color code
  $normal: normal color code

Default values under Microsoft OS:
  $VERSION: MD5-utils version
  $language: 'en'
  $microsoft_os: 1
  $red: ''
  $green: ''
  $yellow: ''
  $blue: ''
  $normal: ''

Default values under other OS:
  $VERSION: MD5-utils version
  $language: 'en'
  $microsoft_os: 0
  $red: "\e[1;31m"
  $green: "\e[32m"
  $yellow: "\e[33m"
  $blue: "\e[34m"
  $normal: "\e[0m"

=cut
sub new {
	my $self = { 
		VERSION			=> shift, 
		language		=> shift || 'en', 
		microsoft_os	=> shift || 0, 
		red				=> shift || q{}, 
		green			=> shift || q{}, 
		yellow			=> shift || q{}, 
		blue			=> shift || q{}, 
		normal			=> shift || q{} 
	};
	
	bless $self;
}

=head1 FUNCTION text

Example:
  print $i18n->text('message');

This sub will return the translated text you ask for.
If you want to manage languages, you have to modify into %texts.

Syntax:
  (...)
  'string_sumary' => {
    'en' => 'translated text',
    'fr' => 'texte traduit',
  },
  (...)

=cut
sub text {
	my $self = shift;
	my $string = shift;
	
	### [ HERE YOU CAN EDIT AND ADD LANGUAGES ] ###
	%texts = (
		'no_result' => {
			# Preview: [--] no result on $server
			'en' => $self->{blue}.'['.$self->{yellow}.'--'.$self->{blue}.']'.$self->{normal}.' no result on ',
			'fr' => $self->{blue}.'['.$self->{yellow}.'--'.$self->{blue}.']'.$self->{normal}.' pas de résultat sur ',
		},
		'one_word_to_hash_please' => {
			'en' => "\n".$self->{red}.'Information'.$self->{normal}.': please tell me at least one word to hash.'."\n\n",
			'fr' => "\n".$self->{red}.'Information'.$self->{normal}.' : veuillez préciser au moins un mot à hasher.'."\n\n",
		},
		'one_hash_to_crack_please' => {
			'en' => "\n".$self->{red}.'Information'.$self->{normal}.': please tell me at least one hash to crack.'."\n\n",
			'fr' => "\n".$self->{red}.'Information'.$self->{normal}.' : veuillez préciser au moins un hash à cracker.'."\n\n",
		},
		'invalid_hash' => {
			# Preview: $bad_hash is not a valide hash (must be 32 chars).
			'en' => ' is not a valide hash (must be 32 hex chars).'."\n",
			'fr' => ' n\'est pas un hash valide (doit faire 32 caractères hexa).'."\n",
		},
		'help' => {
			# Do not change commands name.
			'en' => "\n".'Usage: md5utils '.$self->{yellow}.'<option>'.$self->{normal}.' <option property> '.$self->{red}.'<hash/word/file>'.$self->{normal}."\n\n".
				'Options :'.
				"\n ".$self->{yellow}.'-c'.$self->{normal}.', '.$self->{yellow}.'--crypt'.$self->{normal}."\t".'hash word(s)'.
				"\n ".$self->{yellow}.'-d'.$self->{normal}.', '.$self->{yellow}.'--decrypt'.$self->{normal}."\t".'try to crack hash(es)'.
				"\n ".$self->{yellow}.'-f'.$self->{normal}.', '.$self->{yellow}.'--file'.$self->{normal}."\tt".'ry to crack hash(es) from file'.
				"\n\t\t".'files found.txt and not-found.txt will be appened'.
				"\n ".$self->{yellow}.'-h'.$self->{normal}.', '.$self->{yellow}.'--help'.$self->{normal}."\t".'display this message'.
				"\n ".$self->{yellow}.'-i'.$self->{normal}.', '.$self->{yellow}.'--imode'.$self->{normal}."\t".'use interactive mode'.
				"\n ".$self->{yellow}.'-l'.$self->{normal}.', '.$self->{yellow}.'--list'.$self->{normal}."\t".'list all servers'.
				"\n ".$self->{yellow}.'-u'.$self->{normal}.', '.$self->{yellow}.'--update'.$self->{normal}."\t".'check for an update'.
				"\n ".$self->{yellow}.'-b|-p|-q|-v'.$self->{normal}."\t".'board_color|proxy_enabled|quiet|verbosity'."\n\n".
				'Report bugs, suggestions and comments to <bobotig@gmail.com>.'."\n",
			'fr' => "\n".'Usage : md5utils '.$self->{yellow}.'<option>'.$self->{normal}.' <propriété> '.$self->{red}.'<hash/mot/fichier>'.$self->{normal}."\n\n".
				'Options :'.
				"\n ".$self->{yellow}.'-c'.$self->{normal}.', '.$self->{yellow}.'--crypt'.$self->{normal}."\t".'hash(es) MD5 du/des mot(s) suivant(s)'.
				"\n ".$self->{yellow}.'-d'.$self->{normal}.', '.$self->{yellow}.'--decrypt'.$self->{normal}."\t".'tenter de cracker un/plusieurs hash(es)'.
				"\n ".$self->{yellow}.'-f'.$self->{normal}.', '.$self->{yellow}.'--file'.$self->{normal}."\t".'tenter de cracker un/plusieurs hash(es) du fichier'.
				"\n\t\t".'les fichiers found.txt et not-found.txt seront créés'.
				"\n ".$self->{yellow}.'-h'.$self->{normal}.', '.$self->{yellow}.'--help'.$self->{normal}."\t".'affiche cette aide'.
				"\n ".$self->{yellow}.'-i'.$self->{normal}.', '.$self->{yellow}.'--imode'.$self->{normal}."\t".'utiliser le mode intéractif'.
				"\n ".$self->{yellow}.'-l'.$self->{normal}.', '.$self->{yellow}.'--list'.$self->{normal}."\t".'lister tous les serveurs'.
				"\n ".$self->{yellow}.'-u'.$self->{normal}.', '.$self->{yellow}.'--update'.$self->{normal}."\t".'mettre à jour ce script'.
				"\n ".$self->{yellow}.'-b|-p|-q|-v'.$self->{normal}."\t".'couleurs_forum|proxy_activé|silencieux|verbosité'."\n\n".
				'Reportez bugs, suggestions et commentaires à <bobotig@gmail.com>.'."\n",
		},
		'use_ithreads' => {
			'en' => '(multi-threads version)'."\n",
			'fr' => '(version multi processus)'."\n",
		},
		'use_no_ithreads' => {
			'en' => '(_non_ multi-threaded version)'."\n",
			'fr' => '(version _non_ multi processus)'."\n",
		},
		'get_latest_version' => {
			'en' => "\n".'Go to this address to get the lastest version:'."\n",
			'fr' => "\n".'Rendez-vous à l\'adresse suivante pour récupérer la dernière version :'."\n",
		},
		'server_list' => {
			'en' => 'Available server list:'."\n",
			'fr' => 'Liste des serveurs disponibles :'."\n",
		},
		'hash' => {
			# Preview: Hash of the word $word
			'en' => "\n".'Hash of the word ',
			'fr' => "\n".'Hash du mot ',
		},
		'found_verbose' => {
			# Preview: [ok] find on: $server
			'en' => $self->{blue}.'['.$self->{green}.'ok'.$self->{normal}.$self->{blue}.']'.$self->{normal}.' find on: ',
			'fr' => $self->{blue}.'['.$self->{green}.'ok'.$self->{normal}.$self->{blue}.']'.$self->{normal}.' trouvé sur le serveur : ',
		},
		'not_found' => {
			'en' => 'Plain text not found.'."\n",
			'fr' => 'Empreinte non trouvée.'."\n",
		},
		'not_found_but_collision' => {
			'en' => $self->{red}.'A collision has been found but its fingerprint does not match with the hash:'.$self->{normal}."\n",
			'fr' => $self->{red}.'Une colision a été trouvé mais son empreinte ne correspond pas avec le hash :'.$self->{normal}."\n",
		},
		'found' => {
			'en' => 'Find: ',
			'fr' => 'Trouvé : ',
		},
		'cannot_open_file' => {
			'en' => "\n".$self->{red}.'Information'.$self->{normal}.': impossible to open the file.'."\n",
			'fr' => "\n".$self->{red}.'Information'.$self->{normal}.' : impossible d\'ouvrir le fichier.'."\n",
		},
		'cannot_open_file_interactive' => {
			'en' => 'Impossible to open the file.'."\n",
			'fr' => 'Impossible d\'ouvrir le fichier.'."\n",
		},
		'which_file' => {
			'en' => "\n".$self->{red}.'Information'.$self->{normal}.': please tell me which file to open.'."\n\n",
			'fr' => "\n".$self->{red}.'Information'.$self->{normal}.' : veuillez préciser un fichier à ouvrir.'."\n\n",
		},
		'which_file_interactive' => {
			'en' => 'Please tell me which file to open.'."\n",
			'fr' => 'Veuillez préciser un fichier à ouvrir.'."\n",
		},
		'checking' => {
			'en' => $self->{blue}.'Checking version ...'.$self->{normal}."\n",
			'fr' => $self->{blue}.'Vérification de la version...'.$self->{normal}."\n",
		},
		'this_version' => {
			'en' => '  This version:    ',
			'fr' => '  Version actuelle : ',
		},
		'latest_version' => {
			'en' => '  Lastest version: ',
			'fr' => '  Dernière version : ',
		},
		'update_available' => {
			'en' => $self->{green}.'  ! Update available !'.$self->{normal}."\n",
			'fr' => $self->{green}.'  ! Mise à jour disponible !'.$self->{normal}."\n",
		},
		'error_retrieving_version' => {
			'en' => $self->{red}.'Error when trying to retrieve the latest version.'.$self->{normal}."\n",
			'fr' => $self->{red}.'Erreur lors de la récuperation de la version.'.$self->{normal}."\n",
		},
		'futurist_version' => {
			'en' => $self->{yellow}."\n".'  ! It seems that you have a fututist version =P !'.$self->{normal}."\n",
			'fr' => $self->{yellow}."\n".'  ! Il semblerait que tu aies une versions futuriste =P !'.$self->{normal}."\n",
		},
		'sorting_file' => {
			'en' => "\n".'Sorting of the file ',
			'fr' => "\n".'Tri du fichier ',
		},
		'sorting_file_interactive' => {
			'en' => 'Sorting of the file ',
			'fr' => 'Tri du fichier ',
		},
		'disabled_server' => {
			# Preview: $server [disabled]
			'en' => 'disabled',
			'fr' => 'désactivé',
		},
		'file' => {
			'en' => "\t".'File: ',
			'fr' => "\t".'Fichier : ',
		},
		'invalid_command' => {
			'en' => 'Invalid command.'."\n",
			'fr' => 'Commande invalide.'."\n",
		},
		'entering_interactive_mode' => {
			'en' => "\n".':::Entering into interactive mode ... '.$self->{green}.'Done'.$self->{normal}.".\n".':::Type '.$self->{yellow}.'help'.$self->{normal}.' to know available commands.'."\n",
			'fr' => "\n".':::Entrée en mode intéractif... '.$self->{green}.'Ok'.$self->{normal}.".\n".':::Tape '.$self->{yellow}.'help'.$self->{normal}.' pour voir les commandes disponibles.'."\n",
		},
		'help_interactive_mode' => {
			# Do not change commands name.
			'en' => $self->{yellow}.'   clear'.$self->{normal}."\t\t".'  clear console'."\n".
				$self->{yellow}.'   crack <hash(es)>'.$self->{normal}."\t".'  try to crack this hash(es)'."\n".
				$self->{yellow}.'   crypt <word(s)>'.$self->{normal}."\t".'  crypt this word(s)'."\n".
				$self->{yellow}.'   exit|quit'.$self->{normal}."\t\t".'  quit the program'."\n".
				$self->{yellow}.'   help  [cmd]'.$self->{normal}."\t\t".'  print help message'."\n".
				$self->{yellow}.'   list'.$self->{normal}."\t\t\t".'  list available servers'."\n".
				$self->{yellow}.'   file  <file>'.$self->{normal}."\t\t".'  try to crack hash(es) from file'."\n".
				$self->{yellow}.'   set   <option> <value>'.$self->{normal}.' modifiy an option'."\n".
				$self->{yellow}.'   update'.$self->{normal}."\t\t".'  check for an update'."\n".
				"\n".' Specific help available for set command only.'."\n\n",
			'fr' => $self->{yellow}.'   clear'.$self->{normal}."\t\t".'  effacer la console'."\n".
				$self->{yellow}.'   crack <hash(es)>'.$self->{normal}."\t".'  tenter de cracker le(s) hash(es)'."\n".
				$self->{yellow}.'   crypt <mot(s)>'.$self->{normal}."\t".'  crypter le(s) mot(s)'."\n".
				$self->{yellow}.'   exit|quit'.$self->{normal}."\t\t".'  quitter'."\n".
				$self->{yellow}.'   help  [cmd]'.$self->{normal}."\t\t".'  affiche ce message'."\n".
				$self->{yellow}.'   file  <fichier>'.$self->{normal}."\t".'  tenter de cracker les hashes du fichier'."\n".
				$self->{yellow}.'   list'.$self->{normal}."\t\t\t".'  liste les serveurs disponibles'."\n".
				$self->{yellow}.'   set   <option> <value>'.$self->{normal}.' modifier une option'."\n".
				$self->{yellow}.'   update'.$self->{normal}."\t\t".'  recherche la présence d\'une mise à jour'."\n".
				"\n".' Aide spécifique disponible seulement pour la commande set.'."\n\n",
		},
		'help_interactive_mode_set' => {
			'en' => 'Info : option to modify current language.'."\n".
				'Usage: set <option> <value>'."\n\n".
				'Available options and values:'."\n".
				"\t".'lang   : en, fr'."\n".
				"\t".'verbose: on or off'."\n",
			'fr' => 'Information : option qui modifie la langue actuelle.'."\n".
				'Utilisation : set <option> <valeur>'."\n\n".
				'Options et valeurs disponibles :'."\n".
				"\t".'lang    : en, fr'."\n".
				"\t".'verbose : on ou off'."\n",
		},
		'exiting' => {
			'en' => 'Exiting ...'."\n\n",
			'fr' => 'Sortie...'."\n\n",
		},
		'message_interactive_mode' => {
			'en' => "\n".':::You are on MD5-utils into interactive mode!'."\n".':::Type '.$self->{yellow}.'help'.$self->{normal}.' to know available commands.'."\n",
			'fr' => "\n".':::Tu es sur MD5-utils en mode intéractif !'."\n".':::Tape '.$self->{yellow}.'help'.$self->{normal}.' pour voir les commandes disponibles.'."\n",
		},
		'empty_hash' => {
			'en' => 'Empty hash!'."\n",
			'fr' => 'Hash vide !'."\n",
		},
		'nothing_to_hash' => {
			'en' => 'Nothing to hash!'."\n",
			'fr' => 'Rien à hasher !'."\n",
		},
		'invalid_option' => {
			'en' => $self->{normal}.': invalid option.'."\n",
			'fr' => $self->{normal}.': option invalide.'."\n",
		},
		'connection_impossible' => {
			'en' => 'Connection impossible.'."\n",
			'fr' => 'Impossible de se connecter.'."\n",
		},
		'server_connection_impossible' => {
			'en' => $self->{blue}.'['.$self->{red}.'!!'.$self->{normal}.$self->{blue}.']'.$self->{normal}.' connection failed on ',
			'fr' => $self->{blue}.'['.$self->{red}.'!!'.$self->{normal}.$self->{blue}.']'.$self->{normal}.' connexion échouée pour ',
		},
		'not_a_set_option' => {
			'en' => 'This is not a valid option.'."\n",
			'fr' => 'Ce n\'est pas une option valide'."\n",
		},
		'no_set_value' => {
			'en' => 'Missing value.'."\n",
			'fr' => 'Valeur est omise'."\n",
		},
		'set_lang_error' => {
			'en' => 'Unknown lang.'."\n",
			'fr' => 'Langue inconnue.'."\n",
		},
		'set_lang_unchanged' => {
			'en' => 'Lang unchanged.'."\n",
			'fr' => 'Langue inchangée.'."\n",
		},
		'set_verbose_error' => {
			'en' => 'Value have to be "on" or "off".'."\n",
			'fr' => 'La valeur doit être "on" ou "off".'."\n",
		},
		'set_verbose_unchange' => {
			'en' => 'Verbosity unchanged.'."\n",
			'fr' => 'Verbosité inchangée.'."\n",
		},
		'set_verbose_on' => {
			'en' => 'Verbosity on.'."\n",
			'fr' => 'Verbosité activée.'."\n",
		},
		'set_verbose_off' => {
			'en' => 'Verbosity off.'."\n",
			'fr' => 'Verbosité désactivée.'."\n",
		},
		'module_missing' => {
			'en' => $self->{red}.'Seems that some module is missing: '.$self->{normal},
			'fr' => $self->{red}.'On dirait bien qu\'il manque un module : '.$self->{normal},
		},
	);
	### [ /HERE YOU CAN EDIT AND ADD LANGUAGES ] ###
	
	if ( $self->{microsoft_os} ) {
		return eradicate_accents($texts{$string}->{$self->{language}}, $self->{language});
	} else {
		return $texts{$string}->{$self->{language}};
	}
}

=head1 FUNCTION change_language

Example:

  i18n->change_language('fr');

This sub will change the current language.

Available languages:
  en: english
  fr: french

=cut
sub change_language {
	my $self = shift;
	my (@argZ) = @_;
	
	$self->{language} = $argZ[0];
	return;
}

=head1 FUNCTION eradicate_accents

Example:
  my $string_without_accents = eradicate_accents(
    'string_with_accents',
    'language'
  );

This sub will return a string without accentued characters. It depends of the current language.
It is used by text() sub to return the good string.

For now, only for french language there are modifications: no others translations with accents :)
=cut
sub eradicate_accents {
	my $string = shift;
	my $language = shift;
	
	if ( $language eq 'fr' ) {
		# For french language, these chars have to be changed: à, é, è, ê.
		$string =~ s/à/a/g;
		$string =~ s/(è|é|ê)/e/g;
	}
	return $string;
}

1;
