package client

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"go-admin/microservice/loadbalancer"
	"go-admin/microservice/registry"
)

type ServiceClient struct {
	registry     registry.ServiceRegistry
	balancer     loadbalancer.LoadBalancer
	services     map[string][]*loadbalancer.ServiceInstance
	mu           sync.RWMutex
	watchers     map[string]<-chan []*registry.ServiceInfo
	httpClient   *http.Client
}

type ClientOption func(*ServiceClient)

func WithTimeout(timeout time.Duration) ClientOption {
	return func(c *ServiceClient) {
		c.httpClient.Timeout = timeout
	}
}

func WithLoadBalancer(balancer loadbalancer.LoadBalancer) ClientOption {
	return func(c *ServiceClient) {
		c.balancer = balancer
	}
}

func NewServiceClient(reg registry.ServiceRegistry, opts ...ClientOption) *ServiceClient {
	client := &ServiceClient{
		registry:   reg,
		balancer:   loadbalancer.NewRoundRobinBalancer(),
		services:   make(map[string][]*loadbalancer.ServiceInstance),
		watchers:   make(map[string]<-chan []*registry.ServiceInfo),
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}

	for _, opt := range opts {
		opt(client)
	}

	return client
}

func (c *ServiceClient) Call(ctx context.Context, serviceName, method, path string, body interface{}, result interface{}) error {
	instances, err := c.getServiceInstances(ctx, serviceName)
	if err != nil {
		return err
	}

	if len(instances) == 0 {
		return fmt.Errorf("no available service instance for %s", serviceName)
	}

	instance := c.balancer.Select(instances)
	if instance == nil {
		return fmt.Errorf("load balancer returned nil instance")
	}

	url := fmt.Sprintf("http://%s:%d%s", instance.Address, instance.Port, path)

	var bodyReader io.Reader
	if body != nil {
		bodyBytes, err := json.Marshal(body)
		if err != nil {
			return err
		}
		bodyReader = bytes.NewReader(bodyBytes)
	}

	req, err := http.NewRequestWithContext(ctx, method, url, bodyReader)
	if err != nil {
		return err
	}

	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	if resp.StatusCode >= 400 {
		return fmt.Errorf("service call failed: status=%d, body=%s", resp.StatusCode, string(respBody))
	}

	if result != nil && len(respBody) > 0 {
		if err := json.Unmarshal(respBody, result); err != nil {
			return fmt.Errorf("failed to unmarshal response: %w", err)
		}
	}

	return nil
}

func (c *ServiceClient) Get(ctx context.Context, serviceName, path string, result interface{}) error {
	return c.Call(ctx, serviceName, http.MethodGet, path, nil, result)
}

func (c *ServiceClient) Post(ctx context.Context, serviceName, path string, body interface{}, result interface{}) error {
	return c.Call(ctx, serviceName, http.MethodPost, path, body, result)
}

func (c *ServiceClient) Put(ctx context.Context, serviceName, path string, body interface{}, result interface{}) error {
	return c.Call(ctx, serviceName, http.MethodPut, path, body, result)
}

func (c *ServiceClient) Delete(ctx context.Context, serviceName, path string, result interface{}) error {
	return c.Call(ctx, serviceName, http.MethodDelete, path, nil, result)
}

func (c *ServiceClient) getServiceInstances(ctx context.Context, serviceName string) ([]*loadbalancer.ServiceInstance, error) {
	c.mu.RLock()
	instances, ok := c.services[serviceName]
	c.mu.RUnlock()

	if ok && len(instances) > 0 {
		return instances, nil
	}

	c.mu.Lock()
	defer c.mu.Unlock()

	if _, exists := c.watchers[serviceName]; !exists {
		watchCh, err := c.registry.Watch(ctx, serviceName)
		if err != nil {
			return nil, err
		}
		c.watchers[serviceName] = watchCh

		go c.watchService(serviceName, watchCh)
	}

	services, err := c.registry.Discover(ctx, serviceName)
	if err != nil {
		return nil, err
	}

	instances = c.toInstances(services)
	c.services[serviceName] = instances

	return instances, nil
}

func (c *ServiceClient) watchService(serviceName string, watchCh <-chan []*registry.ServiceInfo) {
	for services := range watchCh {
		instances := c.toInstances(services)
		c.mu.Lock()
		c.services[serviceName] = instances
		c.mu.Unlock()
	}
}

func (c *ServiceClient) toInstances(services []*registry.ServiceInfo) []*loadbalancer.ServiceInstance {
	instances := make([]*loadbalancer.ServiceInstance, 0, len(services))
	for _, s := range services {
		instances = append(instances, &loadbalancer.ServiceInstance{
			Name:    s.Name,
			Address: s.Address,
			Port:    s.Port,
			Weight:  s.Weight,
		})
	}
	return instances
}

func (c *ServiceClient) Close() error {
	return c.registry.Close()
}
