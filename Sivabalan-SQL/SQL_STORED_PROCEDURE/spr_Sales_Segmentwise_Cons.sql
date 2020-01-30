Create Procedure spr_Sales_Segmentwise_Cons
(
 @BranchName NVarChar(4000),
	@CustHierarchy NVarChar(255),
	@SegmentName NVarChar(255),
	@FromDate Datetime,
 @ToDate DateTime
)
As 
Set DateFormat DMY

Declare @CIDSetUp As NVarChar(15)  
Select @CIDSetUp=RegisteredOwner From Setup   

Declare @Cur_SegmentID As Cursor  
Declare @Segment_ID As Int
Declare @Delimeter as Char(1)

Set @Delimeter = Char(15)

CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @BranchName = N'%'              
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports    
Else              
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    

If @CustHierarchy = N'%'  
	Select @CustHierarchy = Max(Level) From CustomerSegment
Else
	Select @CustHierarchy = HierarchyID From CustomerHierarchy	Where HierarchyName = @CustHierarchy

Create Table #TmpSegmentID(SegmentID Int)
Create Table #TmpSegmentID_Leaf(SegmentID Int)
Create Table #TmpSegmentName(SegmentName NVarChar(255))

If @SegmentName = N'%'  
 Insert Into #TmpSegmentID Select SegmentID From CustomerSegment Where Level = @CustHierarchy And Active = 1
Else  
 Insert Into #TmpSegmentID Select SegmentID From CustomerSegment Where SegmentName In (Select * From dbo.sp_SplitIn2Rows(@SegmentName,@Delimeter))

Set @Cur_SegmentID = Cursor For Select cast(SegmentID As Int) From #TmpSegmentID
Open @Cur_SegmentID
Fetch Next From @Cur_SegmentID Into @Segment_ID
While @@Fetch_Status=0
Begin    
 Insert Into #TmpSegmentID_Leaf Select SegmentID From dbo.fn_GetLeafLevelSegment(@Segment_ID)
	Fetch Next From @Cur_SegmentID Into @Segment_ID
End     
Close @Cur_SegmentID

Insert Into #TmpSegmentName Select SegmentName From CustomerSegment Where SegmentID In(Select * From #TmpSegmentID_Leaf)

Set @FromDate= dbo.StripDateFromTime(@FromDate)
Set @ToDate= dbo.StripDateFromTime(@ToDate)

Select 
	Cast(Cast(CS.SegmentID As NVarChar)+ @CIDSetUp As NVarChar),  
	"Distributor Code"=@CIDSetUp,"Segment Code" = CS.SegmentCode,
	"Segment Name" = CS.SegmentName,"Count of Customers" = Count(Distinct IA.CustomerID),
 "No. of Invoices" = Count(IA.InvoiceID),
	"Total Sales Value  (%c)" = Sum(IsNull(IA.NetValue,0)) - Sum(IsNull(IA.Freight,0))
From 
	CustomerSegment CS,#TmpSegmentID_Leaf TL,Customer C,InvoiceAbstract IA
Where 
	CS.SegmentID = TL.SegmentID 
	And C.SegmentID = TL.SegmentID
	And C.CustomerID = IA.CustomerID
	And dbo.StripDateFromTime(IA.InvoiceDate) = @FromDate
	And dbo.StripDateFromTime(IA.InvoiceDate) = @ToDate
	And IsNull(IA.Status,0) & 128 = 0
Group By
 CS.SegmentID,CS.SegmentCode,CS.SegmentName

Union All  
  
Select         
 Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,"Segment Code" = Field1,
	"Segment Name" = Field2,"Count of Customers" = Field3,
  "No. of Invoices" = Field4, "Total Sales Value (%c)" = Field5
From    
 Reports,ReportAbstractReceived,#TmpSegmentName     
Where    
 Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Segment Wise Sales'
 And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Segment Wise Sales') Where FromDate = @FromDate And ToDate = @ToDate) Group by CompanyId)
 And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)    
 And ReportAbstractReceived.ReportID = Reports.ReportID   
	And Field2 = #TmpSegmentName.SegmentName
 And Field1 <> N'Segment Code' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'   

Drop Table #TmpSegmentID
Drop Table #TmpSegmentID_Leaf
Drop Table #TmpSegmentName


