#!/usr/bin/env sh

API_ENDPOINT="https://api.github.com"
DEFAULT_ORGANIZATION=$1 # "GrupoZapVivaReal"
S3_BUCKET_BACKUP=$2 # "backup-git-repos"

# SLACK_WEBHOOK
# GH_TOKEN
# AWS_SECRET_ACCESS_KEY
# AWS_ACCESS_KEY_ID

export PROJECTS=$(cat $3)

# OR use like this
# export PROJECTS=$(cat <<-END
# project1
# project2
# END
# )

backup_and_delete_repo(){
    project=$1
    status_code=$(curl -H "Authorization: token $GH_TOKEN" -w "%{http_code}" -o /dev/null -sL $API_ENDPOINT/repos/$DEFAULT_ORGANIZATION/$project)
    if [ $status_code -ne 200 ]; then
        echo "$project does not exist"
        continue
    fi

    curl -H "Authorization: token $GH_TOKEN" -sL $API_ENDPOINT/repos/$DEFAULT_ORGANIZATION/$project/zipball > $project.zip
    docker run \
	   -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
	   -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
	   -v $PWD:/data garland/aws-cli-docker aws s3 cp "$project".zip s3://$S3_BUCKET_BACKUP/
    if [ $? -ne 0 ]; then
        echo "$project.zip - aws cp failed"
        continue
    fi

    status_code=$(curl -XDELETE -H "Authorization: token $GH_TOKEN" -w "%{http_code}" -o /dev/null -sL $API_ENDPOINT/repos/$DEFAULT_ORGANIZATION/$project)
    if [ $status_code -ne 204 ]; then
        echo "problem deleting repository $project"
        continue
    fi
    echo "$project deleted from github"
    curl -X POST -H 'Content-type:application/json' --data "{\"text\":\"Removi o projeto \`$project\` do Github. O backup está no s3, bucket: \`$S3_BUCKET_BACKUP\`. \n> Ass. Marinete\",\"channel\":\"engineering\",\"username\":\"Marinete\",\"icon_url\": \"https://pbs.twimg.com/profile_images/897496840/marinete_400x400.jpg\"}" $SLACK_WEBHOOK
}

for project in $PROJECTS; do
    backup_and_delete_repo $project &
done

echo "deleting"
wait
echo "done"
