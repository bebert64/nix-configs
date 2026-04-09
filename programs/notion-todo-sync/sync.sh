# Notion TODO Sync — syncs assigned tickets from shared Notion databases
# into the personal TODO board.

ROMAIN_USER_ID="4a8c5256-3193-415c-86f7-848e821783a2"
TECH_TASKS_DB="b093a2a6-d589-4a39-ba4d-83624ad41c3b"
QTT_DB="d6cdb24f-62ac-4581-9503-c6035d22babf"
TODO_DB="cdf5bb4b-4437-4533-a8cb-170b4f0e1186"

MCP_TOKEN=$(cat "$MCP_TOKEN_FILE")
PERSONAL_TOKEN=$(cat "$PERSONAL_TOKEN_FILE")

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Query a Notion database with pagination. Returns all results as a JSON array.
# $1: database ID, $2: token, $3: filter JSON
query_notion_db() {
  local db_id="$1" token="$2" filter="$3"
  local all_results="[]" has_more="true" cursor=""

  while [[ "$has_more" == "true" ]]; do
    local body
    if [[ -n "$cursor" ]]; then
      body=$(jq -n --argjson filter "$filter" --arg cursor "$cursor" \
        '{filter: $filter, start_cursor: $cursor, page_size: 100}')
    else
      body=$(jq -n --argjson filter "$filter" \
        '{filter: $filter, page_size: 100}')
    fi

    local response
    response=$(curl -s -X POST "https://api.notion.com/v1/databases/${db_id}/query" \
      -H "Authorization: Bearer ${token}" \
      -H "Notion-Version: 2022-06-28" \
      -H "Content-Type: application/json" \
      -d "$body")

    # Check for API errors
    if echo "$response" | jq -e '.object == "error"' > /dev/null 2>&1; then
      log "ERROR: Notion API error: $(echo "$response" | jq -r '.message')"
      return 1
    fi

    local page_results
    page_results=$(echo "$response" | jq '.results')
    all_results=$(jq -n --argjson a "$all_results" --argjson b "$page_results" '$a + $b')
    has_more=$(echo "$response" | jq -r '.has_more')
    cursor=$(echo "$response" | jq -r '.next_cursor // empty')
  done

  echo "$all_results"
}

# Extract page ID and title from query results
# $1: JSON array of pages
extract_pages() {
  echo "$1" | jq -r '[.[] | {
    id: .id,
    title: ([.properties | to_entries[] | select(.value.type == "title") | .value.title[] | .plain_text] | join(""))
  }]'
}

# --- Fetch active source tickets (not Done, not Dropped) ---

log "Fetching active Tech Tasks..."
tech_tasks_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"property": "Status Intl", "status": {"does_not_equal": "🟣 3 - Done"}},
    {"property": "Status Intl", "status": {"does_not_equal": "⚪ -1 - Dropped"}}
  ]
}')
active_tech_tasks=$(query_notion_db "$TECH_TASKS_DB" "$MCP_TOKEN" "$tech_tasks_filter")

log "Fetching active QTT tickets..."
qtt_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"property": "Status", "status": {"does_not_equal": "4 - Done"}},
    {"property": "Status", "status": {"does_not_equal": "-1 - Dropped"}}
  ]
}')
active_qtt=$(query_notion_db "$QTT_DB" "$MCP_TOKEN" "$qtt_filter")

active_tech_pages=$(extract_pages "$active_tech_tasks")
active_qtt_pages=$(extract_pages "$active_qtt")

log "Found $(echo "$active_tech_pages" | jq 'length') active Tech Tasks"
log "Found $(echo "$active_qtt_pages" | jq 'length') active QTT tickets"

# --- Fetch existing TODO entries ---

log "Fetching existing TODO entries..."
todo_filter='{
  "or": [
    {"property": "Area", "select": {"equals": "🎯 Tech Task"}},
    {"property": "Area", "select": {"equals": "🍬 Quality Tech Ticket"}}
  ]
}'
existing_todos=$(query_notion_db "$TODO_DB" "$PERSONAL_TOKEN" "$todo_filter")

# Extract source page IDs from TODO titles (page mentions)
# Each TODO title should contain a mention with a page ID pointing to the source ticket
existing_todo_map=$(echo "$existing_todos" | jq '[.[] | {
  todo_id: .id,
  source_id: ([.properties | to_entries[] | select(.value.type == "title") | .value.title[] | select(.type == "mention") | .mention.page.id] | first),
  status: (.properties.Status.status.name // null)
}] | map(select(.source_id != null))')

