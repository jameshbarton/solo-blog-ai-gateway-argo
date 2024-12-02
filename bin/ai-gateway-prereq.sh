#!/bin/bash

echo "Setup Gloo AI Gateway prerequisites"

# Check to see if license key variable was passed through, if not prompt for key
if [[ ${license_key} == "" ]]
  then
    # provide license key
    echo "Please provide your Gloo AI Gateway License Key:"
    read license_key
fi

# Check OS type
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        BASE64_license_key=$(echo -n "${license_key}" | base64 -w 0)
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        BASE64_license_key=$(echo -n "${license_key}" | base64)
else
        echo unknown OS type
        exit 1
fi

echo "Establishing AI Gateway license"
cluster_context=$(kubectl config current-context)
kubectl create ns gloo-system --context ${cluster_context}

kubectl apply --context ${cluster_context} -f - <<EOF
apiVersion: v1
data:
  license-key: ${BASE64_license_key}
kind: Secret
metadata:
  labels:
    app: gloo
    gloo: license
  name: license
  namespace: gloo-system
type: Opaque
EOF

echo "Installing Gateway API CRDs"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml