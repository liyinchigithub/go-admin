package gateway

import (
	"context"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
	"sync"

	"github.com/gin-gonic/gin"
	"go-admin/microservice/loadbalancer"
	"go-admin/microservice/registry"
)

type RouteConfig struct {
	PathPrefix  string
	ServiceName string
	StripPrefix bool
}

type Gateway struct {
	registry  registry.ServiceRegistry
	balancer  loadbalancer.LoadBalancer
	routes    []RouteConfig
	services  map[string][]*loadbalancer.ServiceInstance
	mu        sync.RWMutex
	engine    *gin.Engine
}

func NewGateway(reg registry.ServiceRegistry, routes []RouteConfig) *Gateway {
	return &Gateway{
		registry: reg,
		balancer: loadbalancer.NewRoundRobinBalancer(),
		routes:   routes,
		services: make(map[string][]*loadbalancer.ServiceInstance),
		engine:   gin.Default(),
	}
}

func (g *Gateway) Init(ctx context.Context) error {
	for _, route := range g.routes {
		services, err := g.registry.Discover(ctx, route.ServiceName)
		if err != nil {
			continue
		}
		instances := make([]*loadbalancer.ServiceInstance, 0, len(services))
		for _, s := range services {
			instances = append(instances, &loadbalancer.ServiceInstance{
				Name:    s.Name,
				Address: s.Address,
				Port:    s.Port,
				Weight:  s.Weight,
			})
		}
		g.mu.Lock()
		g.services[route.ServiceName] = instances
		g.mu.Unlock()

		watchCh, err := g.registry.Watch(ctx, route.ServiceName)
		if err != nil {
			continue
		}

		go g.watchService(route.ServiceName, watchCh)
	}

	g.setupRoutes()
	return nil
}

func (g *Gateway) watchService(serviceName string, watchCh <-chan []*registry.ServiceInfo) {
	for services := range watchCh {
		instances := make([]*loadbalancer.ServiceInstance, 0, len(services))
		for _, s := range services {
			instances = append(instances, &loadbalancer.ServiceInstance{
				Name:    s.Name,
				Address: s.Address,
				Port:    s.Port,
				Weight:  s.Weight,
			})
		}
		g.mu.Lock()
		g.services[serviceName] = instances
		g.mu.Unlock()
	}
}

func (g *Gateway) setupRoutes() {
	for _, route := range g.routes {
		routeCopy := route
		g.engine.Any(routeCopy.PathPrefix+"/*any", g.proxyHandler(routeCopy))
	}
}

func (g *Gateway) proxyHandler(route RouteConfig) gin.HandlerFunc {
	return func(c *gin.Context) {
		g.mu.RLock()
		instances := g.services[route.ServiceName]
		g.mu.RUnlock()

		if len(instances) == 0 {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"code": 503,
				"msg":  "service unavailable",
			})
			return
		}

		instance := g.balancer.Select(instances)
		if instance == nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"code": 503,
				"msg":  "no available instance",
			})
			return
		}

		target := &url.URL{
			Scheme: "http",
			Host:   instance.Address + ":" + itoa(instance.Port),
		}

		proxy := httputil.NewSingleHostReverseProxy(target)
		proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
			c.JSON(http.StatusBadGateway, gin.H{
				"code": 502,
				"msg":  "bad gateway",
			})
		}

		originalPath := c.Request.URL.Path
		if route.StripPrefix {
			c.Request.URL.Path = strings.TrimPrefix(originalPath, route.PathPrefix)
		}

		proxy.ServeHTTP(c.Writer, c.Request)
	}
}

func (g *Gateway) Run(addr string) error {
	return g.engine.Run(addr)
}

func (g *Gateway) GetEngine() *gin.Engine {
	return g.engine
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var buf [20]byte
	pos := len(buf)
	for i > 0 {
		pos--
		buf[pos] = byte('0' + i%10)
		i /= 10
	}
	return string(buf[pos:])
}
