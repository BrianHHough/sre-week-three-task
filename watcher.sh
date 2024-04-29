#!/bin/bash

# Constants for namespace, deployment, # of restarts before shutting down
NAMESPACE="sre"
DEPLOYMENT="swype-app"
MAX_RESTARTS=3

# Function to get current restart count
function get_restart_count() {
  kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT} -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}'
}

# Initial log message
echo "Monitoring deployment ${DEPLOYMENT} in namespace ${NAMESPACE} for excessive restarts..."

while true; do
  # Fetch current number of restarts
  RESTARTS=$(get_restart_count)

  # Output current restart count
  echo "$(date) - Current restart count: ${RESTARTS}"

  # Check if restart count exceeds max allowed
  if [ "${RESTARTS}" -gt "${MAX_RESTARTS}" ]; then
    echo "$(date) - Maximum restarts exceeded. Scaling down ${DEPLOYMENT}..."
    kubectl scale --replicas=0 deployment/${DEPLOYMENT} -n ${NAMESPACE}
    break
  fi

  # Delay before next check
  sleep 60
done

echo "$(date) - Monitoring stopped or deployment scaled down."