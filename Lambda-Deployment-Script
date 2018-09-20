#!/bin/bash

#Declaring the variable
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
DARKGRAY="\033[1;90m"
LIGHTBLUE="\033[1;94m"
LIGHTGRAY="\033[1;37m"
NOCOLOR="\033[0m"

#sls config
slsRegion='ap-southeast-1'
slsConfig='serverless.yml'
slsStage=$1
slsProfile=$2

#log file
logFilePath='/opt/aws-lambda-adapter/sls-logs/'
gitCommitID=$(git log --format="%H" -n 1)
logFile="$logFilePath$gitCommitID"'.log'

#Decorator function
outputDecorator(){
 if [ $1 == 0 ]
 then
  echo -e "${RED}Error: ${NOCOLOR} $2. ${NOCOLOR}" | tee -a $logFile
 elif [ $1 == 1 ]
 then
  echo -e "${GREEN}Success: ${NOCOLOR} $2. ${NOCOLOR}" | tee -a $logFile
 elif [ $1 == -1 ]
 then
  echo -e "$2 ${NOCOLOR}" | tee -a $logFile
 fi
}

#Serverless delployment function
serverlessDeployment(){
  outputDecorator -1 "${LIGHTBLUE}NPM:${NOCOLOR}${LIGHTGRAY}  Installing the App's Dependency Packages...."
  npm install
  outputDecorator -1 "${LIGHTBLUE}NPM:${NOCOLOR}${LIGHTGRAY}  Updating the App's Dependency Packages...."
  npm update
  outputDecorator -1 "${LIGHTBLUE}SLS:${NOCOLOR}${LIGHTGRAY}  Serverless Deploying...."
  outputDecorator -1 "${YELLOW}    -------------------------------------------------------"
  if [ -z "$slsProfile"  ]; then
    serverless deploy --stage "$slsStage" --region "$slsRegion" | tee -a $logFile
  else
    serverless deploy --stage "$slsStage" --region "$slsRegion" --profile "$slsProfile" | tee -a $logFile
  fi
  outputDecorator -1 "${YELLOW}    -------------------------------------------------------"
  outputDecorator 1 "${GREEN}  Serverless Deployment has successfully finished."
}

#Start default OUTPUT line
 outputDecorator -1 "${DARKGRAY}############################## DEPLOYMENT LOG ##############################"
