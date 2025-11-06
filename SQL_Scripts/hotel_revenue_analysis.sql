CREATE DATABASE hotel_revenue_db;

 use hotel_revenue_db



 /*Purpose:
 This query consolidates hotel booking data from 2018, 2019, and 2020 into a single dataset,
 then calculates the total revenue and meal cost for each hotel per year.

  Insight:
  Provides a yearly comparison of hotel revenues and meal costs, helping identify 
  trends over time and evaluate which hotels generated the highest returns.*/
 with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select arrival_date_year,hotel,
  round(sum((stays_in_weekend_nights+stays_in_week_nights)* adr ),2)as revenue,round(sum(Cost),2) as meal_cost
 from hotels
left join dbo.[meal_cost$]
 on hotels.meal=dbo.[meal_cost$].meal
 left join dbo.[market_segment$]
 on hotels.market_segment=dbo.[market_segment$].market_segment
 group by arrival_date_year,hotel

 /*  Purpose:
   Identify the top 5 hotels with the highest total revenue across the years 2018–2020.  

   Insight:
   Highlights which hotels generated the most revenue overall, enabling quick recognition 
   of top-performing properties and supporting strategic decisions on investment and resource allocation. */
with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select top 5 arrival_date_year,hotel,
  round(sum((stays_in_weekend_nights+stays_in_week_nights)* adr ),2) as revenue
 from hotels
 group by arrival_date_year,hotel
 order by revenue desc;


/*    Purpose:
     Analyze hotel revenue by month across all years to identify seasonal trends and performance variations.  

    Insight:
     Reveals peak and low-revenue months for each hotel, helping in forecasting demand, 
     optimizing pricing strategies, and planning staffing or promotions around high and low seasons.  */

with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select arrival_date_month,hotel,
  round(sum((stays_in_weekend_nights+stays_in_week_nights)* adr ),2) as revenue
 from hotels
 group by arrival_date_month,hotel
 order by revenue desc;
 
 
/*    Purpose:
     Calculate hotel revenue after applying market segment-specific discounts to measure 
     the true financial contribution of each customer segment.  

    Insight:
	Identifies which market segments remain most profitable even after discounts, 
    helping evaluate discount strategies and understand customer segments that drive sustainable revenue. */
 with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select dbo.[market_segment$].market_segment,discount,
  round((sum((stays_in_weekend_nights+stays_in_week_nights)* adr ))*(1-discount),2) as RevenueAfterDiscount
 from hotels
 left join dbo.[market_segment$]
 on hotels.market_segment=dbo.[market_segment$].market_segment
 group by dbo.[market_segment$].market_segment,discount
 order by RevenueAfterDiscount desc;
  


/*   Purpose:
    Summarize the total number of adults, children, and babies staying at each hotel 
    across all years to analyze guest demographics.  
  
   Insight:
    Provides a clear view of the customer composition per hotel, helping identify 
    whether hotels cater more to families, solo travelers, or adult groups, 
    which supports targeted marketing and service adjustments. */
  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotel,
  sum(adults)as SumAdults,sum(children)as SumChildren,sum(babies)as SumBabies
  from hotels
  group by hotel



/*   Purpose:
    Calculate the cancellation rate (CancelRatPct) and confirmation rate (ConfRatPct) 
    for each hotel across all years.  

    Insight:
     Highlights the proportion of canceled versus confirmed bookings per hotel, 
     providing key insights into booking reliability, customer behavior, and potential revenue risks.  */
  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotel,
  round((cast(sum(case when is_canceled=1 then 1 else 0 end) as float)/count(*))*100,2)as CancelRatPct,
  round((100-(cast(sum(case when is_canceled=1 then 1 else 0 end) as float)/count(*))*100),2) as ConfRatPct
  from hotels
  group by hotel


/*    Purpose:
      Calculate the booking cancellation rate and the average lead time (days between booking and arrival) 
      for each hotel.  

    Insight:
     Shows how early guests typically book and how this correlates with cancellation patterns, 
     helping hotels anticipate demand, manage cancellations, and refine booking policies.    */

  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotel,
  round((cast(sum(case when is_canceled=1 then 1 else 0 end) as float)/count(*))*100,2)as CancelRatPct,
  round(avg(lead_time),1) as lead_time
  from hotels
  group by hotel
  order by lead_time desc


