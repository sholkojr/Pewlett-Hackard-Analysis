-- Create table with employees who are in retirement age and their titles
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	tt.title,
	tt.from_date,
	tt.to_date
INTO retirement_titles
FROM employees AS e
	INNER JOIN titles AS tt
		ON (e.emp_no = tt.emp_no)
	WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	ORDER BY emp_no;

SELECT * FROM retirement_titles

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (emp_no) emp_no,
	first_name,
	last_name,
	title
INTO ret_emp_latest_title
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

-- Create table showing retiring employee count by titles
SELECT COUNT(emp_no), title
INTO retiring_titles
FROM ret_emp_latest_title
GROUP BY title
ORDER BY COUNT(emp_no) DESC;

-- Create table showing employees eligable for mentorship program
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	d.from_date,
	d.to_date,
	tt.title	
INTO mentorship_eligability
FROM employees AS e
	INNER JOIN 
	(
		SELECT DISTINCT ON (emp_no) emp_no, 
			dept_no, 
			from_date, 
			to_date
		FROM dept_emp
		WHERE (to_date = '9999-01-01')
		ORDER BY emp_no, to_date DESC
	) AS d
		ON (e.emp_no = d.emp_no )
	INNER JOIN
	(
		SELECT DISTINCT ON (emp_no) emp_no, title
		FROM titles
		ORDER BY emp_no, to_date DESC
	) AS tt
		ON (e.emp_no = tt.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no;

-- Table showing mentor count by title and department names
SELECT COUNT(e.emp_no) AS mentor_count,
	tt.title,
	d.dept_name
INTO x_mentor_count
FROM employees AS e
	INNER JOIN 
	(
		SELECT DISTINCT ON (de.emp_no) de.emp_no, 
			de.dept_no, 
			de.from_date, 
			de.to_date, 
			dd.dept_name
		FROM dept_emp AS de
		INNER JOIN departments AS dd
			ON (de.dept_no = dd.dept_no)
		WHERE (to_date = '9999-01-01')
		ORDER BY emp_no, to_date DESC
	) AS d
		ON (e.emp_no = d.emp_no )
	INNER JOIN
	(
		SELECT DISTINCT ON (emp_no) emp_no, title
		FROM titles
		ORDER BY emp_no, to_date DESC
	) AS tt
		ON (e.emp_no = tt.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
GROUP BY tt.title, d.dept_name
ORDER BY d.dept_name, tt.title;

-- Table showing near retirement count by title and department names
SELECT COUNT(e.emp_no) AS near_ret_count,
	tt.title,
	d.dept_name
INTO x_near_ret_count
FROM employees AS e
	INNER JOIN 
	(
		SELECT DISTINCT ON (de.emp_no) de.emp_no, 
			de.dept_no, 
			de.from_date, 
			de.to_date, 
			dd.dept_name
		FROM dept_emp AS de
		INNER JOIN departments AS dd
			ON (de.dept_no = dd.dept_no)
		WHERE (to_date = '9999-01-01')
		ORDER BY emp_no, to_date DESC
	) AS d
		ON (e.emp_no = d.emp_no )
	INNER JOIN
	(
		SELECT DISTINCT ON (emp_no) emp_no, title
		FROM titles
		ORDER BY emp_no, to_date DESC
	) AS tt
		ON (e.emp_no = tt.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
GROUP BY tt.title, d.dept_name
ORDER BY d.dept_name, tt.title;

-- Table showing other employee count by title and department names
SELECT COUNT(e.emp_no) AS other_count,
	tt.title,
	d.dept_name
INTO x_other_emp_count
FROM employees AS e
	INNER JOIN 
	(
		SELECT DISTINCT ON (de.emp_no) de.emp_no, 
			de.dept_no, 
			de.from_date, 
			de.to_date, 
			dd.dept_name
		FROM dept_emp AS de
		INNER JOIN departments AS dd
			ON (de.dept_no = dd.dept_no)
		WHERE (to_date = '9999-01-01')
		ORDER BY emp_no, to_date DESC
	) AS d
		ON (e.emp_no = d.emp_no )
	INNER JOIN
	(
		SELECT DISTINCT ON (emp_no) emp_no, title
		FROM titles
		ORDER BY emp_no, to_date DESC
	) AS tt
		ON (e.emp_no = tt.emp_no)
WHERE (e.birth_date NOT BETWEEN '1952-01-01' AND '1955-12-31')
	AND (e.birth_date NOT BETWEEN '1965-01-01' AND '1965-12-31')
GROUP BY tt.title, d.dept_name
ORDER BY d.dept_name, tt.title;

-- Table showing total employee count by title and department names
SELECT COUNT(e.emp_no),
	tt.title,
	d.dept_name
INTO x_total_emp_count
FROM employees AS e
	INNER JOIN 
	(
		SELECT DISTINCT ON (de.emp_no) de.emp_no, 
			de.dept_no, 
			de.from_date, 
			de.to_date, 
			dd.dept_name
		FROM dept_emp AS de
		INNER JOIN departments AS dd
			ON (de.dept_no = dd.dept_no)
		WHERE (to_date = '9999-01-01')
		ORDER BY emp_no, to_date DESC
	) AS d
		ON (e.emp_no = d.emp_no )
	INNER JOIN
	(
		SELECT DISTINCT ON (emp_no) emp_no, title
		FROM titles
		ORDER BY emp_no, to_date DESC
	) AS tt
		ON (e.emp_no = tt.emp_no)
GROUP BY tt.title, d.dept_name
ORDER BY d.dept_name, tt.title;

-- Join the employee counts for export table
SELECT tot.dept_name,
	tot.title,
	mt.mentor_count,
	rt.near_ret_count,
	ot.other_count,
	tot.tot_count
INTO x_count_breakdown
FROM x_total_emp_count AS tot
	LEFT JOIN x_mentor_count AS mt
		ON (tot.dept_name = mt.dept_name) AND (tot.title = mt.title)
	LEFT JOIN x_near_ret_count AS rt
		ON (tot.dept_name = rt.dept_name) AND (tot.title = rt.title)
	LEFT JOIN x_other_emp_count AS ot
		ON (tot.dept_name = ot.dept_name) AND (tot.title = ot.title);