Create Procedure spr_Sales_Segmentwise_ARU_Chevron
(  
 @CustHierarchy NVarChar(255),  
 @SegmentName NVarChar(255),  
 @FromDate Datetime,  
 @ToDate DateTime  
)  
As   
Set DateFormat DMY  
  
Declare @Cur_SegmentID As Cursor    
Declare @Segment_ID As Int  
Declare @Delimeter as Char(1)  
  
Set @Delimeter = Char(15)  
  
If @CustHierarchy = N'%'    
 Select @CustHierarchy = Max(Level) From CustomerSegment  
Else  
 Select @CustHierarchy = HierarchyID From CustomerHierarchy Where HierarchyName = @CustHierarchy  
  
Create Table #TmpSegmentID(SegmentID Int)  
Create Table #TmpSegmentID_Leaf(SegmentID Int)  
  
If @SegmentName = N'%'    
 Insert Into #TmpSegmentID Select SegmentID From CustomerSegment Where Level = @CustHierarchy And Active = 1  
Else    
 Insert Into #TmpSegmentID Select SegmentID From CustomerSegment Where SegmentName In (Select * From dbo.sp_SplitIn2Rows(@SegmentName,@Delimeter))  
  
Set @Cur_SegmentID = Cursor For Select Cast(SegmentID As Int) From #TmpSegmentID  
Open @Cur_SegmentID  
Fetch Next From @Cur_SegmentID Into @Segment_ID  
While @@Fetch_Status=0  
Begin      
 Insert Into #TmpSegmentID_Leaf Select SegmentID From dbo.fn_GetLeafLevelSegment(@Segment_ID)  
 Fetch Next From @Cur_SegmentID Into @Segment_ID  
End       
Close @Cur_SegmentID  
  
Set @FromDate= dbo.StripDateFromTime(@FromDate)  
Set @ToDate= dbo.StripDateFromTime(@ToDate)  
  
Select   
 CS.SegmentID,"Segment Code" = CS.SegmentCode,"Segment Name" = CS.SegmentName,  
 "Count of Customers" = Count(Distinct IA.CustomerID),
 "No. of Invoices" = Count(IA.InvoiceID),
 "Total Sales Value  (%c)" = Sum(IsNull(IA.NetValue,0)) - Sum(IsNull(IA.Freight,0))  
From   
 CustomerSegment CS,#TmpSegmentID_Leaf TL,Customer C,InvoiceAbstract IA  
Where   
 CS.SegmentID = TL.SegmentID   
 And C.SegmentID = TL.SegmentID  
 And C.CustomerID = IA.CustomerID  
 And dbo.StripDateFromTime(IA.InvoiceDate) >= @FromDate  
 And dbo.StripDateFromTime(IA.InvoiceDate) <= @ToDate  
 And IsNull(IA.Status,0) & 128 = 0  
Group By  
 CS.SegmentID,CS.SegmentCode,CS.SegmentName  
  
Drop Table #TmpSegmentID  
Drop Table #TmpSegmentID_Leaf

