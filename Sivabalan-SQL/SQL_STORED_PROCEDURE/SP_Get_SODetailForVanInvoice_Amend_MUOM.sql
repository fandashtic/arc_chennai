CREATE Procedure SP_Get_SODetailForVanInvoice_Amend_MUOM(@SONo nvarchar(255), @VanStmtID Int, @InvNo Int)              
AS        
--This procedure returns the Pending SO Details By UOM Wise for Van.              
Declare @ProductCode nvarchar(30)              
Declare @BatchNumber nvarchar(128)              
Declare @SalePrice decimal(18,6)              
Declare @PendingQty nvarchar(62)              
Declare @ECP decimal(18,6)              
Declare @Discount decimal(18,6)              
Declare @SaleTax decimal(18,6)              
Declare @TaxSuffered decimal(18,6)              
Declare @TaxApplicableOn int              
Declare @TaxPartOff decimal(18,6)              
Declare @TaxSuffApplicableOn int              
Declare @TaxSuffPartOff decimal(18,6)              
Declare @Qty Decimal(18,6)              
Declare @Count int              
Declare @UOM Int              
Declare @UOMConversion Decimal(18,6)              
Declare @UOMPrice Decimal(18,6)              
Declare @UOMDescription nvarchar(510)              
Declare @Serial int              
Declare @Pending Decimal(18,6)            
Declare @Quantity Decimal(18,6)            
Declare @SCLIST nVarchar(1000)              
Create Table #TempUOMWiseSODetail(              
 Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,               
 Batch_Number nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,               
 SalePrice Decimal(18,6),               
 Quantity Decimal(18,6),              
 UomDescription nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,              
 ECP decimal(18,6),               
 Discount decimal(18,6),              
 TaxApplicableOn int,              
 TaxPartOff Decimal(18,6),              
 TaxSuffApplicableOn int,              
 TaxSuffPartOff Decimal(18,6),              
 saletax Decimal(18,6),              
 taxsuffered Decimal(18,6),               
 UOM Int,               
 UOMPrice Decimal(18,6),              
 Serial int              
 )            
              
