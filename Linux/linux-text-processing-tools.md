# Linux Text Processing and Command Line Tools

## Text Viewing and Basic Operations

### File Content Display

```bash
# Display entire file
cat filename.txt
cat file1.txt file2.txt  # Concatenate multiple files

# Display with line numbers
cat -n filename.txt
nl filename.txt

# Display non-printing characters
cat -A filename.txt
cat -v filename.txt      # Show non-printing chars
cat -T filename.txt      # Show tabs as ^I
cat -E filename.txt      # Show end of lines as $
```

### Paging Through Files

```bash
# Page through files
less filename.txt
more filename.txt

# less navigation:
# Space/f - Forward one page
# b - Backward one page
# j/Down - Down one line
# k/Up - Up one line
# g - Go to beginning
# G - Go to end
# /pattern - Search forward
# ?pattern - Search backward
# n - Next search result
# N - Previous search result
# q - Quit

# Display first/last lines
head filename.txt         # First 10 lines
head -n 20 filename.txt   # First 20 lines
head -c 100 filename.txt  # First 100 characters

tail filename.txt         # Last 10 lines
tail -n 20 filename.txt   # Last 20 lines
tail -f filename.txt      # Follow file changes (useful for logs)
tail -F filename.txt      # Follow with retry (if file is rotated)
```

## Text Searching and Pattern Matching

### grep - Pattern Searching

```bash
# Basic search
grep "pattern" filename.txt
grep "error" /var/log/syslog

# Case-insensitive search
grep -i "error" filename.txt

# Show line numbers
grep -n "pattern" filename.txt

# Search recursively in directories
grep -r "pattern" /path/to/directory
grep -R "pattern" /path/to/directory  # Follow symlinks

# Search multiple files
grep "pattern" *.txt
grep "pattern" file1.txt file2.txt

# Show only matching filenames
grep -l "pattern" *.txt

# Show files that don't match
grep -L "pattern" *.txt

# Count matches
grep -c "pattern" filename.txt

# Show context around matches
grep -B 5 "pattern" filename.txt    # 5 lines before
grep -A 5 "pattern" filename.txt    # 5 lines after
grep -C 5 "pattern" filename.txt    # 5 lines before and after

# Invert match (lines that don't contain pattern)
grep -v "pattern" filename.txt

# Match whole words only
grep -w "word" filename.txt

# Use extended regular expressions
grep -E "pattern1|pattern2" filename.txt
egrep "pattern1|pattern2" filename.txt
```

### Regular Expressions with grep

```bash
# Basic regex patterns
grep "^start" filename.txt      # Lines starting with "start"
grep "end$" filename.txt        # Lines ending with "end"
grep "^$" filename.txt          # Empty lines
grep "[0-9]" filename.txt       # Lines containing digits
grep "[a-zA-Z]" filename.txt    # Lines containing letters
grep "[aeiou]" filename.txt     # Lines containing vowels

# Extended regex patterns
grep -E "[0-9]{3}" filename.txt     # Exactly 3 digits
grep -E "[0-9]{2,4}" filename.txt   # 2 to 4 digits
grep -E "colou?r" filename.txt      # "color" or "colour"
grep -E "(cat|dog)" filename.txt    # "cat" or "dog"
grep -E "^[A-Z]" filename.txt       # Lines starting with capital letter

# Practical examples
grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log  # IP addresses
grep -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" contacts.txt  # Email addresses
grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}" logs.txt                         # Dates (YYYY-MM-DD)
```

## Text Processing and Manipulation

### sed - Stream Editor

```bash
# Basic substitution
sed 's/old/new/' filename.txt           # Replace first occurrence per line
sed 's/old/new/g' filename.txt          # Replace all occurrences
sed 's/old/new/2' filename.txt          # Replace second occurrence per line

# Case-insensitive substitution
sed 's/old/new/gi' filename.txt

# In-place editing
sed -i 's/old/new/g' filename.txt       # Modify file directly
sed -i.bak 's/old/new/g' filename.txt   # Create backup with .bak extension

# Delete lines
sed '/pattern/d' filename.txt           # Delete lines containing pattern
sed '3d' filename.txt                   # Delete line 3
sed '2,5d' filename.txt                 # Delete lines 2-5
sed '$d' filename.txt                   # Delete last line

# Print specific lines
sed -n '3p' filename.txt                # Print line 3 only
sed -n '2,5p' filename.txt              # Print lines 2-5
sed -n '/pattern/p' filename.txt        # Print lines matching pattern

# Multiple commands
sed -e 's/old1/new1/g' -e 's/old2/new2/g' filename.txt
sed 's/old1/new1/g; s/old2/new2/g' filename.txt

# Advanced examples
sed 's/^/> /' filename.txt              # Add "> " to beginning of each line
sed 's/$/\r/' filename.txt              # Add carriage return to end of lines
sed '/^$/d' filename.txt                # Remove empty lines
sed 's/[[:space:]]*$//' filename.txt    # Remove trailing whitespace
```

