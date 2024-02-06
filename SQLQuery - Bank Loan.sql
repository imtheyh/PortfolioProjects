-- To find the total number of loan applications via id
Select COUNT(id) as Total_Loan_Applications
From BankLoan..BankLoanData

-- To find the Month-to-Date (MTD) Loan Applications
Select COUNT(id) as MTD_Loan_Applications
From BankLoan..BankLoanData
Where MONTH(issue_date)=12 and YEAR(issue_date)=2021

-- To find the Previous_Month-to-Date (MTD) Loan Applications
Select MONTH(issue_date) as 'Month'
From BankLoan..BankLoanData

WITH MonthlyData AS 
	(
    SELECT
        FORMAT(issue_date, 'MM') AS Month,
        COUNT(DISTINCT id) AS TotalLoans,
        LAG(COUNT(DISTINCT id)) OVER (ORDER BY FORMAT(issue_date, 'MM')) AS PreviousMonthTotal
    FROM BankLoan..BankLoanData
    GROUP BY FORMAT(issue_date, 'MM')
	)
SELECT
    Month,
    TotalLoans,
    ISNULL(TotalLoans - PreviousMonthTotal, 0) AS MonthlyChange,
	ISNULL((TotalLoans - PreviousMonthTotal) *1.00 / ISNULL(PreviousMonthTotal, 0), 0) AS MonthlyChangePercentage
FROM MonthlyData

-- to find the total loan amount
Select SUM(loan_amount) as Total_Funded_Amount
From BankLoan..BankLoanData

-- To find the Month-to-Date (MTD) loan amount disbursed
Select SUM(loan_amount) as MTD_Funded_Amount
From BankLoan..BankLoanData
Where MONTH(issue_date) = 12 and YEAR(issue_date) = 2021

-- To find the Previous_Month-to-Date (MTD) Loan Amount disbursed
WITH MonthlyData AS 
	(
    SELECT
        FORMAT(issue_date, 'MM') AS Month,
        SUM(loan_amount) AS TotalLoanAmount,
        LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT(issue_date, 'MM')) AS PreviousMonthTotal
    FROM BankLoan..BankLoanData
    GROUP BY FORMAT(issue_date, 'MM')
	)
SELECT
    Month,
    TotalLoanAmount,
    ISNULL(TotalLoanAmount - PreviousMonthTotal, 0) AS MonthlyChange,
	ISNULL((TotalLoanAmount - PreviousMonthTotal) *1.00 / ISNULL(PreviousMonthTotal, 0), 0) AS MonthlyChangePercentage
FROM MonthlyData

-- to find the total payments from borrowers
Select SUM(total_payment) as Total_Amount_Received
From BankLoan..BankLoanData

-- To find the Month-to-Date (MTD) loan amount received
Select SUM(total_payment) as MTD_Funded_Amount
From BankLoan..BankLoanData
Where MONTH(issue_date) = 12 and YEAR(issue_date) = 2021

-- To find the Previous_Month-to-Date (MTD) Loan Amount received
WITH MonthlyData AS 
	(
    SELECT
        FORMAT(issue_date, 'MM') AS Month,
        SUM(total_payment) AS TotalLoanAmountReceived,
        LAG(SUM(total_payment)) OVER (ORDER BY FORMAT(issue_date, 'MM')) AS PreviousMonthTotal
    FROM BankLoan..BankLoanData
    GROUP BY FORMAT(issue_date, 'MM')
	)
SELECT
    Month,
    TotalLoanAmountReceived,
    ISNULL(TotalLoanAmountReceived - PreviousMonthTotal, 0) AS MonthlyChange,
	ISNULL((TotalLoanAmountReceived - PreviousMonthTotal) *1.00 / ISNULL(PreviousMonthTotal, 0), 0) AS MonthlyChangePercentage
FROM MonthlyData

-- to find average interest rate
Select ROUND(AVG(int_rate),6) as Avg_Interest_Rate
From BankLoan..BankLoanData

-- To find the Month-to-Date (MTD) average interest rate
Select AVG(int_rate) as Avg_Interest_Rate
From BankLoan..BankLoanData
Where MONTH(issue_date) = 12 and YEAR(issue_date) = 2021

-- To find the Previous_Month-to-Date (MTD) average interest rate
WITH MonthlyData AS 
	(
    SELECT
        FORMAT(issue_date, 'MM') AS Month,
        AVG(int_rate) AS AverageInterestRate,
        LAG(AVG(int_rate)) OVER (ORDER BY FORMAT(issue_date, 'MM')) AS PreviousMonthTotal
    FROM BankLoan..BankLoanData
    GROUP BY FORMAT(issue_date, 'MM')
	)
