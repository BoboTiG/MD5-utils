#!/usr/bin/perl
#
# $Id       : MD5-utils $
# $HeadURL  : http://www.bobotig.fr/contenu/projets/purmous/ $
# $Source   : http://www.bobotig.fr/contenu/projets/purmous/ $
# $Author   : BoboTiG <bobotig@gmail.com> (http://www.bobotig.fr) $
# $Revision : 16 $
# $Date     : 2011/01/01 $
#


### [ Modules ] ###
use strict;
use Config;
use Cwd qw(abs_path);
use File::Basename;
if ( $Config{useithreads} ) {
	eval "use threads;";
	eval "use threads::shared;";
}
use warnings;

# Personal modules, we need to locate them
my $location;
# Why -12 in the next line? -> lenght('md5-utils.pl') = 12
BEGIN { $location = substr(abs_path($0), 0, -12); }
use lib $location;
use MD5utils::i18n;
use MD5utils::servers;

# Provide a friendly message for missing modules ...
my @non_standard_modules = (
	'Digest::MD5',
	'LWP::UserAgent',
	'Term::ReadLine',
);
foreach ( @non_standard_modules ) {
	next if ( $_ eq 'Term::ReadLine' and check_ms_os() );
	eval "use $_";
	if ( $@ =~ /Can't locate/ ) {
		warn 'Seems that some module is missing: '.$_."\n";
		exit;
	}
}
### [ /Modules ] ###


### [ Script configuration ] ###
# Version
our $VERSION = '20110101';

# Configuration
my %config;
%config = &read_config($location.'md5-utils.cfg');

# Links for update
my $up_link = 'https://github.com/BoboTiG/md5-utils/';
my $test_version = 'md5-utils.version';

# Path where found.txt and not-found.txt will be created
my $path = q{};

# Colors
my ($red, $green, $yellow, $blue, $normal);
if ( $config{colors} ) {
	if ( check_ms_os() ) {
		system 'color a';
	} else {
		$red = "\e[31m";
		$green = "\e[32m";
		$yellow = "\e[33m";
		$blue = "\e[34m";
		$normal = "\e[0m";
	}
} else {
	$yellow = q{};
	$normal = q{};
}
# Shared variable
my $FOUND : shared = 0;
my $TERMINATED : shared = 0;
### [ /Script configuration ] ###


### [ Packages configuration ] ###
# For explanations, see package.pm infos into MD5utils folder or use perldoc.

# Internationalization
my $i18n = i18n::new($VERSION, $config{language}, check_ms_os(), $red, $green, $yellow, $blue, $normal);

# Servers
my @form_get = @servers::form_get;
my @form_post = @servers::form_post;
my %dont_mind = %servers::dont_mind;
### [ /Packages configuration ] ###


### [ Interactive mode configuration ] ###
# Available commands
my @commands = ('clear', 'crack', 'crypt', 'exit', 'file', 'help', 'list', 'quit', 'set', 'update');

# Available set options
my @options_set = ('lang', 'verbose');

# Available languages
my @languages = ('en', 'fr');

# Available help commands
my @commands_help = ('set');
### [ /Interactive mode configuration ] ###


### [ Subs ] ###
#
# Fonction	: check_ms_os
# Objectif	: check Microsoft Windows OS
# Entries	: none
# Returns	: (int)1|0
# Update	: 20100522
#
sub check_ms_os {
	my $os = $^O;
	
	return 1 if ( $os eq 'dos' or $os eq 'MSWin32' or $os eq 'os2' );
	return 0;
}


#
# Fonction	: message
# Objectif	: print header message
# Entries	: none
# Returns	: void
# Update	: 20100512
#
sub message {
	print 'MD5-utils v'.$VERSION.' - Copyright (C) 2009-2011 by BoboTiG.'."\n";
	if ( $Config{useithreads} ) {
		print $i18n->text('use_ithreads') ;
	} else {
		print $i18n->text('use_no_ithreads') ;
	}
	return;
}

