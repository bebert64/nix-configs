month=$(date +%-m)
dow=$(date +%u)
day=$(date +%-d)
hour=$(date +%-H)
min=$(date +%-M)
sec=$(date +%-S)
month_name=$(date +%b)
weekday_name=$(date +%a)
days_in_month=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%-d)

jq -cn \
  --argjson month "$month" \
  --argjson dow "$dow" \
  --argjson day "$day" \
  --argjson hour "$hour" \
  --argjson min "$min" \
  --argjson sec "$sec" \
  --argjson dim "$days_in_month" \
  --arg month_name "$month_name" \
  --arg weekday_name "$weekday_name" \
  '
  # HSL (h:0-360, s:0-1, l:0-1) to #RRGGBB
  def hsl_to_hex:
    .[0] as $h | .[1] as $s | .[2] as $l |
    ($l * 2 - 1 | if . < 0 then -. else . end) as $a |
    ($s * (1 - $a) / 2) as $c |
    ($l - $c) as $m |
    ($c * 2) as $c2 |
    (($h / 60) | floor) as $sector |
    (($h / 60) - $sector) as $f |
    ($c2 * (1 - ($f * 2 - 1 | if . < 0 then -. else . end))) as $x |
    (if   $sector == 0 then [$c2, $x, 0]
     elif $sector == 1 then [$x, $c2, 0]
     elif $sector == 2 then [0, $c2, $x]
     elif $sector == 3 then [0, $x, $c2]
     elif $sector == 4 then [$x, 0, $c2]
     else                    [$c2, 0, $x]
     end) |
    map(. + $m | . * 255 | round |
      if . < 0 then 0 elif . > 255 then 255 else . end) |
    "#" + (map(
      if . < 16 then "0" + (. | floor | explode | map(. + 0) | implode) else "" end
    ) | join("")) |
    . ;

  # simpler: use direct formula
  def hsl_to_rgb:
    .[0] as $h | .[1] as $s | .[2] as $l |
    (if $l < 0.5 then $l * (1 + $s) else $l + $s - $l * $s end) as $q |
    (2 * $l - $q) as $p |
    def hue2rgb:
      . as $t_in |
      (if $t_in < 0 then $t_in + 1 elif $t_in > 1 then $t_in - 1 else $t_in end) as $t |
      if   $t < (1/6) then $p + ($q - $p) * 6 * $t
      elif $t < (1/2) then $q
      elif $t < (2/3) then $p + ($q - $p) * (2/3 - $t) * 6
      else $p
      end;
    ($h / 360) as $hn |
    [($hn + 1/3 | hue2rgb), ($hn | hue2rgb), ($hn - 1/3 | hue2rgb)] |
    map(. * 255 | round | if . < 0 then 0 elif . > 255 then 255 else . end);

  def to_hex:
    def digit: if . < 10 then . + 48 else . - 10 + 97 end;
    [(. / 16 | floor | digit), (. % 16 | digit)] | implode;

  def rgb_to_hex:
    "#" + (map(to_hex) | join(""));

  def color_for_progress:
    . * 3.6 |  # progress (0-100) to hue (0-360)
    [., 0.7, 0.55] | hsl_to_rgb | rgb_to_hex;

  {
    month_val:    (if $month <= 1 then 0 else ($month - 1) / 11 * 100 end),
    weekday_val:  (if $dow <= 1 then 0 else ($dow - 1) / 6 * 100 end),
    day_val:      (if $dim <= 1 then 0 else ($day - 1) / ($dim - 1) * 100 end),
    hour_val:     (($hour * 3600 + $min * 60 + $sec) / 864 | . * 100 / 100),
    minute_val:   (($min * 60 + $sec) / 36 | . * 100 / 100),
    second_val:   ($sec / 60 * 100),

    hour_label:   (if $hour < 10 then "0\($hour)" else "\($hour)" end),
    minute_label: (if $min < 10 then "0\($min)" else "\($min)" end),
    second_label: (if $sec < 10 then "0\($sec)" else "\($sec)" end),
    month_label:  $month_name,
    weekday_label: $weekday_name,
    day_label:    "\($day)"
  } |
  .month_color   = (.month_val | color_for_progress) |
  .weekday_color = (.weekday_val | color_for_progress) |
  .day_color     = (.day_val | color_for_progress) |
  .hour_color    = (.hour_val | color_for_progress) |
  .minute_color  = (.minute_val | color_for_progress) |
  .second_color  = (.second_val | color_for_progress)
  '
