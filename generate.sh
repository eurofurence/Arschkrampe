#!/bin/bash

UP=icons/arrow_up.png
DOWN=icons/arrow_down.png
LEFT=icons/arrow_left.png
RIGHT=icons/arrow_right.png
TURN=icons/arrow_turnaround.png
HERE=icons/here.png
ELEVATOR=icons/elevator_up.png
STAIRS=icons/stairs_up.png
BLANK=icons/blank.png
CROSS=icons/cross.png
WHEELCHAIR=icons/wheelchair_white.png
FIRSTAID=icons/cross.png

BACKGROUND_LANDSCAPE=EF26_Signage_Landscape.png
BACKGROUND_PORTRAIT=EF26_Signage_Portrait.png

FONT=GOTHIC.TTF

HEADERPOS_LANDSCAPE=(+160+310)
## Offset Y = 180
TEXTPOS_LANDSCAPE=(+340+460 +340+640 +340+820 +1220+460 +1220+640 +1220+820)
## Offest von 80 funktioniert gut
SUBTEXTPOS_LANDSCAPE=(+340+548 +340+728 +340+908 +1220+548 +1220+728 +1220+908)
## Offset von -180 (nach links) und 20 nach unten
ICONPOS_LANDSCAPE=(+160+480 +160+660 +160+840 +1040+480 +1040+660 +1040+840)

HEADERPOS_PORTRAIT=(+160+300)
## Offset Y = 180
TEXTPOS_PORTRAIT=(+340+460 +340+640 +340+820 +340+1000 +340+1180 +340+1360 +340+1540)
## Offest von 80 funktioniert gut
SUBTEXTPOS_PORTRAIT=(+340+548 +340+728 +340+908 +340+1088 +340+1268 +340+1448 +340+1628)
## Offset von -180 (nach links) und 20 nach unten
ICONPOS_PORTRAIT=(+160+480 +160+660 +160+840 +160+1020 +160+1200 +160+1380 +160+1560)

COLORTEXT=#FFFFFF
COLORSUBTEXT=#c0c0c0


############ Get params from file 

if [ -z "$1" ]
then
	echo "No input file defined"
    exit -1
else
	source $1
fi

if [ "$ORIENTATION" = "landscape" ]
then
	HEADERPOS=$HEADERPOS_LANDSCAPE
	TEXTPOS=("${TEXTPOS_LANDSCAPE[@]}")
	SUBTEXTPOS=("${SUBTEXTPOS_LANDSCAPE[@]}")
	ICONPOS=("${ICONPOS_LANDSCAPE[@]}")
	BACKGROUND=$BACKGROUND_LANDSCAPE
	TEXTICONOFFSETX=500
elif [ "$ORIENTATION" = "portrait" ]
then
	HEADERPOS=$HEADERPOS_PORTRAIT
	TEXTPOS=("${TEXTPOS_PORTRAIT[@]}")
	SUBTEXTPOS=("${SUBTEXTPOS_PORTRAIT[@]}")
	ICONPOS=("${ICONPOS_PORTRAIT[@]}")
	BACKGROUND=$BACKGROUND_PORTRAIT
	TEXTICONOFFSETX=550
else
	echo "Error in reading orientation"
	exit -1
fi

############ Adding Header Text

CONVERT="convert -font $FONT -pointsize 72 -stroke white -fill \"$COLORTEXT\" -gravity NorthWest"

if [ "${TYPE[0]}" = "rooms" ]
then
	HEADERTEXT="Event Rooms"
elif [ "${TYPE[0]}" = "services" ]
then
	HEADERTEXT="Convention Services"
else
	echo "ERROR: Unknown Room/Service type"
	exit -1
fi

if [ ! -z "${TYPE[1]}" ]
then
	HEADERTEXT="$HEADERTEXT ${TYPE[1]}"
fi

CONVERT="$CONVERT -annotate $HEADERPOS \"$HEADERTEXT\""

############# Adding Major Room Text

# Function to chain up the text strings, also handle the newline for moving the subtext:
SUBTEXTPADDINGPLUS=90

function addRoomName {
	ROOM_NAME=ROOM_$1[1] # Copy over the room - kinda dynamic
	if [ ! -z "${!ROOM_NAME}" ]
	then
		#echo "${!ROOM_NAME}"
		CONVERT="$CONVERT -annotate ${TEXTPOS[$1]} \"${!ROOM_NAME}\""
		if [[ ${!ROOM_NAME} =~ "\n" ]]
		then
			IFS='+' ## Set the delimiter to +
			read -a SubTextNew <<< ${SUBTEXTPOS[$1]} ## Split it!
			unset IFS ## Unset the Delimiter - or things break
			SUBTEXTPOS[$1]="+${SubTextNew[1]}+$((${SubTextNew[2]} + $SUBTEXTPADDINGPLUS))" # rebuild spacing with padding
		fi
	else
	echo "WARNING: Room $1 in $NAME is not set"
	fi
}