#
# Fonction	: message_interactive
# Objectif	: print header message in interactive mode
# Entries	: none
# Returns	: void
# Update	: 20110101
#
sub message_interactive {
	clear_console();
	print
		'                                                           '."\n".
		'  ______   _____    _______                    _  _        '."\n".
		' |  ___ \ (____ \  (_______)             _    (_)| |       '."\n".
		' | | _ | | _   \ \  ______   ___  _   _ | |_   _ | |  ___  '."\n".
		' | || || || |   | |(_____ \ (___)| | | ||  _) | || | /___) '."\n".
		' | || || || |__/ /  _____) )     | |_| || |__ | || ||___ | '."\n".
		' |_||_||_||_____/  (______/       \____| \___)|_||_|(___/  '."\n".
		'                                                 v'.$VERSION."\n".
		'            Copyright (C) 2009-2011 by BoboTiG.            '."\n\n";
	return;
}

#
# Fonction	: args
# Objectif	: arguments traitment
# Entries	: (array)arguments
# Returns	: void
# Update	: 20110101
#
sub args {
	my (@argZ) = @_;
	my @huge_list;
	my $mode = '';
	
	if ( defined $argZ[0] ) 	{
		#
		# Help option
		#
		if ( $argZ[0] eq '-h' or $argZ[0] eq '--help' ) {
			message();
			print 
				"\n".'MD5-utils comes with ABSOLUTELY NO WARRANTY.'."\n".
				'This is free software, and you are welcome to redistribute it under '."\n".
				'certain conditions. See the GNU General Public Licence for details.'."\n";
			help();
		}
		#
		# Crypt option
		#
		elsif ( $argZ[0] eq '-c' or $argZ[0] eq '--crypt' ) {
			# Is there '--stdout'? This would say that we have to use <STDOUT> directly
			if ( in_array('--stdout', @argZ) ) {
				@argZ = purge_array('-c', @argZ);
				@argZ = purge_array('--stdout', @argZ);
				foreach ( @argZ ) {
					generate(rtrim($_), '--stdout');
					print "\n";
				}
			} else {
				message();
				if ( ! defined $argZ[1] ) {
					print $i18n->text('one_word_to_hash_please');
					exit 1;
				} else {
					shift(@argZ);
					foreach ( @argZ ) { generate($_) };
					print "\n";
				}
				print "\n";
			}
		}
		#
		# Crack option
		#
		elsif ( $argZ[0] eq '-d' or $argZ[0] eq '--decrypt' ) {
			message() if ( ! in_array('-q', @argZ) );
			if ( in_array('-b', @argZ) ) {
				@argZ = purge_array('-b', @argZ);
				$config{on_board} = 1;
			}
			if ( in_array('-q', @argZ) ) {
				@argZ = purge_array('-q', @argZ);
				$mode = 'quiet';
			}
			if ( in_array('-p', @argZ) ) {
				@argZ = purge_array('-p', @argZ);
				$config{proxy_enable} = 1;
			}
			if ( in_array('-v', @argZ) ) {
				@argZ = purge_array('-v', @argZ);
				if ( ! $config{verbose} ) { $config{verbose} = 1 };
			}
			# Is there '--stdin'? This would say that we have to use <STDIN> instead of $argZ
			if ( in_array('--stdin', @argZ) ) {
				@argZ = purge_array('--stdin', @argZ);
				while ( <STDIN> ) {
					if ( lc rtrim($_) =~ m/^[a-f0-9]{32}$/xms ) { 
						search($_, $mode);
					}
				}
			} else {
				if ( ! defined $argZ[1] ) {
					print $i18n->text('one_hash_to_crack_please');
					exit 1;
				}
				shift @argZ;
				foreach ( @argZ ) {
					my $hash = lc rtrim($_);
					if ( ! $hash =~ m/^[a-f0-9]{32}$/xms ) { 
						print "\n".$red.$hash.$normal.$i18n->text('invalid_hash');
						next;
					} else { search($hash, $mode); }
				}
			}
			print "\n";
		}
		#
		# Crack all hashes in a file option
		#
		elsif ( $argZ[0] eq '-f' or $argZ[0] eq '--file' ) {
			message();
			if ( in_array('-b', @argZ) ) {
				@argZ = purge_array('-b', @argZ);
				$config{on_board} = 1;
			}
			if ( ! defined $argZ[1] ) {
				print $i18n->text('which_file');
				exit 1;
			}
			$path = File::Basename::dirname($argZ[1]);
			if ( -e $argZ[1] and -r $argZ[1] ) {
				@huge_list = uniq_array($argZ[1]);
				foreach ( @huge_list ) { search($_, 'file'); }
			} else {
				print $i18n->text('cannot_open_file');
			}
			print "\n";
		}
		#
		# Interactive mode option
		#
		elsif ( $argZ[0] eq '-i' or $argZ[0] eq '--imode' ) {
			if ( in_array('-v', @argZ) ) {
				@argZ = purge_array('-v', @argZ);
				$config{verbose} = 1 if ( ! $config{verbose} );
			}
			message_interactive();
			print $i18n->text('entering_interactive_mode');
			while ( 1 ) { interactive_mode(); }
		}
		#
		# List servers option
		#
		elsif ( $argZ[0] eq '-l' or $argZ[0] eq '--list' ) {
			message();
			print "\n";
			list();
			print "\n";
		}
		#
		# Check for update option
		#
		elsif ( $argZ[0] eq '-u' or $argZ[0] eq '--update' ) {
			message();
			print "\n";
			if ( in_array('-p', @argZ) ) {
				@argZ = purge_array('-p', @argZ);
				if ( ! $config{proxy_enable} ) { $config{proxy_enable} = 1 };
			}
			update();
		}
		#
		# Unknown option
		#
		else { print $red.$argZ[0].$i18n->text('invalid_option'); }
	} else {
		message();
		help();
	}
	return;
}

