with a as (
select client_id, submission_date_s3, sum(subsession_length)/3600 as thours,sum(active_ticks)*5/3600 as ahours
from main_summary
where app_name='Firefox'
and normalized_channel='release'
and substring(app_version,1,2)='56'
and submission_date_s3 >= '20170925'
and subsession_length<=86400 and  subsession_length>=0 and active_ticks>=0
and sample_id='42'
group by 1,2
),
b as (
select submission_date_s3 as date, avg(thours) as thrs56,avg(ahours) as ahrs56 from a group by 1 order by  1
),
c as (
select client_id, submission_date_s3, sum(subsession_length)/3600 as thours,sum(active_ticks)*5/3600 as ahours
from main_summary
where app_name='Firefox'
and submission_date_s3 >= '20170925'
and normalized_channel='release'
and subsession_length<=86400 and  subsession_length>=0 and active_ticks>=0
and sample_id='42'
group by 1,2
),
d as (select submission_date_s3 as date, avg(thours) as thrsAll,avg(ahours) as ahrsAll from c group by 1 order by 1)
select
d.date, thrsAll,thrs56,ahrsAll, ahrs56 from b join d on b.date=d.date
order by 1
