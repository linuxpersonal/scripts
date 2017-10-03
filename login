#!/bin/bash
trap 'echo -e "\nYou are not allowed please do not escape"' SIGINT
trap 'echo -e "\nYou are not allowed please do not escape"'  SIGQUIT
trap 'echo -e "\nYou are not allowed please do not escape"' SIGTSTP

if [ $UID != 0 ]; then exit 0;fi

if [ -f /custom/color ]
then
source /custom/color
fi

while [ b != "Raven" ]
do

clear
#cat << EOF 
echo -e "${BROWN}========================================================================${NC}"
echo -e "${BROWN}    ANYONE WITH UNAUTHORISED ENTRY TO THIS SERVER WILL BE PROSECUTED    ${NC}"
echo -e "${BROWN}========================================================================${NC}"
echo -e "${BROWN}========================================================================${NC}"
echo -e "${BROWN}                         DOCSKULL LOGIN PAGE                            ${NC}"
echo -e "${BROWN}========================================================================${NC}"
echo ""
#EOF

i=1
while [ $i -ne 2 ]
do
echo "beep";sleep 1
echo "boop";sleep 1
echo "beep";sleep 1
echo ""
i=$[$i+1]
wait
done

read -p "What is your pet's name? " b

case $b in
"Raven")
        echo -e "\nYes you are correct, Welcome!"; echo ""; exit 0;;
"raven")
        echo -e "\nYes you are correct, Welcome!"; echo ""; exit 0;;
        *)
        echo -e "\nYou are incorrect please try again"
        sleep 2;;
        esac
done
~     
