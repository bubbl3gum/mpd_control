#!/bin/bash

# source configuration file for dmenu if exists
if [ -f $HOME/.dmenurc ]; then
  . $HOME/.dmenurc
else
  DMENU='dmenu -i'
fi


case $1 in
	
	-a|--artist)
	
	while true; do

		ARTIST="$(mpc list artist | sort -f | $DMENU)";
		if [ "$ARTIST" = "" ]; then break; fi
		
		while true; do

			ALBUMS=$(mpc list album artist "$ARTIST");
			ALBUM=$(echo -e "replace all\nadd all\n--------------------------\n$ALBUMS" | $DMENU);
			if [ "$ALBUM" = "" ]; then break;
			
			elif [ "$ALBUM" = "replace all" ]; then mpc clear && mpc list filename artist "$ARTIST" | mpc add && mpc play && exit;
			elif [ "$ALBUM" = "add all" ]; then mpc list filename artist "$ARTIST" | mpc add && mpc play && exit;
			fi
			
			while true; do
				
				TITLES=$(mpc list title artist "$ARTIST" album "$ALBUM")
				TITLE=$(echo -e "replace all\nadd all\n--------------------------\n$TITLES" | $DMENU);
				if [ "$TITLE" = "" ]; then break; fi
				if [ "$TITLE" = "replace all" ]; then
					mpc clear;
					mpc list filename artist "$ARTIST" album "$ALBUM" | mpc add; 
				elif [ "$TITLE" = "add all" ]; then
					mpc list filename artist "$ARTIST" album "$ALBUM" | mpc add; 
				
				else
				while true; do
					DEC=$(echo -e "replace\nadd" | $DMENU);
					if [ "$DEC" = "" ]; then break; fi
					if [ "$DEC" = "replace" ]; then
						mpc clear;
					fi
				
					mpc list filename artist "$ARTIST" album "$ALBUM" title "$TITLE"| mpc add; 
					mpc play;
					exit;	

					

				done
				fi



			done
			


		done
		
		
	
	done
	;;

	-t|--track)
		
		CURRENT=$(mpc | sed -n '2,2p' | tr -s " "  | cut -d " "  -f 2 | cut -d "#" -f 2 | cut -d "/" -f 1)
		
		TITLE=$(mpc list title | sort -f | $DMENU | head -n 1)
		if [ "$TITLE" = "" ]; then exit; fi
		
		SONG=$(mpc list filename title "$TITLE") 
		mpc add "$SONG";
		LAST=$(mpc | sed -n '2,2p' | tr -s " "  | cut -d " "  -f 2 | cut -d / -f 2)
		if [ "$LAST" = "" ]; then mpc play;
		else mpc move $LAST $((CURRENT+1)) && mpc play $((CURRENT+1))
		fi 
	
	;;

	-p|--playlist)
	PLAYLIST=$(mpc lsplaylists | $DMENU);
	if [ "$PLAYLIST" = "" ]; then exit; fi
	mpc clear
	mpc load "$PLAYLIST";
	mpc play 
	#`mpc | sed -n '2,2p' | tr -s " " | cut -d " " -f 2 | cut -d "/" -f 2`

	;;

	-j|--jump)
	
	TITLE=$(mpc playlist | $DMENU);
	if [ "$TITLE" = "" ]; then exit; fi
	POS=$(echo "$TITLE" | awk '{print $1}' | sed 's/)//' | sed 's/>//');
	mpc play $POS;
	;;
	
	-h|--help)
	echo -e "-a, --artist\tsearch for artist, then album, then title"
    echo -e "-t, --track\tsearch for a single track in the whole database"
	echo -e "-p, --playlist\tsearch for a playlist play it"
	echo -e "-j, --jump\tjump to another song in the current playlist"		 
	
	
	
	
	;;
	
	*)
	echo "Usage: mpc_control [OPTION]"
	echo "Try 'mpc_control --help' for more information."
	;;

esac