#
# Fonction	: clear_console
# Objectif	: clear the console in interactive mode
# Entries	: none
# Returns	: void
# Update	: 20110101
#
sub clear_console {
	if ( check_ms_os() ) {
		system 'title MD5-utils v'.$VERSION;
		system 'cls';
	} else { system 'clear'; }
	return;
}

#
# Fonction	: generate
# Objectif	: hash one word
# Entries	:
#		- (string)word
#		- (string)mode [default is 'normal']
# Returns	: (array)array_purged
# Update	: 20100625
#
sub generate {
	my $string = shift;
	my $mode = shift || 'normal';
	my $hash = Digest::MD5::md5_hex($string);
	
	if ( $mode eq '--stdout' ) {
		print $hash;
	} elsif ( $mode eq 'interactive' ) {
		print $green.$hash.$normal."\n";
	} else {
		print $i18n->text('hash').$red.$string.$normal.' : '.$green.$hash.$normal;
	}
	return;
}

#
# Fonction	: help
# Objectif	: print help message and exit
# Entries	: none
# Returns	: void
# Update	: 20110101
#
sub help {
	print $i18n->text('help');
	exit 0;
}

#
# Fonction	: imode_cmd
# Objectif	: commands traitment for interactive mode
# Entries	: (array)command_line
# Returns	: void
# Update	: 20110101
#
sub imode_cmd {
	my (@argZ) = @_;
	my @huge_list;
	# Split and push all words in an array
	# $cmd[0]: command name
	# $cmd[1..n]: arguments
	my @cmd = split q{ },  $argZ[0];
	
	if ( defined $cmd[0] and in_array($cmd[0], @commands) ) {
		if ( $cmd[0] eq 'clear' ) {
			message_interactive();
			print $i18n->text('message_interactive_mode');
		} elsif ( $cmd[0] eq 'crack' ) {
			if ( ! defined $cmd[1] ) {
				print $i18n->text('empty_hash');
			} else {
				shift @cmd;
				foreach ( @cmd ) {
					if ( lc $_ =~ m/^[a-f0-9]{32}$/xms ) {
						if ( ! test_connection('interactive') ) {
							print $i18n->text('connection_impossible');
						} else {
							search($_, 'interactive');
						}
					} else {
						print $red.$_.$normal.$i18n->text('invalid_hash');
					}
				}
			}
		} elsif ( $cmd[0] eq 'crypt' ) {
			if ( ! defined $cmd[1] ) {
				print $i18n->text('nothing_to_hash');
			} else {
				shift @cmd;
				foreach ( @cmd ) {
					print $_.': ';
					generate($_, 'interactive');
				}
			}
		} elsif ( $cmd[0] eq 'exit' or $cmd[0] eq 'quit' ) {
			print $i18n->text('exiting');
			exit 0;
		}  elsif ( $cmd[0] eq 'file' ) {
			if ( ! defined $cmd[1] ) {
				print $i18n->text('which_file_interactive');
			} else {
				if ( -e $cmd[1] and -r $cmd[1] ) {
					$path = File::Basename::dirname($cmd[1]);
					@huge_list = uniq_array($cmd[1], 'interactive');
					foreach ( @huge_list ) { search($_, 'file'); }
				} else {
					print $i18n->text('cannot_open_file_interactive');
				}
			}
		} elsif ( $cmd[0] eq 'help' ) {
			if ( defined $cmd[1] and in_array($cmd[1], @commands_help) ) {
				print $i18n->text('help_interactive_mode_'.$cmd[1]);
			} else {
				print $i18n->text('help_interactive_mode');
			}
		} elsif ( $cmd[0] eq 'list' ) {
			list();
		} elsif ( $cmd[0] eq 'set' ) {
			if ( defined $cmd[1] and in_array($cmd[1], @options_set) ) {
				if ( $cmd[1] eq 'lang' ) {
					if ( defined $cmd[2] ) {
						if ( in_array($cmd[2], @languages) ) {
							if ( $config{language} ne $cmd[2] ) {
								$config{language} = $cmd[2];
								$i18n->change_language($config{language});
								message_interactive();
								print $i18n->text('message_interactive_mode')."\n";
							} else {
								print $i18n->text('set_lang_unchanged');
							}
						} else { print $i18n->text('set_lang_error'); }
					} else { print $i18n->text('no_set_value'); }
				} elsif ( $cmd[1] eq 'verbose' ) {
					if ( defined $cmd[2] ) {
						if ( $cmd[2] eq 'off' ) {
							if ( ! $config{verbose} ) {
								print $i18n->text('set_verbose_unchange');
							} else {
								$config{verbose} = 0;
								print $i18n->text('set_verbose_off');
							}
						} elsif ( $cmd[2] eq 'on' ) {
							if ( $config{verbose} ) {
								print $i18n->text('set_verbose_unchange');
							} else {
								$config{verbose} = 1;
								print $i18n->text('set_verbose_on');
							}
						} else {
							print $i18n->text('set_verbose_error');
						}
					} else { print $i18n->text('no_set_value'); }
				}
			} else { print $i18n->text('not_a_set_option'); }
		} elsif ( $cmd[0] eq 'update' ) { update(); }
	} else { print $i18n->text('invalid_command'); }
	return;
}

