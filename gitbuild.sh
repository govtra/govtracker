#!/usr/bin/zsh

git pull
if [ ! -d "govtracker-data" ]; then
    git clone https://github.com/govtra/govtracker-data.git
else
    cd govtracker-data; git pull origin master; cd ..
fi

./gensite.sh
