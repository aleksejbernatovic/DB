-- Лабораторная работа №11. Подзапросы: несвязанные, связанные, размерность подзапроса
SET search_path TO public;


-- ============ ПО МЕСТУ НАХОЖДЕНИЯ ============

-- 1. Подзапрос в SELECT: все дисциплины и описание видов занятий по ним
--    (string_agg в PostgreSQL = GROUP_CONCAT в MySQL)
SELECT d."Name" AS discipline,
       (SELECT string_agg(ty."Name", ', ' ORDER BY ty."ID")
        FROM "DisciplineHours" dh
        INNER JOIN "Types" ty ON ty."ID" = dh."TypeID"
        WHERE dh."DisciplineID" = d."ID") AS types_description
FROM "Discipline" d
ORDER BY d."Name";

-- 2. Подзапрос во FROM: то же самое через производную таблицу
SELECT types_details."DisciplineID", d."Name" AS discipline, types_details.types_description, types_details.total_hours
FROM (
  SELECT dh."DisciplineID",
         string_agg(ty."Name", ', ' ORDER BY ty."ID") AS types_description,
         SUM(dh."Hours") AS total_hours
  FROM "DisciplineHours" dh
  INNER JOIN "Types" ty ON ty."ID" = dh."TypeID"
  GROUP BY dh."DisciplineID"
) AS types_details
INNER JOIN "Discipline" d ON d."ID" = types_details."DisciplineID"
ORDER BY types_details.total_hours DESC;

-- 3. Подзапрос в WHERE: дисциплины, у которых ровно 2 вида занятий
SELECT d."ID", d."Name"
FROM "Discipline" d
WHERE 2 = (SELECT COUNT(*) FROM "DisciplineHours" dh WHERE dh."DisciplineID" = d."ID")
ORDER BY d."Name";

-- 4. Подзапрос в WHERE с EXISTS и IN: дисциплины, где есть лабораторные или семинары
SELECT d."ID", d."Name"
FROM "Discipline" d
WHERE EXISTS (
  SELECT 1 FROM "DisciplineHours" dh
  INNER JOIN "Types" ty ON ty."ID" = dh."TypeID"
  WHERE ty."Name" IN ('Лабораторная', 'Семинар') AND dh."DisciplineID" = d."ID"
)
ORDER BY d."Name";


-- ============ ПО ТИПУ СВЯЗИ С ВНЕШНИМ ЗАПРОСОМ ============

-- 5. Связанный: студенты, у которых ещё нет ни одной оценки.
--    Подзапрос ссылается на s."StudentID" внешнего запроса и выполняется для каждой строки.
SELECT s."StudentID", s."LastName", s."FirstName"
FROM "Student" s
WHERE NOT EXISTS (
  SELECT 1 FROM "Attempt" a
  WHERE a."StudentID" = s."StudentID"
)
ORDER BY s."LastName";

-- 6. Несвязанный: то же самое. Подзапрос не зависит от внешнего и выполняется один раз.
SELECT s."StudentID", s."LastName", s."FirstName"
FROM "Student" s
WHERE s."StudentID" NOT IN (SELECT a."StudentID" FROM "Attempt" a)
ORDER BY s."LastName";


-- ============ РАЗМЕРНОСТЬ ПОДЗАПРОСА ============

-- 7. Скалярный подзапрос (1 строка × 1 столбец): группы со средним баллом выше среднего по всем оценкам
SELECT g."Name" AS group_name, ROUND(AVG(a."Grade"), 2) AS avg_grade,
       (SELECT ROUND(AVG("Grade"), 2) FROM "Attempt") AS overall_avg
FROM "Attempt" a
INNER JOIN "StudentGroup" sg ON sg."StudentID" = a."StudentID"
INNER JOIN "Group" g ON g."ID" = sg."GroupID"
GROUP BY g."Name"
HAVING AVG(a."Grade") > (SELECT AVG("Grade") FROM "Attempt")
ORDER BY avg_grade DESC;

-- 8. Подзапрос-столбец (N строк × 1 столбец) с IN: преподаватели кафедр факультета математики и информатики
SELECT t."LastName", t."FirstName", t."DepartmentID"
FROM "Teacher" t
WHERE t."DepartmentID" IN (
  SELECT dep."ID" FROM "Department" dep
  INNER JOIN "Facultys" f ON f."ID" = dep."FacultyID"
  WHERE f."Name" = 'Факультет математики и информатики'
)
ORDER BY t."LastName";