SELECT
    Month,
    AverageInterestRate,
    ISNULL(AverageInterestRate - PreviousMonthTotal, 0) AS MonthlyChange,
	ISNULL((AverageInterestRate - PreviousMonthTotal) *1.00 / ISNULL(PreviousMonthTotal, 0), 0) AS MonthlyChangePercentage
FROM MonthlyData

-- to find debt-to-income ratio
Select AVG(dti) as Avg_DTI
From BankLoan..BankLoanData

-- To find the Month-to-Date (MTD) debt-to-income ratio
Select AVG(dti) as Avg_DTI
From BankLoan..BankLoanData
Where MONTH(issue_date) = 12 and YEAR(issue_date) = 2021

-- To find the Previous_Month-to-Date (MTD) dti
WITH MonthlyData AS 
	(
    SELECT
        FORMAT(issue_date, 'MM') AS Month,
        AVG(dti) AS AverageDTI,
        LAG(AVG(dti)) OVER (ORDER BY FORMAT(issue_date, 'MM')) AS PreviousMonthTotal
    FROM BankLoan..BankLoanData
    GROUP BY FORMAT(issue_date, 'MM')
	)
SELECT
    Month,
    AverageDTI,
    ISNULL(AverageDTI - PreviousMonthTotal, 0) AS MonthlyChange,
	ISNULL((AverageDTI - PreviousMonthTotal) *1.00 / ISNULL(PreviousMonthTotal, 0), 0) AS MonthlyChangePercentage
FROM MonthlyData

-- To find the application percentage of Good Loan (Current and Fully Paid)
Select 
(COUNT(CASE WHEN loan_status = 'Fully Paid' or loan_status = 'Current' THEN id END)*1.0)
/ COUNT(id) as Good_Loan_Percentage
From BankLoan..BankLoanData

-- To find the number of Good Loan applications
Select COUNT(id) as Number_of_Good_Loan
From BankLoan..BankLoanData
Where loan_status = 'Fully Paid' or loan_status = 'Current'

-- To find the Good Loan funded amount
Select SUM(loan_amount) as Good_Loan_funded_amount
From BankLoan..BankLoanData
Where loan_status = 'Fully Paid' or loan_status = 'Current'

-- To find the Good Loan amount received
Select SUM(total_payment) as Good_Loan_amount_received
From BankLoan..BankLoanData
Where loan_status = 'Fully Paid' or loan_status = 'Current'

-- To find the application percentage of Bad Loan (Charged off)
Select 
(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END)*1.0)
/ COUNT(id) as Bad_Loan_Percentage
From BankLoan..BankLoanData

-- To find the number of Bad Loan applications
Select COUNT(id) as Number_of_Bad_Loan
From BankLoan..BankLoanData
Where loan_status = 'Charged Off'

-- To find the Bad Loan funded amount
Select SUM(loan_amount) as Bad_Loan_funded_amount
From BankLoan..BankLoanData
Where loan_status = 'Charged Off'

-- To find the Bad Loan amount received
Select SUM(total_payment) as Bad_Loan_amount_received
From BankLoan..BankLoanData
Where loan_status = 'Charged Off'

-- To find the aggregation by loan_status 
SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        SUM(total_payment) AS Total_Amount_Received,
        SUM(loan_amount) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
FROM
        BankLoan..BankLoanData
GROUP BY
        loan_status

-- To find the aggregation by loan_status MTD
SELECT 
	loan_status, 
	SUM(total_payment) AS MTD_Total_Amount_Received, 
	SUM(loan_amount) AS MTD_Total_Funded_Amount 
FROM BankLoan..BankLoanData
WHERE MONTH(issue_date) = 12 
GROUP BY loan_status

-- For Tableau Dashboard - to find the monthly trends by Issue Date (Line Chart)
SELECT 
	MONTH(issue_date) AS Month_Munber, 
	DATENAME(MONTH, issue_date) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)

-- For Tableau Dashboard - to find the regional analysis by State (Filled Map)
SELECT 
	address_state AS State, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY address_state
ORDER BY address_state

-- For Tableau Dashboard - to find the Loan Term Analysis (Donut Chart)
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY term
ORDER BY term

-- For Tableau Dashboard - to find the Employee Length Analysis (Bar Chart)
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY emp_length
ORDER BY emp_length

-- For Tableau Dashboard - to find the Loan Purpose Breakdown (Bar Chart)
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY purpose
ORDER BY purpose

-- For Tableau Dashboard - to find the Home Ownership analysis (Tree Map)
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM BankLoan..BankLoanData
GROUP BY home_ownership
ORDER BY home_ownership







-- To check the updated data
Select *
From BankLoan..BankLoanData