#
# Fonction	: interactive_mode
# Objectif	: create and deal with the console, this is the interactive mode
# Entries	: none
# Returns	: void
# Update	: 20110101
#
sub interactive_mode {
	my $prompt;
	my $command;
	my $term;
	
	if ( defined $ENV{USERNAME} ) {
		$prompt = $ENV{USERNAME}.' # ';
	} else {
		$prompt = 'BoboTiG # ';
	}
	print "\n";
	if ( check_ms_os() ) {
		print $prompt;
		chomp($command = <STDIN>);
		$command = rtrim($command);
		imode_cmd($command);
	} else {
		$term = Term::ReadLine->new('MD5-utils');
		while ( defined($_ = $term->readline($prompt)) ) {
			$term->addhistory($_) if /\S/;
			imode_cmd($_) if /\S/;
		}
	}
	return;
}

#
# Fonction	: in_array
# Objectif	: check if a variable is into an array
# Entries	:
#		- (string)variable
#		- (array)checked_array
# Returns	: (int)1|0
# Update	: 20100512
#
sub in_array {
	my $var = shift;
	
	foreach ( @_ ) { return 1 if ( $_ eq $var ); }
	return 0;
}

#
# Fonction	: is_numeric
# Objectif	: check if a variable is numeric
# Entries	: (int)variable
# Returns	: (int)1|0
# Update	: 20110101
#
sub is_numeric {
	my $value = shift;
	my $len = length $value;
	
	if ( substr $value, 0, 1 eq '-' ) {
		--$len;
		$value = substr $value, 1;
	}
	return 1 if ( $value =~ m/^\d{$len}$/xms );
	return 0;
} #end is_numeric

