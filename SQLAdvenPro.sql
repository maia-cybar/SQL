use AdventureWorks2019;

-- Q1
--a. 
Select *
From Person.Person p
Where p.FirstName ='Ken'
	and p.LastName = 'Sánchez'
 
Select 
	pe.EmailAddress  
From Person.Person p 
	Inner Join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
	Inner Join Person.EmailAddress pe on pe.BusinessEntityID = p.BusinessEntityID
Where e.BusinessEntityID=176
 
--part b
Update Person.EmailAddress
Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
Where BusinessEntityID = 1


---q2
--part a 
Select 
	Rank() Over (Order by Hiredate asc) as 'Seniority'
	,* 
From HumanResources.Employee
 
--part b 
Select 
	Rank() Over(Order by Hiredate asc) as 'Seniority'
	,DATEDIFF(Day,HireDate,'2014-03-03') as 'DaysEmployed'
	,DATEDIFF(Month,HireDate,'2014-03-03') as 'MonthsEmployed'
	,DATEDIFF(Year,HireDate,'2014-03-03') as 'YearsEmployed'
	,* 
from HumanResources.Employee
 
 
Declare @CurrentDate  date 
set @CurrentDate= '2014-03-03'
 
Select 
	Rank() Over(Order by Hiredate asc) as 'Seniority'
	,DATEDIFF(Day,HireDate,@CurrentDate) as 'DaysEmployed'
	,DATEDIFF(Month,HireDate,@CurrentDate) as 'MonthsEmployed'
	,DATEDIFF(Year,HireDate,@CurrentDate) as 'YearsEmployed'
	,* 
from HumanResources.Employee



---Q3

--part a 
Select 
	distinct Name as RegionName
From Sales.SalesTerritory
 
--part b.
Select 
	distinct st.Name as RegionName
	,Format(Sum(TotalDue),'C0') as TotalDue
From Sales.SalesTerritory st
	Inner Join Sales.SalesOrderHeader soh on soh.TerritoryID = st.TerritoryID
Group by st.Name
 
--part c
Select 
	distinct (st.Name )as RegionName
	,Concat(p.FirstName,' ',p.LastName) as CustomerName
	,Format(Sum(TotalDue),'C0') as TotalDue
From Sales.SalesTerritory st
	Inner Join Sales.SalesOrderHeader soh on soh.TerritoryID = st.TerritoryID
	Inner Join Sales.Customer c on c.CustomerID = soh.CustomerID
	Inner Join Person.Person p on p.BusinessEntityID = c.PersonID
Group by 
	st.Name
	,Concat(p.FirstName,' ',p.LastName) 
 
--part d 
Select 
	distinct st.Name as RegionName
	,Concat(p.FirstName,' ',p.LastName) as CustomerName
	,Format(Sum(TotalDue),'C0') as TotalDue
	,ROW_NUMBER() Over(Partition by st.Name Order by Sum(TotalDue) desc) as RowNum
From Sales.SalesTerritory st
	Inner Join Sales.SalesOrderHeader soh on soh.TerritoryID = st.TerritoryID
	Inner Join Sales.Customer c on c.CustomerID = soh.CustomerID
	Inner Join Person.Person p on p.BusinessEntityID = c.PersonID
Group by 
	st.Name
	,Concat(p.FirstName,' ',p.LastName)


--Q 4
--part a
Select 
	Format(Sum(Freight),'C0') as TotalFreight
From Sales.SalesOrderHeader
 
--part b
Select 
	Year(ShipDate) as ShipYear
	,Format(Sum(Freight),'C0') as TotalFreight
From Sales.SalesOrderHeader
Group by Year(ShipDate)
Order by 1 asc
 
--part c
Select 
	Year(ShipDate) as ShipYear
	,Sum(Freight) as TotalFreight
	,Avg(Freight) as AvgFreight 
From Sales.SalesOrderHeader
Group by Year(ShipDate)
Order by 1 asc
 
--part d
 
Select 
	ShipYear
	,Format(TotalFreight,'C0') as TotalFreight
	,Format(AvgFreight,'C0') as AvgFreight
	,Format(Sum(TotalFreight) Over (Order by ShipYear),'C0') as RunningTotal
From(
	Select 
		Year(ShipDate) as ShipYear
		,Sum(Freight) as TotalFreight
		,Avg(Freight) as AvgFreight 
	From Sales.SalesOrderHeader
	Group by 
		Year(ShipDate))a


--Q5

Select 
    t.name as TableName
    ,Max(p.rows) as RowCNT
    ,Sum(u.total_pages * 8) as TotalAllocated_kb
    ,Sum(u.used_pages * 8) as Used_kb
    ,(Sum(u.total_pages * 8) - Sum(u.used_pages * 8)) as Unused_kb
From sys.allocation_units u
    Inner Join sys.partitions p on p.hobt_id = u.container_id
    Inner Join sys.tables t on t.object_id = p.object_id
Group by t.name

--Q6
--part a
Select 
    BusinessEntityID
    ,EmailAddress
    ,CHARINDEX('@',EmailAddress) CharCNT
    ,Left(EmailAddress,CHARINDEX('@',EmailAddress)-1) Username
From Person.EmailAddress
Order by 1 asc
 
--part b
Select * 
From(
    Select 
        BusinessEntityID
	,EmailAddress
	,CHARINDEX('@',EmailAddress) CharCNT
	,Left(EmailAddress,CHARINDEX('@',EmailAddress)-1) Username
    From Person.EmailAddress) a 
Group by 
    BusinessEntityID
    ,EmailAddress
    ,CharCNT
    ,UserName
Having Count(Distinct Username) > 1
 
