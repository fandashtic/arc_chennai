CREATE procedure [dbo].[spr_beatwise_customers_With_DSTYPE](@Salesman nVarChar(50), @DSType nVarchar(2550))
AS

Declare @OTHERS As NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)  
Declare @Delimeter Nvarchar(1)

Set @Delimeter = Char(15)
Create table #tmpDSType
(SalesmanID Int,
Salesman_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSTypeName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS) 

if @DSType = N'%' or @DSType = N'' 
begin      
   Insert into #tmpDSType 
   select Salesman.SalesmanID,Salesman_Name, DSTypeValue 
   from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
   and DSType_Master.DSTypeCtlPos = 1 
   Union
   Select SalesmanID,Salesman_Name,'' from Salesman 
   where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1 )
   Union
   Select 0, @Others, ''
end
Else        
begin
   Insert into #tmpDSType 
   select Salesman.SalesmanID,Salesman_Name,DSTypeValue 
	from DSType_Master,DSType_Details,Salesman
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
   and DSType_Details.SalesmanID = Salesman.SalesmanID
   and DSType_Master.DSTypeCtlPos = 1 
   and DSType_Master.DSTypeValue in (select Distinct ItemValue from dbo.sp_SplitIn2Rows(@DSType,@Delimeter))  
end

Create Table #BeatTemp (BeatID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Salesman nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesmanID Int, Outlet Integer)  
If @Salesman = N'%'  
Begin  
Insert into #BeatTemp(BeatID, BeatDesc, Salesman, SalesmanID)-- Values(  
Select distinct Beat.BeatID, Beat.Description, 
Case IsNull(Salesman.Salesman_Name, N'')  
When N'' Then @OTHERS  
Else Salesman.Salesman_Name End,IsNull(Salesman.SalesmanID,0)  
FROM Beat, Beat_Salesman, Salesman  
WHERE  Beat.BeatID = Beat_Salesman.BeatID And  
 Beat_Salesman.SalesmanID *= Salesman.SalesmanID 
ANd Salesman.SalesmanID  in (Select distinct SalesmanID FROM #tmpDSType WITH (NOLOcK)) 
End  
Else  
Begin  
Insert into #BeatTemp(BeatID, BeatDesc, Salesman, SalesmanID)-- Values(  
Select distinct Beat.BeatID, Beat.Description, Salesman.Salesman_Name,IsNull(Salesman.SalesmanID,0)  
FROM Beat, Beat_Salesman, Salesman  
WHERE  Beat.BeatID = Beat_Salesman.BeatID And  
 Beat_Salesman.SalesmanID = Salesman.SalesmanID And  
 Salesman.Salesman_Name Like @Salesman 
ANd Salesman.SalesmanID  in (Select distinct SalesmanID FROM #tmpDSType WITH (NOLOcK))  
End  

update #BeatTemp Set Outlet = (Select Count(distinct bs.CustomerID) From Beat_Salesman bs, Customer cu Where   
bs.customerid = cu.customerid And cu.Active = 1 And   
bs.BeatID = #BeatTemp.BeatID COLLATE SQL_Latin1_General_CP1_CI_AS 
and IsNull(bs.salesmanID, 0) = #BeatTemp.SalesmanID and isnull(bs.CustomerID,N'') <> N'')
  
Select BeatID, "Beat Description" = BeatDesc, Salesman, 
"No of Outlet" = Outlet,
"DS Type" = D.DSTypeName --(Select TOP 1 DSTypeName FROM #tmpDSType WITH (NOLOcK) WHERE SalesmanID = #BeatTemp.SalesmanID)
from #BeatTemp  
Join #tmpDSType D WITH (NOLOcK) ON D.SalesmanID = #BeatTemp.SalesmanID

Drop Table #BeatTemp
