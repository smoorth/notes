# PostgreSQL VACUUM & AUTOVACUUM Guide

## Overview

PostgreSQL's **VACUUM** and **AUTOVACUUM** are essential for database performance and health. This guide provides a structured overview, best practices, and tuning strategies.

---

## Types of VACUUM

| Type | Description | When to Use |
|------|------------|------------|
| **VACUUM** | Marks dead tuples as reusable space without reclaiming disk space. | Regular maintenance to prevent bloat. |
| **VACUUM FULL** | Rewrites the entire table, reclaiming disk space. | When excessive bloat is impacting performance. |
| **ANALYZE** | Updates statistics for the query planner. | After major inserts, updates, or deletes. |
| **AUTOVACUUM** | Background process that automatically vacuums and analyzes tables based on thresholds. | Recommended for most workloads. |

---

## Autovacuum Configuration Parameters

### Thresholds for Triggering Autovacuum

| Parameter | Description | Default Value |
|-----------|------------|---------------|
| `autovacuum_vacuum_threshold` | Minimum dead tuples before vacuum starts. | `50` |
| `autovacuum_analyze_threshold` | Minimum row changes before analyze runs. | `50` |

### Scale Factors (Relative to Table Size)

| Parameter | Description | Default Value |
|-----------|------------|---------------|
| `autovacuum_vacuum_scale_factor` | Percentage of table size before vacuum triggers. | `0.2` |
| `autovacuum_analyze_scale_factor` | Percentage of table size before analyze triggers. | `0.1` |

### Timing & Cost Settings

| Parameter | Description | Default Value |
|-----------|------------|---------------|
| `autovacuum_naptime` | Time between autovacuum runs. | `60s` |
| `autovacuum_vacuum_cost_limit` | Amount of work done before pausing vacuum. | `200` |
| `autovacuum_vacuum_cost_delay` | Pause duration before resuming work. | `20ms` |

---

## Tuning Recommendations

| Issue | Solution |
|-------|----------|
| **High bloat & slow queries** | Lower `autovacuum_vacuum_scale_factor` and increase `autovacuum_vacuum_cost_limit`. |
| **Autovacuum running too infrequently** | Decrease `autovacuum_naptime` for more frequent checks. |
| **Performance impact due to vacuum** | Increase `autovacuum_vacuum_cost_delay` to reduce CPU and I/O load. |

---

## Best Practices

1. **Enable Autovacuum** unless manually managing vacuuming.
2. **Monitor table bloat** with:

```sql
   SELECT relname, n_dead_tup, pg_size_pretty(pg_total_relation_size(relname::regclass))
   FROM pg_stat_user_tables
   ORDER BY n_dead_tup DESC
   LIMIT 10;
```

3. **Use `VACUUM FULL` sparingly**—it locks the table and is resource-intensive.
4. **Consider `pg_repack`** for online vacuuming without table locks.
5. **Adjust settings based on workload**—high-write databases may require lower thresholds.

---

## Summary

PostgreSQL's **VACUUM** and **AUTOVACUUM** are critical for database health, reducing bloat, and improving query performance. Proper configuration ensures optimal operation without manual intervention.
