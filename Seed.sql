-- Тестовые данные. Скрипт можно запускать повторно: сначала всё очищается.
SET search_path TO public;

TRUNCATE "Attempt", "Assessment", "AssessmentType", "Teaches", "Teacher", "Degrees", "Positions",
  "GroupDiscipline", "DisciplineHours", "Types", "Discipline", "StudentGroup", "Group", "Student",
  "Status", "FundingType", "StudyFormat", "Specialties", "Department", "Facultys" RESTART IDENTITY;

SELECT setseed(0.42);

-- Тестовые оценки и зачисления — в прошлом, поэтому проверку «не раньше сегодня» на время заливки выключаем
ALTER TABLE "Attempt" DISABLE TRIGGER "attempt_date_not_past";
ALTER TABLE "Student" DISABLE TRIGGER "student_start_not_past";

-- Справочники

INSERT INTO "Facultys" ("ID", "Name") VALUES
  (1, 'Факультет математики и информатики'),
  (2, 'Физико-технический факультет'),
  (3, 'Факультет экономики и управления');

INSERT INTO "Department" ("ID", "Name", "FacultyID") VALUES
  (1, 'Кафедра современных технологий программирования', 1),
  (2, 'Кафедра системного программирования и компьютерной безопасности', 1),
  (3, 'Кафедра математического анализа, дифференциальных уравнений и алгебры', 1),
  (4, 'Кафедра фундаментальной и прикладной математики', 1),
  (5, 'Кафедра общей физики', 2),
  (6, 'Кафедра экономики и управления', 3);

INSERT INTO "Specialties" ("ID", "Name", "FacultyID") VALUES
  (1, 'Программная инженерия', 1),
  (2, 'Информатика', 1),
  (3, 'Математика', 1),
  (4, 'Компьютерная безопасность', 1),
  (5, 'Физика', 2),
  (6, 'Экономика', 3);

INSERT INTO "StudyFormat" ("ID", "Name") VALUES (1, 'Очная'), (2, 'Заочная'), (3, 'Вечерняя');
INSERT INTO "FundingType" ("ID", "Type") VALUES (1, 'Бюджет'), (2, 'Платное');
INSERT INTO "Status" ("ID", "Status") VALUES (1, 'Учится'), (2, 'Академический отпуск'), (3, 'Отчислен'), (4, 'Выпускник');
INSERT INTO "Types" ("ID", "Name") VALUES (1, 'Лекция'), (2, 'Практика'), (3, 'Лабораторная'), (4, 'Семинар');

INSERT INTO "Positions" ("ID", "Name") VALUES
  (1, 'Ассистент'), (2, 'Преподаватель'), (3, 'Старший преподаватель'),
  (4, 'Доцент'), (5, 'Профессор'), (6, 'Заведующий кафедрой');

INSERT INTO "Degrees" ("ID", "Name") VALUES
  (1, 'Кандидат физико-математических наук'), (2, 'Доктор физико-математических наук'),
  (3, 'Кандидат технических наук'), (4, 'Кандидат экономических наук');

INSERT INTO "AssessmentType" ("ID", "Name") VALUES
  (1, 'Экзамен'), (2, 'Зачёт'), (3, 'Дифференцированный зачёт'), (4, 'Курсовая работа');

-- Преподаватели

INSERT INTO "Teacher" ("ID", "FirstName", "MiddleName", "LastName", "DepartmentID", "PositionID", "DegreeID") VALUES
  (1,  'Виктор',  'Михайлович',     'Пецевич',    1, 3, NULL),
  (2,  'Юлия',    'Вальдемаровна',  'Гуща',       1, 3, NULL),
  (3,  'Андрей',  'Николаевич',     'Ковальчук',  1, 4, 3),
  (4,  'Ольга',   'Ивановна',       'Савицкая',   2, 4, 1),
  (5,  'Сергей',  'Петрович',       'Лукашевич',  2, 6, 3),
  (6,  'Наталья', 'Викторовна',     'Климович',   2, 3, NULL),
  (7,  'Игорь',   'Александрович',  'Романович',  3, 5, 2),
  (8,  'Елена',   'Сергеевна',      'Жук',        4, 4, 1),
  (9,  'Дмитрий', 'Олегович',       'Мельник',    4, 1, NULL),
  (10, 'Татьяна', 'Николаевна',     'Гринкевич',  5, 4, 1),
  (11, 'Марина',  'Андреевна',      'Ярошевич',   6, 4, 4),
  (12, 'Павел',   'Игоревич',       'Новик',      1, 1, NULL);

