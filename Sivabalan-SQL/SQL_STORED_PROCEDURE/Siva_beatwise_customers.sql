--Exec Siva_beatwise_customers 'SURIYANARAYANAN'
CREATE PROCEDURE Siva_beatwise_customers(@Salesman nVarChar(50))  
AS  
  
Declare @OTHERS As NVarchar(50)    
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)    

Create Table #BeatTemp 
	(BeatID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	 BeatDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	 Salesman nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 SalesmanID Int, 
	 DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 Outlet Integer)  
	   
If @Salesman = N'%'    
Begin    
	Insert into #BeatTemp(BeatID, BeatDesc, Salesman, SalesmanID)-- Values(    
	Select distinct Beat.BeatID, Beat.Description,   
	Case IsNull(Salesman.Salesman_Name, N'')    
	When N'' Then @OTHERS    
	Else Salesman.Salesman_Name End,IsNull(Salesman.SalesmanID,0)    
	FROM Beat  
	inner join Beat_Salesman on Beat.BeatID = Beat_Salesman.BeatID      
	left outer join Salesman on    Beat_Salesman.SalesmanID = Salesman.SalesmanID    
End    
Else    
Begin    
	Insert into #BeatTemp(BeatID, BeatDesc, Salesman, SalesmanID)-- Values(    
	Select distinct Beat.BeatID, Beat.Description, Salesman.Salesman_Name,IsNull(Salesman.SalesmanID,0)    
	FROM Beat, Beat_Salesman, Salesman    
	WHERE  Beat.BeatID = Beat_Salesman.BeatID And    
	 Beat_Salesman.SalesmanID = Salesman.SalesmanID And    
	 Salesman.Salesman_Name Like @Salesman    
End    

Declare @SalesManDSType AS TABLE(
	SalesmanID INT,
	Salesman_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DSTypeId INT,
	DSTypeCtlPos INT,
	DSTypeName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

INSERT INTO @SalesManDSType(SalesmanID,Salesman_Name, DSTypeId, DSTypeCtlPos, DSTypeName)
Select S.SalesmanID,S.Salesman_Name,DD.DSTypeId, DD.DSTypeCtlPos, DM.DSTypeValue 
from Salesman S WITH (NOLOCK)
JOIN DSType_Details DD  WITH (NOLOCK) ON DD.SalesManID = s.SalesmanID
JOIN DSType_Master DM  WITH (NOLOCK) ON DM.DSTypeId = DD.DSTypeId
  
update #BeatTemp Set Outlet = (Select Count(distinct bs.CustomerID) From Beat_Salesman bs, Customer cu Where     
bs.customerid = cu.customerid And cu.Active = 1 And     
bs.BeatID = #BeatTemp.BeatID COLLATE SQL_Latin1_General_CP1_CI_AS   
and IsNull(bs.salesmanID, 0) = #BeatTemp.SalesmanID and isnull(bs.CustomerID,N'') <> N'')  

Update B SET B.DSType = D.DSTypeName
FROM #BeatTemp B WITH (NOLOCK)
JOIN @SalesManDSType D ON D.SalesmanID = B.SalesmanID AND D.DSTypeCtlPos = 1
    
Select BeatID, "Beat Description" = BeatDesc, SalesmanID SalesmanCode, Salesman, DSType, "No of Outlet" = Outlet from #BeatTemp    
    
Drop Table #BeatTemp  