# Do the actual work
for ROOM_NUMBER in {0..6}
do
	addRoomName $ROOM_NUMBER
done

# ############# Doing the work into a temp

CONVERT="$CONVERT $BACKGROUND temp.png"
#echo "Running: $CONVERT"
eval $CONVERT

############# Start with the secondary text (original 36)

CONVERT="mogrify -format png -font $FONT -pointsize 38 -fill \"$COLORSUBTEXT\" -gravity NorthWest"

function addSubText {
	ROOM_SUBTEXT=ROOM_$1[2]
	if [ ! -z "${!ROOM_SUBTEXT}" ]
	then
		CONVERT="$CONVERT -annotate ${SUBTEXTPOS[$1]} \"${!ROOM_SUBTEXT}\""
	#else
		#echo "WARNING: Subtext Room 0 not set"
	fi
}

# Do the actual work
for ROOM_NUMBER in {0..6}
do
	addSubText $ROOM_NUMBER
done

############# Add it to the picture
CONVERT="$CONVERT temp.png"
#echo "Running: $CONVERT"
eval $CONVERT

############# Icons

CONVERT_HEAD="composite -compose atop -gravity NorthWest"
CONVERT_TAIL="temp.png temp.png"

function replaceIcon {
	if [ $ICON = "up" ]
	then
		ICON=$UP
	elif [ $ICON = "down" ]
	then
		ICON=$DOWN
	elif [ $ICON = "left" ]
	then
		ICON=$LEFT
	elif [ $ICON = "right" ]
	then
		ICON=$RIGHT
	elif [ $ICON = "turn" ]
	then
		ICON=$TURN
	elif [ $ICON = "here" ]
	then
		ICON=$HERE
	elif [ $ICON = "elevator" ]
	then
		ICON=$ELEVATOR
	elif [ $ICON = "stairs" ]
	then
		ICON=$STAIRS
	elif [ $ICON = "wheelchair" ]
	then
		ICON=$WHEELCHAIR
	elif [ $ICON = "medic" ]
	then
		ICON=$FIRSTAID
	elif [ $ICON = "blank" ]
	then
		ICON=$BLANK
	else
		echo "ERROR: Found no valid icon for entry $ICON"
		exit -1
	fi
}
	
########## Let's start with placing the arrows

function insertIcon {
	ROOM_ICON=ROOM_$1[0]
	if [ ! -z "${!ROOM_ICON}" ]
	then
		ICON=${!ROOM_ICON}
		replaceIcon #little switcharoo - since Bash functions don't know a return string
		CONVERT="$CONVERT_HEAD -geometry ${ICONPOS[$1]} $ICON $CONVERT_TAIL"
		#echo "Running: $CONVERT"
		eval $CONVERT
	fi
}

########## Add the additional icons

function insertTextIcon {
	ROOM_TEXTICON=ROOM_$1[3]
	if [ ! -z "${!ROOM_TEXTICON}" ]
	then
		ICON=${!ROOM_TEXTICON}
		replaceIcon
		IFS='+' ## Set the delimiter to +
		read -a TextIconPos <<< ${TEXTPOS[$1]} ## Split it!
		unset IFS ## Unset the Delimiter - or things break
	
		TextIconPos="+$((${TextIconPos[1]} + $TEXTICONOFFSETX ))+$((${TextIconPos[2]} + 20 ))" # building the icon position
		CONVERT="$CONVERT_HEAD -geometry $TextIconPos \( $ICON -resize 72x72 \) $CONVERT_TAIL"
		eval $CONVERT
	fi
}

# Do the actual work
for ROOM_NUMBER in {0..6}
do
	insertIcon $ROOM_NUMBER
	insertTextIcon $ROOM_NUMBER
done

# Add debug output at the bottom
#mogrify -format png -font $FONT -pointsize 12 -fill black -gravity SouthEast -annotate +0+0 "$NAME generated at $(date +%Y-%m-%d_%H-%M-%S)" temp.png

if [ -f "output/${NAME}.png" ]; then
	echo "ERROR: ${NAME}.png ALREADY EXISTS"
fi
mv temp.png output/${NAME}.png

echo "NOTICE: Saving to output/${NAME}.png"
exit 0
