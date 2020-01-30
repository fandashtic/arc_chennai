CREATE procedure spr_SchemePerformance (@FromDate Datetime,
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
Select Distinct "invID" = ids.InvoiceID,   
"SchemeID" = sch.SchemeID, "Scheme Name" = sch.SchemeName,   
"Item Code" = ids.product_code, "Item Name" = its.productname,   
"Current Period Sales Value" = ids.Amount,   
  
"Current Period Scheme Value" = IsNull((Select   
Case When sch.SchemeType IN (19, 81, 21, 22) Then Sum((ss.Value * ss.Cost) / 100) Else Sum(IsNull(Cost, 0)) End From Schemesale ss   
Where ss.Type = sch.SchemeID And ss.InvoiceID = ids.InvoiceID   
-- And   
-- (ss.Product_Code = (Case   
-- When sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) Then ids.product_code End)   
--  Or   
-- ss.Serial = (Case When sch.SchemeType In (18) Then ids.freeserial End)  
-- )
), 1)  
,  
"Comparitive Period Sales Value" = 0,   
"Comparitive Period Scheme Sales Value" = 0,  
"Incremental Value" = 0, "Increment %" = 0,   
"Scheme Type" = sch.SchemeType,  
"FreeSerial" = ids.freeserial  
From Schemes sch, InvoiceAbstract ia,   
InvoiceDetail ids, Items its 
Where IsNull(ia.Status, 0) & 192 = 0  and
sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) And  
ia.InvoiceDate Between @FromDate And @ToDate And 
ids.Amount > 0 And 
sch.SchemeName In (Select SchemeName From #tmpSch) And   
(ids.schemeid = sch.schemeid Or ids.splcatschemeid = sch.schemeid) And 
ia.InvoiceID = ids.InvoiceID And  
ids.product_code = its.product_code
  
Union  
  
Select "invID" = ids.InvoiceID,   
"SchemeID" = sch.SchemeID, "Scheme Name" = sch.SchemeName,   
"Item Code" = ids.product_code, "Item Name" = its.productname,   
"Current Period Sales Value" = 0,   
  
"Current Period Scheme Value" = 0,  
"Comparitive Period Sales Value" = ids.Amount,   
"Comparitive Period Scheme Sales Value" = IsNull((Select   
Case When sch.SchemeType in (19, 81, 21, 22) Then Sum((ss.Value * ss.Cost) / 100) Else Sum(IsNull(Cost, 0)) End   
From Schemesale ss Where ss.Type = sch.SchemeID And ss.InvoiceID = ids.InvoiceID 
-- And   
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
IsNull(ia.Status, 0) & 192 = 0 And 
sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) And  
ia.InvoiceDate Between @CompFromDate And @CompToDate And 
ids.Amount > 0 And 
sch.SchemeName In (Select SchemeName From #tmpSch) And   
sch.SchemeID In 
(Select Sch.SchemeID From   
Schemes sch, InvoiceAbstract ia,   
InvoiceDetail ids, Items its 
Where 
IsNull(ia.Status, 0) & 192 = 0 and
sch.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) And  
ia.InvoiceDate Between @FromDate And @ToDate And 
ids.Amount > 0 And 
sch.SchemeName In (Select SchemeName From #tmpSch) And   
(ids.schemeid = sch.schemeid Or ids.splcatschemeid = sch.schemeid) And 
ia.InvoiceID = ids.InvoiceID And  
ids.product_code = its.product_code
) and  
(ids.schemeid = sch.schemeid Or ids.splcatschemeid = sch.schemeid) And 
ia.InvoiceID = ids.InvoiceID And  
ids.product_code = its.product_code

----------------------------------------  
-- select * from #temp1  
----------------------------------------
  
Insert InTo #temp2   
Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
Sum(CPS), Sum(CPSC), Sum(COPS), Sum(COPSC), Sum(IncrementV), Sum(IncrementP),   
SchType, FreeS From #temp1 Group By FreeS, SchType, InvoiceID, SchemeID, SchemeName, ItemCode, ItemName  
  
  
Insert InTo #temp3 Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
CPS, CPSC, COPS, COPSC, IncrementV, IncrementP,   
SchType, FreeS From #temp2 Where SchType In (18, 84)
  
Delete From #temp2  
  
Insert InTo #temp2   
Select InvoiceID, SchemeID, SchemeName, ItemCode, ItemName,   
Sum(CPS), Sum(CPSC), Sum(COPS), Sum(COPSC), Sum(IncrementV), Sum(IncrementP),   
SchType, '' From #temp1 Group By SchType, InvoiceID, SchemeID, SchemeName, ItemCode, ItemName  
  
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
#temp4.SID = Schemesale.Serial Group By  #temp4.InvoiceID, SchType, ItemCode, SchID  
  
-- Select * From #temp2  
-- Select * From #temp5  
  
Select @Count1 = Count(*) From #temp3   
Set @Inc = 1  
  
Set @InvID = 0  
Set @SchType = 0  
Set @ItemCode = ''  
Set @SchID = 0  

-- select invoiceid, schtype, itemcode, CPS, * from #temp2  order by invoiceid, schtype, itemcode
-- select * from #temp3  
-- select * from #temp4  
-- select * from #temp5  order by ids
  

While (@Inc <= @Count1)  
Begin  
	Select @InvID = InvoiceID, @SchType = SchType, @ItemCode = ItemCode, @SchID = SchID From #temp5  
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
	#temp2.SchType = #temp5.SchType And #temp2.ItemCode = #temp5.ItemCode And  #temp2.SchemeID = #temp5.SchID And 
	#temp5.IDS = @Inc), 0)) > 0   
	Begin  
  
		Update #temp2 Set COPSC = IsNull((Select Cost From #temp5 Where IDS = @Inc), 0)  
		Where InvoiceID = @InvID And ItemCode = @ItemCode And SchType = @SchType And SchemeID = @SchID 
  
	End  
  
Set @Inc = @Inc + 1  
End  
  
-- Select * From #temp2  
-- Select * From #temp5  
  
Create Table #temp6 (InvoiceID Int, SchemeID Int, SchemeName nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS, SchemeType nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
SchemeSubType nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS, CurrentPeriodSalesValue Decimal(18, 6),   
CurrentPeriodSchemeValue Decimal(18, 6), ComparitivePeriodSalesValue Decimal(18, 6),  
ComparitivePeriodSchemeValue Decimal(18, 6), IncrementValue Decimal(18, 6),   
IncrementP Decimal(18, 6))  
  
Create Table #temp7 (SchemeID Int, SchemeName nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS, SchemeType nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS,   
SchemeSubType nVarChar(250) Collate SQL_Latin1_General_CP1_CI_AS, CurrentPeriodSalesValue Decimal(18, 6),   
CurrentPeriodSchemeValue Decimal(18, 6), ComparitivePeriodSalesValue Decimal(18, 6),  
ComparitivePeriodSchemeValue Decimal(18, 6), IncrementValue Decimal(18, 6),   
IncrementP Decimal(18, 6))  
  
Insert InTo #temp6  
Select Distinct ia.InvoiceID, sch.SchemeID, "Scheme Name" = sch.SchemeName, "Scheme Type" =   
(Case When sch.SchemeType In (1, 2, 3, 4) Then 'Invoice Based' 
      When sch.SchemeType In (97, 98, 99, 100) Then 'Item Based Invoice Discount' End),   
"Scheme SubType" = (Case When sch.SchemeType In (1) Then 'Amount'   
			 When sch.SchemeType In (2, 98, 100) Then 'Percentage'   
     			 When sch.SchemeType In (3, 97, 99) Then 'Free Items' 
			 When sch.SchemeType In (4) Then 'Items Worth X Amount Free' End),   
"Current Period Sale Value" = ia.Netvalue - ia.Freight,   
"Current Period Scheme Value" = Case When sch.SchemeType In (1, 2, 98, 100) Then   
    ia.[SchemeDiscountAmount] Else   
IsNull((Select Sum(Cost) From SchemeSale Where Type = ss.Type And InvoiceID = ia.InvoiceID), 0) End,   
"Comparitive Period Sale Value" = 0,   
  
"Comparitive Period Scheme Value" = 0,  
"Increment Value" = 0,  
"Increment %" = 0  
From Schemes sch
Inner Join InvoiceAbstract ia On ia.SchemeID = sch.SchemeID
Left Outer Join Schemesale ss On ss.Type = sch.SchemeID  
Where  
ia.Status & 192 = 0 And   
sch.SchemeType In (1, 2, 3, 4, 97, 98, 99, 100) And  
ia.InvoiceDate Between @FromDate And @ToDate And 
sch.SchemeName In (Select SchemeName From #tmpSch)
 
Union  
  
Select ia.InvoiceID, sch.SchemeID, "Scheme Name" = sch.SchemeName, "Scheme Type" =   
(Case When sch.SchemeType In (1, 2, 3, 4) Then 'Invoice Based' 
      When sch.SchemeType In (97, 98, 99, 100) Then 'Item Based Invoice Discount' End),   
"Scheme SubType" = (Case When sch.SchemeType In (1) Then 'Amount'   
			 When sch.SchemeType In (2, 98, 100) Then 'Percentage'   
     			 When sch.SchemeType In (3, 97, 99) Then 'Free Items' 
			 When sch.SchemeType In (4) Then 'Items Worth X Amount Free' End),   
"Current Period Sale Value" = 0,  
"Current Period Scheme Value" = 0,   
"Comparitive Period Sale Value" = ia.Netvalue - ia.Freight,   
  
"Comparitive Period Scheme Value" = Case When sch.SchemeType In (1, 2, 98, 100) Then   
    ia.[SchemeDiscountAmount] Else   
IsNull((Select Sum(Cost) From SchemeSale Where Type = ss.Type And InvoiceID = ia.InvoiceID), 0) End,   
"Increment Value" = 0,  
"Increment %" = 0  
From Schemes sch
Inner Join InvoiceAbstract ia On ia.SchemeID = sch.SchemeID 
Left Outer Join Schemesale ss On ss.Type = sch.SchemeID 
Where   
ia.Status & 192 = 0 And   
sch.SchemeType In (1, 2, 3, 4, 97, 98, 99, 100) And  
ia.InvoiceDate Between @CompFromDate And @CompToDate And 
sch.SchemeName In (Select SchemeName From #tmpSch) And  
sch.SchemeID In 
(Select sch.SchemeID From Schemes sch
Inner Join InvoiceAbstract ia On ia.SchemeID = sch.SchemeID
Left Outer Join Schemesale ss On ss.Type = sch.SchemeID 
Where ia.Status & 192 = 0 And   
sch.SchemeType In (1, 2, 3, 4, 97, 98, 99, 100) And  
ia.InvoiceDate Between @FromDate And @ToDate And 
sch.SchemeName In (Select SchemeName From #tmpSch)) 

Insert InTo #temp7  
Select SchemeID, SchemeName, SchemeType, SchemeSubType, Sum(CurrentPeriodSalesValue),  
Sum(CurrentPeriodSchemeValue), Sum(ComparitivePeriodSalesValue),   
Sum(ComparitivePeriodSchemeValue), Sum(IncrementValue),   
Sum(IncrementP) from #temp6   
Group By SchemeID, SchemeName, SchemeType, SchemeSubType  
  
Select "Scheme ID" = #temp2.SchemeID, "Scheme Name" = #temp2.SchemeName, "Scheme Type" =   
(Case When Schemes.SchemeType In (17, 83, 18, 84, 19, 81, 20, 82, 21, 22) Then 'Item Based' End),  
"Scheme SubType" = Case Schemes.SchemeType When 17 Then 'Same Item Free'  
	When 83  Then 'Same Item Free' 
        When 18 Then 'Different Item Free'  
	When 84 Then 'Different Item Free'  
        When 19 Then 'Percentage'  
	When 81 Then 'Percentage'  
        When 20 Then 'Amount' 
	When 82 Then 'Amount'
	When 21 Then 'Percentage Discount on Cheaper Item'
	When 22 Then 'Percentage Discount on Expensive Item' End,  
"Current Period Sales Value" = Sum(CPS),  
"Current Period Scheme Value" = Sum(CPSC),  
"Comparitive Period Sales Value" = Sum(COPS),  
"Comparitive Period Scheme Value" = Sum(COPSC),   
"Increment Value" = (Sum(CPS) - Sum(COPS)),  
"Increment %" = Case When Sum(COPS) = 0 Then 100 Else   
((Sum(CPS) - Sum(COPS)) / Sum(COPS))* 100 End  
From #temp2, Schemes Where  
#temp2.SchemeID = Schemes.SchemeID  
Group By #temp2.SchemeID, #temp2.SchemeName, Schemes.SchemeType  
  
Union   
  
Select "Scheme ID" = SchemeID, "Scheme Name" = SchemeName, "Scheme Type" = SchemeType,  
"Scheme SubType" = SchemeSubType, "Current Period Sales Value" = CurrentPeriodSalesValue,  
"Current Period Scheme Value" = CurrentPeriodSchemeValue,  
"Comparitive Period Sales Value" = ComparitivePeriodSalesValue,  
"Comparitive Period Scheme Value" = ComparitivePeriodSchemeValue,   
"Increment Value" = (CurrentPeriodSalesValue - ComparitivePeriodSalesValue),  
"Increment %" = Case When ComparitivePeriodSalesValue = 0 Then 100 Else   
((CurrentPeriodSalesValue - ComparitivePeriodSalesValue) / ComparitivePeriodSalesValue)* 100 End  
From #temp7   
  
Drop Table #temp1  
Drop Table #temp2  
Drop Table #temp3  
Drop Table #temp4  
Drop Table #temp5  
Drop Table #temp6  
Drop Table #temp7  
Drop Table #tmpSch  
