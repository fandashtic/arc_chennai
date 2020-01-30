CREATE procedure spr_SchemePerformance_Detail (@SchemeID Int, 
					      @FromDate Datetime,
					      @ToDate DateTime,
					      @CompFromDate DateTime,
					      @CompToDate DateTime,
					      @SchemeName nVarchar(2550))
As                                
Declare @Delimeter as Char(1)                                  
Declare @Count1 Int
Declare @Inc Int
Set @Inc = 1
Set @Delimeter=Char(15)                                 

If IsNull((Select SchemeType From Schemes Where SchemeID = @SchemeID), 0) NOT In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22)
Begin
Select ''
End
Else 
Begin

Create Table #tmpSch( SchemeName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS)  
If @SchemeName='%'                                     
   Insert into #tmpSch select SchemeName from Schemes                                    
Else                                    
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                                    
  
Create Table #temp1 (InvoiceID Int, SchemeID Int, SchemeName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
ItemCode nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,  
ItemName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, CPS Decimal(18, 6), CPSC Decimal(18, 6),   
COPS Decimal(18, 6), COPSC Decimal(18, 6), IncrementV Decimal(18, 6),   
IncrementP Decimal(18, 6), SchType Int, FreeS nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS)  
  
Create Table #temp2 (InvoiceID Int, SchemeID Int, SchemeName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
ItemCode nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,  
ItemName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, CPS Decimal(18, 6), CPSC Decimal(18, 6),   
COPS Decimal(18, 6), COPSC Decimal(18, 6), IncrementV Decimal(18, 6),   
IncrementP Decimal(18, 6), SchType Int, FreeS nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS)  
  
Create Table #temp3 (IDS Int IDENTITY(1, 1), InvoiceID Int, SchemeID Int, SchemeName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
ItemCode nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,  
ItemName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, CPS Decimal(18, 6), CPSC Decimal(18, 6),   
COPS Decimal(18, 6), COPSC Decimal(18, 6), IncrementV Decimal(18, 6),   
IncrementP Decimal(18, 6), SchType Int, FreeS nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS)  
  
  
Insert InTo #temp1   
Select "invID" = ids.InvoiceID,   
"SchemeID" = sch.SchemeID, "Scheme Name" = sch.SchemeName,   
"Item Code" = ids.product_code, "Item Name" = its.productname,   
"Current Period Sales Value" = ids.Amount,   
  
"Current Period Scheme Value" = IsNull((Select   
Case When sch.SchemeType In (19, 81, 21, 22) Then Sum((ss.Value * ss.Cost) / 100) Else Sum(IsNull(Cost, 0)) End   
From Schemesale ss   
Where ss.Type = sch.SchemeID And ss.InvoiceID = ids.InvoiceID   
-- And   
-- (ss.Product_Code = (Case   
-- When sch.SchemeType In (17, 83, 19, 81, 20, 82, 21, 22) Then ids.product_code End)   
--  Or   
-- ss.Serial = (Case When sch.SchemeType In (18) Then ids.freeserial End)  
--)
), 0)  
,  
"Comparitive Period Sales Value" = 0,   
"Comparitive Period Scheme Sales Value" = 0,  
"Incremental Value" = 0, "Increment %" = 0,   
"Scheme Type" = sch.SchemeType,  
"FreeSerial" = ids.freeserial  
From Schemes sch, InvoiceAbstract ia,   
InvoiceDetail ids, Items its 
Where 
IsNull(ia.Status, 0) & 192 = 0 and
sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) And  
ia.InvoiceDate Between @FromDate And @ToDate And 
sch.SchemeName In (Select SchemeName From #tmpSch) And   
ia.InvoiceID = ids.InvoiceID And  
ids.Amount > 0 And 
(ids.schemeid = sch.schemeid Or ids.splcatschemeid = sch.schemeid) And 
ids.product_code = its.product_code 
  
Union  
  
Select "invID" = ids.InvoiceID,   
"SchemeID" = sch.SchemeID, "Scheme Name" = sch.SchemeName,   
"Item Code" = ids.product_code, "Item Name" = its.productname,   
"Current Period Sales Value" = 0,   
  
"Current Period Scheme Value" = 0,  
"Comparitive Period Sales Value" = ids.Amount,   
"Comparitive Period Scheme Sales Value" = IsNull((Select   
Case When sch.SchemeType In (19, 81, 21, 22) Then Sum((ss.Value * ss.Cost) / 100) Else Sum(IsNull(Cost, 0)) End   
From   
Schemesale ss Where ss.Type = sch.SchemeID And ss.InvoiceID = ids.InvoiceID 
--And   
-- (ss.Product_Code = (Case   
-- When sch.SchemeType In (17, 83, 19, 81, 20, 82, 21, 22) Then ids.product_code End)   
--  Or   
-- ss.Serial = (Case When sch.SchemeType In (18) Then ids.freeserial End)  
--)
), 0)  
,  
"Incremental Value" = 0, "Increment %" = 0,   
"Scheme Type" = sch.SchemeType,  
"FreeSerial" = ids.freeserial  
From Schemes sch, InvoiceAbstract ia,   
InvoiceDetail ids, Items its 
Where 
IsNull(ia.Status, 0) & 192 = 0  and
sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) And  
ia.InvoiceDate Between @CompFromDate And @CompToDate And 
ids.Amount > 0 And 
sch.SchemeName In (Select SchemeName From #tmpSch) And   
(ids.schemeid = sch.schemeid Or ids.splcatschemeid = sch.schemeid) And 
ia.InvoiceID = ids.InvoiceID And  
ids.product_code = its.product_code    
  
  
Insert InTo #temp2 Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
Sum(CPS), Sum(CPSC), Sum(COPS), Sum(COPSC), Sum(IncrementV), Sum(IncrementP),   
SchType, FreeS From #temp1 Group By InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,  
SchType, FreeS   
  
Insert InTo #temp3 Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
CPS, CPSC, COPS, COPSC, IncrementV, IncrementP,   
SchType, FreeS From #temp2 Where SchType = 18  
  
Delete From #temp2  
  
Insert InTo #temp2 Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
Sum(CPS), Sum(CPSC), Sum(COPS), Sum(COPSC), Sum(IncrementV), Sum(IncrementP),   
SchType, '' From #temp1 Group By InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,  
SchType  
  
Select @Count1 = Count(*) From #temp3   
  
Declare @SID nVarchar(250)  
Declare @InvID Int  
Declare @SchType Int  
Declare @ItemCode nVarchar(250)  
Declare @SchID Int 
  
Create Table #temp5 (IDS Int IDENTITY(1, 1), InvoiceID Int, SchID Int, SchType Int, ItemCode nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
Cost Decimal(18, 6))  
Create Table #temp4 (IDS Int, InvoiceID Int, SchID Int, SchType Int, ItemCode nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, SID Int)  
While (@Inc <= @Count1)  
Begin  
Select @SID = FreeS, @InvID = InvoiceID, @SchID = SchemeID, @SchType = SchType,   
@ItemCode = ItemCode From #temp3 Where IDS = @Inc  
Insert InTo #temp4 Select @Inc, @InvID, @SchID, @SchType, @ItemCode, * From dbo.sp_SplitIn2Rows(@SID, ',')  
--select * from #temp4  
--Insert InTo #temp5 Select @Inc, Ids, @InvID, @SchType, @ItemCode From #temp4  
--select * from #temp5  
Set @Inc = @Inc + 1  
End  
  
