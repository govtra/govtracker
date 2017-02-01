#!/usr/bin/zsh

if [ ! -d "govtracker-data" ]; then
    echo "Use git clone https://github.com/govtra/govtracker-data.git to get the data"
    exit 1
fi

mkdir work
for j in govtracker-data/*/; do
    j2=`basename $j`
    j2=${j2%_entries}
    echo "" > work/content.html
    for i in $j/*; do
        i2=`basename $i`
        sed -- 's/{{{DATE}}}/'"${i2%.md}"'/g' templates/entry_template.html > work/tmp
        markdown $i > work/md.html
        cp work/content.html work/backup_content.html
        sed -e '/{{{DATA}}}/ {' -e "r work/md.html" -e 'd' -e '}' work/tmp > work/content.html
        cat work/backup_content.html >> work/content.html
    done
    if [ ! -d "site/$j2" ]; then
        mkdir site/$j2
    fi
    j2up=`echo "$j2" | tr '[:lower:]' '[:upper:]'`
    sed -- 's/{{{COUNTRY}}}/'"$j2up"'/g' templates/index_template.html > work/index.html
    sed -e '/{{{CONTENT}}}/ {' -e "r work/content.html" -e 'd' -e '}' work/index.html > site/$j2/index.html
done

rm -r work
