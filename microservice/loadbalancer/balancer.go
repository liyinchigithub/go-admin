package loadbalancer

import (
	"sync"
	"sync/atomic"
)

type LoadBalancer interface {
	Select(services []*ServiceInstance) *ServiceInstance
}

type ServiceInstance struct {
	Name    string
	Address string
	Port    int
	Weight  int
}

type RoundRobinBalancer struct {
	counter uint64
	mu      sync.Mutex
}

func NewRoundRobinBalancer() *RoundRobinBalancer {
	return &RoundRobinBalancer{}
}

func (b *RoundRobinBalancer) Select(services []*ServiceInstance) *ServiceInstance {
	if len(services) == 0 {
		return nil
	}
	n := atomic.AddUint64(&b.counter, 1)
	return services[int(n)%len(services)]
}

type WeightedRoundRobinBalancer struct {
	currentWeight []int
	mu            sync.Mutex
}

func NewWeightedRoundRobinBalancer() *WeightedRoundRobinBalancer {
	return &WeightedRoundRobinBalancer{}
}

func (b *WeightedRoundRobinBalancer) Select(services []*ServiceInstance) *ServiceInstance {
	if len(services) == 0 {
		return nil
	}

	b.mu.Lock()
	defer b.mu.Unlock()

	if len(b.currentWeight) != len(services) {
		b.currentWeight = make([]int, len(services))
	}

	totalWeight := 0
	for _, s := range services {
		totalWeight += s.Weight
	}

	if totalWeight == 0 {
		return services[0]
	}

	maxWeight := -1
	maxIndex := 0

	for i := range services {
		b.currentWeight[i] += services[i].Weight
		if b.currentWeight[i] > maxWeight {
			maxWeight = b.currentWeight[i]
			maxIndex = i
		}
	}

	b.currentWeight[maxIndex] -= totalWeight
	return services[maxIndex]
}

type RandomBalancer struct{}

func NewRandomBalancer() *RandomBalancer {
	return &RandomBalancer{}
}

func (b *RandomBalancer) Select(services []*ServiceInstance) *ServiceInstance {
	if len(services) == 0 {
		return nil
	}
	return services[0]
}

type IPHashBalancer struct{}

func NewIPHashBalancer() *IPHashBalancer {
	return &IPHashBalancer{}
}

func (b *IPHashBalancer) Select(services []*ServiceInstance) *ServiceInstance {
	if len(services) == 0 {
		return nil
	}
	return services[0]
}