#
# Fonction	: list
# Objectif	: list all servers
# Entries	: none
# Returns	: void
# Update	: 20100728
#
sub list {
	my $i = 1;
	my $server;
	
	print $i18n->text('server_list');
	# Array GET
	foreach my $SERVER ( @form_get ) {
		$server = $$SERVER[0];
		print "\t".'('.$i.')'."\t".$server."\n";
		++$i;
	}
	# Array POST
	foreach my $SERVER ( @form_post ) {
		$server = $$SERVER[0];
		print "\t".'('.$i.')'."\t".$server."\n";
		++$i;
	}
	return;
}

#
# Fonction	: purge_array
# Objectif	: purge an array from a variable
# Entries	:
#		- (mixed)value
#		- (array)array_to_purge
# Returns	: (array)array_purged
# Update	: 20100521
#
sub purge_array {
	my $value = shift;
	my (@array) = @_;
	my $len = $#array;
	
	for ( my $i = 0; $i <= $len; ++$i ) {
		splice(@_, $i, 1) if ( $array[$i] eq $value );
	}
	return @_;
}


#
# Fonction	: read_config
# Objectif	: read config file and store key/values into a hash
# Entries	: (string)config file path
# Returns	: (hash)config hash
# Update	: 20110101
#
sub read_config {
	my $config_file = shift;
	my %config;
	my $FILE;
	
	%config = (
		'language'		=> 'en',
		'colors'		=> 1,
		'verbose'		=> 0,
		'on_board'		=> 0,
		'user_agent'	=> 'Mozilla/5.0 (X11; U; Linux x86_64; fr; rv:1.9.1.9) Gecko/20100501 Iceweasel/3.5.9 (like Firefox/3.5.9)',
		'proxy_enable'	=> 0,
		'proxy'			=> 'http://221.130.13.232:80',
	);
	if ( open $FILE, '<', $config_file ) {
		foreach ( <$FILE> ) {
			if ( $_ =~ m/^language = (.+)$/ms ) {
				if ( $1 =~ m/^(en|fr)$/xms ) {
					$config{language} = $1;
				} else {
					warn '"language" configuration mistake.'."\n";
				}
			} elsif ( $_ =~ m/^colors = (.+)$/ms ) {
				if ( $1 =~ m/^(true|false)$/xms ) {
					if ( $1 eq 'true' ) { $config{colors} = 1; }
					if ( $1 eq 'false' ) { $config{colors} = 0; }
				} else {
					warn '"color" configuration mistake.'."\n";
				}
			} elsif ( $_ =~ m/^verbose = (.+)$/ms ) {
				if ( $1 =~ m/^(true|false)$/xms ) {
					if ( $1 eq 'true' ) { $config{verbose} = 1; }
					if ( $1 eq 'false' ) { $config{verbose} = 0; }
				} else {
					warn '"verbose" configuration mistake.'."\n";
				}
			} elsif ( $_ =~ m/^on_board = (.+)$/ms ) {
				if ( $1 =~ m/^(true|false)$/xms ) {
					if ( $1 eq 'true' ) { $config{on_board} = 1; }
					if ( $1 eq 'false' ) { $config{on_board} = 0; }
				} else {
					warn '"on_board" configuration mistake.'."\n";
				}
			} elsif ( $_ =~ m/^user_agent = (.+)$/ms ) {
				$config{user_agent} = $+;
			} elsif ( $_ =~ m/^proxy_enable = (.+)$/ms ) {
				if ( $1 =~ m/^(true|false)$/xms ) {
					if ( $1 eq 'true' ) { $config{proxy_enable} = 1; }
					if ( $1 eq 'false' ) { $config{proxy_enable} = 0; }
				} else {
					warn '"proxy_enable" configuration mistake.'."\n";
				}
			} elsif ( $_ =~ m/^proxy = (.+)$/ms ) {
				if ( $1 =~ m/^http:\/\//xms ) {
					$config{proxy} = $1;
				} else { warn '"proxy" configuration mistake.'."\n"; }
			}
		}
		close $FILE;
	} else {
		warn 'Config file "'.$config_file.'" cannot be open !'."\n";
	}
	return %config;
}


#
# Fonction	: rtrim
# Objectif	: remove trailing whitespace at the end of a string
# Entries	: (string)string
# Returns	: (string)string_purged
# Update	: 20100728
#
sub rtrim {
	my $var = shift;
	
	$var =~ s/\s+$//;
	return $var;
}


# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
# IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
#
# Fonction	: (multi-threaded)search
# Objectif	: try to crack one hash using all available servers
# Entries	:
#		- (string)hash
#		- (string)mode [default is 'normal']
# Returns	: void
# Update	: 20100728
#
sub search {
	my $hash_to_crack = shift;
	my $mode = shift || 'normal';
	my (@argZ) = @_;
	my ($ua, $server, $link, $regexp, $requete, $looking_for, $result);
	my $j;
	my $output;
	my $FILE;
	
	if ( $mode ne 'quiet' and $mode ne 'interactive' ) {
		print "\n".' >> '.$yellow.$hash_to_crack.$normal.' <<'."\n";
	}
	if ( $Config{useithreads} ) {
		$FOUND = 0;
		$TERMINATED = 0;
		foreach my $GET ( @form_get ) {
			$server = $$GET[0];
			last if ( $TERMINATED );
			$$GET[1] =~ s/\{hash\}/$hash_to_crack/;
			# Params: hash, server, link, regexp, mode
			my $thr = threads->create('search_thread_get', $hash_to_crack, $server, $$GET[1], $$GET[2], $mode);
			$thr->set_thread_exit_only('true');
			$thr->detach();
			sleep(1);
		}
		foreach my $POST ( @form_post ) {
			$server = $$POST[0];
			my %arguments;
			last if ( $TERMINATED );
			for ( $j = 1; $j <= $$POST[3]; ++$j ) {
				$$POST[($j + 3)][1] =~ s/\{hash\}/$hash_to_crack/ if ( grep /\{hash\}/, $$POST[($j + 3)][1] );
				$arguments{$$POST[($j + 3)][0]} = $$POST[($j + 3)][1];
			}
			# Params: hash, server, link, regexp, mode, arguments
			my $thr = threads->create('search_thread_post', $hash_to_crack, $server, $$POST[1], $$POST[2], $mode, %arguments);
			$thr->set_thread_exit_only('true');
			$thr->detach();
			sleep(1);
		}
	} else {
		foreach my $GET ( @form_get ) {
			$server = $$GET[0];
			$link = $$GET[1];
			$link =~ s/\{hash\}/$hash_to_crack/;
			$regexp = $$GET[2];
			$ua = new LWP::UserAgent;
			$ua->agent($config{user_agent});
			$ua->proxy('http',  $config{proxy}) if $config{proxy_enable};
			$requete = $ua->request(new HTTP::Request('GET', $link));
			if ( $requete->is_success ) {
				$looking_for = $requete->content;
				$looking_for =~ /($regexp)/;
				$result = $+;
				if ( defined $result ) {
					if ( $server eq 'www.google.com' ) {
						my @tmp = split '</em>', $result;
						$result = $tmp[0];
					}
					if ( ! defined $dont_mind{$server} or $result ne $dont_mind{$server} ) {
						$FOUND = 1;
						search_result($hash_to_crack, $result, $server, $mode);
						last;
					}
				} elsif ( $config{verbose} ) {
					print $i18n->text('no_result').$server."\n";
				}
			} elsif ( $config{verbose} ) {
				print $i18n->text('server_connection_impossible').$server."\n";
			}
		}
		if ( ! $FOUND ) {
			foreach my $POST ( @form_post ) {
				$server = $$POST[0];
				$link = $$POST[1];
				$regexp = $$POST[2];
				my %arguments;
				for ( $j = 1; $j <= $$POST[3]; ++$j ) {
					$$POST[($j + 3)][1] =~ s/\{hash\}/$hash_to_crack/ if ( grep /\{hash\}/, $$POST[($j + 3)][1] );
					$arguments{$$POST[($j + 3)][0]} = $$POST[($j + 3)][1];
				}
				$ua = new LWP::UserAgent;
				$ua->agent($config{user_agent});
				$ua->proxy('http',  $config{proxy}) if ( $config{proxy_enable} );
				$requete = $ua->post($link, \%arguments) ;
				if ( $requete->is_success ) {
					$looking_for = $requete->content;
					$looking_for =~ /($regexp)/;
					$result = $+;
					if ( defined $result and (! defined $dont_mind{$server} or $result ne $dont_mind{$server}) ) {
						search_result($hash_to_crack, $result, $server, $mode);
						$FOUND = 1 ;
						last;
					} elsif ( $config{verbose} ) {
						print $i18n->text('no_result').$server."\n";
					}
				} elsif ( $config{verbose} ) {
					print $i18n->text('server_connection_impossible').$server."\n";
				}
			}
		}
	}
	if ( ! $FOUND ) {
		return if ( $mode eq 'quiet' );
		if ( $config{verbose} ) {
			print $i18n->text('no_result').$server."\n";
		} else {
			if ( $mode eq 'file' ) {
				$output = $path.'/not-found.txt';
				open $FILE, '>>', $output;
				print $FILE "\n".$hash_to_crack;
				close $FILE;
			}
			print $i18n->text('not_found');
		}
	}
	return;
}


