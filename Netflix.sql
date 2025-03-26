CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
Select * from netflix;

Select Count(*) from netflix;

-- 1. Count the Number of Movies vs TV Shows
Select type,Count(*) from netflix group by 1;
-- 2. Find the Most Common Rating for Movies and TV Shows
Select type,rating from 
(
Select type,rating,
  Count(*),Rank() Over(
	 Partition By type Order By Count(*)DESC)as ranking From netflix Group  by 1,2)as t1
	 WHERE ranking=1;
	 
-- 3. List All Movies Released in a Specific Year (e.g., 2020)
Select * from netflix WHERE release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix.
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5.Identify the Longest Movie
Select type,duration from netflix where type = 'Movie'
Order by SPLIT_PART(duration,' ',1)::INT DESC;

-- 6.Find Content Added in the Last 5 Years
Select * from netflix where To_DATE(
	date_added,'Month DD,YYYY'
)>= CURRENT_DATE-INTERVAL '5years';

-- 7.Find All Movies/TV Shows by Director 'Rajiv Chilaka'
Select * from netflix where director = 'Rajiv Chilaka';

-- 8. List All TV Shows with More Than 5 Seasons
Select * from netflix where type = 'TV Show' 
and SPLIT_PART(duration,' ',1)::INT>5; 

-- 9. Count the Number of Content Items in Each Genre
Select UNNEST(STRING_TO_ARRAY(listed_in,','))As genre,
count(*) as total_content
from netflix
group by 1;

-- 10. Find each year and the average numbers of content release by India on netflix.
Select 
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY'))as year,
count(*) as yearly_content,
Round(
	count(*)::numeric/(Select count(*)from netflix where country = 'India')::numeric*100,
	2)as avg_content_by_India 
from netflix
where country='India'
group by 1;

-- 11. List all movies that are documentaries
Select * from netflix where listed_in LIKE'%Documentaries';

-- 12. Find all content without a director
Select * from netflix where director is NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
Select * from netflix
WHERE
casts like '%Salman Khan%' and 
release_year>
EXTRACT(YEAR from CURRENT_DATE)-10;

-- - 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
Select UNNEST(STRING_TO_ARRAY(casts,','))as actor,
Count(*) from netflix
where country ='India'
Group by 1
order by 2 DESC
limit 10;

-- 15.-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- -- content as 'Good'. Count how many items fall into each category.

With new_table
as
(
Select *,CASE
WHEN description  ILIKE '%kill%'
OR 
description  ILIKE '%violence%'
THEN 'BAD'
ELSE 'GOOD'
END  as CATEGORY
from netflix
)
Select category, Count(*)as 
total_content 
from new_table
group by 1;