/*   Purpose:
    Analyze the distribution and total cost of different meal types booked by hotel guests.  

   Insight:
   Identifies the most frequently chosen meals and their associated costs, 
   helping hotels understand guest preferences and evaluate the profitability of meal offerings.   */

  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotels.meal,
  count(*)as MealCount,round(sum(Cost),2)as meal_cost$
  from hotels
  left join dbo.[meal_cost$]
  on hotels.meal=dbo.[meal_cost$].meal
  group by hotels.meal
  order by  meal_cost$ desc

 /*    Purpose:
      Determine the most frequently ordered meal for each market segment by identifying 
      the meal with the highest order count per segment.  

     Insight:
      Reveals the preferred meal choice of different customer segments, 
      helping hotels tailor menu offerings, design promotions, and improve customer satisfaction 
      based on segment-specific preferences.  */
  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] ),

  order_counts as(select hotels.meal,hotels.market_segment,count(*)as OrderCount
  from hotels
  group by hotels.meal,hotels.market_segment),
  
  max_count as(
  select market_segment,max(OrderCount) as MaxOrder
  from  order_counts
  group by market_segment)
  
 select order_counts.meal,order_counts.market_segment,order_counts.OrderCount
 from order_counts 
  inner join max_count
  on order_counts.market_segment=max_count.market_segment 
     and
     order_counts.OrderCount=max_count.MaxOrder
  order by order_counts.OrderCount desc


 /*    Purpose:
      Measure the percentage of canceled reservations that included special requests 
      versus those without any special requests.  

     Insight:
      Helps understand whether guests who make special requests are more or less likely to cancel, 
      offering valuable input for customer service strategy and cancellation risk assessment.   */
 with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select reservation_status,
  round((cast((sum(case  when total_of_special_requests>0 then 1 else 0 end)) as float)/count(*))*100,2) as total_of__special_requests,
  round(((cast((sum(case  when total_of_special_requests=0 then 1 else 0 end))as float)/count(*)) )*100,2) as total_of_without_special_requests
  from hotels
  where reservation_status='Canceled'
  group by reservation_status
 
 
/*    Purpose:
     Calculate the average number of required car parking spaces per hotel, 
     considering only bookings where parking was requested.  

    Insight:
     Provides an understanding of guest parking demand at each hotel, 
     supporting decisions on parking capacity planning and infrastructure improvements.    */
  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotel,
   case when (sum(case when required_car_parking_spaces >0 then 1 else 0 end ))=0 then 0 
   else sum(required_car_parking_spaces)*1.0/sum(case when required_car_parking_spaces >0 then 1 else 0 end ) end as avg_required_car_parking_spaces
  from hotels
  group by hotel

  
 /*   Purpose:
      Calculate the total and maximum number of car parking spaces required by guests for each hotel.  

    Insight:
      Identifies overall parking demand and peak requirements per hotel, 
      helping management assess whether existing parking facilities are sufficient 
      and plan for future capacity needs. */
  with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select hotel,
   sum(required_car_parking_spaces)as total_required_car_parking_spaces,max(required_car_parking_spaces)as Max_required_car_parking_spaces
  from hotels
  group by hotel
  order by total_required_car_parking_spaces desc



/*  
Purpose:
    Improve query performance for hotel revenue analysis by creating indexes 
    on columns frequently used in joins, grouping, and filtering operations.  

Insight:
    These indexes help SQL Server quickly locate data for each hotel and year 
    without scanning the entire tables, especially when combining multiple years of data.
*/
CREATE INDEX idx_hotel_year_2018 ON dbo.['2018$'](hotel, arrival_date_year);

CREATE INDEX idx_hotel_year_2019 ON dbo.['2019$'](hotel, arrival_date_year);
 
CREATE INDEX idx_hotel_year_2020 ON dbo.['2020$'](hotel, arrival_date_year);

/*  
Purpose:
    Calculate the total revenue generated by each hotel for every year 
    by combining booking data from 2018, 2019, and 2020.  

Insight:
    This view allows easy comparison of yearly hotel performance 
    and helps identify which hotels are consistently generating the most revenue.
*/


 create view vw_hotel_revenue as
 with hotels as
 (
 select * from dbo.['2018$']
 union
 select * from dbo.['2019$']
 union
 select * from dbo.['2020$'] )
  select arrival_date_year,hotel,
  round(sum((stays_in_weekend_nights+stays_in_week_nights)* adr ),2)as revenue
 from hotels
 group by arrival_date_year,hotel
 
 /*  
Purpose:
    Retrieve summarized hotel revenue data from the created view.  

Insight:
    Allows quick visualization of total revenue per hotel per year 
    without re-running the full union and aggregation query each time.
*/

-- Display the results of the hotel revenue view

 SELECT * FROM vw_hotel_revenue;






 
