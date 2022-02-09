#! /bin/bash


target=$HOME/.ssh/config
if [ ! -f "$target" ]; then
    touch $target
fi

while IFS= read -r line ; do 
	if ! grep -Fqxe "$line" "$target" ; then 
		printf "%s\n" "$line" >> "$target" 
	fi 
done < setup_git_ssh