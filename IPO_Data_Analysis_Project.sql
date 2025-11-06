create table ipo(
Dates date,	
IPO_Name	varchar(300),
Issue_Size_crores	 numeric(20,5),
QIB	 numeric(20,5),
HNI	 numeric(20,5),
RII	 numeric(20,5),
Total	 numeric(20,5),
Offer_Price	 numeric(20,5),
List_Price	 numeric(20,5),
Listing_Gain	 numeric(20,5),
CMP_BSE	 numeric(20,5),
CMP_NSE	 numeric(20,5),
Current_Gains numeric(20,5)
);

select * from ipo;


-- Retrieve all IPOs where the Listing Gain was positive.

select ipo_name, Listing_Gain from ipo
where Listing_Gain >0
order by Listing_Gain desc;

-- List the top 10 IPOs with the highest Issue Size.

select ipo_name, Issue_Size_crores from ipo
order by Issue_Size_crores desc
limit 10;

-- Find the average Offer Price and average List Price of all IPOs.

select avg(Offer_Price) as AVG_OFFER_PRICE, avg(List_Price) as AVG_OFFER_PRICE from ipo;

-- Show IPOs where the Current Gains are higher than the Listing Gain.

select ipo_name, Current_Gains, Listing_Gain from ipo
where Current_Gains>Listing_Gain
order by Current_Gains desc, Listing_Gain ; 

-- Find the number of IPOs launched each year/month.

SELECT 
    EXTRACT(YEAR FROM Dates) AS IPO_Year,
    TO_CHAR(Dates, 'Month') AS IPO_Month,
    COUNT(IPO_Name) AS Total_IPOs
FROM ipo
GROUP BY EXTRACT(YEAR FROM Dates), TO_CHAR(Dates, 'Month'), EXTRACT(MONTH FROM Dates)
ORDER BY IPO_Year, EXTRACT(MONTH FROM Dates);

-- Compare the average subscription (QIB, HNI, RII) for profitable vs. loss-making IPOs.

select case
when Listing_Gain>0 then 'Profitable IPO'
else 'Loss_making IPO'
end as IPO_Type,
avg(QIB) as AVG_QIB,
avg(HNI) as AVG_HNI,
avg(RII) as AVG_RII from ipo
group by 
case
when Listing_Gain>0 then 'Profitable IPO'
else 'Loss_making IPO'
end;

-- Identify IPOs where the List Price was less than the Offer Price (i.e., listed at a discount).

select ipo_name, List_Price, Offer_Price from ipo
where List_Price<Offer_Price
order by List_Price desc;

-- Find the top 5 IPOs with the highest listing gain percentage.

select ipo_name, Listing_Gain from ipo
order by Listing_Gain desc
limit 5;

-- Rank IPOs by Total Subscription and show the top performers.

select ipo_name, Total, Issue_Size_crores,
rank () over (order by Total desc) as Rank_By_Subscription
from ipo
order by Total desc;

-- Compare QIB vs HNI subscription to identify which investor category contributes more overall.

SELECT 
    ROUND(AVG(QIB), 2) AS Avg_QIB_Subscription,
    ROUND(AVG(HNI), 2) AS Avg_HNI_Subscription,
    ROUND(AVG(RII), 2) AS Avg_RII_Subscription
FROM ipo;

-- Find the year-on-year trend of average listing gains.

select ipo_name, round(avg(Listing_Gain),2) as AVG_Listing_Gain, Extract(Year from Dates) as IPO_Year
from ipo
group by ipo_name, Extract(Year from Dates)
order by Extract(Year from Dates) asc;

-- Show how average issue size has changed over time.

select ipo_name, round(avg(Issue_Size_crores),2) as AVG_Listing_Gain, to_char(Dates, 'Month') as IPO_Month, extract(year from Dates) as IPO_Year
from ipo
group by ipo_name, Extract(Month from Dates), to_char(Dates, 'Month'), extract(year from Dates)
order by Extract(Month from Dates), extract(year from Dates) asc;

-- Determine the month in which most IPOs are launched.

select TO_char(Dates, 'Month') as IPO_Month, Extract(year from Dates) as IPO_Year, count(ipo_name) as IPO
from ipo
group by TO_char(Dates, 'Month'), Extract(year from Dates)
order by Count(ipo_name) , Extract(year from Dates)asc;

-- Calculate the average Current Gain per year.

select Extract(year from Dates) as IPO_Year, round(avg(Current_Gains),2) as AVG_Current_Gain
from ipo
group by Extract(year from Dates)
order by avg(Current_Gains) desc;

-- Identify years with the most successful IPOs (based on average listing gain).

select Extract(year from Dates) as IPO_Year, round(avg(Listing_Gain),2) as AVG_Listing_Gain
from ipo
group by Extract(year from Dates)
order by avg(Listing_Gain) desc;

-- Find IPOs with Current CMP > List Price and Listing Gain > 10%.

select ipo_name, CMP_NSE, List_Price, Listing_Gain
from ipo
where CMP_NSE > List_Price and Listing_Gain >10
order by List_Price desc;