existing_source_ids=$(echo "$existing_todo_map" | jq -r '[.[].source_id] | join("\n")')

log "Found $(echo "$existing_todo_map" | jq 'length') existing TODO entries with source links"

# --- Create new TODO entries for tickets not yet tracked ---

create_todo() {
  local source_id="$1" area_label="$2"
  curl -s -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer ${PERSONAL_TOKEN}" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg db "$TODO_DB" --arg src_id "$source_id" --arg area "$area_label" '{
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
    }')" > /dev/null
}

# Create TODOs for active tech tasks
echo "$active_tech_pages" | jq -r '.[].id' | while read -r page_id; do
  if echo "$existing_source_ids" | grep -q "$page_id"; then
    log "Skipping Tech Task $page_id (already in TODO)"
  else
    log "Creating TODO for Tech Task $page_id"
    create_todo "$page_id" "🎯 Tech Task"
  fi
done

# Create TODOs for active QTT tickets
echo "$active_qtt_pages" | jq -r '.[].id' | while read -r page_id; do
  if echo "$existing_source_ids" | grep -q "$page_id"; then
    log "Skipping QTT $page_id (already in TODO)"
  else
    log "Creating TODO for QTT $page_id"
    create_todo "$page_id" "🍬 Quality Tech Ticket"
  fi
done

# --- Handle completed/dropped tickets ---

log "Fetching completed/dropped Tech Tasks..."
done_tech_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"or": [
      {"property": "Status Intl", "status": {"equals": "🟣 3 - Done"}},
      {"property": "Status Intl", "status": {"equals": "⚪ -1 - Dropped"}}
    ]}
  ]
}')
done_tech_tasks=$(query_notion_db "$TECH_TASKS_DB" "$MCP_TOKEN" "$done_tech_filter")

log "Fetching completed/dropped QTT tickets..."
done_qtt_filter=$(jq -n --arg uid "$ROMAIN_USER_ID" '{
  "and": [
    {"property": "Assignee", "people": {"contains": $uid}},
    {"or": [
      {"property": "Status", "status": {"equals": "4 - Done"}},
      {"property": "Status", "status": {"equals": "-1 - Dropped"}}
    ]}
  ]
}')
done_qtt=$(query_notion_db "$QTT_DB" "$MCP_TOKEN" "$done_qtt_filter")

# Build a map of done/dropped source IDs to their status
done_source_ids=$(jq -n \
  --argjson tech "$done_tech_tasks" \
  --argjson qtt "$done_qtt" \
  '[$tech[], $qtt[]] | [.[] | {
    id: .id,
    is_dropped: (
      [.properties | to_entries[] | select(.value.type == "status") | .value.status.name] | first |
      test("Dropped$")
    )
  }]')

# Update or delete existing TODOs whose source is now done/dropped
echo "$existing_todo_map" | jq -c '.[]' | while read -r todo_entry; do
  todo_id=$(echo "$todo_entry" | jq -r '.todo_id')
  source_id=$(echo "$todo_entry" | jq -r '.source_id')
  current_status=$(echo "$todo_entry" | jq -r '.status')

  done_info=$(echo "$done_source_ids" | jq -r --arg sid "$source_id" '.[] | select(.id == $sid)')

  if [[ -z "$done_info" ]]; then
    continue
  fi

  is_dropped=$(echo "$done_info" | jq -r '.is_dropped')

  if [[ "$is_dropped" == "true" ]]; then
    log "Deleting TODO $todo_id (source $source_id was dropped)"
    curl -s -X PATCH "https://api.notion.com/v1/pages/${todo_id}" \
      -H "Authorization: Bearer ${PERSONAL_TOKEN}" \
      -H "Notion-Version: 2022-06-28" \
      -H "Content-Type: application/json" \
      -d '{"archived": true}' > /dev/null
  elif [[ "$current_status" != "Done" ]]; then
    log "Marking TODO $todo_id as Done (source $source_id completed)"
    curl -s -X PATCH "https://api.notion.com/v1/pages/${todo_id}" \
      -H "Authorization: Bearer ${PERSONAL_TOKEN}" \
      -H "Notion-Version: 2022-06-28" \
      -H "Content-Type: application/json" \
      -d '{"properties": {"Status": {"status": {"name": "Done"}}}}' > /dev/null
  fi
done

log "Sync complete"