-- Дисциплины и часы

INSERT INTO "Discipline" ("ID", "Name", "DepartmentID") VALUES
  (1,  'Базы данных', 1),
  (2,  'Программирование на C++', 1),
  (3,  'Веб-программирование', 1),
  (4,  'Объектно-ориентированное программирование', 1),
  (5,  'Компьютерные сети', 2),
  (6,  'Криптографические методы защиты информации', 2),
  (7,  'Операционные системы', 2),
  (8,  'Математический анализ', 3),
  (9,  'Линейная алгебра и аналитическая геометрия', 4),
  (10, 'Дискретная математика', 4),
  (11, 'Теория вероятностей и математическая статистика', 4),
  (12, 'Физика', 5),
  (13, 'Экономическая теория', 6);

-- вид занятий: 1 лекция, 2 практика, 3 лабораторная, 4 семинар
INSERT INTO "DisciplineHours" ("DisciplineID", "TypeID", "Hours") VALUES
  (1, 1, 34), (1, 3, 34),
  (2, 1, 32), (2, 3, 48),
  (3, 1, 24), (3, 3, 40),
  (4, 1, 32), (4, 3, 32),
  (5, 1, 30), (5, 3, 30),
  (6, 1, 32), (6, 2, 16), (6, 3, 16),
  (7, 1, 30), (7, 3, 30),
  (8, 1, 48), (8, 2, 48),
  (9, 1, 34), (9, 2, 34),
  (10, 1, 32), (10, 2, 32),
  (11, 1, 32), (11, 2, 32),
  (12, 1, 32), (12, 2, 16), (12, 3, 16),
  (13, 1, 24), (13, 4, 24);

-- Группы: название по году поступления, курс на осень 2026

INSERT INTO "Group" ("ID", "Name", "SpecialtyID", "StudyYear", "StudyFormatID") VALUES
  (1, 'СДП-ПИ-231',  1, 4, 1),
  (2, 'СДП-ПИ-241',  1, 3, 1),
  (3, 'СДП-ПИ-251',  1, 2, 1),
  (4, 'СДП-ПИ-261',  1, 1, 1),
  (5, 'СДП-ИНФ-241', 2, 3, 1),
  (6, 'СДП-МАТ-251', 3, 2, 1),
  (7, 'СДП-КБ-231',  4, 4, 1),
  (8, 'ЗФК-ПИ-241',  1, 3, 2);

-- Студенты: по 10 в очной группе, 8 в заочной; ID = номер группы * 100 + номер в группе

CREATE TEMP TABLE gen ON COMMIT DROP AS
SELECT g."ID" AS gid, g."StudyYear" AS year, g."StudyFormatID" AS format, n,
       random() < 0.5 AS male,
       1 + floor(random() * 15)::int AS fi,
       1 + floor(random() * 10)::int AS pi,
       1 + floor(random() * 18)::int AS si,
       random() AS r_fund, random() AS r_status
FROM "Group" g, generate_series(1, CASE WHEN g."StudyFormatID" = 2 THEN 8 ELSE 10 END) n;

