CREATE PROCEDURE spr_DSwiseBeatwiseItemwiseProductivity 
(
	@DS NVARCHAR(2550),
	@BEAT NVARCHAR(2550),
	@DSTYPE NVARCHAR(4000),
	@PRODUCTCODE NVARCHAR(4000),
	@FROMDATE DATETIME, 
	@TODATE DATETIME
)
AS
Begin
Declare @Delimeter as Char(1)              
Set @Delimeter = Char(15)            

Create Table #Sman(SalesmanID Int)           
Create Table #Beat(BeatID Int)          
Create Table #Item(ItemCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @DS='%'               
	Insert Into #Sman Select SalesmanID From Salesman
Else              
	Insert Into #Sman Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_SplitIn2Rows(@DS, @Delimeter))

If @BEAT='%'
	Insert Into #Beat Select BeatID From Beat
Else
	Insert Into #Beat Select BeatID From Beat Where [Description] In (Select * From dbo.sp_SplitIn2Rows(@BEAT, @Delimeter))

If @PRODUCTCODE='%'               
	Insert Into #Item Select Product_Code From Items
Else
	Insert Into #Item Select * From dbo.sp_SplitIn2Rows(@PRODUCTCODE, @Delimeter)

Create table #tmpDSType (SalesmanID Int, Salesman_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
DSTypeValue nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)   

if @DSType = N'%' or @DSType = N''           
   Insert into #tmpDSType   
   select Salesman.SalesmanID,Salesman_Name, DSTypeValue   
   from DSType_Master,DSType_Details,Salesman  
   Where Salesman.SalesmanID = DSType_Details.SalesmanID  
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID   
   and DSType_Master.DSTypeCtlPos = 1   
   Union  
   Select SalesmanID,Salesman_Name,'' from Salesman   
   where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1)  
Else          
   Insert into #tmpDSType   
   select Salesman.SalesmanID,Salesman_Name,DSTypeValue from DSType_Master,DSType_Details,Salesman  
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID    
   and DSType_Details.SalesmanID = Salesman.SalesmanID  
   and DSType_Master.DSTypeCtlPos = 1   
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter)) 

Select "Beat ID" = [Beat ID], "Salesman ID" = [Salesman ID], "DS Type" = ([DS Type]), 
"Customer Count" = Count(Distinct [Customer ID]) 
Into #Temp1 From (
Select Distinct "Beat ID" = bs.BeatID, "Salesman ID" = bs.SalesmanID, "DS Type" = tds.DSTypeValue, 
"Customer ID" = bs.CustomerID From Beat_Salesman bs, #tmpDSType tds
Where bs.SalesmanID > 0 And 
bs.CustomerID <> '' And 
bs.BeatID In (Select BeatID From #Beat) And 
bs.SalesmanID In (Select SalesmanID From #Sman) And 
bs.SalesmanID = tds.SalesmanID) t1
Group By 
[Beat ID], [Salesman ID], [DS Type]

Select "Customer ID" = inv.CustomerID, 
"Beat ID" = inv.BeatID, 
"Salesman ID" = inv.SalesmanID, 
"Amount" = Sum(invd.Amount) 
Into #temp2
From InvoiceAbstract Inv, InvoiceDetail InvD	--, DSType_Master dm, DSType_Details dd
Where inv.InvoiceID = Invd.InvoiceID And 
inv.InvoiceType in (1, 3) and ISNULL(inv.STATUS, 0) & 128 = 0  And
inv.InvoiceDate Between @FROMDATE And @TODATE And
inv.BeatID In (Select BeatID From #Beat) And 
inv.SalesmanID In (Select SalesmanID From #Sman) And 
invd.Product_Code In (Select itemcode From #item)
Group By inv.CustomerID, inv.BeatID, inv.SalesmanID

Select "sb" = Cast([Salesman ID] As nVarchar) + @Delimeter + Cast([Beat ID] As nVarchar),
"DS Name" = (Select Salesman_Name From Salesman 
	            Where SalesmanID = #temp1.[Salesman ID]), 
"DS Type" = [DS Type],
"Beat" = (Select [Description] From Beat 
	 Where BeatID = [Beat ID]), 
"Total No Of Customers" = [Customer Count], 
"No Of Customers Invoiced" = (Select Count(Distinct [Customer ID]) From #temp2 
			      Where [Beat ID] =  #temp1.[Beat ID] 
		              And [Salesman ID] = #temp1.[Salesman ID]),
"No Of Customers Not Invoiced" = [Customer Count] - (Select Count(Distinct [Customer ID]) 
                              From #temp2 
			      Where [Beat ID] =  #temp1.[Beat ID] 
		              And [Salesman ID] = #temp1.[Salesman ID]), 
"Value(%c)" = (Select Sum(Amount) From #temp2 
			      Where [Beat ID] =  #temp1.[Beat ID] 
		              And [Salesman ID] = #temp1.[Salesman ID])

From #temp1 Order By [DS Name]

Drop Table #Sman
Drop Table #Beat
Drop Table #Item
Drop Table #tmpDSType
End