--part c 
Select 
    ea.BusinessEntityID
    ,EmailAddress
    ,CHARINDEX('@',EmailAddress)
    ,Left(EmailAddress,CHARINDEX('@',EmailAddress)-1) Username
    ,Concat(
	Left(FirstName,2)
	,'.'
	,Right(LastName,2) 
	,'.'
	,Left(NewID(),5)) as TempPassword
From Person.EmailAddress ea
    Inner Join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID
Order by 1 asc

--Q 7
--part a 
Select top 1
    BusinessEntityID
From Sales.SalesPerson
Order by SalesYTD desc
 
--part b 
Declare @TopSalesPersonID int
Set @TopSalesPersonID = (Select top 1
			    BusinessEntityID
			 From Sales.SalesPerson
		         Order by SalesYTD desc)
 
--part c
Declare @CurrentYear int
Set @CurrentYear = (Select top 1 
			Year(OrderDate)
		    From Sales.SalesOrderHeader
		    Order by 1 desc)
 
--part c
Select top 10		
	p.Name as ProductName
	,Format(Sum(SubTotal),'C0') as SubTotal
From Sales.SalesOrderHeader soh
    Inner Join Sales.SalesOrderDetail sod
	on soh.SalesOrderID = sod.SalesOrderID
    Inner Join Production.Product p 
	on p.ProductID = sod.ProductID
Where SalesPersonID = @TopSalesPersonID
	and Year(OrderDate) = @CurrentYear
Group by p.Name
Order by Sum(SubTotal) desc

--Q 8
--part a
 Select 
    Concat(FirstName,' ',LastName) as FullName
    ,soh.AccountNumber
    ,PhoneNumber
    ,OrderDate
    ,p.Name as ProductName
    ,Sum(LineTotal) as LineTotal
 From Sales.SalesOrderHeader soh
    Inner Join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
    Inner Join Production.Product p on p.ProductID = sod.ProductID
    Inner Join Sales.Customer c on c.CustomerID = soh.CustomerID
    Inner Join Person.Person pr on pr.BusinessEntityID = c.PersonID
    Inner Join Person.PersonPhone pp on pp.BusinessEntityID = pr.BusinessEntityID
 Group by 
    Concat(FirstName,' ',LastName)
    ,soh.AccountNumber
    ,PhoneNumber
    ,OrderDate
    ,p.Name
 
--part b
Create Procedure CustomerPurchaseHistory
	@PhoneNumber varchar(25)
	,@AccountNumber nvarchar(15)
as (
	 Select 
		Concat(FirstName,' ',LastName) as FullName
		,soh.AccountNumber
		,PhoneNumber
		,OrderDate
		,p.Name as ProductName
		,Sum(LineTotal) as LineTotal
	 From Sales.SalesOrderHeader soh
		Inner Join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
		Inner Join Production.Product p on p.ProductID = sod.ProductID
		Inner Join Sales.Customer c on c.CustomerID = soh.CustomerID
		Inner Join Person.Person pr on pr.BusinessEntityID = c.PersonID
		Inner Join Person.PersonPhone pp on pp.BusinessEntityID = pr.BusinessEntityID
	 Where @PhoneNumber = PhoneNumber
		and @AccountNumber = soh.AccountNumber
	 Group by 
  		Concat(FirstName,' ',LastName)
		,soh.AccountNumber
		,PhoneNumber
		,OrderDate
		,p.Name)
--part c 
Exec CustomerPurchaseHistory
	@PhoneNumber = '620-555-0117'
	,@AccountNumber = '10-4020-000695'
 
--part d
Drop Procedure CustomerPurchaseHistory

--Q 9
-- part a
Drop Index AK_SalesOrderDetail_rowguid
on Sales.SalesOrderDetail


--part b

Drop Index IX_SalesOrderDetail_ProductID
on Sales.SalesOrderDetail


--part c

Alter Table Sales.SalesOrderDetail
Drop Constraint PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 


--part d

Create Unique NonClustered Index AK_SalesOrderDetail_rowguid
on Sales.SalesOrderDetail(rowguid)

--part e

Create NonClustered Index IX_SalesOrderDetail_ProductID
on Sales.SalesOrderDetail(ProductID)


--part f

Alter Table Sales.SalesOrderDetail
Add Constraint PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 
Primary Key Clustered (SalesOrderID,SalesOrderDetailID)

--Q 10
--part a 
If Object_ID('Sales.DailyRevenue') is not null drop table Sales.DailyRevenue
 
Create Table Sales.DailyRevenue
	(OrderDate Date
	,TotalDue money)
 
Declare @BeginDate datetime
Declare @EndDate datetime
Declare @InsertDays int
Declare @LoopEndDate datetime
Set @BeginDate = (Select Min(OrderDate) From Sales.SalesOrderHeader)
Set @EndDate = (Select Max(OrderDate) From Sales.SalesOrderHeader)
Set @InsertDays = 100
Set @LoopEndDate = @BeginDate+@InsertDays
 
 
While @BeginDate < @EndDate
Begin 
 
	Insert Into Sales.DailyRevenue
		(OrderDate,TotalDue)
		Select 
			OrderDate
			,Sum(Totaldue) as TotalDue
		From Sales.SalesOrderHeader
		Where 
			OrderDate > = @BeginDate
			and OrderDate <@LoopEndDate
			and OrderDate <= @EndDate
		Group by OrderDate
		Order by 1 desc
 
--part b 
	Print 'Data Between ' + DateName(month,@BeginDate) +' '+DateName(Year,@BeginDate) 
	      + ' through ' + DateName(month,@LoopEndDate) +' '+DateName(Year,@LoopEndDate) 
	      + ' inserted'
 
	Set @BeginDate = @LoopEndDate
	Set @LoopEndDate = (@LoopEndDate + @InsertDays)	
end