Select @Pending = Sum(Pending), @Quantity= Sum(Quantity)           
From SODetail SOD Where SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,N','))            
If @Pending = @Quantity            
  Begin            
    Select * into #tempScNew from dbo.sp_splitin2rows(@SONo,N',')              
    Insert Into #TempUOMWiseSODetail           
    Select SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,              
    (Case When sum(SODetail.Pending) <= sum(VanStatementDetail.Pending)           
    Then sum(SODetail.Pending) Else sum(VanStatementDetail.Pending) End) as AvailQty,          
    UOM.Description,Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,              
    TaxSuffPartOff , (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",            
    SoDetail.taxsuffered, SoDetail.UOM, SoDetail.UomPrice, sodetail.serial              
    From SOAbstract, SODetail, #tempScNew, Customer, Uom, VanStatementDetail           
    WHERE SODetail.SONumber = #tempScNew.itemvalue               
    And Customer.CustomerId = SOAbstract.CustomerID              
    And SOAbstract.SONumber = #tempScNew.itemvalue               
    And SoDetail.UOM = UOM.UOM            
    And VanStatementDetail.DocSerial = @VanStmtID          
    And VanStatementDetail.Product_Code = SODetail.Product_Code      
--     And VanStatementDetail.SalePrice > 0      
    GROUP BY  sodetail.serial,SODetail.Product_Code,SODetail.Batch_Number,SoDetail.SalePrice  ,              
    Sodetail.Ecp,Sodetail.Discount,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff ,sodetail.saletax,sodetail.taxcode2,              
    Sodetail.taxsuffered, Customer.Locality, UOM.Description, SoDetail.UOM, SoDetail.UomPrice             
    Having sum(sodetail.pending) > 0               
    Order by sodetail.serial  
   
Select * from #TempUOMWiseSODetail order by Serial              
    Drop Table #TempUOMWiseSODetail              
    Drop Table #tempScNew            
  End            
Else            
  Begin      
   Create Table #TempSO(                
   Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,                 
   Batch_Number nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,                 
   SalePrice Decimal(18,6),                 
   Quantity Decimal(18,6),                
   ECP decimal(18,6),                 
   Discount decimal(18,6),                
   TaxApplicableOn int,                
   TaxPartOff Decimal(18,6),                
   TaxSuffApplicableOn int,                
   TaxSuffPartOff Decimal(18,6),                
   saletax Decimal(18,6),                
   taxsuffered Decimal(18,6),         
   Serial int )         
      
   Select * into #tempSc from dbo.sp_splitin2rows(@SOno,N',')                
   Select @SCLIST = SoNumber From InvoiceAbstract Where InvoiceID = @InvNo        
       
 -- To collect SO detail       
   Insert into #TempSO     
   Select Distinct SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,            
    sum(SODetail.Pending) as AvailQty,        
    Sodetail.Ecp,Sodetail.Discount, SODetail.TaxApplicableOn,      
    SODetail.TaxPartOff, SODetail.TaxSuffApplicableOn,            
    SODetail.TaxSuffPartOff, (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",    
    SoDetail.taxsuffered, sodetail.serial            
   From SOAbstract, SODetail, Customer, #tempSc      
   Where SODetail.SONumber =  #tempSc.itemvalue       
    And Customer.CustomerId = SOAbstract.CustomerID            
    And SOAbstract.SONumber =  #tempSc.itemvalue       
   Group By SODetail.SoNumber, SODetail.Product_Code, SODetail.Batch_Number, SoDetail.SalePrice,             
    Sodetail.Ecp,Sodetail.Discount,SODetail.TaxApplicableOn, SODetail.TaxPartOff,      
    SODetail.TaxSuffApplicableOn, SODetail.TaxSuffPartOff ,Sodetail.saletax, Sodetail.taxcode2,            
    SoDetail.taxsuffered, sodetail.serial, Customer.Locality       
    UNION ALL    
 -- To Collect Invoice Detail    
   Select Distinct SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,              
   (IsNull(Sum(InvDet.Quantity),0) - (Select IsNull(Sum(Exs_Qty),0) From InvFromSoDetail Where InvFromSoDetail.InvoiceID = @InvNo And InvFromSoDetail.Sonumber = SODetail.SONumber And InvFromSoDetail.Product_code = SODetail.Product_Code)) as AvailQty,     
  
    
    Sodetail.Ecp,Sodetail.Discount, SODetail.TaxApplicableOn,        
    SODetail.TaxPartOff, SODetail.TaxSuffApplicableOn,              
    SODetail.TaxSuffPartOff, (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",      
    SoDetail.taxsuffered, sodetail.serial      
   From SOAbstract, SODetail, Customer, InvoiceDetail InvDet      
   Where SOAbstract.SONumber  = SODetail.SONumber       
    And Customer.CustomerId = SOAbstract.CustomerID              
    And SOAbstract.SONumber in(Select * from dbo.sp_splitin2Rows(@SCLIST,N','))      
    And InvDet.InvoiceID = @InvNo        
    And SODetail.Product_code = InvDet.Product_Code          
    And InvDet.FlagWord = 0        
   Group By  SODetail.SoNumber, SODetail.Product_Code, SODetail.Batch_Number, SoDetail.SalePrice,               
    Sodetail.Ecp,Sodetail.Discount,SODetail.TaxApplicableOn, SODetail.TaxPartOff,        
    SODetail.TaxSuffApplicableOn, SODetail.TaxSuffPartOff ,Sodetail.saletax, Sodetail.taxcode2,              
    SoDetail.taxsuffered, sodetail.serial, Customer.Locality      
    
--  -- To Compare with Van Stmt Detail Qty       
   Select TSO.Product_Code, TSO.Batch_Number, TSO.SalePrice,            
   CASE WHEN (IsNull(Sum(TSO.Quantity),0) <= (Sum(VSD.Pending)+ ((Select IsNull(Sum(Quantity), 0) From InvoiceDetail Where Product_Code = TSO.Product_code And InvoiceID = @InvNo)-(Select IsNull(Sum(Exs_Qty), 0) From InvFromSoDetail InvSO, #TempSC TSC   
  				Where InvSO.SoNumber = TSC.ItemValue And InvSO.Product_Code = TSO.Product_code And InvSO.InvoiceID = @InvNo))))       
    THEN IsNull(Sum(TSO.Quantity),0)      
    ELSE (Sum(VSD.Pending)+ ((Select IsNull(Sum(Quantity), 0) From InvoiceDetail Where Product_Code = TSO.Product_code And InvoiceID = @InvNo)-(Select IsNull(Sum(Exs_Qty), 0) From InvFromSoDetail InvSO, #TempSC TSC   
  				Where InvSO.SoNumber = TSC.ItemValue And InvSO.Product_Code = TSO.Product_code And InvSO.InvoiceID = @InvNo))) End as AvailQty,
   TSO.Ecp, TSO.Discount, TSO.TaxApplicableOn, TSO.TaxPartOff, TSO.TaxSuffApplicableOn,            
   TSO.TaxSuffPartOff, TSO.SaleTax, TSO.taxsuffered, TSO.serial    
   Into #TempSODetail     
   From #TempSO TSO, (Select Product_Code, Sum(Pending) as Pending From VanStatementDetail Where DocSerial = @VanStmtID Group By Product_Code) as VSD     
   Where VSD.Product_Code = TSO.Product_code       
--    And (VSD.SalePrice + VSD.PTS) > 0      
   Group By  TSO.Product_Code, TSO.Batch_Number, TSO.SalePrice,         
    TSO.Ecp,TSO.Discount, TSO.TaxApplicableOn, TSO.TaxPartOff,      
    TSO.TaxSuffApplicableOn, TSO.TaxSuffPartOff, TSO.SaleTax, TSO.taxsuffered, TSO.serial    
   Order by TSO.serial      
      
   Declare CurSODetails Cursor for     
   Select Product_Code, Batch_Number, SalePrice, dbo.GetQtyAsMultiple(Product_Code,Sum(AvailQty)), Ecp, Discount, TaxApplicableOn,       
   TaxPartOff, TaxSuffApplicableOn, TaxSuffPartOff, SaleTax, Taxsuffered, serial From #TempSODetail      
   Group by Product_Code, Batch_Number, SalePrice, Ecp, Discount,       
   TaxApplicableOn, TaxPartOff, TaxSuffApplicableOn, TaxSuffPartOff, SaleTax,     
   taxsuffered, serial    
   Order by serial      
   Open CurSODetails               
   Fetch From CurSODetails into @ProductCode,@BatchNumber,@SalePrice,@PendingQty,               
   @ECP,@Discount,@TaxApplicableOn,@TaxPartOff,@TaxSuffApplicableOn,              
   @TaxSuffPartOff, @saletax, @taxsuffered, @serial           
               
    While @@Fetch_Status = 0        
    Begin            
      Set @count = 0             
      Select * into #TempQty From Dbo.Sp_SplitIn2Rows(@PendingQty,'*')            
      Declare CurQty Cursor for Select * from #TempQty            
      Open CurQty            
      Fetch From CurQty into @Qty            
        While @@Fetch_Status = 0            
        Begin             
          Set @count = @count + 1            
          If @Qty > 0            
        Begin            
          If @count = 1             
              Begin            
           Select @UOM = UOM2, @UOMConversion = UOM2_Conversion             
        From Items Where Product_Code = @ProductCode            
           End            
          Else if @count = 2            
              Begin            
            Select @UOM = UOM1, @UOMConversion = UOM1_Conversion             
            From Items Where Product_Code = @ProductCode            
              End            
          Else            
           Begin            
        Select @UOM = UOM, @UOMConversion = 1             
        From Items Where Product_Code = @ProductCode            
           End             
          Select @UomDescription = Description from uom where uom = @uom            
          Set @UOMPrice = @SalePrice * @UOMConversion            
          Set @Qty = @Qty * @UOMConversion            
          Insert into #TempUOMWiseSODetail             
          Values(@ProductCode, @BatchNumber, @SalePrice, @Qty,            
          @UomDescription,@ECP,@Discount,@TaxApplicableOn,@TaxPartOff,@TaxSuffApplicableOn,            
          @TaxSuffPartOff,@saletax,@taxsuffered, @UOM, @UOMPrice,@serial)            
           End       
    Fetch From CurQty into @Qty            
     End            
    Fetch From CurSODetails into @ProductCode,@BatchNumber,@SalePrice,@PendingQty,            
    @ECP,@Discount,@TaxApplicableOn,@TaxPartOff,@TaxSuffApplicableOn,            
    @TaxSuffPartOff,@saletax,@taxsuffered,@serial            
    Drop table #TempQty             
    Close CurQty            
    Deallocate CurQty            
    End            
  Close CurSODetails              
  Deallocate CurSODetails              
 Drop Table #TempSODetail      
  Drop table #TempSO                
 Select * from #TempUOMWiseSODetail order by Serial              
  Drop Table #TempUOMWiseSODetail               
  drop table #tempSc               
  End          
    
  



