# Wait for the NGINX server to start
TIME=120
FOUND=0
echo "Waiting for NGINX server to open port ${port}..."
for ((i=1; i<=TIME*2; i++)); do
  if ! kill -0 ${SCRIPT_PID} 2>/dev/null; then
    echo "Script used to launch NGINX server exited early!"
    clean_up 1
  elif port_used "${port}"; then
    FOUND=1
    echo "Discovered NGINX server listening on port ${port}!"
    break
  fi
  sleep 0.5
done
[[ ${FOUND} -eq 0 ]] && echo "Timed out waiting for NGINX server!" && clean_up 1
