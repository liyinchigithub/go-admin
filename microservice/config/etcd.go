package config

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"

	clientv3 "go.etcd.io/etcd/client/v3"
)

type ConfigCenter interface {
	Get(ctx context.Context, key string) (string, error)
	Set(ctx context.Context, key, value string) error
	Delete(ctx context.Context, key string) error
	Watch(ctx context.Context, key string) (<-chan string, error)
	Close() error
}

type EtcdConfigCenter struct {
	client  *clientv3.Client
	mu      sync.RWMutex
	configs map[string]string
}

func NewEtcdConfigCenter(endpoints []string) (*EtcdConfigCenter, error) {
	client, err := clientv3.New(clientv3.Config{
		Endpoints: endpoints,
	})
	if err != nil {
		return nil, err
	}

	return &EtcdConfigCenter{
		client:  client,
		configs: make(map[string]string),
	}, nil
}

func (c *EtcdConfigCenter) Get(ctx context.Context, key string) (string, error) {
	c.mu.RLock()
	if val, ok := c.configs[key]; ok {
		c.mu.RUnlock()
		return val, nil
	}
	c.mu.RUnlock()

	resp, err := c.client.Get(ctx, key)
	if err != nil {
		return "", err
	}

	if len(resp.Kvs) == 0 {
		return "", fmt.Errorf("config key not found: %s", key)
	}

	value := string(resp.Kvs[0].Value)
	c.mu.Lock()
	c.configs[key] = value
	c.mu.Unlock()

	return value, nil
}

func (c *EtcdConfigCenter) GetJSON(ctx context.Context, key string, result interface{}) error {
	value, err := c.Get(ctx, key)
	if err != nil {
		return err
	}
	return json.Unmarshal([]byte(value), result)
}

func (c *EtcdConfigCenter) Set(ctx context.Context, key, value string) error {
	_, err := c.client.Put(ctx, key, value)
	if err != nil {
		return err
	}

	c.mu.Lock()
	c.configs[key] = value
	c.mu.Unlock()

	return nil
}

func (c *EtcdConfigCenter) SetJSON(ctx context.Context, key string, value interface{}) error {
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return c.Set(ctx, key, string(data))
}

func (c *EtcdConfigCenter) Delete(ctx context.Context, key string) error {
	_, err := c.client.Delete(ctx, key)
	if err != nil {
		return err
	}

	c.mu.Lock()
	delete(c.configs, key)
	c.mu.Unlock()

	return nil
}

func (c *EtcdConfigCenter) Watch(ctx context.Context, key string) (<-chan string, error) {
	ch := make(chan string, 10)

	go func() {
		defer close(ch)

		watchChan := c.client.Watch(ctx, key)
		for watchResp := range watchChan {
			for _, event := range watchResp.Events {
				value := string(event.Kv.Value)
				c.mu.Lock()
				c.configs[key] = value
				c.mu.Unlock()
				ch <- value
			}
		}
	}()

	return ch, nil
}

func (c *EtcdConfigCenter) Close() error {
	return c.client.Close()
}
