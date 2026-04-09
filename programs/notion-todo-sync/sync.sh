# Notion TODO Sync — syncs assigned tickets from shared Notion databases
# into the personal TODO board.

ROMAIN_USER_ID="4a8c5256-3193-415c-86f7-848e821783a2"
TECH_TASKS_DB="b093a2a6-d589-4a39-ba4d-83624ad41c3b"
QTT_DB="d6cdb24f-62ac-4581-9503-c6035d22babf"
TODO_DB="cdf5bb4b-4437-4533-a8cb-170b4f0e1186"

MCP_TOKEN=$(cat "$MCP_TOKEN_FILE")
PERSONAL_TOKEN=$(cat "$PERSONAL_TOKEN_FILE")

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Query a Notion database with pagination. Writes results to $5 (output file).
# $1: database ID, $2: token, $3: filter JSON, $4: "old"|"new", $5: output file
query_notion_db() {
  local db_id="$1" token="$2" filter="$3" api_version="${4:-old}" out_file="$5"
  local has_more="true" cursor=""
  local endpoint notion_version

  if [[ "$api_version" == "new" ]]; then
    endpoint="https://api.notion.com/v1/data_sources/${db_id}/query"
    notion_version="2025-09-03"
  else
    endpoint="https://api.notion.com/v1/databases/${db_id}/query"
    notion_version="2022-06-28"
  fi

  echo '[]' > "$out_file"

  while [[ "$has_more" == "true" ]]; do
    local body_file="$WORK_DIR/body.json"
    if [[ -n "$cursor" ]]; then
      jq -n --argjson filter "$filter" --arg cursor "$cursor" \
        '{filter: $filter, start_cursor: $cursor, page_size: 100}' > "$body_file"
    else
      jq -n --argjson filter "$filter" \
        '{filter: $filter, page_size: 100}' > "$body_file"
    fi

    local resp_file="$WORK_DIR/response.json"
    curl -s -X POST "$endpoint" \
      -H "Authorization: Bearer ${token}" \
      -H "Notion-Version: ${notion_version}" \
      -H "Content-Type: application/json" \
      -d @"$body_file" > "$resp_file"

    # Check for API errors
    if jq -e '.object == "error"' "$resp_file" > /dev/null 2>&1; then
      log "ERROR: Notion API error: $(jq -r '.message' "$resp_file")"
      return 1
    fi

    # Append results
    jq -n --slurpfile existing "$out_file" --slurpfile page "$resp_file" \
      '$existing[0] + $page[0].results' > "$out_file.tmp"
    mv "$out_file.tmp" "$out_file"

    has_more=$(jq -r '.has_more' "$resp_file")
    cursor=$(jq -r '.next_cursor // empty' "$resp_file")
  done
}

# Extract page IDs from query results file, write to output file
# $1: input file (full results), $2: output file (id-only array)
extract_page_ids() {
  jq -r '[.[].id]' "$1" > "$2"
}

# --- Fetch active source tickets (not Done, not Dropped) ---

log "Fetching active Tech Tasks..."
tech_tasks_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"property": "Status Intl", "select": {"does_not_equal": "🟣 3 - Done"}},
    {"property": "Status Intl", "select": {"does_not_equal": "⚪ -1 - Dropped"}}
  ]
}')
query_notion_db "$TECH_TASKS_DB" "$MCP_TOKEN" "$tech_tasks_filter" "new" "$WORK_DIR/active_tech.json"

log "Fetching active QTT tickets..."
qtt_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"property": "Status Intl", "select": {"does_not_equal": "🟣 3 - Done"}},
    {"property": "Status Intl", "select": {"does_not_equal": "⚪ -1 - Dropped"}}
  ]
}')
query_notion_db "$QTT_DB" "$MCP_TOKEN" "$qtt_filter" "new" "$WORK_DIR/active_qtt.json"

# Tech Tasks: only keep available tickets (Recap starts with "☑️ Available")
jq '[.[] | select(.properties.Recap.formula.string | startswith("☑️ Available")) | .id]' \
  "$WORK_DIR/active_tech.json" > "$WORK_DIR/active_tech_ids.json"

extract_page_ids "$WORK_DIR/active_qtt.json" "$WORK_DIR/active_qtt_ids.json"

