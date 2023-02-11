/* 1. Фамилия, имя, почта, номер телефона, полный адрес всех студентов*/

SELECT p.last_name, p.first_name, c.phone, c.email, a.country, a.city,  a.street,  a.house
FROM persons p INNER JOIN adress a on p.adress_id = a.adress_id
INNER JOIN contacts c on p.person_id = c.persons_id
ORDER BY p.last_name, p.first_name;

/* 2. Среднее время, потраченное каждым студентом на уроках */

SELECT at.last_name, at.first_name, c.email, at.average_time
FROM (SELECT p.last_name, p.first_name, p.person_id,
       CASE
           WHEN round(avg(l.time),2) is null THEN 0
           ELSE round(avg(l.time),2)
       END average_time
    FROM persons p LEFT JOIN person_lesson pl on p.person_id = pl.person_id
        LEFT JOIN lessons l on pl.lesson_id = l.lesson_id
    WHERE p.role = 'student'
    GROUP BY p.last_name, p.first_name) as at
    INNER JOIN contacts c ON at.person_id = c.persons_id
ORDER BY at.last_name, at.first_name;


/*3. Есть ли в группе однофамильцы */
SELECT last_name, count(*) num_persons
FROM persons
GROUP BY last_name
HAVING num_persons > 1
ORDER BY num_persons, last_name;

/* 4. Есть ли в группе тезки */
SELECT first_name, count(*) num_persons
FROM persons
GROUP BY first_name
HAVING num_persons > 1
ORDER BY num_persons, first_name;

/* 5. Имя, фамилия, контактные данные студент-ки посетив-шей больше всего уроков */

with count_lessons as (SELECT p.person_id, count(*) num_lessons
FROM person_lesson pl INNER JOIN persons p on pl.person_id = p.person_id
WHERE p.role = 'student'
GROUP BY p.person_id)
SELECT p.first_name, p.last_name, c.phone, c.email
FROM persons p INNER JOIN contacts c ON p.person_id = c.persons_id
INNER JOIN count_lessons cl on cl.person_id = p.person_id
WHERE cl.num_lessons IN (SELECT max(num_lessons) FROM count_lessons)
ORDER BY p.last_name, p.first_name;


/* 6. Фамилия, имя, контактные данные учителя, потратившего больше всего времени на уроках */

with time_aggr as (SELECT pl.person_id as person_id, sum(l.time) as time
      FROM person_lesson pl INNER JOIN lessons l on pl.lesson_id = l.lesson_id
      GROUP BY pl.person_id)
SELECT p.first_name, p.last_name, c.email, c.phone
FROM time_aggr
    INNER JOIN persons p ON time_aggr.person_id = p.person_id
    INNER JOIN contacts c on p.person_id = c.persons_id
    WHERE p.role = 'teacher' and time IN (SELECT max(time) from time_aggr)
    ORDER BY p.last_name, p.first_name;


/* 7. Вывести для каждого студента дополнительные материалы для пройденных им уроков */
SELECT p.first_name, p.last_name, l.lesson_name, m.material_name, m.material_type, m.material_source
FROM persons p INNER JOIN person_lesson pl ON p.person_id = pl.person_id
INNER JOIN material_lesson ml on pl.lesson_id = ml.lesson_id
INNER JOIN material m on ml.material_id = m.material_id
INNER JOIN lessons l on pl.lesson_id = l.lesson_id
WHERE p.role = 'student'
ORDER BY p.last_name,p.first_name,ml.lesson_id;


/* 8. Вывести для каждого студента уникальные материалы для пройденных им уроков */
SELECT DISTINCT p.first_name, p.last_name, m.material_name, m.material_type, m.material_source
FROM persons p INNER JOIN person_lesson pl ON p.person_id = pl.person_id
INNER JOIN material_lesson ml on pl.lesson_id = ml.lesson_id
INNER JOIN material m on ml.material_id = m.material_id
WHERE p.role = 'student'
ORDER BY p.last_name,p.first_name;



/* 9. Вывести страну, в которой живут студенты, посетившие больше всего уроков */
SELECT a.country
FROM adress a INNER JOIN persons p on a.adress_id = p.adress_id
INNER JOIN person_lesson pl on p.person_id = pl.person_id
WHERE p.role = 'student'
GROUP BY country
HAVING count(lesson_id) IN (SELECT count(lesson_id)
                            FROM adress a INNER JOIN persons p
                            ON a.adress_id = p.adress_id
                                INNER JOIN person_lesson pl
                                ON p.person_id = pl.person_id
                            WHERE p.role = 'student'
                            GROUP BY country
                            ORDER BY count(lesson_id) DESC
                            LIMIT 1);

/* 10. Вывести город, в котором студенты больше всего потратили время на посещение уроков */


with city_time as (SELECT a.city, sum(l.time) sum_time
      FROM adress a INNER JOIN persons p ON a.adress_id = p.adress_id
          INNER JOIN person_lesson pl ON p.person_id = pl.person_id
          INNER JOIN lessons l on pl.lesson_id = l.lesson_id
      WHERE p.role = 'student'
      GROUP BY city)
SELECT city
FROM city_time
WHERE sum_time IN (SELECT max(sum_time) FROM city_time);
