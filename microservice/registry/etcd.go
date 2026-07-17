package registry

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	clientv3 "go.etcd.io/etcd/client/v3"
)

type ServiceInfo struct {
	Name    string `json:"name"`
	Address string `json:"address"`
	Port    int    `json:"port"`
	Weight  int    `json:"weight"`
	Version string `json:"version"`
}

type ServiceRegistry interface {
	Register(ctx context.Context, info *ServiceInfo) error
	Unregister(ctx context.Context, info *ServiceInfo) error
	Discover(ctx context.Context, serviceName string) ([]*ServiceInfo, error)
	Watch(ctx context.Context, serviceName string) (<-chan []*ServiceInfo, error)
	Close() error
}

type EtcdRegistry struct {
	client      *clientv3.Client
	leaseID     clientv3.LeaseID
	leaseTTL  int64
	mu        sync.RWMutex
	services  map[string][]*ServiceInfo
	watchers  map[string]chan []*ServiceInfo
}

func NewEtcdRegistry(endpoints []string, ttl int64) (*EtcdRegistry, error) {
	client, err := clientv3.New(clientv3.Config{
		Endpoints:   endpoints,
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		return nil, err
	}

	return &EtcdRegistry{
		client:   client,
		leaseTTL: ttl,
		services: make(map[string][]*ServiceInfo),
		watchers: make(map[string]chan []*ServiceInfo),
	}, nil
}

func (r *EtcdRegistry) Register(ctx context.Context, info *ServiceInfo) error {
	leaseResp, err := r.client.Grant(ctx, r.leaseTTL)
	if err != nil {
		return err
	}
	r.leaseID = leaseResp.ID

	key := fmt.Sprintf("/services/%s/%s:%d", info.Name, info.Address, info.Port)
	value, err := json.Marshal(info)
	if err != nil {
		return err
	}

	_, err = r.client.Put(ctx, key, string(value), clientv3.WithLease(leaseResp.ID))
	if err != nil {
		return err
	}

	ch, err := r.client.KeepAlive(ctx, leaseResp.ID)
	if err != nil {
		return err
	}

	go func() {
		for range ch {
		}
	}()

	return nil
}

func (r *EtcdRegistry) Unregister(ctx context.Context, info *ServiceInfo) error {
	key := fmt.Sprintf("/services/%s/%s:%d", info.Name, info.Address, info.Port)
	_, err := r.client.Delete(ctx, key)
	return err
}

func (r *EtcdRegistry) Discover(ctx context.Context, serviceName string) ([]*ServiceInfo, error) {
	prefix := fmt.Sprintf("/services/%s/", serviceName)
	resp, err := r.client.Get(ctx, prefix, clientv3.WithPrefix())
	if err != nil {
		return nil, err
	}

	var services []*ServiceInfo
	for _, kv := range resp.Kvs {
		var info ServiceInfo
		if err := json.Unmarshal(kv.Value, &info); err != nil {
			continue
		}
		services = append(services, &info)
	}

	r.mu.Lock()
	r.services[serviceName] = services
	r.mu.Unlock()

	return services, nil
}

func (r *EtcdRegistry) Watch(ctx context.Context, serviceName string) (<-chan []*ServiceInfo, error) {
	ch := make(chan []*ServiceInfo, 10)
	prefix := fmt.Sprintf("/services/%s/", serviceName)

	go func() {
		defer close(ch)

		services, err := r.Discover(ctx, serviceName)
		if err == nil && len(services) > 0 {
			ch <- services
		}

		watchChan := r.client.Watch(ctx, prefix, clientv3.WithPrefix())
		for watchResp := range watchChan {
			for range watchResp.Events {
				services, err := r.Discover(ctx, serviceName)
				if err == nil {
					select {
					case ch <- services:
					default:
					}
				}
			}
		}
	}()

	r.mu.Lock()
	r.watchers[serviceName] = ch
	r.mu.Unlock()

	return ch, nil
}

func (r *EtcdRegistry) Close() error {
	if r.leaseID != 0 {
		_, _ = r.client.Revoke(context.Background(), r.leaseID)
	}
	return r.client.Close()
}
