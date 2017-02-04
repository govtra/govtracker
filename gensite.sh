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
    echo "" > work/content.rss
    for i in $j/*; do
        i2=`basename $i`
        # HTML
        sed -- 's/{{{DATE}}}/'"${i2%.md}"'/g' templates/entry_template.html > work/tmp
        markdown $i > work/md.html
        cp work/content.html work/backup_content.html
        sed -e '/{{{DATA}}}/ {' -e "r work/md.html" -e 'd' -e '}' work/tmp > work/content.html
        cat work/backup_content.html >> work/content.html

        # RSS
        cp work/content.rss work/backup_content.rss
        sed -- 's/{{{DATE}}}/'"${i2%.md}"'/g' templates/rss_entry_template.xml > work/rss_tmp
        sed -- 's/{{{COUNTRY}}}/'"$j2"'/g' work/rss_tmp > work/content.rss
        cat work/backup_content.rss >> work/content.rss
    done
    if [ ! -d "site/$j2" ]; then
        mkdir site/$j2
    fi
    # HTML
    j2up=`echo "$j2" | tr '[:lower:]' '[:upper:]'`
    sed -- 's/{{{COUNTRY}}}/'"$j2up"'/g' templates/index_template.html > work/index2.html
    sed -- 's/{{{COUNTRY_S}}}/'"$j2"'/g' work/index2.html > work/index.html
    sed -e '/{{{CONTENT}}}/ {' -e "r work/content.html" -e 'd' -e '}' work/index.html > site/$j2/index.html

    # RSS
    sed -- 's/{{{COUNTRY}}}/'"$j2up"'/g' templates/rss_template.xml > work/rss.xml
    sed -e '/{{{CONTENT}}}/ {' -e "r work/content.rss" -e 'd' -e '}' work/rss.xml > site/$j2/rss.xml
done

rm -r work
