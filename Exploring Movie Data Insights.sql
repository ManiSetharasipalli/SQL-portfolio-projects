use movies;
-- Create the Movies table
CREATE TABLE Movies (
    Movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    release_date DATE,
    genres VARCHAR(255),
    original_language VARCHAR(10),
    IMDB_Rating DECIMAL(3, 1),
    vote_count BIGINT,
    budget BIGINT,
    collections BIGINT,
    runtime INT
);

-- Query 1: Top-Rated Movies

SELECT
	ROW_NUMBER() OVER(ORDER BY imdb_rating DESC, vote_count DESC) AS Rating_Rank,
	title,
	release_date,
	genres,
	original_language,
	IMDB_Rating,
	vote_count
FROM movies
WHERE IMDB_Rating >= 7;

-- Query 2: Movies per Genre
SELECT
    genres,
    COUNT(title) AS no_of_movies,
    MAX(budget) AS maximum_budget,
    MAX(collections) AS maximum_collections
FROM movies
GROUP BY genres
ORDER BY no_of_movies DESC;

-- Query 3: Language Distribution
SELECT
    original_language,
    COUNT(movie_id) AS no_of_movies
FROM movies
GROUP BY original_language
ORDER BY no_of_movies DESC;

-- Query 4: Movie Releases as per Date
SELECT
    MONTH(release_date) AS Monthly_releases,
    COUNT(title) AS No_of_movies,
    SUM(collections) - SUM(budget) AS Profits_as_per_month
FROM movies
GROUP BY MONTH(release_date)
ORDER BY COUNT(title) DESC, Profits_as_per_month DESC;

-- Query 5: Number of Days Movies Have Been Released
SELECT
    title,
    No_of_days,
    ROUND(No_of_days / 30) AS No_of_months,
    ROUND(No_of_days / 365, 1) AS No_of_years
FROM (
    SELECT
        title,
        DATEDIFF(NOW(), release_date) AS No_of_days
    FROM movies
) Days;

-- Query 6: Movies as per Runtime
SELECT
    title,
    runtime,
    CONCAT(FLOOR(runtime / 60), 'h ', runtime % 60, 'm') AS runtime_in_hours
FROM movies
ORDER BY runtime DESC;

-- Query 7: Genre with Longest Runtime
SELECT
    DENSE_RANK() OVER(ORDER BY average_runtime DESC) AS 'rank',
    genres,
    average_runtime
FROM (
    SELECT
        genres,
        ROUND(AVG(runtime)) AS average_runtime
    FROM movies
    GROUP BY genres
) avg_runtime;

-- Query 8: Top 10 Highest Collection Movies
SELECT
    title,
    ROUND(collections / 1000000) AS collections_in_millions
FROM movies
ORDER BY collections_in_millions DESC
LIMIT 10;

-- Query 9: Top 10 Most Profitable Movies and Their Genres
WITH Highest_profits_movies AS (
    SELECT
        title,
        genres,
        ROUND((collections - budget) / 1000000) AS profit_in_millions,
        ROUND(budget / 1000000) AS budget_in_millions
    FROM movies
    ORDER BY profit_in_millions DESC
    LIMIT 10
)
-- How many times do the profits exceed the budget
SELECT
    *,
    ROUND(profit_in_millions / budget_in_millions) AS no_of_times
FROM Highest_profits_movies
ORDER BY no_of_times DESC;

-- 10. Are High-Releasing Months Also the Most Profitable
SELECT 
    MONTH(release_date) AS Monthly_releases,
    COUNT(title) AS No_of_movies,
    ROUND((SUM(collections) - SUM(budget))/1000000) AS Profits_as_per_month_in_millions
FROM movies
GROUP BY MONTH(release_date)
ORDER BY No_of_movies DESC, Profits_as_per_month_in_millions DESC;