#
# Fonction	: search_result
# Objectif	: manage results
# Entries	:
#		- (string)hash
#		- (mixed)result
#		- (string)server_name
#		- (string)mode
# Returns	: void
# Update	: 20100728
#
sub search_result {
	my $hash_to_crack = shift;
	my $result = shift;
	my $server = shift;
	my $mode = shift;
	my $output;
	my $FILE;
	
	if ( ($Config{useithreads} and ! $TERMINATED) or ! $Config{useithreads} ) {
		if ( (($Config{useithreads} and $FOUND) or ! $Config{useithreads}) and $result ne '' ) {
			if ( $hash_to_crack eq Digest::MD5::md5_hex($result) ) {
				$TERMINATED = 1 if ( $Config{useithreads} );
				if ( $mode eq 'quiet' ) {
					print $result;
				} else {
					if ( $config{verbose} ) {
						print $i18n->text('found_verbose').$server.': ';
						print $green.$result.$normal."\n";
					} else {
						print $i18n->text('found').$green.$result.$normal."\n";
					}
					print $blue.Digest::MD5::md5_hex($result).':[color=green][b]'.$result.'[/b][/color]'.$normal."\n" if ( $config{on_board} );
					if ( $mode eq 'file' ) {
						$output = $path.'/found.txt';
						open $FILE, '>>', $output;
						if ( $config{on_board} ) {
							print $FILE Digest::MD5::md5_hex($result).':[color=green][b]'.$result.'[/b][/color]'."\n";
						} else {
							print $FILE "\n".$hash_to_crack.':'.$result;
						}
						close $FILE;
					}
				}
			} else {
				$FOUND = 0 if ( $Config{useithreads} );
				if ( $mode ne 'quiet' ) {
					print $i18n->text('not_found_but_collision');
					print 's: '.$server;
					print "\nr: '".$green.$result.$normal.'\''."\n";
				}
				if ( $mode eq 'file' ) {
					$output = $path.'/not-found.txt';
					open $FILE, '>>', $output;
					print $FILE "\n".$hash_to_crack;
					close $FILE;
				}
			}
		} elsif ( $config{verbose} ) {
			print $i18n->text('no_result').$server."\n";
		}
	}
	return;
}

#
# Fonction	: search_thread_get
# Objectif	: try to crack one hash using all GET servers using several threads
# Entries	:
#		- (string)hash
#		- (string)server_name
#		- (string)server_link
#		- (string)server_regexp
#		- (string)mode
# Returns	: void
# Update	: 20110101
#
sub search_thread_get {
	my $hash = shift;
	my $server = shift;
	my $link = shift;
	my $regexp = shift;
	my $mode = shift;
	my ($ua, $requete, $looking_for, $result);
	my @tmp;
	
	$ua = new LWP::UserAgent;
	$ua->agent($config{user_agent});
	$ua->proxy('http',  $config{proxy}) if $config{proxy_enable};
	eval '$ua->request(new HTTP::Request("GET", "$link"));';
	if ( $config{verbose} and $@ =~ /Can'to connect/ ) {
		print $i18n->text('server_connection_impossible').$server."\n";
	} else {
		$requete = $ua->request(new HTTP::Request('GET', $link));
		if ( $requete->is_success ) {
			$looking_for = $requete->content;
			$looking_for =~ /($regexp)/;
			$result = $+;
			if ( defined $result ) {
				if ( $server eq 'www.google.com' ) {
					@tmp = split '</em>', $result;
					$result = $tmp[0]; 
				}
				if ( ! defined $dont_mind{$server} or $result ne $dont_mind{$server} ) {
					$FOUND = 1;
				}
			}
			search_result($hash, $result, $server, $mode);
		} elsif ( $config{verbose} ) {
			print $i18n->text('server_connection_impossible').$server."\n";
		}
	}
	threads->exit();
}


