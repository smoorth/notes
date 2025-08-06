/*
Step-by-Step Example
1. Set Up the Table
We’ll start with a table to store products and their vector embeddings.
*/

-- Enable the pgvector extension
CREATE EXTENSION vector;

-- Create a table for storing products and their vector embeddings
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,           -- Product name
    description TEXT,             -- Product description
    embedding VECTOR(5)           -- 5-dimensional vector representing the product
);
/*
2. Insert Sample Products
Insert some products into the database with their vector embeddings (the embeddings could come from a machine learning model trained to represent product similarities).
*/

-- Insert sample data (product embeddings are hypothetical)
INSERT INTO products (name, description, embedding) VALUES
('Laptop A', 'High-performance laptop with 16GB RAM and 1TB SSD', '[0.9, 1.2, 0.8, 0.5, 0.7]'),
('Laptop B', 'Budget-friendly laptop with 8GB RAM and 256GB SSD', '[0.5, 0.8, 0.4, 0.3, 0.9]'),
('Gaming Laptop', 'Gaming laptop with RTX 3080 and 32GB RAM', '[1.0, 1.5, 0.9, 0.8, 0.6]'),
('Smartphone A', 'Latest smartphone with OLED display and 5G support', '[0.3, 0.4, 1.0, 0.7, 1.2]'),
('Smartphone B', 'Affordable smartphone with 4G and HD display', '[0.2, 0.3, 0.9, 0.6, 1.1]');

/*
3. Query for Similarity Search
When a customer views a product (e.g., "Laptop A"), we want to recommend similar products by finding the nearest neighbors based on their vector embeddings. For example:
*/

-- Find the top 3 products most similar to "Laptop A" based on the embedding
SELECT id, name, description
FROM products
ORDER BY embedding <-> '[0.9, 1.2, 0.8, 0.5, 0.7]' -- The embedding of "Laptop A"
LIMIT 3;

/*
4. AI in Action: Explain the Magic
Here’s what’s happening:

Embedding Generation: A machine learning model (like a product catalog embedding model) generates a vector for each product. These embeddings capture the semantic similarity between products.
Products with similar features (like RAM, price range, or use case) have embeddings that are close in vector space.
Nearest Neighbor Search: The query uses the <-> operator (which computes the distance, e.g., cosine similarity or Euclidean distance) to find the products that are closest to the input embedding.

5. Add a Customer Query Example
Let’s make it even more interactive. Suppose a customer enters "Gaming Laptop with RTX 3070" in the search bar. We generate an embedding for their query and find the closest matching products.
*/

-- Assume the embedding for the query "Gaming Laptop with RTX 3070" is '[1.0, 1.4, 0.8, 0.7, 0.6]'
SELECT id, name, description
FROM products
ORDER BY embedding <-> '[1.0, 1.4, 0.8, 0.7, 0.6]' -- Query embedding
LIMIT 3;
