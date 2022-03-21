#! /bin/bash


target=$HOME/.bash_profile
if [ ! -f "$target" ]; then
    touch $target
fi

while IFS= read -r line ; do 
	if ! grep -Fqxe "$line" "$target" ; then 
		printf "%s\n" "$line" >> "$target" 
	fi 
done < bashprofile_additions