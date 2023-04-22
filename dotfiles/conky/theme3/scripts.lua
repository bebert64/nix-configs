function conky_myimg()
    local handle = io.popen([[qdbus org.mpris.MediaPlayer2.strawberry /org/mpris/MediaPlayer2 Metadata | grep artUrl | sed -e 's#.*file://\(\)#\1#']])
    local path = handle:read("*a")
    handle:close()
    local s = "${image "..path.." -s 256x256 -p 85x0}";
    return s;
end
