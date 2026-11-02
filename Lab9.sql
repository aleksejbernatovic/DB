-- Лабораторная работа №9. Объединения (UNION) и соединения (JOIN)
-- Пара таблиц для примеров JOIN: A = "Teacher" (преподаватели), B = "Degrees" (учёные степени).
-- Ключ соединения: "Teacher"."DegreeID" = "Degrees"."ID".
-- Есть преподаватели без степени (нет пары в B) и степень, которой нет ни у кого (нет пары в A).
SET search_path TO public;


-- ============ ОБЪЕДИНЕНИЯ ============

-- 1. UNION (DISTINCT): все фамилии преподавателей и студентов без повторов
(SELECT "LastName" FROM "Teacher")
UNION DISTINCT
(SELECT "LastName" FROM "Student")
ORDER BY "LastName";

-- 2. UNION ALL: то же, но с повторами — видно, сколько раз встречается каждая фамилия
(SELECT "LastName" FROM "Teacher")
UNION ALL
(SELECT "LastName" FROM "Student")
ORDER BY "LastName";

-- 3. UNION ALL разных сущностей: общий список людей с ролью
(SELECT "LastName", "FirstName", 'Преподаватель' AS role FROM "Teacher")
UNION ALL
(SELECT "LastName", "FirstName", 'Студент' FROM "Student")
ORDER BY "LastName", "FirstName";


-- ============ СОЕДИНЕНИЯ ============

-- 4. CROSS JOIN: все сочетания формы обучения и вида финансирования (3 × 2 = 6 строк). Три равносильные записи:
SELECT * FROM "StudyFormat", "FundingType";
SELECT * FROM "StudyFormat" JOIN "FundingType" ON TRUE;   -- в PostgreSQL JOIN без условия не пишется, нужен ON TRUE
SELECT * FROM "StudyFormat" CROSS JOIN "FundingType";

-- 5. INNER JOIN ... ON: преподаватели со степенью
SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
INNER JOIN "Degrees" d ON t."DegreeID" = d."ID";

-- 6. INNER JOIN ... USING: студенты и их группы (у таблиц общий столбец "StudentID")
SELECT "StudentID", s."LastName", s."FirstName", sg."GroupID"
FROM "Student" s
INNER JOIN "StudentGroup" sg USING ("StudentID")
ORDER BY "StudentID";

-- 7. LEFT JOIN: все преподаватели, у кого нет степени — NULL
SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
LEFT JOIN "Degrees" d ON t."DegreeID" = d."ID";

SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
LEFT OUTER JOIN "Degrees" d ON t."DegreeID" = d."ID";

-- 7а. LEFT JOIN через подзапрос
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t INNER JOIN "Degrees" d ON t."DegreeID" = d."ID"
)
UNION
(
  SELECT t."LastName", t."FirstName", NULL FROM "Teacher" t
  WHERE NOT EXISTS (SELECT 1 FROM "Degrees" d WHERE d."ID" = t."DegreeID")
)
ORDER BY "LastName";

-- 8. LEFT JOIN ... WHERE B.Key IS NULL: преподаватели без степени
SELECT t."LastName", t."FirstName"
FROM "Teacher" t
LEFT OUTER JOIN "Degrees" d ON t."DegreeID" = d."ID"
WHERE d."ID" IS NULL;

-- 8а. То же через подзапрос
SELECT t."LastName", t."FirstName" FROM "Teacher" t
WHERE NOT EXISTS (SELECT 1 FROM "Degrees" d WHERE d."ID" = t."DegreeID");

-- 9. RIGHT JOIN: все степени и их обладатели, степень без обладателей — с NULL
SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
RIGHT JOIN "Degrees" d ON t."DegreeID" = d."ID";

SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
RIGHT OUTER JOIN "Degrees" d ON t."DegreeID" = d."ID";

-- 9а. RIGHT JOIN через подзапрос
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t INNER JOIN "Degrees" d ON t."DegreeID" = d."ID"
)
UNION
(
  SELECT NULL, NULL, d."Name" FROM "Degrees" d
  WHERE NOT EXISTS (SELECT 1 FROM "Teacher" t WHERE t."DegreeID" = d."ID")
)
ORDER BY degree;