INSERT INTO "Student" ("StudentID", "FirstName", "MiddleName", "LastName", "FundingTypeID", "StartDate", "StatusID")
SELECT gid * 100 + n,
  CASE WHEN male
    THEN (ARRAY['Алексей','Андрей','Артём','Владислав','Дмитрий','Евгений','Иван','Кирилл','Максим','Никита','Павел','Сергей','Егор','Илья','Денис'])[fi]
    ELSE (ARRAY['Анастасия','Анна','Валерия','Дарья','Екатерина','Елизавета','Мария','Полина','Виктория','Ксения','Алина','Юлия','Ольга','Диана','София'])[fi]
  END,
  CASE WHEN male
    THEN (ARRAY['Александрович','Андреевич','Викторович','Дмитриевич','Игоревич','Николаевич','Олегович','Сергеевич','Владимирович','Петрович'])[pi]
    ELSE (ARRAY['Александровна','Андреевна','Викторовна','Дмитриевна','Игоревна','Николаевна','Олеговна','Сергеевна','Владимировна','Петровна'])[pi]
  END,
  CASE WHEN male
    THEN (ARRAY['Ковалёв','Новик','Жук','Ковальчук','Савицкий','Мельник','Шевчук','Бондаренко','Климович','Лукашевич','Сидоров','Гринкевич','Козлов','Романович','Павлюкевич','Ярошевич','Карпович','Волков'])[si]
    ELSE (ARRAY['Ковалёва','Новик','Жук','Ковальчук','Савицкая','Мельник','Шевчук','Бондаренко','Климович','Лукашевич','Сидорова','Гринкевич','Козлова','Романович','Павлюкевич','Ярошевич','Карпович','Волкова'])[si]
  END,
  CASE WHEN r_fund < (CASE WHEN format = 2 THEN 0.2 ELSE 0.7 END) THEN 1 ELSE 2 END,
  make_date(2027 - year, 9, 1),
  CASE WHEN r_status < 0.05 THEN 2 ELSE 1 END
FROM gen;

INSERT INTO "StudentGroup" ("StudentID", "GroupID") SELECT gid * 100 + n, gid FROM gen;

-- Учебный план: (специальность, дисциплина, семестр). Группе достаются семестры до текущего включительно.

CREATE TEMP TABLE plan ON COMMIT DROP AS
SELECT * FROM (VALUES
  -- Программная инженерия и Информатика
  (1, 8, 1), (1, 9, 1), (1, 10, 1), (1, 2, 1),
  (1, 8, 2), (1, 4, 2), (1, 12, 2),
  (1, 11, 3), (1, 13, 3),
  (1, 7, 4),
  (1, 1, 5), (1, 3, 5),
  (1, 5, 6),
  (1, 6, 7),
  -- Математика
  (3, 8, 1), (3, 9, 1), (3, 10, 1),
  (3, 8, 2), (3, 2, 2),
  (3, 11, 3), (3, 12, 3),
  (3, 13, 4),
  -- Компьютерная безопасность
  (4, 8, 1), (4, 9, 1), (4, 10, 1), (4, 2, 1),
  (4, 8, 2), (4, 4, 2), (4, 12, 2),
  (4, 11, 3), (4, 7, 3),
  (4, 5, 4),
  (4, 1, 5), (4, 6, 5),
  (4, 3, 6),
  (4, 13, 7)
) v(spec, disc, sem)
UNION ALL
SELECT 2, disc, sem FROM (VALUES (8,1),(9,1),(10,1),(2,1),(8,2),(4,2),(12,2),(11,3),(13,3),(7,4),(1,5),(3,5),(5,6)) v(disc, sem);

INSERT INTO "GroupDiscipline" ("GroupID", "DisciplineID", "SemesterNum")
SELECT g."ID", p.disc, p.sem
FROM "Group" g JOIN plan p ON p.spec = g."SpecialtyID"
WHERE p.sem <= 2 * g."StudyYear" - 1;

-- Кто какой вид занятий ведёт по дисциплине (у всех групп одинаково)

