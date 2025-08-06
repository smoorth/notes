import psycopg2
import redis
import json
import time
import random

# Redis Connection Pool
pool = redis.ConnectionPool(host='localhost', port=6379, db=0, decode_responses=True)
redis_client = redis.Redis(connection_pool=pool)

# PostgreSQL Connection
pg_conn = psycopg2.connect(
    host="localhost",
    port=6432,
    database="app",
    user="postgres",
    password="zQy2hutFTCQHtGngqncB7QCsjkWuuaocKDOIqXzNzJGtXt310t0Ouxgo99ltbR50"
)
pg_cursor = pg_conn.cursor()

def preload_redis():
    """Preloads Redis with user data in bulk."""
    print("Preloading Redis with user data...")

    # Fetch all user data in one query instead of 1000 separate ones
    pg_cursor.execute("SELECT id, name, email FROM users LIMIT 10000")
    users = pg_cursor.fetchall()

    # Store in Redis
    for user in users:
        redis_client.setex(f"user:{user[0]}", 300, json.dumps({
            "id": user[0], "name": user[1], "email": user[2]
        }))

    print(f"Preloaded {len(users)} users into Redis.")

def get_user(user_id):
    """Fetches user from Redis if available, otherwise queries PostgreSQL."""
    cache_key = f"user:{user_id}"

    # Check Redis first
    cached_data = redis_client.get(cache_key)
    if cached_data:
        return "CACHE HIT", json.loads(cached_data)

    # Query PostgreSQL if not found in Redis
    pg_cursor.execute("SELECT id, name, email FROM users WHERE id = %s", (user_id,))
    user = pg_cursor.fetchone()

    if user:
        # Store result in Redis with 300-second expiration
        redis_client.setex(cache_key, 300, json.dumps({"id": user[0], "name": user[1], "email": user[2]}))

    return "CACHE MISS", user

# Preload Redis for better cache hit rate
preload_redis()

# Simulate 10,000 requests with random user IDs
def benchmark():
    """Runs benchmark tests for database queries with and without Redis."""
    # Reduce the range to improve cache hits
    user_id_range = 10000

    # Without Redis
    start_time_no_cache = time.time()
    for _ in range(10000):
        user_id = random.randint(1, user_id_range)
        pg_cursor.execute("SELECT id, name, email FROM users WHERE id = %s", (user_id,))
        pg_cursor.fetchone()
    end_time_no_cache = time.time()

    # With Redis
    start_time_cache = time.time()
    for _ in range(10000):
        user_id = random.randint(1, user_id_range)
        get_user(user_id)
    end_time_cache = time.time()

    print("Without Redis: ", end_time_no_cache - start_time_no_cache, "seconds")
    print("With Redis: ", end_time_cache - start_time_cache, "seconds")

benchmark()