-- 10. RIGHT JOIN ... WHERE A.Key IS NULL: степени, которых нет ни у одного преподавателя
SELECT d."Name" AS degree
FROM "Teacher" t
RIGHT JOIN "Degrees" d ON t."DegreeID" = d."ID"
WHERE t."ID" IS NULL;

-- 10а. То же через подзапрос
SELECT d."Name" AS degree FROM "Degrees" d
WHERE NOT EXISTS (SELECT 1 FROM "Teacher" t WHERE t."DegreeID" = d."ID");

-- 11. FULL OUTER JOIN: и преподаватели без степени, и степени без преподавателей
SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
FULL OUTER JOIN "Degrees" d ON t."DegreeID" = d."ID";

-- 11а. То же как в MySQL: LEFT JOIN UNION RIGHT JOIN
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t LEFT JOIN "Degrees" d ON t."DegreeID" = d."ID"
)
UNION
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t RIGHT JOIN "Degrees" d ON t."DegreeID" = d."ID"
);

-- 12. FULL OUTER JOIN ... WHERE A.Key IS NULL OR B.Key IS NULL: только строки без пары
SELECT t."LastName", t."FirstName", d."Name" AS degree
FROM "Teacher" t
FULL OUTER JOIN "Degrees" d ON t."DegreeID" = d."ID"
WHERE t."ID" IS NULL OR d."ID" IS NULL;

-- 12а. То же через UNION
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t LEFT JOIN "Degrees" d ON t."DegreeID" = d."ID"
  WHERE d."ID" IS NULL
)
UNION
(
  SELECT t."LastName", t."FirstName", d."Name" AS degree
  FROM "Teacher" t RIGHT JOIN "Degrees" d ON t."DegreeID" = d."ID"
  WHERE t."ID" IS NULL
);

-- 13. SELF JOIN: пары групп одной специальности, идущих курс за курсом (как «пары чисел по возрастанию»)
SELECT first."Name" AS group_name, first."StudyYear",
       second."Name" AS next_course_group, second."StudyYear"
FROM "Group" first, "Group" second
WHERE second."SpecialtyID" = first."SpecialtyID"
  AND second."StudyFormatID" = first."StudyFormatID"
  AND second."StudyYear" = first."StudyYear" + 1
ORDER BY first."StudyYear";


-- ============ ПРИМЕРЫ ЗАПРОСОВ ============

-- 14. Сколько людей на каждом факультете: студенты и преподаватели (UNION ALL внутри подзапроса)
SELECT f."Name" AS faculty, SUM(people.count) AS people_total
FROM (
  (SELECT sp."FacultyID", COUNT(*) AS count
   FROM "Student" s
   JOIN "StudentGroup" sg ON sg."StudentID" = s."StudentID"
   JOIN "Group" g ON g."ID" = sg."GroupID"
   JOIN "Specialties" sp ON sp."ID" = g."SpecialtyID"
   GROUP BY sp."FacultyID")
  UNION ALL
  (SELECT dep."FacultyID", COUNT(*)
   FROM "Teacher" t JOIN "Department" dep ON dep."ID" = t."DepartmentID"
   GROUP BY dep."FacultyID")
) AS people
INNER JOIN "Facultys" f ON f."ID" = people."FacultyID"
GROUP BY f."Name"
ORDER BY people_total DESC;

-- 15. Студенты, у которых ещё нет ни одной оценки (первокурсники)
SELECT s."LastName", s."FirstName", g."Name" AS group_name
FROM "Student" s
LEFT JOIN "Attempt" a ON a."StudentID" = s."StudentID"
INNER JOIN "StudentGroup" sg ON sg."StudentID" = s."StudentID"
INNER JOIN "Group" g ON g."ID" = sg."GroupID"
WHERE a."ID" IS NULL
ORDER BY g."Name", s."LastName";

-- 16. Средний балл по группам, лучшие сверху
SELECT g."Name" AS group_name, ROUND(AVG(a."Grade"), 2) AS avg_grade, COUNT(*) AS grades
FROM "Attempt" a
INNER JOIN "StudentGroup" sg ON sg."StudentID" = a."StudentID"
INNER JOIN "Group" g ON g."ID" = sg."GroupID"
GROUP BY g."Name"
ORDER BY avg_grade DESC;

