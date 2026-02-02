CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.appointments;
CREATE TABLE staging.appointments (
    appointment_uid TEXT PRIMARY KEY,
    appointment_id INTEGER,
    appointment_date DATE,
    appointment_age_group TEXT,
    appointment_type TEXT,
    appointment_status TEXT,
    wait_time_days INTEGER,
    consultation_duration_minutes FLOAT,
    staff_role TEXT,
    clinic_location TEXT,
    outcome_category TEXT,
    source_period TEXT
);

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' 
  AND table_name = 'appointments' 
  AND column_name = 'appointment_date';

SELECT COUNT(*) 
FROM staging.appointments;
SELECT * 
FROM staging.appointments;

CREATE SCHEMA IF NOT EXISTS warehouse;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'warehouse';

-- =====================================================
-- DIMTABLE: DIM_DATE
-- =====================================================

CREATE TABLE warehouse.dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    day INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name TEXT NOT NULL,
    quarter INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

INSERT INTO warehouse.dim_date (
    date_id,
    full_date,
    year,
    month,
    month_name,
    day,
    day_of_week,
    day_name,
    quarter,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(appointment_date, 'YYYYMMDD')::INTEGER AS date_id,
    appointment_date AS full_date,
    EXTRACT(YEAR FROM appointment_date)::INTEGER AS year,
    EXTRACT(MONTH FROM appointment_date)::INTEGER AS month,
    TO_CHAR(appointment_date, 'Month') AS month_name,
    EXTRACT(DAY FROM appointment_date)::INTEGER AS day,
    EXTRACT(ISODOW FROM appointment_date)::INTEGER AS day_of_week,
    TO_CHAR(appointment_date, 'Day') AS day_name,
    EXTRACT(QUARTER FROM appointment_date)::INTEGER AS quarter,
    CASE
        WHEN EXTRACT(ISODOW FROM appointment_date) IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM staging.appointments
WHERE appointment_date IS NOT NULL;

SELECT COUNT(*) 
FROM warehouse.dim_date;

SELECT *
FROM warehouse.dim_date
ORDER BY full_date
LIMIT 10;

SELECT full_date, day_name, is_weekend
FROM warehouse.dim_date
WHERE is_weekend = TRUE
LIMIT 5;

-- =====================================================
-- DIMTABLE: DIM_APPOINTMENT_TYPE
-- =====================================================

CREATE TABLE warehouse.dim_appointment_type (
    appointment_type_id SERIAL PRIMARY KEY,
    appointment_type TEXT NOT NULL UNIQUE
);

SELECT DISTINCT appointment_type
FROM staging.appointments
ORDER BY appointment_type;

INSERT INTO warehouse.dim_appointment_type (appointment_type)
SELECT DISTINCT
       TRIM(INITCAP(appointment_type)) AS appointment_type
FROM staging.appointments
WHERE appointment_type IS NOT NULL;

SELECT *
FROM warehouse.dim_appointment_type
ORDER BY appointment_type_id;

-- =====================================================
-- DIMTABLE: DIM_APPOINTMENT_STATUS
-- =====================================================

CREATE TABLE warehouse.dim_appointment_status (
    appointment_status_id SERIAL PRIMARY KEY,
    appointment_status TEXT NOT NULL UNIQUE
);

SELECT DISTINCT appointment_status
FROM staging.appointments
ORDER BY appointment_status;

INSERT INTO warehouse.dim_appointment_status (appointment_status)
SELECT DISTINCT
       TRIM(INITCAP(appointment_status)) AS appointment_status
FROM staging.appointments
WHERE appointment_status IS NOT NULL;

SELECT *
FROM warehouse.dim_appointment_status
ORDER BY appointment_status_id;

-- =====================================================
-- DIMTABLE: DIM_STAFF_ROLL
-- =====================================================

CREATE TABLE warehouse.dim_staff_role (
    staff_role_id SERIAL PRIMARY KEY,
    staff_role TEXT NOT NULL UNIQUE
);

SELECT DISTINCT staff_role
FROM staging.appointments
ORDER BY staff_role;

INSERT INTO warehouse.dim_staff_role (staff_role)
SELECT DISTINCT
       TRIM(INITCAP(staff_role)) AS staff_role
FROM staging.appointments
WHERE staff_role IS NOT NULL;

SELECT *
FROM warehouse.dim_staff_role
ORDER BY staff_role_id;

-- =====================================================
-- DIMTABLE: DIM_CLINIC_LOCATION
-- =====================================================

CREATE TABLE warehouse.dim_clinic_location (
    clinic_location_id SERIAL PRIMARY KEY,
    clinic_location TEXT NOT NULL UNIQUE
);

SELECT DISTINCT clinic_location
FROM staging.appointments
ORDER BY clinic_location;

INSERT INTO warehouse.dim_clinic_location (clinic_location)
SELECT DISTINCT
       TRIM(INITCAP(clinic_location)) AS clinic_location
FROM staging.appointments
WHERE clinic_location IS NOT NULL;

SELECT *
FROM warehouse.dim_clinic_location
ORDER BY clinic_location_id;

-- =====================================================
-- DIMTABLE: DIM_AGE_GROUP
-- =====================================================

CREATE TABLE warehouse.dim_patient_age_group (
    age_group_id SERIAL PRIMARY KEY,
    age_group TEXT NOT NULL UNIQUE
);

SELECT DISTINCT appointment_age_group
FROM staging.appointments
ORDER BY appointment_age_group;

INSERT INTO warehouse.dim_patient_age_group (age_group)
SELECT DISTINCT
       TRIM(appointment_age_group) AS age_group
FROM staging.appointments
WHERE appointment_age_group IS NOT NULL;

SELECT *
FROM warehouse.dim_patient_age_group
ORDER BY age_group_id;

-- =====================================================
-- DIMTABLE: DIM_OUTCOME_CATEGORY
-- =====================================================

CREATE TABLE warehouse.dim_outcome_category (
    outcome_id SERIAL PRIMARY KEY,
    outcome_category TEXT NOT NULL UNIQUE
);

SELECT DISTINCT outcome_category
FROM staging.appointments
ORDER BY outcome_category;

INSERT INTO warehouse.dim_outcome_category (outcome_category)
SELECT DISTINCT
       TRIM(INITCAP(outcome_category)) AS outcome_category
FROM staging.appointments
WHERE outcome_category IS NOT NULL
  AND outcome_category <> '';

SELECT *
FROM warehouse.dim_outcome_category
ORDER BY outcome_id;

-- =====================================================
-- Table: FACT_APPOINTMENT
-- =====================================================

CREATE TABLE warehouse.fact_appointments (
    fact_appointment_id SERIAL PRIMARY KEY,

    appointment_uid TEXT NOT NULL,

    date_id INT NOT NULL,
    age_group_id INT NOT NULL,
    appointment_type_id INT NOT NULL,
    appointment_status_id INT NOT NULL,
    staff_role_id INT NOT NULL,
    clinic_location_id INT NOT NULL,
    outcome_id INT,

    wait_time_days INT,
    consultation_duration_minutes INT,

    CONSTRAINT fk_date
        FOREIGN KEY (date_id) REFERENCES warehouse.dim_date(date_id),

    CONSTRAINT fk_age_group
        FOREIGN KEY (age_group_id) REFERENCES warehouse.dim_patient_age_group(age_group_id),

    CONSTRAINT fk_appointment_type
        FOREIGN KEY (appointment_type_id) REFERENCES warehouse.dim_appointment_type(appointment_type_id),

    CONSTRAINT fk_appointment_status
        FOREIGN KEY (appointment_status_id) REFERENCES warehouse.dim_appointment_status(appointment_status_id),

    CONSTRAINT fk_staff_role
        FOREIGN KEY (staff_role_id) REFERENCES warehouse.dim_staff_role(staff_role_id),

    CONSTRAINT fk_clinic_location
        FOREIGN KEY (clinic_location_id) REFERENCES warehouse.dim_clinic_location(clinic_location_id),

    CONSTRAINT fk_outcome
        FOREIGN KEY (outcome_id) REFERENCES warehouse.dim_outcome_category(outcome_id)
);

INSERT INTO warehouse.fact_appointments (
    appointment_uid,
    date_id,
    age_group_id,
    appointment_type_id,
    appointment_status_id,
    staff_role_id,
    clinic_location_id,
    outcome_id,
    wait_time_days,
    consultation_duration_minutes
)
SELECT
    s.appointment_uid,
    d.date_id,
    ag.age_group_id,
    at.appointment_type_id,
    ast.appointment_status_id,
    sr.staff_role_id,
    cl.clinic_location_id,
    oc.outcome_id,
    s.wait_time_days,
    s.consultation_duration_minutes
FROM staging.appointments s
JOIN warehouse.dim_date d
    ON s.appointment_date = d.full_date
JOIN warehouse.dim_patient_age_group ag
    ON s.appointment_age_group = ag.age_group
JOIN warehouse.dim_appointment_type at
    ON TRIM(INITCAP(s.appointment_type)) = at.appointment_type
JOIN warehouse.dim_appointment_status ast
    ON TRIM(INITCAP(s.appointment_status)) = ast.appointment_status
JOIN warehouse.dim_staff_role sr
    ON TRIM(INITCAP(s.staff_role)) = sr.staff_role
JOIN warehouse.dim_clinic_location cl
    ON TRIM(INITCAP(s.clinic_location)) = cl.clinic_location
LEFT JOIN warehouse.dim_outcome_category oc
    ON TRIM(INITCAP(s.outcome_category)) = oc.outcome_category;

SELECT COUNT(*) 
FROM staging.appointments;
SELECT COUNT(*) 
FROM warehouse.fact_appointments;

SELECT *
FROM warehouse.fact_appointments
WHERE date_id IS NULL
   OR appointment_type_id IS NULL
   OR appointment_status_id IS NULL;


SELECT *
FROM warehouse.fact_appointments
LIMIT 10;