INSERT INTO "Teaches" ("GroupDisciplineID", "TeacherID", "TypeID")
SELECT gd."ID", t.teacher, t.type
FROM "GroupDiscipline" gd
JOIN (VALUES
  (1, 1, 1), (1, 3, 2),                  -- Базы данных: лекции Пецевич, лабы Гуща
  (2, 1, 2), (2, 3, 2), (2, 3, 12),      -- C++: Гуща, лабы ещё Новик
  (3, 1, 2), (3, 3, 2),                  -- Веб: Гуща
  (4, 1, 3), (4, 3, 1),                  -- ООП: лекции Ковальчук, лабы Пецевич
  (5, 1, 5), (5, 3, 6),
  (6, 1, 4), (6, 2, 4), (6, 3, 6),
  (7, 1, 5), (7, 3, 6),
  (8, 1, 7), (8, 2, 9),
  (9, 1, 8), (9, 2, 9),
  (10, 1, 8), (10, 2, 8),
  (11, 1, 8), (11, 2, 9),
  (12, 1, 10), (12, 2, 10), (12, 3, 10),
  (13, 1, 11), (13, 4, 11)
) t(disc, type, teacher) ON t.disc = gd."DisciplineID";

-- Аттестации: экзамен (3 попытки) везде, зачёт (2 попытки) там, где есть лабораторные

INSERT INTO "Assessment" ("AssessmentTypeID", "MaxAttempts", "GroupDisciplineID")
SELECT 1, 3, gd."ID" FROM "GroupDiscipline" gd
UNION ALL
SELECT 2, 2, gd."ID" FROM "GroupDiscipline" gd
WHERE EXISTS (SELECT 1 FROM "DisciplineHours" dh WHERE dh."DisciplineID" = gd."DisciplineID" AND dh."TypeID" = 3);

-- Оценки только за прошедшие семестры. Сессия: январь (нечётный семестр) или июнь (чётный).
-- Ставит лектор; зачёт за две недели до экзамена; ~12% двоек и троек с пересдачей через 10 дней.

CREATE TEMP TABLE first_try ON COMMIT DROP AS
SELECT a."ID" AS assessment, sg."StudentID" AS student, a."MaxAttempts" AS max_attempts,
  (SELECT min(t."TeacherID") FROM "Teaches" t WHERE t."GroupDisciplineID" = gd."ID" AND t."TypeID" = 1) AS teacher,
  CASE WHEN gd."SemesterNum" % 2 = 1
    THEN make_date(2027 - g."StudyYear" + (gd."SemesterNum" + 1) / 2, 1, 12 + gd."DisciplineID")
    ELSE make_date(2027 - g."StudyYear" + gd."SemesterNum" / 2, 6, 8 + gd."DisciplineID")
  END - CASE WHEN a."AssessmentTypeID" = 2 THEN 14 ELSE 0 END AS day,
  CASE WHEN random() < 0.12 THEN 2 + floor(random() * 2) ELSE 4 + floor(random() * 7) END::int AS grade
FROM "Assessment" a
JOIN "GroupDiscipline" gd ON gd."ID" = a."GroupDisciplineID"
JOIN "Group" g ON g."ID" = gd."GroupID"
JOIN "StudentGroup" sg ON sg."GroupID" = g."ID"
WHERE gd."SemesterNum" < 2 * g."StudyYear" - 1;

INSERT INTO "Attempt" ("AssessmentID", "StudentID", "TeacherID", "Grade", "Date")
SELECT assessment, student, teacher, grade, day FROM first_try ORDER BY day, assessment, student;

INSERT INTO "Attempt" ("AssessmentID", "StudentID", "TeacherID", "Grade", "Date", "Note")
SELECT assessment, student, teacher, 4 + floor(random() * 5)::int, day + 10, 'Пересдача'
FROM first_try WHERE grade < 4 AND max_attempts >= 2
ORDER BY day, assessment, student;

-- Счётчики ID после вставки с явными номерами

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT table_name, column_name FROM information_schema.columns
           WHERE table_schema = 'public' AND is_identity = 'YES' LOOP
    EXECUTE format('SELECT setval(pg_get_serial_sequence(%L, %L), coalesce(max(%I), 1), max(%I) IS NOT NULL) FROM %I',
                   format('%I', r.table_name), r.column_name, r.column_name, r.column_name, r.table_name);
  END LOOP;
END $$;

ALTER TABLE "Attempt" ENABLE TRIGGER "attempt_date_not_past";
ALTER TABLE "Student" ENABLE TRIGGER "student_start_not_past";
