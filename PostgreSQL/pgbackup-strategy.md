# RTO & RPO Overview

## Recovery Time Objective (RTO) & Recovery Point Objective (RPO)

| Environment | Backup Strategy | RTO (Max Downtime) | RPO (Max Data Loss) | Backup Retention | Additional Backup (Weekly Dump) |
|-------------|-----------------|--------------------|---------------------|------------------|---------------------------------|
| Production (PRD) | - Daily Basebackup<br>- WAL Archiving (Continuous)<br>- Point-in-Time Recovery (PITR) | ≤ 15 minutes | ≤ 1 minute | 14 days retention | Weekly dump on Sunday |
| Staging (STG) | - Daily Basebackup<br>- WAL Archiving<br>- PITR | ≤ 1 hour | ≤ 5 minutes | 7 days retention | Weekly dump on Sunday |
| Development (DEV) | - Daily Logical Dump<br>- No WAL Archiving | ≤ 4 hours | ≤ 24 hours | 3 days retention | Weekly dump on Sunday |

### Production (PRD) Environment

**Backup Strategy:**

- Basebackups performed daily
- WAL archiving ensures continuous transaction logs for Point-in-Time Recovery (PITR)
- Basebackups are stored in object storage with a 14-day retention period
- Weekly dumps created on Sundays as a secondary backup

**RTO (Max Downtime):** ≤ 15 minutes

- In case of a failure, the system should be restored in under 15 minutes using PITR from the basebackup and WAL logs.

**RPO (Max Data Loss):** ≤ 1 minute

- Data loss is minimized with continuous WAL archiving, enabling recovery to within 1 minute of failure.

### Staging (STG) Environment

**Backup Strategy:**

- Basebackups performed daily, similar to PRD
- WAL archiving enabled, ensuring point-in-time recovery capabilities
- Retention of basebackups for 7 days
- Weekly dumps created on Sundays to capture data for restoration

**RTO (Max Downtime):** ≤ 1 hour

- While slightly less critical than PRD, the staging environment should still be restored within an hour after failure.

**RPO (Max Data Loss):** ≤ 5 minutes

- Using WAL archiving ensures that data loss is limited to no more than 5 minutes.

### Development (DEV) Environment

**Backup Strategy:**

- Logical dumps taken daily
- No WAL archiving in DEV, simplifying the environment
- Retention of logical dumps for 3 days
- Weekly dumps created on Sundays

**RTO (Max Downtime):** ≤ 4 hours

- DEV environments are less critical, but recovery within 4 hours is acceptable.

**RPO (Max Data Loss):** ≤ 24 hours

- As DEV data is less sensitive, a daily dump is sufficient to meet a maximum of 24 hours of data loss.

## Backup Overview & Weekly Dumps

### PRD

- **Daily Backup:** Full basebackup with WAL archiving and PITR capabilities
- **Retention:** 14 days
- **Weekly Dump:** Created every Sunday as a secondary measure

### STG

- **Daily Backup:** Full basebackup with WAL archiving
- **Retention:** 7 days
- **Weekly Dump:** Created every Sunday

### DEV

- **Daily Backup:** Logical dump (no WAL archiving)
- **Retention:** 3 days
- **Weekly Dump:** Created every Sunday