log "Found $(jq 'length' "$WORK_DIR/active_tech_ids.json") available Tech Tasks ($(jq 'length' "$WORK_DIR/unavailable_tech_ids.json") not available)"
log "Found $(jq 'length' "$WORK_DIR/active_qtt_ids.json") active QTT tickets"

# --- Fetch existing TODO entries ---

log "Fetching existing TODO entries..."
todo_filter='{
  "or": [
    {"property": "Area", "select": {"equals": "🎯 Tech Task"}},
    {"property": "Area", "select": {"equals": "🍬 Quality Tech Ticket"}}
  ]
}'
query_notion_db "$TODO_DB" "$PERSONAL_TOKEN" "$todo_filter" "old" "$WORK_DIR/existing_todos.json"

# Extract source page IDs from TODO titles (page mentions)
jq '[.[] | {
  todo_id: .id,
  source_id: ([.properties | to_entries[] | select(.value.type == "title") | .value.title[] | select(.type == "mention") | .mention.page.id] | first),
  status: (.properties.Status.status.name // null)
}] | map(select(.source_id != null))' "$WORK_DIR/existing_todos.json" > "$WORK_DIR/todo_map.json"

jq -r '[.[].source_id]' "$WORK_DIR/todo_map.json" > "$WORK_DIR/existing_source_ids.json"

log "Found $(jq 'length' "$WORK_DIR/todo_map.json") existing TODO entries with source links"

# --- Create new TODO entries for tickets not yet tracked ---

create_todo() {
  local source_id="$1" area_label="$2"
  local body_file="$WORK_DIR/create_body.json"
  jq -n --arg db "$TODO_DB" --arg src_id "$source_id" --arg area "$area_label" '{
    parent: {database_id: $db},
    properties: {
      title: {
        title: [{
          type: "mention",
          mention: {page: {id: $src_id}}
        }]
      },
      Area: {select: {name: $area}},
      Status: {status: {name: "New"}}
    }
  }' > "$body_file"
  curl -s -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer ${PERSONAL_TOKEN}" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d @"$body_file" > /dev/null
}

# Create TODOs for active tech tasks
jq -r '.[]' "$WORK_DIR/active_tech_ids.json" | while read -r page_id; do
  if jq -e --arg id "$page_id" 'index($id)' "$WORK_DIR/existing_source_ids.json" > /dev/null 2>&1; then
    log "Skipping Tech Task $page_id (already in TODO)"
  else
    log "Creating TODO for Tech Task $page_id"
    create_todo "$page_id" "🎯 Tech Task"
  fi
done

# Create TODOs for active QTT tickets
jq -r '.[]' "$WORK_DIR/active_qtt_ids.json" | while read -r page_id; do
  if jq -e --arg id "$page_id" 'index($id)' "$WORK_DIR/existing_source_ids.json" > /dev/null 2>&1; then
    log "Skipping QTT $page_id (already in TODO)"
  else
    log "Creating TODO for QTT $page_id"
    create_todo "$page_id" "🍬 Quality Tech Ticket"
  fi
done

# --- Archive TODOs whose source is no longer in the active lists ---
# No need to query done/dropped separately: if a TODO's source isn't in the
# active+available lists, it moved to a status we don't care about — archive it.

# Merge active tech (available only) + active QTT into one list
jq -n --slurpfile tech "$WORK_DIR/active_tech_ids.json" --slurpfile qtt "$WORK_DIR/active_qtt_ids.json" \
  '$tech[0] + $qtt[0]' > "$WORK_DIR/all_active_ids.json"

jq -c '.[]' "$WORK_DIR/todo_map.json" | while read -r todo_entry; do
  todo_id=$(echo "$todo_entry" | jq -r '.todo_id')
  source_id=$(echo "$todo_entry" | jq -r '.source_id')

  if ! jq -e --arg id "$source_id" 'index($id)' "$WORK_DIR/all_active_ids.json" > /dev/null 2>&1; then
    log "Archiving TODO $todo_id (source $source_id no longer active/available)"
    curl -s -X PATCH "https://api.notion.com/v1/pages/${todo_id}" \
      -H "Authorization: Bearer ${PERSONAL_TOKEN}" \
      -H "Notion-Version: 2022-06-28" \
      -H "Content-Type: application/json" \
      -d '{"archived": true}' > /dev/null
  fi
done

log "Sync complete"