-- 9. Подзапрос-столбец с ALL и ANY.
--    ALL: студенты, у которых все оценки выше 5 (ни одной оценки 5 и ниже)
SELECT s."LastName", s."FirstName"
FROM "Student" s
WHERE EXISTS (SELECT 1 FROM "Attempt" a WHERE a."StudentID" = s."StudentID")
  AND 5 < ALL (SELECT a."Grade" FROM "Attempt" a WHERE a."StudentID" = s."StudentID")
ORDER BY s."LastName", s."FirstName";

--    ANY: студенты, у которых есть хотя бы одна десятка
SELECT s."LastName", s."FirstName"
FROM "Student" s
WHERE s."StudentID" = ANY (SELECT a."StudentID" FROM "Attempt" a WHERE a."Grade" = 10)
ORDER BY s."LastName", s."FirstName"
LIMIT 10;

-- 10. Подзапрос-строка (1 строка × N столбцов): группы той же специальности, курса и формы обучения, что и СДП-ПИ-241
SELECT g."Name", g."SpecialtyID", g."StudyYear", g."StudyFormatID"
FROM "Group" g
WHERE (g."SpecialtyID", g."StudyYear") = (
  SELECT "SpecialtyID", "StudyYear" FROM "Group" WHERE "Name" = 'СДП-ПИ-241'
);

-- 11. Подзапрос-таблица (N строк × N столбцов) во FROM: лучший студент каждой группы по среднему баллу
SELECT ranked.group_name, ranked."LastName", ranked."FirstName", ranked.avg_grade
FROM (
  SELECT g."Name" AS group_name, s."LastName", s."FirstName",
         ROUND(AVG(a."Grade"), 2) AS avg_grade,
         RANK() OVER (PARTITION BY g."ID" ORDER BY AVG(a."Grade") DESC) AS place
  FROM "Attempt" a
  INNER JOIN "Student" s ON s."StudentID" = a."StudentID"
  INNER JOIN "StudentGroup" sg ON sg."StudentID" = s."StudentID"
  INNER JOIN "Group" g ON g."ID" = sg."GroupID"
  GROUP BY g."ID", g."Name", s."StudentID", s."LastName", s."FirstName"
) AS ranked
WHERE ranked.place = 1
ORDER BY ranked.avg_grade DESC;


-- ============ ПРИМЕРЫ ЗАПРОСОВ ============

-- 12. Преподаватели, отсортированные по числу отличных оценок (9–10) за последние 100 по дате оценок
--     (как «деятели киноиндустрии по числу фильмов в топе»)
SELECT t."ID", t."LastName", t."FirstName", (
  SELECT COUNT(*) FROM "Attempt" a
  INNER JOIN (SELECT "ID" FROM "Attempt" ORDER BY "Date" DESC, "ID" DESC LIMIT 100) AS latest
    ON latest."ID" = a."ID"
  WHERE a."TeacherID" = t."ID" AND a."Grade" >= 9
) AS excellent_grades
FROM "Teacher" t
ORDER BY excellent_grades DESC
LIMIT 10;

-- 13. Группы и число студентов в них (подзапрос в SELECT, как «сериалы по количеству серий»)
SELECT g."ID", g."Name", (
  SELECT COUNT(*) FROM "StudentGroup" sg
  WHERE sg."GroupID" = g."ID"
) AS students_count
FROM "Group" g
ORDER BY students_count DESC, g."Name";

-- 14. Аналог с использованием JOIN
SELECT g."ID", g."Name", COUNT(*) AS students_count
FROM "Group" g
INNER JOIN "StudentGroup" sg ON sg."GroupID" = g."ID"
GROUP BY g."ID", g."Name"
ORDER BY students_count DESC, g."Name";

-- 15. Студенты, у которых средний балл выше среднего по их собственной группе (связанный подзапрос)
SELECT g."Name" AS group_name, s."LastName", s."FirstName",
       ROUND(AVG(a."Grade"), 2) AS student_avg
FROM "Student" s
INNER JOIN "Attempt" a ON a."StudentID" = s."StudentID"
INNER JOIN "StudentGroup" sg ON sg."StudentID" = s."StudentID"
INNER JOIN "Group" g ON g."ID" = sg."GroupID"
GROUP BY g."ID", g."Name", s."StudentID", s."LastName", s."FirstName"
HAVING AVG(a."Grade") > (
  SELECT AVG(a2."Grade") FROM "Attempt" a2
  INNER JOIN "StudentGroup" sg2 ON sg2."StudentID" = a2."StudentID"
  WHERE sg2."GroupID" = g."ID"
)
ORDER BY g."Name", student_avg DESC;