-- Calculate the average return (Current Gains) per IPO category.

SELECT 
    CASE 
        WHEN Current_Gains > 0 THEN 'Profitable IPO'
        ELSE 'Loss-making IPO'
    END AS IPO_Category,
    ROUND(AVG(Current_Gains), 2) AS Avg_Current_Gain
FROM ipo
GROUP BY 
    CASE 
        WHEN Current_Gains > 0 THEN 'Profitable IPO'
        ELSE 'Loss-making IPO'
    END;


-- Identify IPOs with negative listing gain but positive current gains (recovered later).

select ipo_name, Listing_Gain, Current_Gains
from ipo
where Listing_Gain<0 and Current_Gains>1;

-- Determine the best-performing IPO by overall gains (Listing + Current).

select ipo_name, (Listing_Gain+Current_Gains) as IPO_Performance
from ipo
order by (Listing_Gain+Current_Gains) desc;

-- Find the total investment value (sum of Issue_Size) vs. total market value (sum of CMP × Issue_Size ratio if you have share data).

SELECT 
    ROUND(SUM(Issue_Size_crores), 2) AS Total_Issue_Value,
    ROUND(SUM(Issue_Size_crores * (( (CMP_BSE + CMP_NSE) / 2 ) / Offer_Price)), 2) AS Total_Market_Value
FROM ipo;

-- Find correlation-like relationships between Issue Size and Listing Gain (you can check trend using groupings).

SELECT 
    corr(Issue_Size_crores, Listing_Gain) AS Correlation_IssueSize_ListingGain
FROM ipo;

-- Show the average subscription rate (QIB, HNI, RII) for different ranges of Issue Size.

SELECT 
    CASE
        WHEN Issue_Size_crores < 500 THEN 'Small IPO (< ₹500 Cr)'
        WHEN Issue_Size_crores BETWEEN 500 AND 2000 THEN 'Medium IPO (₹500–₹2000 Cr)'
        ELSE 'Large IPO (> ₹2000 Cr)'
    END AS Issue_Size_Range,
    ROUND(AVG(QIB), 2) AS Avg_QIB_Subscription,
    ROUND(AVG(HNI), 2) AS Avg_HNI_Subscription,
    ROUND(AVG(RII), 2) AS Avg_RII_Subscription
FROM ipo
GROUP BY 
    CASE
        WHEN Issue_Size_crores < 500 THEN 'Small IPO (< ₹500 Cr)'
        WHEN Issue_Size_crores BETWEEN 500 AND 2000 THEN 'Medium IPO (₹500–₹2000 Cr)'
        ELSE 'Large IPO (> ₹2000 Cr)'
    END
ORDER BY MIN(Issue_Size_crores);

-- Calculate average Current Gains by Offer Price range (e.g., <₹500, ₹500–₹1000, >₹1000).

SELECT 
    CASE
        WHEN Offer_Price < 500 THEN 'Low (< ₹500)'
        WHEN Offer_Price BETWEEN 500 AND 1000 THEN 'Medium (₹500–₹1000)'
        ELSE 'High (> ₹1000)'
    END AS Offer_Price_Range,
    ROUND(AVG(Current_Gains), 2) AS Avg_Current_Gains
FROM ipo
GROUP BY 
    CASE
        WHEN Offer_Price < 500 THEN 'Low (< ₹500)'
        WHEN Offer_Price BETWEEN 500 AND 1000 THEN 'Medium (₹500–₹1000)'
        ELSE 'High (> ₹1000)'
    END
ORDER BY Avg_Current_Gains DESC;

-- Identify IPOs where retail investors (RII) subscribed most compared to institutional investors (QIB).

SELECT 
    IPO_Name,
    QIB,
    RII,
    HNI,
    Issue_Size_crores,
    ROUND(RII - QIB, 2) AS Retail_Lead_Difference
FROM ipo
WHERE RII > QIB
ORDER BY Retail_Lead_Difference DESC;

-- Group IPOs by performance categories (e.g., Excellent: gain > 50%, Good: 10–50%, Poor: <10%) and count each category.

SELECT 
    CASE
        WHEN Listing_Gain > 50 THEN 'Excellent (Gain > 50%)'
        WHEN Listing_Gain BETWEEN 10 AND 50 THEN 'Good (Gain 10%–50%)'
        WHEN Listing_Gain BETWEEN 0 AND 10 THEN 'Average (Gain 0%–10%)'
        ELSE 'Poor (Loss < 0%)'
    END AS Performance_Category,
    COUNT(*) AS Total_IPOs
FROM ipo
GROUP BY 
    CASE
        WHEN Listing_Gain > 50 THEN 'Excellent (Gain > 50%)'
        WHEN Listing_Gain BETWEEN 10 AND 50 THEN 'Good (Gain 10%–50%)'
        WHEN Listing_Gain BETWEEN 0 AND 10 THEN 'Average (Gain 0%–10%)'
        ELSE 'Poor (Loss < 0%)'
    END
ORDER BY MIN(Listing_Gain) ASC;
