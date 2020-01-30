Create PROCEDURE Spr_NoofBillsforacustomer_Abstract(@DSName NVarchar(200),
  @BName NVarchar(200),
  @DSType nVarchar(4000),
  @FromDate DateTime,
  @ToDate DateTime)                       
AS      
            
BEGIN    
      
Declare @Delimeter as Char(1)
        
Set @Delimeter = Char(15)
  
Create Table #TmpSalesman(Salesman_Name NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)
        
Create Table #TmpBeat(BeatName NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #TmpDSType(DSTypeID int)

Create Table #TmpDSTypeList(Salesman_Name NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			    Description NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS ,
			    DSTypeID int)
        
if @DSName = N'%'
   Insert into #TmpSalesman select Salesman_Name from Salesman
else
   Insert into #TmpSalesman select * from dbo.sp_SplitIn2Rows(@DSName, @Delimeter)
        
if @BName = N'%'
   Insert into #TmpBeat select Description from Beat
else
   Insert into #TmpBeat select * from dbo.sp_SplitIn2Rows(@BName, @Delimeter)

if @DSType = N'%' or @DSType = N''
   Insert into #TmpDSType select DSTypeID from DSType_Master where DSTypeCtlPos=1
else
   Insert into #TmpDSType Select distinct DsTypeID From DSType_Master Where DSTypeValue In (Select * From Dbo.sp_SplitIn2Rows(@DSType,@Delimeter))

if @DSType =N'%' or @DSType = N''
Begin
	Insert into #TmpDSTypeList Select Salesman_Name, Description,DD.DSTypeID 
	From InvoiceAbstract IA
	Inner Join  Beat On Beat.BeatID = IA.BeatID
	Inner Join Salesman On IA.SalesmanID = Salesman.SalesmanID
	Left Outer Join DSType_Details DD On DD.SalesManID = IA.SalesmanID
	Where IA.InvoiceDate Between @FromDate And @ToDate
	And Description In (Select * From #TmpBeat)
	And Salesman_Name In (Select * From #TmpSalesman)
	and Isnull(DD.DSTypeID,0) in (select DSTypeID from #TmpDSType)
	Group By Salesman_Name,Description,DD.DSTypeID
End
Else
Begin
	Insert into #TmpDSTypeList Select Salesman_Name, Description,DD.DSTypeID
	From InvoiceAbstract IA, Beat, Salesman,DSType_Details DD
	Where Beat.BeatID = IA.BeatID
	And IA.SalesmanID = Salesman.SalesmanID
	and DD.SalesManID = IA.SalesmanID
	And IA.InvoiceDate Between @FromDate And @ToDate
	And Description In (Select * From #TmpBeat)
	And Salesman_Name In (Select * From #TmpSalesman)
	and Isnull(DD.DSTypeID,0) in(select DSTypeID from #TmpDSType)
	Group By Salesman_Name,Description,DD.DSTypeID
End

select * into #temp from #TmpDSTypeList
            
Select
            
"DS Beat" = Salesman_Name + Char(15) + Description,
            
"DS Name" = Salesman_Name,

"DS Type" = DSType_master.DSTypeValue,
            
"Beat Name" = Description,
            
"No of New Customers" = (Select Count(*) From Customer Where CreationDate Between @FromDate And @ToDate And CustomerID In
(Select CustomerID From InvoiceAbstract IA, Beat,Salesman Where IA.BeatID = Beat.BeatID And
 IA.SalesmanID = Salesman.SalesmanID And Salesman_Name Like C.Salesman_Name And Description Like C.Description And CustomerID In
(Select CustomerId from InvoiceAbstract where InvoiceDate Between @Fromdate And @ToDate And Status & 192 = 0 And InvoiceType in (1,3)))),
"No of Bills for New Customers" = (Select Count(InvoiceAbstract.InvoiceID) From InvoiceAbstract, Salesman, Beat
Where InvoiceAbstract.SalesmanId = Salesman.SalesmanID And  InvoiceAbstract.BeatId = Beat.BeatID And Beat.Description Like C.Description And
Salesman.Salesman_Name Like C.Salesman_Name And CustomerID In
(Select CustomerID From InvoiceAbstract, Beat,Salesman Where InvoiceAbstract.BeatID = Beat.BeatID And
 InvoiceAbstract.SalesmanID = Salesman.SalesmanID And Salesman_Name Like C.Salesman_Name And Description Like C.Description And
 CustomerID In (Select CustomerID From Customer Where CreationDate Between @FromDate And @ToDate)) And InvoiceDate Between @FromDate And @ToDate
 And Status & 192 = 0 and InvoiceType in (1,3)),
"No of Repeat Customers" = (Select Count(*) From Customer Where CreationDate < @FromDate And CustomerID In
(Select CustomerID From InvoiceAbstract IA, Beat,Salesman Where IA.BeatID = Beat.BeatID And
 IA.SalesmanID = Salesman.SalesmanID And Salesman_Name Like C.Salesman_Name And Description Like C.Description And CustomerID In
 (Select CustomerId from InvoiceAbstract where InvoiceDate Between @Fromdate And @ToDate And Status & 192 = 0 And InvoiceType in (1,3)))),
            
"No of Bills for Repeat Customers" = (Select Count(InvoiceAbstract.InvoiceID) From InvoiceAbstract, Salesman, Beat
Where InvoiceAbstract.SalesmanId = Salesman.SalesmanID And  InvoiceAbstract.BeatId = Beat.BeatID
And Beat.Description Like C.Description And
Salesman.Salesman_Name Like C.Salesman_Name And CustomerID In
(Select CustomerID From InvoiceAbstract IA, Beat,Salesman Where IA.BeatID = Beat.BeatID And
 IA.SalesmanID = Salesman.SalesmanID And Salesman_Name Like C.Salesman_Name And Description Like C.Description And
 CustomerID In (Select CustomerID From Customer Where CreationDate < @FromDate)) And InvoiceDate Between @FromDate And @ToDate And
 Status & 192 = 0 And InvoiceType In (1,3))
          
Into #temp1
          
From #temp c
Left Outer Join DSType_Master On isnull(DSType_master.DSTypeId,0) = isnull(c.DSTypeID,0)
          
Select * From #temp1 Where [No of New Customers] <> 0 or [No of Repeat Customers] <> 0
            
Drop Table #temp
          
Drop Table #temp1
      
Drop Table #TmpSalesman
      
Drop Table #TmpBeat
Drop Table #TmpDSTypeList
            
End
