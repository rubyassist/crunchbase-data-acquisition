create database crunchbase;

--create schema
CREATE SCHEMA crunch;

set SEARCH_PATH to crunch;

-- create table
CREATE TABLE crunch.org_sum (api_path text,
					 city_name text,
					 country text,
					 created_at int,
					 domain text,
					 homepage text,
					 name text,
				 	 num_investments int,
					 permalink text,
					 primary_role text,
					 profile_image text,
					 region_name text,
					 short_descript text,
					 stock_symb text,
					 total_fund float,
					 updated_at int,
					 uuid text,
					 web_path text);

-- copy CSV to table
COPY crunch.org_sum FROM '/Users/davidwen/crunchbase/getCompany_ALL.csv' DELIMITER ',' CSV;

select count(*) from org_sum; --335257

select DISTINCT city_name from org_sum where region_name = 'CA';

CREATE TABLE crunch.SV_CITIES (city_name CHAR(25));

COPY crunch.SV_CITIES from '/Users/davidwen/crunchbase/svcities.txt';

select distinct permalink
from org_sum INNER JOIN sv_cities as sv using (city_name)
order by permalink;  --16439 distinct (16626 non-distinct)

drop table crunch.org;

CREATE TABLE crunch.org (iindex int,
					 also_known_as text,
	api_path text,
	closed_on TIMESTAMP,
	closed_on_trust_code TEXT,
	created_at float,
	description TEXT,
	founded_on Timestamp,
	founded_on_trust_code int,
	homepage_url TEXT,
	is_closed TEXT,
	name TEXT,
	num_employees_max INT,
	num_employees_min INT,
	number_of_investments FLOAT,
	permalink TEXT,
	primary_role TEXT,
	role_company TEXT,
	role_group TEXT,
	role_investor TEXT,
	role_school TEXT,
	short_description TEXT,
	stock_exchange TEXT,
	stock_symbol TEXT,
	total_funding_usd FLOAT,
	updated_at float,
	web_path TEXT
);

COPY crunch.org FROM '/Users/davidwen/crunchbase/all_companies.csv' DELIMITER ',' CSV;

select * from org_sum where uuid = 'df6628127f970b439d3e12f64f504fbb';
select count(*) from org_sum;

select * from org where permalink = 'facebook';  -- facebook not in there because it has a city_name of null

-- COMPANY_CATEGORIES table
drop table crunch.company_categories;
create table crunch.company_categories (
	iindex int,
	category_uuid text,
	permalink text
);

COPY crunch.company_categories FROM '/Users/davidwen/crunchbase/all_company_categories.csv' DELIMITER ',' CSV;

select count(*) from company_categories; -- 41448
select * from company_categories where iindex = 100;

-- COMPANY_FUNDING_ROUNDS table
create table crunch.company_funding_rounds(
	iindex int,
	funding_round_uuid text,
	permalink text
);

COPY crunch.company_funding_rounds FROM '/Users/davidwen/crunchbase/all_company_funding_rounds.csv' DELIMITER ',' CSV;

select count(*) from company_funding_rounds;
select * from company_funding_rounds where iindex = 100;

--- CATEGORY table
drop table crunch.category;
CREATE TABLE crunch.category (created_at int,
      events_in_category int,
      name text,
        organizations_in_category int,
      products_in_category int,
      --type text,
      updated_at int,
      uuid text,
      web_path text);

COPY crunch.category FROM '/Users/davidwen/crunchbase/crunchbasedata/getCategory_ALL.csv' DELIMITER ',' CSV;

select DISTINCT organizations_in_category, name from crunch.category ORDER BY 1 DESC;