### awk - Text Processing Tool

```bash
# Basic awk usage
awk '{print}' filename.txt              # Print all lines (same as cat)
awk '{print $1}' filename.txt          # Print first field
awk '{print $1, $3}' filename.txt      # Print first and third fields
awk '{print NF}' filename.txt          # Print number of fields per line
awk '{print NR, $0}' filename.txt      # Print line number and content

# Field separator
awk -F: '{print $1}' /etc/passwd        # Use : as field separator
awk -F',' '{print $2}' data.csv         # Use comma as separator

# Pattern matching
awk '/pattern/ {print}' filename.txt    # Print lines matching pattern
awk '$1 == "value" {print}' filename.txt # Print lines where first field equals "value"
awk '$3 > 100 {print}' filename.txt     # Print lines where third field > 100

# Mathematical operations
awk '{sum += $1} END {print sum}' numbers.txt        # Sum first column
awk '{sum += $1} END {print sum/NR}' numbers.txt     # Average of first column
awk '{if($1 > max) max = $1} END {print max}' numbers.txt  # Maximum value

# String operations
awk '{print length($0)}' filename.txt               # Print length of each line
awk '{print toupper($0)}' filename.txt              # Convert to uppercase
awk '{print tolower($0)}' filename.txt              # Convert to lowercase
awk '{gsub(/old/, "new"); print}' filename.txt      # Global substitution

# Practical examples
awk -F: '$3 >= 1000 {print $1}' /etc/passwd         # Users with UID >= 1000
awk '{print $1, $4}' access.log | sort | uniq -c    # Count unique IP addresses
awk '/ERROR/ {count++} END {print count}' log.txt   # Count error lines
```

### cut - Extract Columns

```bash
# Extract specific fields
cut -f1 filename.txt                    # First field (tab-separated)
cut -f1,3 filename.txt                  # First and third fields
cut -f1-3 filename.txt                  # Fields 1 through 3

# Custom delimiter
cut -d: -f1 /etc/passwd                 # First field, colon-separated
cut -d, -f2,4 data.csv                  # Second and fourth fields, comma-separated

# Character positions
cut -c1-10 filename.txt                 # Characters 1-10
cut -c5- filename.txt                   # From character 5 to end
cut -c-10 filename.txt                  # First 10 characters

# Examples
cut -d: -f1,5 /etc/passwd               # Username and full name
ps aux | cut -c1-11,46-                 # PID and command from ps output
```

### sort - Sorting Text

```bash
# Basic sorting
sort filename.txt                       # Alphabetical sort
sort -r filename.txt                    # Reverse sort
sort -n filename.txt                    # Numeric sort
sort -nr filename.txt                   # Reverse numeric sort

# Field-based sorting
sort -k2 filename.txt                   # Sort by second field
sort -k2,2 filename.txt                 # Sort by second field only
sort -k2n filename.txt                  # Numeric sort by second field
sort -k2nr filename.txt                 # Reverse numeric sort by second field

# Custom delimiter
sort -t: -k3n /etc/passwd               # Sort by UID (third field)
sort -t, -k2 data.csv                   # Sort CSV by second column

# Advanced options
sort -u filename.txt                    # Remove duplicates
sort -f filename.txt                    # Case-insensitive sort
sort -b filename.txt                    # Ignore leading blanks
sort -o output.txt filename.txt         # Save output to file

# Multiple criteria
sort -k1,1 -k2n filename.txt           # Sort by first field, then numerically by second
```

### uniq - Remove Duplicates

```bash
# Basic usage (input must be sorted)
sort filename.txt | uniq                # Remove duplicate lines
sort filename.txt | uniq -c             # Count occurrences
sort filename.txt | uniq -d             # Show only duplicate lines
sort filename.txt | uniq -u             # Show only unique lines

# Field-based uniqueness
sort filename.txt | uniq -f1            # Skip first field when comparing
sort filename.txt | uniq -w10           # Compare only first 10 characters

# Case-insensitive
sort filename.txt | uniq -i

# Examples
cut -d: -f7 /etc/passwd | sort | uniq -c        # Count shells used
awk '{print $1}' access.log | sort | uniq -c     # Count IP addresses
```

## Advanced Text Processing

### tr - Character Translation

```bash
# Character substitution
tr 'a-z' 'A-Z' < filename.txt          # Convert lowercase to uppercase
tr 'A-Z' 'a-z' < filename.txt          # Convert uppercase to lowercase
tr ' ' '_' < filename.txt               # Replace spaces with underscores

# Delete characters
tr -d 'aeiou' < filename.txt            # Delete vowels
tr -d '0-9' < filename.txt              # Delete digits
tr -d '\n' < filename.txt               # Delete newlines

# Squeeze repeated characters
tr -s ' ' < filename.txt                # Squeeze multiple spaces to one
tr -s '\n' < filename.txt               # Remove empty lines

# Character sets
tr '[:lower:]' '[:upper:]' < filename.txt       # Lowercase to uppercase
tr '[:digit:]' 'X' < filename.txt               # Replace digits with X
tr -d '[:punct:]' < filename.txt                # Delete punctuation

# Examples
tr '\t' ',' < data.tsv > data.csv               # Convert tabs to commas
tr -d '\r' < dos_file.txt > unix_file.txt       # Remove carriage returns
echo "Hello World" | tr ' ' '\n'                # Split words to lines
```