-- 17. Пересдачи: студент, дисциплина, вид аттестации, первая оценка и оценка на пересдаче
SELECT s."LastName", s."FirstName", d."Name" AS discipline, at."Name" AS assessment,
       first."Grade" AS first_grade, retake."Grade" AS retake_grade, retake."Date" AS retake_date
FROM "Attempt" retake
INNER JOIN "Attempt" first ON first."AssessmentID" = retake."AssessmentID"
                          AND first."StudentID" = retake."StudentID"
                          AND first."Date" < retake."Date"
INNER JOIN "Student" s ON s."StudentID" = retake."StudentID"
INNER JOIN "Assessment" asm ON asm."ID" = retake."AssessmentID"
INNER JOIN "AssessmentType" at ON at."ID" = asm."AssessmentTypeID"
INNER JOIN "GroupDiscipline" gd ON gd."ID" = asm."GroupDisciplineID"
INNER JOIN "Discipline" d ON d."ID" = gd."DisciplineID"
ORDER BY retake."Date" DESC
LIMIT 10;

-- 18. Нагрузка преподавателей в часах: сумма часов по всем группам и видам занятий, которые они ведут
SELECT t."LastName", t."FirstName", COUNT(*) AS classes, SUM(dh."Hours") AS hours
FROM "Teacher" t
INNER JOIN "Teaches" tc ON tc."TeacherID" = t."ID"
INNER JOIN "GroupDiscipline" gd ON gd."ID" = tc."GroupDisciplineID"
INNER JOIN "DisciplineHours" dh ON dh."DisciplineID" = gd."DisciplineID" AND dh."TypeID" = tc."TypeID"
GROUP BY t."ID", t."LastName", t."FirstName"
ORDER BY hours DESC;

-- 19. Аттестации, по которым ещё нет оценок (текущий семестр)
SELECT g."Name" AS group_name, d."Name" AS discipline, at."Name" AS assessment, gd."SemesterNum"
FROM "Assessment" asm
LEFT JOIN "Attempt" a ON a."AssessmentID" = asm."ID"
INNER JOIN "AssessmentType" at ON at."ID" = asm."AssessmentTypeID"
INNER JOIN "GroupDiscipline" gd ON gd."ID" = asm."GroupDisciplineID"
INNER JOIN "Group" g ON g."ID" = gd."GroupID"
INNER JOIN "Discipline" d ON d."ID" = gd."DisciplineID"
WHERE a."ID" IS NULL
ORDER BY g."Name", d."Name";

-- 20. Однофамильцы в одной группе (SELF JOIN, как «члены съёмочной группы с одинаковым годом рождения»)
SELECT g."Name" AS group_name, s1."LastName", s1."FirstName" AS first, s2."FirstName" AS second
FROM "Student" s1
INNER JOIN "Student" s2 ON s2."LastName" = s1."LastName" AND s2."StudentID" > s1."StudentID"
INNER JOIN "StudentGroup" sg1 ON sg1."StudentID" = s1."StudentID"
INNER JOIN "StudentGroup" sg2 ON sg2."StudentID" = s2."StudentID" AND sg2."GroupID" = sg1."GroupID"
INNER JOIN "Group" g ON g."ID" = sg1."GroupID"
ORDER BY g."Name", s1."LastName";

-- 21. Сколько пар однофамильцев в каждой группе
SELECT g."Name" AS group_name, COUNT(*) AS namesake_pairs
FROM "Student" s1
INNER JOIN "Student" s2 ON s2."LastName" = s1."LastName" AND s2."StudentID" > s1."StudentID"
INNER JOIN "StudentGroup" sg1 ON sg1."StudentID" = s1."StudentID"
INNER JOIN "StudentGroup" sg2 ON sg2."StudentID" = s2."StudentID" AND sg2."GroupID" = sg1."GroupID"
INNER JOIN "Group" g ON g."ID" = sg1."GroupID"
GROUP BY g."Name"
ORDER BY namesake_pairs DESC;