#END default line
#Check arguments supplied
#The $# variable will tell you the number of input arguments the script was passed.
if [ $# -eq 0 ]
then
  outputDecorator 0 "${RED}Environment variable not defined.${NOCOCLOR}.\n${YELLOW}Hint: Pass the arguments to script as staging/prod"
  exit 1
elif [ $slsStage == 'staging' ] || [ $slsStage == 'prod' ]
then
  outputDecorator -1 "${LIGHTBLUE}ENV:${NOCOLOR}${LIGHTGRAY}  Setting the Serverless environment as $slsStage"
else
  outputDecorator 0 "Invalid Stage Param. Stage Parameter should be either ${YELLOW}Staging ${NOCOLOR}or ${GREEN}Prod"
  exit 1
fi

#Check git command exist
if ! [ -x "$(command -v git)" ]; then
   outputDecorator 0 "${RED}git ${NOCOLOR}is not installed"
  exit 1
fi

#Git details
gitBaseName=$(basename `git rev-parse --show-toplevel`)
gitCommitID=$(git log --format="%H" -n 1)
gitNameEmailKey=0;
gitRevCommitIDs[$gitNameEmailKey]=$gitCommitID
gitUserName[$gitNameEmailKey]=$(git --no-pager show -s --format='%an <%ae>' $gitCommitID | grep -o -P '(?<=).*(?=<)')
gitUserEmail[$gitNameEmailKey]=$(git --no-pager show -s --format='%an <%ae>' $gitCommitID | grep -o -P '(?<=<).*(?=>)')

for parentCommitID in $(git log --pretty=%P -n 1 $gitCommitID) 
do 
  ((gitNameEmailKey++));
  gitRevCommitIDs[$gitNameEmailKey]=$parentCommitID
  gitUserName[$gitNameEmailKey]=$(git --no-pager show -s --format='%an <%ae>' $parentCommitID | grep -o -P '(?<=).*(?=<)')
  gitUserEmail[$gitNameEmailKey]=$(git --no-pager show -s --format='%an <%ae>' $parentCommitID | grep -o -P '(?<=<).*(?=>)')
done;

#We can just overwrite our array with the unique elements
gitRevCommitIDs=( `for i in ${gitRevCommitIDs[@]}; do echo $i; done | sort -u` )
gitUserName=( `for i in ${gitUserName[@]}; do echo $i; done | sort -u` )
gitUserEmail=( `for i in ${gitUserEmail[@]}; do echo $i; done | sort -u` )

outputDecorator -1 "${LIGHTBLUE}GIT:${NOCOLOR}${LIGHTGRAY}  Checking the Git Repository...."

#Check git repository exist
if [ -d '.git'  ] || [ -d '../.git'  ]; then
  outputDecorator -1 "${LIGHTBLUE}GIT:${NOCOLOR}${LIGHTGRAY}  Git Repository exists as $gitBaseName"
  outputDecorator -1 "${LIGHTBLUE}GIT:${NOCOLOR}${LIGHTGRAY}  Git resetting the $slsConfig file"
  outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${YELLOW}  --------------- Git revision details ---------------"
  outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  Revision: $gitCommitID"
  outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  User    : $gitUserName"
  outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  Email   : $gitUserEmail"
  outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${YELLOW}  ----------------------------------------------------"
  #If the commit was a merge, and it was TREESAME to parent, follow all parents.
  if [[ "$(git cat-file -p $gitCommitID)" =~ .*Merging*. ]]; then
	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${YELLOW}  Revision has merge history and it was TREESAME to following parents"
  	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${YELLOW}  --------------- Git revision's Parent commit details ---------------"
	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  CommitId: ${gitRevCommitIDs[*]}"
  	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  Users    : ${gitUserName[*]}"
   	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${LIGHTGRAY}  Emails   : ${gitUserEmail[*]}"
  	outputDecorator -1 "${LIGHTBLUE}    ${NOCOLOR}${YELLOW}  ----------------------------------------------------"
  fi
  git checkout "$slsConfig"
else
  outputDecorator 0 "${RED} Git Repository ${NOCOLOR}Not exists"
  exit 1
fi
exit 1;
#Check serverless config file and Replace the env variable
#if [ -f 'serverless.yml' ]; then
if [ $(ls -1 *.yml 2>/dev/null | wc -l) -gt 0 ] || [ $(ls -1 *.yaml 2>/dev/null | wc -l) -gt 0 ]; then
  #sed -i "s/.*stage:.*$/  stage: $slsStage/" "$slsConfig"
  outputDecorator -1 "${LIGHTBLUE}ENV:${NOCOLOR}${LIGHTGRAY}  Resetting the stage variable as $slsStage"
  serverlessDeployment
else
  echo 'Error: "$slsConfig" file is not exist.' >&2
  exit 1
fi

#Start default OUTPUT line
 outputDecorator -1 "${DARKGRAY}############################## ENDED DEPLOYMENT LOG ##############################"
 cp "$logFile" "$logFilePath$gitBaseName"'.log'
 sed -ri "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$logFilePath$gitBaseName"'.log'
 echo $'\n\n\n\n\n' >> "$logFile"
 #Sending mail with the dump file
 mutt -e "set from=noreply@aceturtle.com" -e "set realname=Deployment" -s "${gitBaseName^} Deployment Logs: $(date +%d%b%Y-%T)" -a "$logFilePath$gitBaseName"'.log' -- $(echo ${gitUserEmail[@]} | tr ' ' ,) < '/tmp/message.txt'
 rm -f "$logFilePath$gitBaseName"'.log'
 rm -f "$logFile"
#END default line
