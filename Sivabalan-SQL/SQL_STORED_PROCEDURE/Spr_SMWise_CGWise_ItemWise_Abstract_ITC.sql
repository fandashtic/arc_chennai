Create Procedure Spr_SMWise_CGWise_ItemWise_Abstract_ITC        
(        
 @SalesMan NVarChar(4000),        
 @Beat NVarChar(4000),
 @DSType nVarchar(4000),
 @Group NVarChar(4000),        
 @UOM NVarChar(10),        
 @FromDate Datetime,        
 @ToDate Datetime        
)          
As          
Declare @Delimeter As NVarChar(1)        
Declare @Others as nVarchar(50)    
Declare @OtherBeat as nVarchar(50)    
Declare @GroupID Int        


Set @Delimeter=Char(15)     
             
        
Create Table #TmpSalesMan(SalesManID Int)        
Create Table #TmpBeat(BeatID Int)        
Create Table #TmpGroup(GroupID Int)        
Create Table #TmpItem(GroupID Int,Product_Code NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS)        
  
    
Set @OTHERS = dbo.LookUpDictionaryItem(N'Others',Default)    
Set @OTHERBEAT = dbo.LookUpDictionaryItem(N'OtherBeat',Default)        
        
If @SalesMan = N'%'        
Begin        
 Insert InTo #TmpSalesMan  Select Distinct SalesManID From SalesMan        
 Insert Into #TmpSalesMan Values(0)        
End        
Else        
 Insert InTo #TmpSalesMan        
 Select Distinct SalesManID From SalesMan Where SalesMan_Name In (Select * From Dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))        
        
If @SalesMan = N'%' And @Beat = N'%'        
Begin        
 Insert InTo #TmpBeat Select Distinct BeatID From Beat        
 Insert Into #TmpBeat Values(0)        
End        
Else If @SalesMan <> N'%' And @Beat = N'%'        
Begin        
 Insert InTo #TmpBeat        
 Select BeatID From Beat_SalesMan Where SalesManID In (Select SalesManID From #TmpSalesMan) Group By BeatID        
 Insert Into #TmpBeat Values(0)        
End        
Else        
 Insert InTo #TmpBeat        
 Select BeatID From Beat Where [Description] In (Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))        
        
If @Group = N'%'        
 Insert InTo #TmpGroup Select Distinct GroupID From ProductCategoryGroupAbstract        
Else        
 Insert InTo #TmpGroup        
 Select GroupID From ProductCategoryGroupAbstract Where GroupName In (Select * From Dbo.sp_SplitIn2Rows(@Group,@Delimeter))        
       

Create table #tmpDSType(SalesmanID Int,DSTypeName nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS) 

if @DSType = N'%' or @DSType = N''
Begin        
   Insert into #tmpDSType 
   select Salesman.SalesmanID,DSTypeValue from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
   and DSType_Master.DSTypeCtlPos = 1 
   Union
   Select SalesmanID,'' from Salesman where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1)
End
Else        
Begin
   Insert into #tmpDSType 
   select SalesmanID,DSTypeValue from DSType_Master,DSType_Details
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
   and DSType_Master.DSTypeCtlPos = 1 
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter)) 
End


Declare Parent Cursor Keyset For Select GroupID From #TmpGroup        
Open Parent        
Fetch From Parent Into @GroupID        
While @@Fetch_Status = 0            
Begin            
 Insert Into #TmpItem Select @GroupID,Product_Code From dbo.Sp_Get_ItemsFrmCG_ITC(@GroupID)        
 Fetch Next From Parent Into @GroupID        
End        
Close Parent        
DeAllocate Parent        
        
Create Table #TmpSale        
(        
 InvoiceId Int, GroupId Int, SalesMan nVarchar(510),DSTypeName nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
 Beat nVarChar(510),        
 GroupName nVarchar(510), 
 GrossValue Decimal(18,6),DiscountAmount Decimal(18,6),  
 SchemeDiscAmount Decimal(18,6),TaxAmount Decimal(18,6),Freight Decimal(18,6), TotalValue Decimal(18,6),Balance Decimal(18,6)        
)        
        
