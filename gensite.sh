#!/usr/bin/zsh

if [ ! -d "govtracker-data" ]; then
    echo "Use git clone https://github.com/govtra/govtracker-data.git to get the data"
    exit 1
fi

mkdir work
touch work/imp.html
echo "Processing important"
for i in govtracker-data/important/*.md; do
    i2=`basename $i`
    echo "# $i2"
    echo "<p class='date'>${i2%.md}</p>`markdown $i`" > work/imp2.html
    cat work/imp.html >> work/imp2.html
    mv work/imp2.html work/imp.html
done
sed -e '/{{{CONTENT}}}/ {' -e "r work/imp.html" -e 'd' -e '}' templates/index_template.html > site/index.html
echo "Done important\n"

for j in govtracker-data/*_*/; do
    j2=`basename $j`
    j2=${j2%_entries}
    j2up=`echo "$j2" | tr '[:lower:]' '[:upper:]'`
    echo "Processing $j2up"
    echo "" > work/content.html
    echo "" > work/content.rss
    for i in $j/*; do
        i2=`basename $i`
        echo "# $i2"
        # HTML
        sed -- 's/{{{DATE}}}/'"${i2%.md}"'/g' templates/entry_template.html > work/tmp
        markdown $i > work/md.html
        sed -- 's/\(href="[^ >]*"\)/\1 target="_blank"/' work/md.html > work/md2.html
        cp work/content.html work/backup_content.html
        sed -e '/{{{DATA}}}/ {' -e "r work/md2.html" -e 'd' -e '}' work/tmp > work/content.html
        cat work/backup_content.html >> work/content.html

        # RSS
        # descr=`pandoc -f markdown -t plain $i | tr -d '\n'| cut -c-50`
        cp work/content.rss work/backup_content.rss
        sed -- 's/{{{DATE}}}/'"${i2%.md}"'/g' templates/rss_entry_template.xml > work/rss_tmp
        #sed -- 's/{{{DESCR}}}/'"$descr"'/g' work/rss_tmp > work/content2.rss
        sed -e '/{{{DESCR}}}/ {' -e "r work/md.html" -e 'd' -e '}' work/rss_tmp > work/content2.rss
        sed -- 's/{{{COUNTRY_S}}}/'"$j2"'/g' work/content2.rss > work/content.rss
        cat work/backup_content.rss >> work/content.rss
    done
    if [ ! -d "site/$j2" ]; then
        mkdir site/$j2
    fi
    # HTML
    sed -- 's/{{{COUNTRY}}}/'"$j2up"'/g' templates/country_index_template.html > work/index2.html
    sed -- 's/{{{COUNTRY_S}}}/'"$j2"'/g' work/index2.html > work/index.html
    sed -e '/{{{CONTENT}}}/ {' -e "r work/content.html" -e 'd' -e '}' work/index.html > site/$j2/index.html

    # RSS
    sed -- 's/{{{COUNTRY}}}/'"$j2up"'/g' templates/rss_template.xml > work/rss.xml
    sed -e '/{{{CONTENT}}}/ {' -e "r work/content.rss" -e 'd' -e '}' work/rss.xml > site/$j2/rss.xml
    echo "Done $j2up\n"
done

rm -r work