--Select * From #temp2  
--Select * From #temp3  
--Select * From #temp4  
  
Insert InTo #temp5 Select #temp4.InvoiceID, SchID, SchType, ItemCode, Sum(Cost)  
From #temp4, Schemesale Where #temp4.InvoiceID = Schemesale.InvoiceID And   
#temp4.SID = Schemesale.Serial Group By #temp4.InvoiceID, SchType, ItemCode, SchID  
  
--Select * From #temp2  
--Select * From #temp5  
  
Select @Count1 = Count(*) From #temp3   
Set @Inc = 1  
  
Set @InvID = 0  
Set @SchType = 0  
Set @ItemCode = ''  
Set @SchID = 0  
  
While (@Inc <= @Count1)  
Begin  
	Select @InvID = InvoiceID, @SchType = SchType, @ItemCode = ItemCode, @SchID = SchID  From #temp5  
	Where IDS = @Inc  
	  
	If(IsNull((Select CPS From #temp2, #temp5 Where #temp2.InvoiceID = #temp5.InvoiceID And  
	#temp2.SchType = #temp5.SchType And #temp2.ItemCode = #temp5.ItemCode And #temp2.SchemeID = #temp5.SchID And 
	#temp5.IDS = @Inc), 0)) > 0   
	Begin  
  
		Update #temp2 Set CPSC = IsNull((Select Cost From #temp5 Where IDS = @Inc), 0)  
		Where InvoiceID = @InvID And ItemCode = @ItemCode And SchType = @SchType And SchemeID = @SchID
  
		If(IsNull((Select COPS From #temp2, #temp5 Where #temp2.InvoiceID = #temp5.InvoiceID And  
		#temp2.SchType = #temp5.SchType And #temp2.ItemCode = #temp5.ItemCode And #temp2.SchemeID = #temp5.SchID And 
		#temp5.IDS = @Inc), 0)) > 0   
		Begin  
  
			Update #temp2 Set COPSC = IsNull((Select Cost From #temp5 Where IDS = @Inc), 0)  
			Where InvoiceID = @InvID And ItemCode = @ItemCode And SchType = @SchType And SchemeID = @SchID 
  
		End  
	End  
  
	Else If(IsNull((Select COPS From #temp2, #temp5 Where #temp2.InvoiceID = #temp5.InvoiceID And  
	#temp2.SchType = #temp5.SchType And #temp2.ItemCode = #temp5.ItemCode And #temp2.SchemeID = #temp5.SchID And 
	#temp5.IDS = @Inc), 0)) > 0   
	Begin  
  
		Update #temp2 Set COPSC = IsNull((Select Cost From #temp5 Where IDS = @Inc), 0)  
		Where InvoiceID = @InvID And ItemCode = @ItemCode And SchType = @SchType And SchemeID = @SchID 
  
	End  
  
Set @Inc = @Inc + 1  
End  
  
Select "Item Code" = ItemCode, "Item Code" = ItemCode, "Item Name" =  ItemName,   
"Current Period Sales Value" = Sum(CPS),   
"Current Period Scheme Value" = Sum(CPSC),   
"Comparitive Period Sales Value" = Sum(COPS),   
"Comparitive Period Scheme Value" = Sum(COPSC),  
"Increment Value" = (Sum(CPS) - Sum(COPS)),   
"Increment %" = Case When Sum(COPS) = 0 Then 100 Else   
((Sum(CPS) - Sum(COPS)) / Sum(COPS)) * 100 End  
From #temp2 Where SchemeID = @SchemeID Group By   
ItemCode, ItemName  
  
Drop Table #temp1  
Drop Table #temp2  
Drop Table #temp3  
Drop Table #temp4  
Drop Table #temp5  
Drop Table #tmpSch  
  
End  
  



