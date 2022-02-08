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

function play-round() {
    local dealer player dcount pcount
    dealer=$(draw-card)
    player=$(draw-card)
    dealer=$dealer$(draw-card)
    player=$player$(draw-card)
	output_json='{ "dealer": "'$(display-hand $dealer dealer)'", "player": "'$(display-hand $player player)'", "round_id": "'${round_id}'", "action": "HIT or STAND?" }'
	echo $output_json
	output='{ "dealer": "'$dealer'", "player": "'$player'", "round_id": "'${round_id}'" }'
	echo $output > /services/blackjack/${round_id}/${round_id}.json #ubuntu
#	echo $output > $PWD/${round_id}/$round_id.json #windows
}

function main() {
    remove-expired-rounds
	clear-used
    shuffle-cards
    play-round
}

round_id=$((1 + RANDOM % 999))
#mkdir $PWD/${round_id}/ #windows
mkdir /services/blackjack/${round_id}/ #ubuntu
#PREFIX=$PWD/${round_id} #windows
PREFIX=/services/blackjack/${round_id} #ubuntu
if [ -L "$0" ]; then
    PREFIX=$(ls -l "$0" | sed -e 's/.*-> \(.*\)/\1/')
    PREFIX=${PREFIX%/*}
fi
CARDFILE=$PREFIX/cards
USEDCARDS=$PREFIX/usedcards
main "$@"