#
# Fonction	: search_thread_post
# Objectif	: try to crack one hash using all POST servers using several threads
# Entries	:
#		- (string)hash
#		- (string)server_name
#		- (string)server_link
#		- (string)server_regexp
#		- (string)mode
#		- (hash)POST_arguments
# Returns	: void
# Update	: 20110101
#
sub search_thread_post {
	my $hash = shift;
	my $server = shift;
	my $link = shift;
	my $regexp = shift;
	my $mode = shift;
	my (%arguments) = @_;
	my ($ua, $requete, $looking_for, $result);
	
	$ua = new LWP::UserAgent;
	$ua->agent($config{user_agent});
	$ua->proxy('http',  $config{proxy}) if ( $config{proxy_enable} );
	eval '$ua->post("$link", %arguments);';
	if ( $config{verbose} and $@ =~ /Can'to connect/ ) {
		print $i18n->text('server_connection_impossible').$server."\n";
	} else {
		$requete = $ua->post($link, \%arguments);
		if ( $requete->is_success ) {
			$looking_for = $requete->content;
			$looking_for =~ /($regexp)/;
			$result = $+;
			if ( defined $result and (! defined $dont_mind{$server} or $result ne $dont_mind{$server}) ) {
				$FOUND = 1;
			}
			search_result($hash, $result, $server, $mode);
		} elsif ( $config{verbose} ) {
			print $i18n->text('server_connection_impossible').$server."\n";
		}
	}
	threads->exit();
}

#
# Fonction	: uniq_array
# Objectif	: uniq an array
# Entries	: (array)array_to_purge
# Returns	: (array)array_purged
# Update	: 20100510
#
sub uniq_array {
	my (@argZ) = @_;
	my $huge_file = $argZ[0];
	my @list;
	my @uniqed;
	my %u;
	my $hash;
	my $file;
	my $len;
	
	# Message
	if ( defined($argZ[1]) and $argZ[1] eq 'interactive' ) {
		print $i18n->text('sorting_file_interactive').$blue.$huge_file.$normal." ...\n";
	} else {
		print $i18n->text('sorting_file').$blue.$huge_file.$normal." ...\n";
	}
	# Transfert hashes from file to array
	open($file, '<', $huge_file);
	while ( <$file> ) {
		$len = length(rtrim($_));
		if ( $len >= 32 ) {
			$_ = lc($_);
			$hash = substr($_, 0, 32);		
			push(@list, $hash) if grep(/[a-f0-9]{32}/, $hash);
		}
	}
	close($file);
	# Uniq uniq!
	@uniqed = grep {defined} map {
		if ( exists $u{$_} ) {
			undef;
		} else {
			$u{$_} = undef;
			$_;
		}
	} @list;
	undef %u;
	return @uniqed;
}

#
# Fonction	: update
# Objectif	: check online for an up to date version of MD5-utils
# Entries	: none
# Returns	: void
# Update	: 20100619
#
sub update {
	my $ua;
	my $requete;
	my $latest;
	
	print $i18n->text('checking');
	print $i18n->text('this_version').$VERSION."\n";
	$ua = new LWP::UserAgent;
	$ua->agent($config{user_agent});
	$ua->proxy('http',  $config{proxy}) if $config{proxy_enable};
	$requete = $ua->get($up_link.$test_version);
	if ( $requete->is_success ) {
		$latest = rtrim($requete->content);
		if ( ! is_numeric($latest) ) {
			print $i18n->text('error_retrieving_version');
		} elsif ( $VERSION < $latest ) {
			print $i18n->text('latest_version').$latest;
			print $i18n->text('update_available');
			print $i18n->text('get_latest_version');
			print $blue.$up_link.$normal."\n";
		} elsif ( $VERSION > $latest ) {
			print $i18n->text('latest_version').$latest;
			print $i18n->text('futurist_version');
		}
	} else {
		print $i18n->text('connection_impossible');
	}
	return;
}
### [ /Subs ] ###


###
# Let's go!
args(@ARGV);
exit;
