-- Лаба №14. Влияние индекса на отчёт об оценках.
-- Запустите весь скрипт в DBeaver. Сравните Execution Time в двух планах.

BEGIN;
SET LOCAL jit = off;

-- Временный набор: 160 копий оценок, у каждой копии свои ID студентов.
CREATE TEMP TABLE lab14_attempt_demo AS
SELECT a."StudentID" + copies.n * 1000000::bigint AS "StudentID",
       a."Grade"
FROM public."Attempt" a
CROSS JOIN generate_series(0, 159) AS copies(n);

ANALYZE lab14_attempt_demo;

-- ДО. Для каждого студента из шести копий считаем попытки и средний балл.
EXPLAIN (ANALYZE, BUFFERS)
SELECT s."StudentID" + copies.n * 1000000::bigint AS student_id,
       s."LastName",
       stats.attempts,
       stats.failed_attempts,
       stats.avg_grade
FROM public."Student" s
CROSS JOIN generate_series(0, 5) AS copies(n)
CROSS JOIN LATERAL (
    SELECT COUNT(*) AS attempts,
           COUNT(*) FILTER (WHERE a."Grade" < 4) AS failed_attempts,
           ROUND(AVG(a."Grade"), 2) AS avg_grade
    FROM lab14_attempt_demo a
    WHERE a."StudentID" = s."StudentID" + copies.n * 1000000::bigint
) stats;

CREATE INDEX lab14_attempt_demo_student_idx ON lab14_attempt_demo ("StudentID");

-- ПОСЛЕ. Тот же запрос на том же наборе данных.
EXPLAIN (ANALYZE, BUFFERS)
SELECT s."StudentID" + copies.n * 1000000::bigint AS student_id,
       s."LastName",
       stats.attempts,
       stats.failed_attempts,
       stats.avg_grade
FROM public."Student" s
CROSS JOIN generate_series(0, 5) AS copies(n)
CROSS JOIN LATERAL (
    SELECT COUNT(*) AS attempts,
           COUNT(*) FILTER (WHERE a."Grade" < 4) AS failed_attempts,
           ROUND(AVG(a."Grade"), 2) AS avg_grade
    FROM lab14_attempt_demo a
    WHERE a."StudentID" = s."StudentID" + copies.n * 1000000::bigint
) stats;

ROLLBACK;
