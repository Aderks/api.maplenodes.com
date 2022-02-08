#!/bin/bash

# Credit goes to player1537 who created the script seen at https://github.com/player1537-playground/bash-stuff/blob/master/blackjack.bash aside from the changes made by myself

#set -x

function display-helper() {
    sed -e 's/./&,/g; s/0/10/g; s/,$//'
}

function display-hand() {
    local hand card type
    hand=$1
    type=$2
    case $type in
	dealer) echo ${hand:0:1}? | display-helper;;
	player) echo "$(echo ${hand} | display-helper) [$(count-value $hand)]";;
	full) echo "$(echo ${hand} | display-helper) [$(count-value $hand)]";;
    esac
}

function clear-used() {
    >$USEDCARDS
}

function add-used() {
    local hand
    hand=$1
    echo $hand | sed -e 's/./&,/g; s/,$//; s/,/\n/g' >> $USEDCARDS
}

function reshuffle-cards() {
    echo Reshuffle cards >&2
    cat $USEDCARDS | shuf >> $CARDFILE
    clear-used
}

function shuffle-cards() {
    local line array
    array=(A 2 3 4 5 6 7 8 9 0 J Q K)
    seq 0 52 | while true; do 
	read line || break
	echo ${array[$(($line / 4))]}
    done | head -n 52 | shuf > $CARDFILE
}

function draw-card() {
    if [ $(wc -l <$CARDFILE) -lt 5 ]; then
	reshuffle-cards
    fi
    head -n 1 $CARDFILE
    sed -e '1d' $CARDFILE -i
}

function count-value() {
    local hand aces value card i
    hand=$1
    aces=0
    value=0
    for ((i=0; i<${#hand}; i++)); do
	card=${hand:i:1}
	((value += $(echo $card | sed -e '/[1-9]/q; s/[0JQK]/10/; s/A/11/')))
	if [ $card = A ]; then
	    ((aces++))
	fi
    done
    while [ $value -gt 21 -a $aces -gt 0 ]; do
	((value -= 10))
	((aces--))
    done
    echo $value
}

function play-dealer() {
    local hand
    if [ -n "$1" ]; then
	hand=$1
    else
	hand=$(draw-card)$(draw-card)
    fi
    while [ $(count-value $hand) -lt 17 ]; do
	hand=$hand$(draw-card)
    done
    echo $hand
}

function get-char() {
    local line
    read line
    echo ${line:0:1}
}

function remove-expired-rounds() {
	#find $PWD/* -type d -mmin +1 -exec rm -r {} \; > /dev/null 2>&1 #rounds expire in 1 mins #windows
	find /services/blackjack/* -type d -mmin +30 -exec rm -r {} \; > /dev/null 2>&1 #rounds expire in 30 mins #ubuntu
}

function get-round() {
	round_id=$1
	#file=$PWD/${round_id}/${round_id}.json #windows
	file=/services/blackjack/${round_id}/${round_id}.json #ubuntu
}		

function play-round() {
	if [ -f $file ];then
		local dealer player dcount pcount	
		#dealer=$(cat $PWD/${round_id}/${round_id}.json | jq -r .dealer) #windows
		#player=$(cat $PWD/${round_id}/${round_id}.json | jq -r .player) #windows
		dealer=$(cat /services/blackjack/${round_id}/${round_id}.json | jq -r .dealer) #ubuntu
		player=$(cat /services/blackjack/${round_id}/${round_id}.json | jq -r .player) #ubuntu
		pcount=$(count-value $player)
		if [ $pcount -gt 21 ];then
			output_json='{ "dealer": "'$(display-hand $dealer full)'", "player": "'$(display-hand $player full)'", "round_id": "'${round_id}'", "message": "BUST, you lose!" }'
			echo $output_json
			#rm -r $PWD/${round_id}/ #delete round windows
			rm -r /services/blackjack/${round_id}/ #delete round ubuntu
		else
			dealer=$(play-dealer $dealer)
			dcount=$(count-value $dealer)
			if [ $dcount -gt 21 ]; then
				output_json='{ "dealer": "'$(display-hand $dealer full)'", "player": "'$(display-hand $player full)'", "round_id": "'${round_id}'", "message": "Dealer BUST, you win!" }'
				echo $output_json
				#rm -r $PWD/${round_id}/ #delete round windows
				rm -r /services/blackjack/${round_id}/ #delete round ubuntu
			elif [ $pcount -gt $dcount ]; then
				output_json='{ "dealer": "'$(display-hand $dealer full)'", "player": "'$(display-hand $player full)'", "round_id": "'${round_id}'", "message": "You win!" }'
				echo $output_json
				#rm -r $PWD/${round_id}/ #delete round windows
				rm -r /services/blackjack/${round_id}/ #delete round ubuntu
			elif [ $dcount -gt $pcount ]; then
				output_json='{ "dealer": "'$(display-hand $dealer full)'", "player": "'$(display-hand $player full)'", "round_id": "'${round_id}'", "message": "You lose!" }'
				echo $output_json
				#rm -r $PWD/${round_id}/ #delete round windows
				rm -r /services/blackjack/${round_id}/ #delete round ubuntu	
			else
				output_json='{ "dealer": "'$(display-hand $dealer full)'", "player": "'$(display-hand $player full)'", "round_id": "'${round_id}'", "message": "You tied!" }'
				echo $output_json
				#rm -r $PWD/${round_id}/ #delete round windows
				rm -r /services/blackjack/${round_id}/ #delete round ubuntu		
			fi
		fi
	else
		output_json='{ "dealer": "null", "player": "null", "round_id": "null", "message": "round_id does not exist" }'
		echo $output_json		
	fi
}

function main() {
    remove-expired-rounds
	get-round $1
    play-round
}

#PREFIX=$PWD/$1 #windows
PREFIX=/services/blackjack/$1 #ubuntu
if [ -L "$0" ]; then
    PREFIX=$(ls -l "$0" | sed -e 's/.*-> \(.*\)/\1/')
    PREFIX=${PREFIX%/*}
fi
CARDFILE=$PREFIX/cards
USEDCARDS=$PREFIX/usedcards
main "$@"
