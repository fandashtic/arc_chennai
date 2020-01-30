Create Procedure Spr_SMWise_CGWise_ItemWise_Detail_ITC          
(          
 @Dummy NVarChar(4000),          
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
Declare @GroupID Int          

Set @Delimeter=Char(15)                
        
If @UOM = N'Base UOM'         
 Set @UOM = N'UOM'        
          
Create Table #Temp(AllID Integer Identity(1,1),AllName NVarChar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #TmpSalesMan(SalesManID Int)          
Create Table #TmpBeat(BeatID Int)          
Create Table #TmpGroup(GroupID Int)          
Create Table #TmpItem(GroupID Int,Product_Code NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create table #TempCategory1(IDS Int Identity(1,1), CategoryID Int,Category NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)                       
          
Exec sp_CatLevelwise_ItemSorting          

--Bottom Frame did not generated if beat description has : character.
Insert Into #Temp Select * from dbo.sp_SplitIn2Rows(@Dummy,@Delimeter)                      
--Insert Into #Temp Select * from dbo.sp_SplitIn2Rows(@Dummy,':')            
          
          
Insert InTo #TmpSalesMan Values(0)          
Insert InTo #TmpSalesMan Select Distinct SalesManID From SalesMan Where SalesMan_Name In (Select AllName From #Temp Where AllID = 1)          


          
Insert InTo #TmpBeat Values(0)                      
Insert InTo #TmpBeat Select BeatID From Beat Where [Description] In (Select AllName From #Temp Where AllID = 2)          
          
Insert InTo #TmpGroup Select GroupID From ProductCategoryGroupAbstract Where GroupName In (Select AllName From #Temp Where AllID = 3)          
          
If Not Exists (Select * From #TmpGroup)          
 Insert Into #TmpItem Select 0,Product_Code From Items          
Else          
 Begin          
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
 End          


          
Select            
 IDE.Product_Code,          
 "ItemCode" = IDE.Product_Code,          
 "Item Name" = Items.ProductName,          
 "Manufacturer" = Manufacturer.Manufacturer_Name,          
 "Batch" = IDE.Batch_Number,          
 "SalePrice" = IDE.SalePrice *          
  Case @UOM                 
   When N'UOM' Then 1          
   When N'UOM1' Then IsNull(Items.UOM1_Conversion,1)                
   When N'UOM2' Then IsNull(Items.UOM2_Conversion,1)            
  End,          
 "UOM"=           
  Case @UOM                 
   When N'UOM' Then IsNull((Select [Description] From UOM Where UOM = Items.UOM),'')                  
   When N'UOM1' Then IsNull((Select [Description] From UOM Where UOM = Items.UOM1),'')            
   When N'UOM2' Then IsNull((Select [Description] From UOM Where UOM = Items.UOM2),'')            
  End,          
 "Quantity" =           
  Case @UOM          
   When N'UOM' Then Sum(ISNULL(IDE.Quantity, 0))                
   When N'UOM1' Then Sum(IsNull(IDE.Quantity,0) / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End))            
   When N'UOM2' Then Sum(IsNull(IDE.Quantity,0) / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End))          
  End,          
"Gross Value " =  Sum((Case IA.Invoicetype When 4 Then -1 Else 1 End) * (IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0))) ,              
 "Discount %" =           
(case isnull(IDE.FlagWord,0)   
   when 0 then((Case IA.InvoiceType When 4 Then -1 Else 1 End) * (Sum(IsNull(IDE.DiscountValue,0) - (IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0)) )        
  +Sum( (IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0))  *((IsNull(IA.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))        
  +Sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) * IsNull(IA.AdditionalDiscount,0)/100.)))          
else  0 end)/  
sum(IsNull(IDE.Quantity,0)*(case isNull(IDE.SalePrice,0) when 0 then 1 else isNull(IDE.SalePrice,0)end)) * 100.,  
        
 "Discount(%c)" =           
 (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (Sum(IsNull(IDE.DiscountValue,0) - (IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0)) )        
  +Sum( (IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0))  *((IsNull(IA.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))        
  +Sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) * IsNull(IA.AdditionalDiscount,0)/100.)),          
 "Scheme Discount %" =          
 (case isnull(IDE.FlagWord,0) when 0 then((Case IA.InvoiceType When 4 Then -1 Else 1 End) *   
   (Sum(IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0))        
  +sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)))        
 else 0 end)/sum(IsNull(IDE.Quantity,0)*(case isNull(IDE.SalePrice,0) when 0 then 1 else isNull(IDE.SalePrice,0)end) ) * 100,        
 "Scheme Discount (%c)" =           
 (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (Sum(IsNull(IDE.SchemeDiscAmount,0) + IsNull(IDE.SplCatDiscAmount,0))        
  +sum((IsNull(IDE.Quantity,0)*IsNull(IDE.SalePrice,0)-IsNull(IDE.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)),        
 "Tax %"   =       
(Case InvoiceType When 4 Then -1 else 1 End) * (isNull(IDE.Taxcode,0)+IsNull(IDE.TaxCode2,0)),          
"Tax Amount" =           
(Case InvoiceType When 4 Then -1 else 1 End) * sum(IsNull(IDE.CSTPayable,0)+IsNull(IDE.STPayable,0)),          
"Net Value" =           
  Case InvoiceType          
   When 4 Then Sum(0-IDE.Amount)          
   Else Sum(IDE.Amount)          
  End          
From          
 InvoiceAbstract IA,InvoiceDetail IDE,Items,Manufacturer,#TmpItem TI,#TempCategory1 TC          
Where          
 IA.InvoiceID = IDE.InvoiceID          
 And Items.CategoryID = TC.CategoryID          
 And Items.Product_Code = IDE.Product_Code          
 And IDE.Product_Code = TI.Product_Code          
 And Manufacturer.ManufacturerID = Items.ManufacturerID           
 And IA.Invoicedate Between @FromDate And @Todate          
 And IsNull(IA.SalesManID,0) In (Select SalesManID From #TmpSalesMan)          
 And IsNull(IA.BeatID,0)  In (Select BeatID From #TmpBeat)          
 And IA.Invoicetype In (1,3,4)          
 And IsNull(IA.Status,0) & 128 = 0          
Group By          
IDE.Product_Code,Items.ProductName,Manufacturer.Manufacturer_Name,IDE.SalePrice,          
IDE.Batch_Number,IDE.SalePrice,[Description],Items.UOM,Items.UOM1,Items.UOM2,          
IA.InvoiceType,TC.IDS,Items.UOM1_Conversion,Items.UOM2_Conversion,          
IDE.Taxcode,IDE.TaxCode2,IDE.FlagWord        
Order by          
 TC.IDS          
          
Drop Table #Temp          
Drop Table #TmpSalesMan          
Drop Table #TmpBeat          
Drop Table #TmpGroup          
Drop Table #TmpItem          
Drop table #TempCategory1     
