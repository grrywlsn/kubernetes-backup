#!/bin/bash

# Check if required environment variables are set
if [[ -z "$CLUSTER_NAME" || -z "$BACKUP_REPO" || -z "$GIT_ACCESS_TOKEN" ]]; then
    echo "Please set CLUSTER_NAME and BACKUP_REPO and GIT_ACCESS_TOKEN environment variables."
    exit 1
fi

git config --global user.email "kubernetes-backup@github.com"
git config --global user.name "kubernetes-backup"
git config --global commit.gpgsign false
git clone https://git:${GIT_ACCESS_TOKEN}@${BACKUP_REPO}.git
cd kubernetes-state-backup

# Clean up everything from the previous run, so we'll get a diff with removed files too
rm -r $CLUSTER_NAME/

# Array of Kubernetes resource kinds
SKIP_RESOURCES=( $SKIP_RESOURCES )
SKIP_NAMESPACES=( $SKIP_NAMESPACES )

# Fetch list of all namespaces
namespaces=$(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}')

RESOURCES_NAMESPACED=()
RESOURCES_CLUSTER_WIDE=()

# Populate array with namespaced resources
while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    RESOURCES_NAMESPACED+=("$name")
done < <(kubectl api-resources --no-headers --namespaced=true | awk '{print $1}')

# Populate array with cluster-wide resources
while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    RESOURCES_CLUSTER_WIDE+=("$name")
done < <(kubectl api-resources --no-headers --namespaced=false | awk '{print $1}')


get_resources() {
    local namespace="$1"

    # Determine resource array based on namespace
    if [ "$namespace" == "cluster-wide" ]; then
        resource_array=("${RESOURCES_CLUSTER_WIDE[@]}")
        namespace_flag=""
    else
        resource_array=("${RESOURCES_NAMESPACED[@]}")
        namespace_flag="-n $namespace"
    fi

    # Iterate through resources of the given type in the namespace
    for resource in "${resource_array[@]}"; do

    if [[ " ${SKIP_RESOURCES[@]} " =~ " $resource " ]]; then
        echo "Skipping $resource resources in $namespace"
    else

        if [[ "$resource" = "externalsecrets" ]]
        then
            # for some reason the plural form also returns clustersecretstores, which breaks the logic below
            resource="externalsecret"
        fi

        # Get list of resources
        echo "Looking for $resource resources in $namespace"
        resource_list=$(kubectl get "$resource" $namespace_flag -o jsonpath='{.items[*].metadata.name}')

        # Iterate through each instance of the resource
        for item in $resource_list; do
        mkdir -p "$CLUSTER_NAME/$namespace/${resource}/"
        kubectl get "$resource" "$item" $namespace_flag -o yaml | yq e 'del(.status)' | yq e 'del(.metadata.resourceVersion)' | yq e 'del(.metadata.generation)' | yq e 'del(.metadata.creationTimestamp)' | yq e 'del(.metadata.uid)' > "$CLUSTER_NAME/$namespace/${resource}/${item}.yaml"
        done
    fi
    done
}

# Get cluster-scoped resources
get_resources "cluster-wide"

# # Loop through namespaces to get namespace-scoped resources
for namespace in $namespaces; do
    # Check if namespace should be skipped
    if [[ " ${SKIP_NAMESPACES[@]} " =~ " $namespace " ]]; then
    echo "Skipping $namespace namespace"
    else
    get_resources $namespace
    fi
done

# Push changes to Git repo
git pull
git add --all

git commit -m "Backup at $(date '+%Y-%m-%d %H:%M:%S %Z')"
git push