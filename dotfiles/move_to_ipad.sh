for n in $(seq 1 $#); do
  echo $1
  mkdir zip
  zip "zip/$1.zip" "$1"/*
  rsync --progress "zip/$1.zip" /home/romain/Mnt/Ipad/Chunky
  rsync --progress "$1" /home/romain/Mnt/Ipad/Chunky
  shift
done
