-- Лабораторная работа №8. Выборка данных: SELECT, WHERE, GROUP BY, HAVING, ORDER BY,
-- агрегатные функции (COUNT, SUM, MIN, MAX, AVG). Данные залиты скриптом Seed.sql.
SET search_path TO public;


-- ============ ВСЕ ОБЪЕКТЫ, ОТСОРТИРОВАННЫЕ ПО ПОЛЮ ============

-- Все студенты по фамилии и имени
SELECT "StudentID", "LastName", "FirstName", "MiddleName", "StartDate"
FROM "Student"
ORDER BY "LastName", "FirstName";


-- ============ КОЛИЧЕСТВО ОБЪЕКТОВ ПО КРИТЕРИЮ (GROUP BY + COUNT) ============

-- Сколько раз поставлена каждая оценка, по убыванию
SELECT "Grade", COUNT(*) AS grade_count
FROM "Attempt"
GROUP BY "Grade"
ORDER BY grade_count DESC;


-- ============ ВЫБОРКА ПО УСЛОВИЮ (WHERE, LIKE, IN, BETWEEN, OR) ============

-- Студенты с фамилией на «Ко» или «Во» — аналог LIKE '%Batman%' OR LIKE '%Dark Knight%'
SELECT "StudentID", "LastName", "FirstName"
FROM "Student"
WHERE "LastName" LIKE 'Ко%' OR "LastName" LIKE 'Во%'
ORDER BY "LastName", "FirstName"
LIMIT 5;


-- ============ АГРЕГАТЫ (SUM, MIN, MAX, AVG) И HAVING ============

-- Общая статистика по всем оценкам
SELECT COUNT(*) AS grades, MIN("Grade") AS min_grade, MAX("Grade") AS max_grade,
       ROUND(AVG("Grade"), 2) AS avg_grade, SUM("Grade") AS grade_sum
FROM "Attempt";
