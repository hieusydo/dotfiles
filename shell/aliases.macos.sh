if command -v caffeinate >/dev/null 2>&1; then
  alias cf="echo 'Starting caffeinate... Ctrl+C to quit' && caffeinate -di"
fi
