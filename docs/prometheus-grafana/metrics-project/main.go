package main

import (
	"fmt"
	"math"
	"math/rand"
	"net/http"
	"runtime"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const (
	port               = ":4689"
	errorRate          = 5.0
	usersLoggedMin     = 50
	usersLoggedMax     = 250
	metricsUpdateDelay = 100 * time.Millisecond
)

var (
	requestsCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "pb_requests_total",
			Help: "Counter of requests",
		},
		[]string{"statusCode"},
	)

	usersOnlineGauge = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "pb_users_logados_total",
			Help: "Number of users logged in",
		},
	)

	responseDurationHistogram = prometheus.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "pb_request_duration_seconds",
			Help:    "API response duration",
			Buckets: prometheus.DefBuckets,
		},
	)

	requestCountByMethod = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "pb_requests_by_method_total",
			Help: "Total number of requests by HTTP method",
		},
		[]string{"method"},
	)

	memoryUsage = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "pb_memory_usage_bytes",
			Help: "Current memory usage in bytes",
		},
	)

	// Create a new random source for generating random values
	rng = rand.New(rand.NewSource(time.Now().UnixNano()))

	// Create a custom registry for only your metrics
	pbRegistry = prometheus.NewRegistry()
)

func init() {
	pbRegistry.MustRegister(requestsCounter)
	pbRegistry.MustRegister(usersOnlineGauge)
	pbRegistry.MustRegister(responseDurationHistogram)
	pbRegistry.MustRegister(requestCountByMethod)
	pbRegistry.MustRegister(memoryUsage)
}

func randomGaussian(min, max, skew float64) float64 {
	var u, v float64
	for u == 0 {
		u = rng.Float64()
	}
	for v == 0 {
		v = rng.Float64()
	}
	num := math.Sqrt(-2.0*math.Log(u)) * math.Cos(2.0*math.Pi*v)

	num = num/10.0 + 0.5
	if num > 1 || num < 0 {
		num = randomGaussian(min, max, skew)
	}
	num = math.Pow(num, skew)
	num *= max - min
	num += min
	return num
}

func trackMetrics() {
	// Fake initial data
	requestsCounter.WithLabelValues("200").Add(float64(70 + rng.Intn(150)))
	requestsCounter.WithLabelValues("500").Add(float64(5 + rng.Intn(20)))
	requestsCounter.WithLabelValues("400").Add(float64(20 + rng.Intn(30)))
	requestsCounter.WithLabelValues("403").Add(float64(25 + rng.Intn(50)))
	requestsCounter.WithLabelValues("404").Add(float64(40 + rng.Intn(60)))
	requestsCounter.WithLabelValues("301").Add(float64(100 + rng.Intn(150)))

	for {
		statusCode := "200"
		randVal := rng.Float64()

		switch {
		case randVal < (errorRate / 100):
			statusCode = "500" // Internal Server Error
		case randVal < (errorRate/100)+0.08:
			statusCode = "400" // Bad Request
		case randVal < (errorRate/100)+0.15:
			statusCode = "403" // Forbidden
		case randVal < (errorRate/100)+0.22:
			statusCode = "404" // Not Found
		case randVal < (errorRate/100)+0.30:
			statusCode = "301" // Moved
		}

		requestsCounter.WithLabelValues(statusCode).Inc()

		usersLogged := float64(usersLoggedMin + rng.Intn(usersLoggedMax))
		usersOnlineGauge.Set(usersLogged)

		responseDuration := randomGaussian(0, 3, 4)
		responseDurationHistogram.Observe(responseDuration)

		// Track memory usage (in bytes)
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.Set(float64(memStats.Alloc))

		// Simulate request count by method
		requestCountByMethod.WithLabelValues("GET").Inc()

		time.Sleep(metricsUpdateDelay)
	}
}

func handleMetrics(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	promhttp.HandlerFor(pbRegistry, promhttp.HandlerOpts{}).ServeHTTP(w, r)
}

func main() {
	go trackMetrics()

	http.HandleFunc("GET /metrics", handleMetrics)

	fmt.Println("Listening on", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		fmt.Printf("Error starting server: %v\n", err)
	}
}
