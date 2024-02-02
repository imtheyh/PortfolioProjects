-- Insert a column for stock name
Alter table PortfolioProject..NVDA
Add Stock varchar(10)

UPDATE PortfolioProject..NVDA
SET Stock = 'NVDA'

-- Insert a column for previous day closing price
Select "Close", LAG("Close",1,0) Over (Order by Date) as Prev_Day_Close
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Prev_Day_Close float

WITH CTE AS 
(
    SELECT
        Prev_Day_Close,
        LAG("Close") OVER (ORDER BY "Date") AS New_Prev_Day_Close
    FROM PortfolioProject.dbo.NVDA
)
UPDATE CTE
SET Prev_Day_Close = New_Prev_Day_Close

-- Insert a column for change in price
Select "Close", "Close" - Prev_Day_Close as Change_in_Price
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Change_in_Price float

UPDATE PortfolioProject..NVDA
SET Change_in_Price = "Close" - Prev_Day_Close 

-- Insert a column for Percent change in price
Select "Close", Prev_Day_Close, Change_in_Price, Change_in_Price / Prev_Day_Close*100 as Percent_Change_in_Price
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Percent_Change_in_Price float

UPDATE PortfolioProject..NVDA
SET Percent_Change_in_Price = Change_in_Price / Prev_Day_Close*100

-- Insert a column for previous day closing volume
Select Volume, LAG(Volume,1,0) Over (Order by Date) as Prev_Day_Volume
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Prev_Day_Volume float

WITH CTE AS 
(
    SELECT
        Prev_Day_Volume,
        LAG(Volume) OVER (ORDER BY "Date") AS New_Prev_Day_Volume
    FROM PortfolioProject.dbo.NVDA
)
UPDATE CTE
SET Prev_Day_Volume = New_Prev_Day_Volume

-- Insert a column for change in volume
Select Volume, Volume - Prev_Day_Volume as Change_in_Volume
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Change_in_Volume float

UPDATE PortfolioProject..NVDA
SET Change_in_Volume = Volume - Prev_Day_Volume

-- Insert a column for Percent change in Volume
Select Volume, Prev_Day_Volume, Change_in_Volume, COALESCE(Change_in_Volume / NULLIF(Prev_Day_Volume, 0) * 100, 0) as Percent_Change_in_Volume
From PortfolioProject..NVDA

Alter table PortfolioProject..NVDA
Add Percent_Change_in_Volume float

UPDATE PortfolioProject..NVDA
SET Percent_Change_in_Volume = COALESCE(Change_in_Volume / NULLIF(Prev_Day_Volume, 0) * 100, 0)


-- to check the updated data
Select *
From PortfolioProject..NVDA
Order by Date