### paste - Merge Lines

```bash
# Merge files line by line
paste file1.txt file2.txt              # Tab-separated merge
paste -d, file1.txt file2.txt          # Comma-separated merge
paste -d: file1.txt file2.txt          # Colon-separated merge

# Serial paste
paste -s file1.txt                     # Merge all lines into one line
paste -s -d, file1.txt                 # Comma-separated single line

# Examples
paste names.txt ages.txt > people.txt          # Create two-column file
cut -d: -f1 /etc/passwd | paste -s -d,         # Create comma-separated user list
```

### join - Join Files on Common Field

```bash
# Join files (must be sorted on join field)
join file1.txt file2.txt               # Join on first field
join -1 2 -2 1 file1.txt file2.txt     # Join field 2 of file1 with field 1 of file2

# Custom delimiter
join -t: file1.txt file2.txt           # Use colon as delimiter

# Different join types
join -a1 file1.txt file2.txt           # Include unmatched lines from file1
join -a2 file1.txt file2.txt           # Include unmatched lines from file2
join -v1 file1.txt file2.txt           # Only unmatched lines from file1
join -v2 file1.txt file2.txt           # Only unmatched lines from file2

# Example
sort -k1 users.txt > users_sorted.txt
sort -k1 groups.txt > groups_sorted.txt
join users_sorted.txt groups_sorted.txt
```

## Text Analysis and Statistics

### wc - Word Count

```bash
# Count lines, words, characters
wc filename.txt                        # Lines, words, characters
wc -l filename.txt                     # Lines only
wc -w filename.txt                     # Words only
wc -c filename.txt                     # Characters only
wc -m filename.txt                     # Characters (multi-byte aware)

# Multiple files
wc *.txt                               # Count for all .txt files
wc -l *.log                            # Line count for all .log files

# Examples
ls -1 | wc -l                          # Count files in directory
grep "ERROR" log.txt | wc -l           # Count error lines
```

### comm - Compare Sorted Files

```bash
# Compare two sorted files
comm file1.txt file2.txt              # Show unique and common lines
comm -1 file1.txt file2.txt           # Suppress lines unique to file1
comm -2 file1.txt file2.txt           # Suppress lines unique to file2
comm -3 file1.txt file2.txt           # Suppress common lines
comm -12 file1.txt file2.txt          # Show only common lines

# Example
sort list1.txt > sorted1.txt
sort list2.txt > sorted2.txt
comm -12 sorted1.txt sorted2.txt      # Find common items
```

### diff - Compare Files

```bash
# Basic comparison
diff file1.txt file2.txt               # Show differences
diff -u file1.txt file2.txt            # Unified format
diff -c file1.txt file2.txt            # Context format
diff -y file1.txt file2.txt            # Side-by-side format

# Directory comparison
diff -r dir1/ dir2/                    # Compare directories recursively
diff -rq dir1/ dir2/                   # Brief output for directories

# Ignore options
diff -i file1.txt file2.txt            # Ignore case
diff -w file1.txt file2.txt            # Ignore whitespace
diff -b file1.txt file2.txt            # Ignore space changes

# Create patches
diff -u original.txt modified.txt > changes.patch
patch original.txt < changes.patch     # Apply patch
```

## One-Liner Examples and Practical Commands

### Log Analysis

```bash
# Find most common IP addresses in access log
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10

# Find 404 errors
grep " 404 " access.log | awk '{print $1}' | sort | uniq -c | sort -nr

# Count requests per hour
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c

# Find largest files accessed
awk '{print $10, $7}' access.log | sort -nr | head -10
```

### System Administration

```bash
# Find users with bash shell
grep "/bin/bash" /etc/passwd | cut -d: -f1

# List processes by memory usage
ps aux --sort=-pmem --no-headers | head -10

# Find files modified in last 24 hours
find /var/log -type f -mtime -1 | head -10

# Check disk usage by directory
du -sh /* 2>/dev/null | sort -hr | head -10
```

### Data Processing

```bash
# Convert CSV to TSV
sed 's/,/\t/g' data.csv > data.tsv

# Remove empty lines and comments
grep -v "^#" config.txt | grep -v "^$"

# Extract email addresses from text
grep -oE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" document.txt

# Count word frequency
tr '[:space:]' '\n' < document.txt | grep -v "^$" | sort | uniq -c | sort -nr
```

This comprehensive guide covers essential text processing tools and techniques that are fundamental for effective command-line work and system administration on Ubuntu systems.
