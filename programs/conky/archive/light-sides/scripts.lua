function conky_myimg()
    local handle = io.popen([[qdbus org.mpris.MediaPlayer2.strawberry /org/mpris/MediaPlayer2 Metadata | grep artUrl | sed -e 's#.*file://\(\)#\1#']])
    local path = handle:read("*a")
    handle:close()
    local s = "${image "..path.." -s 256x256 -p 85,20}";
    return s;
end

function conky_artist()
    local handle = io.popen([==[
ARTIST="$(playerctl -p strawberry  metadata artist 2>&1)"
if [[ "$ARTIST" == *"No player could handle this command"* || "$ARTIST" == *"No players found"* ]];then
      ARTIST="";
fi;
echo $ARTIST
]==])
    local artist = handle:read("*a")
    handle:close()
    return ""..artist.."";
end

function conky_title()
    local handle = io.popen([==[
TITLE="$(playerctl -p strawberry metadata title 2>&1)"
if [[ "$TITLE" == *"No player could handle this command"* || "$TITLE" == *"No players found"* ]];then
        TITLE="";
fi;
echo $TITLE
]==])
    local title = handle:read("*a")
    handle:close()
    return ""..title.."";
end
