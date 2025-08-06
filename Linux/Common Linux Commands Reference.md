
## File and Directory Operations

|Command|Description|Example|
|---|---|---|
|`ls`|List directory contents|`ls -la`|
|`cd`|Change directory|`cd /home/user`|
|`pwd`|Print working directory|`pwd`|
|`mkdir`|Create directory|`mkdir new_folder`|
|`rmdir`|Remove empty directory|`rmdir empty_folder`|
|`rm`|Remove files/directories|`rm file.txt` or `rm -rf folder/`|
|`cp`|Copy files/directories|`cp file.txt backup.txt`|
|`mv`|Move/rename files|`mv old.txt new.txt`|
|`find`|Search for files|`find /home -name "*.txt"`|
|`locate`|Find files by name|`locate filename`|

## File Content Operations

|Command|Description|Example|
|---|---|---|
|`cat`|Display file content|`cat file.txt`|
|`less`|View file page by page|`less file.txt`|
|`head`|Show first lines|`head -10 file.txt`|
|`tail`|Show last lines|`tail -f logfile.txt`|
|`grep`|Search text patterns|`grep "error" logfile.txt`|
|`sort`|Sort lines in file|`sort file.txt`|
|`uniq`|Remove duplicate lines|`uniq file.txt`|
|`wc`|Word/line/character count|`wc -l file.txt`|

## File Permissions and Ownership

|Command|Description|Example|
|---|---|---|
|`chmod`|Change file permissions|`chmod 755 script.sh`|
|`chown`|Change file ownership|`chown user:group file.txt`|
|`chgrp`|Change group ownership|`chgrp developers file.txt`|
|`umask`|Set default permissions|`umask 022`|

## System Information

|Command|Description|Example|
|---|---|---|
|`ps`|Show running processes|`ps aux`|
|`top`|Display running processes|`top`|
|`htop`|Enhanced process viewer|`htop`|
|`df`|Show disk usage|`df -h`|
|`du`|Show directory size|`du -sh /home/user`|
|`free`|Show memory usage|`free -h`|
|`uname`|System information|`uname -a`|
|`whoami`|Current username|`whoami`|
|`uptime`|System uptime|`uptime`|

## Process Management

|Command|Description|Example|
|---|---|---|
|`kill`|Terminate process|`kill 1234`|
|`killall`|Kill processes by name|`killall firefox`|
|`jobs`|Show active jobs|`jobs`|
|`bg`|Put job in background|`bg %1`|
|`fg`|Bring job to foreground|`fg %1`|
|`nohup`|Run command immune to hangups|`nohup command &`|

## Network Commands

|Command|Description|Example|
|---|---|---|
|`ping`|Test network connectivity|`ping google.com`|
|`wget`|Download files|`wget http://example.com/file.zip`|
|`curl`|Transfer data to/from servers|`curl -O http://example.com/file.txt`|
|`ssh`|Secure shell connection|`ssh user@hostname`|
|`scp`|Secure copy over network|`scp file.txt user@host:/path/`|
|`netstat`|Display network connections|`netstat -tuln`|

## Archive and Compression

|Command|Description|Example|
|---|---|---|
|`tar`|Archive files|`tar -czf archive.tar.gz folder/`|
|`untar`|Extract tar files|`tar -xzf archive.tar.gz`|
|`zip`|Create zip archive|`zip -r archive.zip folder/`|
|`unzip`|Extract zip files|`unzip archive.zip`|
|`gzip`|Compress files|`gzip file.txt`|
|`gunzip`|Decompress gzip files|`gunzip file.txt.gz`|

## Text Processing

|Command|Description|Example|
|---|---|---|
|`awk`|Pattern scanning/processing|`awk '{print $1}' file.txt`|
|`sed`|Stream editor|`sed 's/old/new/g' file.txt`|
|`cut`|Extract columns|`cut -d',' -f1 file.csv`|
|`tr`|Translate characters|`tr '[:lower:]' '[:upper:]'`|

## System Control

|Command|Description|Example|
|---|---|---|
|`sudo`|Run as another user|`sudo apt update`|
|`su`|Switch user|`su - username`|
|`passwd`|Change password|`passwd`|
|`history`|Command history|`history`|
|`alias`|Create command alias|`alias ll='ls -la'`|
|`which`|Locate command|`which python`|
|`man`|Manual pages|`man ls`|

## File Editing

|Command|Description|Example|
|---|---|---|
|`nano`|Simple text editor|`nano file.txt`|
|`vim`|Advanced text editor|`vim file.txt`|
|`emacs`|Another text editor|`emacs file.txt`|

## Useful Shortcuts

|Shortcut|Description|
|---|---|
|`Ctrl + C`|Interrupt current command|
|`Ctrl + Z`|Suspend current command|
|`Ctrl + D`|Exit/logout|
|`Ctrl + L`|Clear screen|
|`Ctrl + R`|Search command history|
|`Tab`|Auto-complete|
|`!!`|Repeat last command|
|`!n`|Execute command number n from history|