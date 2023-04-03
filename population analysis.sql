use new_schema;
select * from data1;
ALTER TABLE `new_schema`.`dataset2-population.xlsx - sheet1` 
RENAME TO  `new_schema`.`data2` ;
select * from data2;

/*number of rows in our dataset */
select count(*) from data1;
select count(*) from data2;
 
 /* database for jharkhand and bihar */
 
 select * from data1 where State in('jharkhand','bihar');
 
-- calculate population of india data 2
select * from data2;
select round(sum(population),0) population from data2;

-- average grouth of india data 1
select * from data1;
select avg(growth)*100 avg_growth from data1;

-- by state 
select state, avg(growth)*100 avg_growth from data1 group by State;

-- avg sex ratio per state
 select State,round(avg(Sex_Ratio),0) avg_sexratio from data1 group by state order by avg_sexratio desc;		
 
 -- avg literacy rate 
  select State,round(avg(Literacy),0) avg_literacy from data1 group by state having avg_literacy>90 order by avg_literacy desc  ;		
  
  -- top 3 states showing highest growth 
select state, avg(growth)*100 avg_growth from data1 group by State order by avg_growth desc limit 3;

--  bottum 3 states showing growth
select state, avg(growth)*100 avg_growth from data1 group by State order by avg_growth asc limit 3;

-- bottum 3 having lowest sex ratio
 select State,round(avg(Sex_Ratio),0) avg_sexratio from data1 group by state order by avg_sexratio asc limit 3;		




 
 -- top and bottum 3 states in literacy rate
 -- 1) simple method
 select * from (
 select state, avg(literacy) avg_literacy from data1 group by State order by avg_literacy desc limit 3)a
union
select * from (
select state, avg(literacy) avg_literacy from data1 group by State order by avg_literacy asc limit 3)b ;




-- 2) a) using temp table 
 drop table if exists topstates;
 create table topstates (
 states nvarchar(255) ,
 topstates1 float);
 
insert into topstates
select state, round(avg(literacy),0) avg_literacy from data1 group by State order by avg_literacy desc;
select * from topstates order by topstates.topstates1 desc limit 3;
 
 drop table if exists bottomstates;
 create table bottomstates (
 states nvarchar(255) ,
 bottomstates1 float);
 
insert into bottomstates
select state, round(avg(literacy),0) avg_literacy from data1 group by State order by avg_literacy asc;
select * from bottomstates order by bottomstates.bottomstates1 asc limit 3;
 -- 2) b) union
select * from (
select * from topstates order by topstates.topstates1 desc limit 3)a
union
select * from (
select * from bottomstates order by bottomstates.bottomstates1 asc limit 3)b
;



-- states starting with letter a & b
select distinct state from data1 where lower(state) like 'a%' or lower(state) like 'b%';


-- second part (more advanced)

select * from data1;
select * from data2;

-- joining the tables (either you can use left or inner join)

select a.district,a.state,a.sex_ratio,b.population from data1 a inner join data2 b on a.District=b.District;
 
-- calculating total number of females 
  /*females/males = sex_ratio
 females + males = population
 females = population - males 
( population - males)  = (sex_ratio)*males
population = males(sex_ratio + 1)
males = population/sex ratio + 1 .....males 
females = population - population/(sex_ratio+1)
females = (population * (sex_ratio) / (sex_ratio +1)
*/
select d.state ,  sum(d.males) total_males, sum(d.females) total_females from
(select c.district,c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio ,b.population from data1 a inner join data2 b on a.District=b.District)c)d
group by d.state;

-- calculating total literate people 

select d.state , sum(d.total_literate) total_literate, sum(d.total_illeterate) total_illeterate, sum(d.total_population) total_population from
(select c.district , c.state , round(c.literacy_ratio*c.population) total_literate, round((1-c.literacy_ratio)*c.Population) total_illeterate , c.Population total_population from
(select a.district,a.state,a.Literacy/100 Literacy_ratio,b.population from data1 a inner join data2 b on a.District=b.District)c)d
group by d.state;


-- population in previous census 

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m ;


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from data2)z) r on q.keyy=r.keyy)g;

-- window output top 3 districts from each state with highest literacy rate


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from data1) a

where a.rnk in (1,2,3) order by state;


