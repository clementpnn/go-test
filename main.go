package main

import (
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Déclare un compteur avec un label "ip" pour enregistrer les connexions
var connectionCounter = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "hello_world_connections_total",
		Help: "Nombre total de connexions à l'endpoint /, étiqueté par l'IP du client.",
	},
	[]string{"ip"},
)

func init() {
	// Enregistrer le compteur dans le registre Prometheus par défaut
	prometheus.MustRegister(connectionCounter)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	// Extraire l'IP du client depuis r.RemoteAddr (format "IP:port")
	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		ip = r.RemoteAddr
	}
	// Incrémenter le compteur pour l'IP récupérée
	connectionCounter.WithLabelValues(ip).Inc()

	fmt.Fprintf(w, "Hello World")
}

func main() {
	// Endpoint principal
	http.HandleFunc("/", helloHandler)
	// Endpoint pour exposer les métriques Prometheus
	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Démarrage du serveur sur http://localhost:8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("Erreur lors du démarrage du serveur : %v", err)
	}
}