Insert into #TmpSale        
 Select         
  IA.InvoiceID,PCA.GroupID,        
  Case IsNull(IA.SalesManID,0)        
   When 0 Then @OTHERS    
   Else SM.SalesMan_Name         
  End, 
 dd.DSTypeName,        
  Case IsNull(IA.BeatID,0)        
   When 0 Then @OTHERBEAT    
   Else Beat.[Description]        
  End,        
  PCA.GroupName,        
  (Case IA.Invoicetype When 4 Then -1 Else 1 End)* sum(IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)),    
  (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (Sum(IsNull(IDE.DiscountValue,0) - (IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0)) )    
  +Sum( (IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0))  *((IsNull(IA.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))    
  +Sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) * IsNull(IA.AdditionalDiscount,0)/100.)),    
  (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (Sum(IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0))    
  +sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)),    
  (Case IA.Invoicetype When 4 Then -1 Else 1 End) *Sum(IsNull(CSTPayable,0) + IsNull(STPayable,0)),   
  (Case IA.Invoicetype When 4 Then -1 else 1 End) * IA.Freight,     
  (Case IA.Invoicetype When 4 Then -1 Else 1 End) * Sum(Amount),         
  (Case IA.Invoicetype When 4 Then -1 Else 1 End)* sum((Amount/Case NetValue When 0 Then 1 Else NetValue End)*Balance)   
 From        
  InvoiceAbstract IA,SalesMan SM,Beat,InvoiceDetail IDE,        
  ProductCategoryGroupAbstract PCA,#TmpItem TI,#tmpDSType  DD         
 Where        
  IsNull(IA.SalesManID,0)= SM.SalesManID          
  And IsNull(IA.BeatID,0)= Beat.BeatID       
  and Isnull(IA.SalesmanID,0)=DD.SalesmanID	 
  And Invoicedate Between @FromDate And @Todate        
  And IA.Status & 128 = 0        
  And IA.InvoiceType In (1,3,4)          
  --And IsNull(IA.GroupId,0) = 0        
  And IA.InvoiceID = IDE.InvoiceID        
  And IsNull(IA.SalesManID,0) In (Select SalesManID From #TmpSalesMan)        
  And IsNull(IA.BeatID,0)  In (Select BeatID From #TmpBeat)        
  And IDE.Product_Code = TI.Product_Code      
  And PCA.GroupID = IsNull(TI.GroupID,0)        
 Group By        
  IA.InvoiceID,IA.SalesManID,DD.DSTypeName, IA.BeatID,SM.SalesMan_Name,        
  Beat.[Description],PCA.GroupName,PCA.GroupID,IA.InvoiceType,IDE.FlagWord,IA.Freight       

        
Select         
--Bottom Frame did not generate if beat description has : character. 
SalesMan+char(15)+Beat+char(15)+GroupName,
--SalesMan+':'+Beat+':'+GroupName,
"DS Name" = SalesMan,"DS Type" = DSTypeName,Beat,        
"Category Group" = GroupName,"GrossValue" = Sum(GrossValue),"Discount(%c)" = Sum(DiscountAmount),      
"Scheme Discount(%c)" = Sum(SchemeDiscAmount),"Tax Amount " = Sum(TaxAmount),    
"Net Value" = Sum(TotalValue) ,"Balance" = Sum(Balance)        
From        
 #TmpSale        
Group By        
 SalesMan,DSTypeName,Beat,GroupName,GroupID      
        
Drop Table #TmpSalesMan        
Drop Table #TmpBeat        
Drop Table #TmpGroup        
Drop Table #TmpItem        
Drop table #TmpSale  
drop table #tmpDSType  
