# Redis Guide: Setup, Monitoring, and Optimization

## Connecting to Redis in Kubernetes

If Redis is running inside Kubernetes, connect using a **temporary pod**

```sh
kubectl run -it --rm redis-cli --image=redis:latest -- redis-cli -h mark43-redis-service -p 6379
```

Alternatively, for a local Redis setup

```sh
redis-cli -h localhost -p 6379
```

---

## Basic Redis Commands

### Key Operations

```sh
SET mykey "Hello, Redis!"   # Store a value
GET mykey                   # Retrieve value
DEL mykey                   # Delete a key
EXISTS mykey                # Check if key exists (1 = yes, 0 = no)
EXPIRE mykey 60             # Set key expiration (in seconds)
TTL mykey                   # Check remaining time to live
```

### Working with Hashes

```sh
HSET user:1 name "Alice" email "alice@example.com"
HGET user:1 name
HGETALL user:1
HDEL user:1 email
```

### Working with Lists

```sh
LPUSH tasks "Task1" "Task2" "Task3"   # Push items to a list
LRANGE tasks 0 -1                      # Get all elements in a list
RPOP tasks                              # Remove last element
```

### Working with Sets

```sh
SADD colors "red" "blue" "green"  # Add elements to a set
SMEMBERS colors                   # Get all members
SISMEMBER colors "blue"           # Check if an element exists
```

---

## Monitoring Redis Performance

### Checking Memory Usage

```sh
INFO memory
```

**Key metrics:**

- `used_memory_human` → How much memory is being used.
- `maxmemory` → Maximum allowed memory.
- `evicted_keys` → Keys removed due to memory limits.

### Checking Command Stats

```sh
INFO stats
```

**Key metrics:**

- `total_commands_processed` → Number of commands executed.
- `instantaneous_ops_per_sec` → Current operations per second.
- `keyspace_hits` / `keyspace_misses` → Cache hit ratio.

### Checking Connected Clients

```sh
CLIENT LIST
```

**Key metrics:**

- `connected_clients` → Number of active connections.
- `blocked_clients` → Clients waiting on operations.

### Real-Time Monitoring

```sh
MONITOR
```

This logs **every** Redis command in real-time.

---

## Checking Cache Efficiency

To analyze **cache hit ratio**, run

```sh
redis-cli info stats | grep keyspace
```

- **High `keyspace_misses`** → Too many cache misses (Redis is not being used effectively).
- **High `keyspace_hits`** → Redis is working well as a cache.

---

## Debugging Expired or Evicted Keys

```sh
INFO keyspace
```

- `expired_keys` → How many keys expired naturally.
- `evicted_keys` → Keys removed because Redis ran out of memory.

Check specific keys

```sh
TTL mykey   # Time remaining before expiration (-1 means no expiration)
KEYS *      # List all keys (use with caution in production!)
```

---

## Optimizing Redis Performance

### Increase Max Memory

Edit `redis.conf` or run

```sh
CONFIG SET maxmemory 256mb
CONFIG SET maxmemory-policy allkeys-lru
```

- **`noeviction`** → Prevents Redis from evicting keys (default).
- **`allkeys-lru`** → Removes least recently used (LRU) keys when full.
- **`volatile-lru`** → Removes LRU keys *with expiration*.

### Enable Persistence (If Needed)

To store data permanently

```sh
SAVE       # Manual snapshot
BGSAVE     # Background snapshot
```

To **disable persistence** for a pure cache setup

```sh
CONFIG SET save ""
```

---

## Debugging Slow Commands

Check slow logs

```sh
SLOWLOG GET 10
```

If a command is slow, index your database or optimize queries.

---

## Flushing Redis Data

```sh
FLUSHALL  # Removes all keys (use with caution!)
FLUSHDB   # Removes only the selected database
```
