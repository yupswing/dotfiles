#######################################################################################
# Functions

# cdb - Goes to folder by complete path
function cdb() {
  cd $(dirname $1)
}

# hist - Grep from history
function hist() {
  grep -i $* $HISTFILE
}

# hdu - Human readable report of files and directories sizes
#       *Same behaviour as du*
function hdu() {
  du -k $* | sort -nr | awk '{
        # Prepare human readable
        if($1>=1024*1024) { size=$1/1024/1024; unit="G" }
        else if($1>=1024) { size=$1/1024;      unit="M" }
        else {              size=$1;           unit="K" };
        format="%10.2f%s";
        hsize=sprintf(format,size,unit);

        # Remove $1 (size), then removes " " at the start of $0
        $1=""; thepath=$0; sub(/^ /,"",thepath);

        # Print size and path (directories are bolded)
        if ( system("[ -d \""thepath"\" ]") )
            printf "%-8s %s\n",hsize,thepath;
        else
            printf "%-8s \033[1m%s\033[0m/\n",hsize,thepath;
    }'
}
# list total size in . directory
function dust() {
  hdu -s *
}

function replace() {
  oldstring=$1
  newstring=$2
  grep -rl $oldstring * | xargs sed -i '.bak' s/$oldstring/$newstring/g
}
