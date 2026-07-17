package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gin-gonic/gin"
	"go-admin/microservice/registry"
)

type UserService struct {
	router   *gin.Engine
	registry registry.ServiceRegistry
	info     *registry.ServiceInfo
}

func NewUserService() *UserService {
	return &UserService{
		router: gin.Default(),
		info: &registry.ServiceInfo{
			Name:    "user-service",
			Address: "127.0.0.1",
			Port:    8001,
			Weight:  100,
			Version: "v1.0.0",
		},
	}
}

func (s *UserService) setupRoutes() {
	api := s.router.Group("/api/v1")
	{
		api.GET("/users", s.getUsers)
		api.GET("/users/:id", s.getUser)
		api.POST("/users", s.createUser)
		api.PUT("/users/:id", s.updateUser)
		api.DELETE("/users/:id", s.deleteUser)
	}
}

func (s *UserService) getUsers(c *gin.Context) {
	c.JSON(200, gin.H{
		"code": 200,
		"msg":  "success",
		"data": []gin.H{
			{"id": 1, "username": "admin", "nickname": "管理员"},
			{"id": 2, "username": "test", "nickname": "测试用户"},
		},
	})
}

func (s *UserService) getUser(c *gin.Context) {
	id := c.Param("id")
	c.JSON(200, gin.H{
		"code": 200,
		"msg":  "success",
		"data": gin.H{"id": id, "username": "admin", "nickname": "管理员"},
	})
}

func (s *UserService) createUser(c *gin.Context) {
	c.JSON(200, gin.H{
		"code": 200,
		"msg":  "success",
		"data": gin.H{"id": 3},
	})
}

func (s *UserService) updateUser(c *gin.Context) {
	c.JSON(200, gin.H{
		"code": 200,
		"msg":  "success",
	})
}

func (s *UserService) deleteUser(c *gin.Context) {
	c.JSON(200, gin.H{
		"code": 200,
		"msg":  "success",
	})
}

func (s *UserService) Run() error {
	s.setupRoutes()

	reg, err := registry.NewEtcdRegistry([]string{"127.0.0.1:2379"}, 10)
	if err != nil {
		log.Printf("Warning: failed to connect etcd: %v", err)
	} else {
		s.registry = reg
		ctx := context.Background()
		if err := reg.Register(ctx, s.info); err != nil {
			log.Printf("Warning: failed to register service: %v", err)
		}
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		addr := ":8001"
		log.Printf("User service starting on %s", addr)
		if err := s.router.Run(addr); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	<-quit
	log.Println("Shutting down user service...")

	if s.registry != nil {
		ctx := context.Background()
		_ = s.registry.Unregister(ctx, s.info)
		_ = s.registry.Close()
	}

	return nil
}

func main() {
	service := NewUserService()
	if err := service.Run(); err != nil {
		log.Fatal(err)
	}
}
