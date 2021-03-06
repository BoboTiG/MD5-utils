
     ______   _____    _______                    _  _       
    |  ___ \ (____ \  (_______)             _    (_)| |       
    | | _ | | _   \ \  ______   ___  _   _ | |_   _ | |  ___  
    | || || || |   | |(_____ \ (___)| | | ||  _) | || | /___)
    | || || || |__/ /  _____) )     | |_| || |__ | || ||___ |
    |_||_||_||_____/  (______/       \____| \___)|_||_|(___/  
               Copyright (C) 2009-2013 by BoboTiG

MD5-utils comes with ABSOLUTELY NO WARRANTY.  
This is free software, and you are welcome to redistribute it under  
certain conditions. See the GNU General Public Licence for details.  


English
---

**What is this?**

MD5-utils is a script for MD5 hash function manipulations.   
It can crypt one or more word(s) and try to crack one or more hash(es)  
using online servers. 

**Options**

You can change few options on the top of script.
	
**Examples**

* View help message:

	    perl md5-utils.pl -h
	
* Print server list:

	    perl md5-utils.pl -l
	
* Look for an update:

	    perl md5-utils.pl -u
	
* Interactive mode:

	    perl md5-utils.pl -i
	
* Hash one or more word(s):

	    perl md5-utils.pl -c <word> <word> ...
	
* Try to crack one or more hash(es):

	    perl md5-utils.pl -d <hash> <hash> ...
	
* Try to crack hashes from file:

	    perl md5-utils.pl -f way/to/the/file
	    (found-txt will contain reversible hashes, not-found.txt will contain others)

**Special uses**

You can choose to receive or send args by two ways:

* One for the crypt option, it send results to <STDOUT> and can be used by another  
script using <STDIN>, try this:

	    perl md5-utils.pl -c <word> <word> --stdout
	
* The second is for the crak option, it receive hashes from another script
using <STDIN>, try this:

	    perl md5-utils.pl -d --stdin


Français
---

**De quoi s'agit-il ?**

MD5-utils est un script pour la manipulation de hashes chiffrés en MD5.  
Il peut crypter un ou plusieurs mot(s) et tenter de cracker un ou plusieurs hash(es)  
en effectuant des recherches sur plusieurs serveurs en ligne.

**Options**

	Vous pouvez changer quelques options en début de script.

**Exemples**

* Afficher le message d'aide :
 
	    perl md5-utils.pl -h
	
* Afficher la liste des serveurs :

	    perl md5-utils.pl -l
	
* Voir si une mise à jour existe :

	    perl md5-utils.pl -u
	
* Mode intéractif :

	    perl md5-utils.pl -i
	
* Hasher un ou plusieurs mot(s) :

	    perl md5-utils.pl -c <mot> <mot> ...
	
* Tenter de cracker un ou plusieurs hash(es) :

	    perl md5-utils.pl -d <hash> <hash> ...
	
* Tenter de cracker les hash contenus dans un fichier :

	    perl md5-utils.pl -f chemin/vers/le/fichier
	    (found-txt contiendra les hashes réversibles, not-found.txt contiendra les autres)

**Utilisations spéciales**

Vous avez le choix entre deux autres moyens de recevoir et envoyer des informations :

* Une pour l'option de cryptage, à enverra tout à <STDOUT> pour être utilisé par un autre  
script qui bouclera sur <STDIN>, essayez ceci :

		perl md5-utils.pl -c <mot> <mot> --stdout
		
* La deuxième pour l'option de crack, elle recevra les hashes envoyés par un autre  
script en utilisant <STDIN>, essayez ceci :

		perl md5-utils.pl -d --stdin


End / Fin
---

use bye::bye qw(Tcho);
