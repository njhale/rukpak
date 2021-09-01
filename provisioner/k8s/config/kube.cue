package config

import (
	corev1 "k8s.io/api/core/v1"
	appsv1 "k8s.io/api/apps/v1"
)

serviceAccount: [string]: corev1.#ServiceAccount
serviceAccount: [ID=_]: {
	kind:       "ServiceAccount"
	apiVersion: "v1"
	metadata: name: ID
}

deployment: [string]: appsv1.#Deployment
deployment: [ID=_]: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name: ID
		labels: app: ID
	}
	spec: {
		strategy: type: "RollingUpdate"
		replicas: 1
		selector: matchLabels: app: ID
		template: {
			metadata: labels: app: ID
			spec: {
				serviceAccountName: ID
				containers: [{
					name: "controller"
					command: [
						"/bin/k8s run",
					]
					image:           "quay.io/operator-framework/olm@sha256:e74b2ac57963c7f3ba19122a8c31c9f2a0deb3c0c5cac9e5323ccffd0ca198ed"
					imagePullPolicy: "IfNotPresent"
					ports: [{
						containerPort: 8080
					}, {
						containerPort: 8081
						name:          "metrics"
						protocol:      "TCP"
					}]
					livenessProbe: httpGet: {
						path: "/healthz"
						port: 8080
					}
					readinessProbe: httpGet: {
						path: "/healthz"
						port: 8080
					}
				}]
			}
		}
	}
}

deployment: "alice": {}
serviceAccount: "bob": {}
