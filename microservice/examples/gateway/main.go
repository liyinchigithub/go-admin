package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"go-admin/microservice/config"
	"go-admin/microservice/gateway"
	"go-admin/microservice/registry"
)

func main() {
	etcdEndpoints := []string{"127.0.0.1:2379"}

	reg, err := registry.NewEtcdRegistry(etcdEndpoints, 10)
	if err != nil {
		log.Fatalf("Failed to create registry: %v", err)
	}
	defer reg.Close()

	configCenter, err := config.NewEtcdConfigCenter(etcdEndpoints)
	if err != nil {
		log.Printf("Warning: failed to create config center: %v", err)
	}
	defer configCenter.Close()

	routes := []gateway.RouteConfig{
		{
			PathPrefix:  "/api/v1/user",
			ServiceName: "user-service",
			StripPrefix: true,
		},
		{
			PathPrefix:  "/api/v1/admin",
			ServiceName: "admin-service",
			StripPrefix: true,
		},
		{
			PathPrefix:  "/api/v1/job",
			ServiceName: "job-service",
			StripPrefix: true,
		},
	}

	gw := gateway.NewGateway(reg, routes)
	ctx := context.Background()
	if err := gw.Init(ctx); err != nil {
		log.Fatalf("Failed to init gateway: %v", err)
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		addr := ":8080"
		log.Printf("API Gateway starting on %s", addr)
		if err := gw.Run(addr); err != nil {
			log.Fatalf("Failed to start gateway: %v", err)
		}
	}()

	<-quit
	log.Println("Shutting down gateway...")
}
