#!/bin/bash

mkdir mydir
touch mydir/file{1..5}.txt

chmod 644 mydir/file1.txt
chmod 755 mydir/file2.txt
chmod 600 mydir/file3.txt
chmod 444 mydir/file4.txt
chmod 700 mydir/file5.txt

ls -l mydir
