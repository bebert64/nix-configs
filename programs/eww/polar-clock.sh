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
  '{
    month_val:    (if $month <= 1 then 0 else ($month - 1) / 11 * 100 end),
    weekday_val:  (if $dow <= 1 then 0 else ($dow - 1) / 6 * 100 end),
    day_val:      (if $dim <= 1 then 0 else ($day - 1) / ($dim - 1) * 100 end),
    hour_val:     (($hour * 3600 + $min * 60 + $sec) / 864 | . * 100 / 100),
    minute_val:   (($min * 60 + $sec) / 36 | . * 100 / 100),
    second_val:   ($sec / 60 * 100),

    month_hue:    (if $month <= 1 then 0 else ($month - 1) / 11 * 360 end),
    weekday_hue:  (if $dow <= 1 then 0 else ($dow - 1) / 6 * 360 end),
    day_hue:      (if $dim <= 1 then 0 else ($day - 1) / ($dim - 1) * 360 end),
    hour_hue:     (($hour * 3600 + $min * 60 + $sec) / 86400 * 360),
    minute_hue:   (($min * 60 + $sec) / 3600 * 360),
    second_hue:   ($sec / 60 * 360),

    hour_label:   (if $hour < 10 then "0\($hour)" else "\($hour)" end),
    minute_label: (if $min < 10 then "0\($min)" else "\($min)" end),
    second_label: (if $sec < 10 then "0\($sec)" else "\($sec)" end),
    month_label:  $month_name,
    weekday_label: $weekday_name,
    day_label:    "\($day)"
  }'
