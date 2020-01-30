CREATE Procedure SP_Get_SODetailForVanInvoice(@SONo nvarchar(255), @VanStmtID Int)                    
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
From SODetail SOD Where SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,','))                  
If @Pending = @Quantity                  
  Begin                  
    Select * into #tempScNew from dbo.sp_splitin2rows(@sono,',')                    
    Insert Into #TempUOMWiseSODetail                 
  Select SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,                    
   (Case When (Select sum(Pending) From SoDetail Where SONumber in(Select itemvalue From  #tempScNew) and Product_Code = VanDetails.Product_Code) <=     
   (Select Sum(Pending) From VanStatementDetail Where Product_Code = SODetail.Product_Code And DocSerial = @VanStmtID)      
   Then (Select sum(Pending) From SoDetail Where SONumber in(Select itemvalue From  #tempScNew) and Product_Code = VanDetails.Product_Code)    
   Else (Select Sum(Pending) From VanStatementDetail Where Product_Code = SODetail.Product_Code And DocSerial = @VanStmtID) End) as AvailQty,                
  UOM.Description,Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,                    
  TaxSuffPartOff , (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",                  
  SoDetail.taxsuffered, SoDetail.UOM, SoDetail.UomPrice, sodetail.serial                    
  From SOAbstract, SODetail, Customer, Uom,     
    (Select Product_Code From VanStatementDetail Where DocSerial = @VanStmtID Group by Product_Code) as VanDetails      
  WHERE SODetail.SONumber in (Select Itemvalue From  #tempScNew)      
  And Customer.CustomerId = SOAbstract.CustomerID      
  And SoDetail.UOM = UOM.UOM                  
  And VanDetails.Product_Code = SoDetail.Product_code       
  GROUP BY  sodetail.serial, SODetail.Product_Code, VanDetails.Product_Code, SODetail.Batch_Number,SoDetail.SalePrice  ,                  
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
    Select * into #tempSc from dbo.sp_splitin2rows(@sono,',')           
    Select SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,                    
    dbo.GetQtyAsMultiple(SODetail.Product_Code,(Case When sum(SODetail.Pending) <= sum(VanDetails.Pending)                 
    Then sum(SODetail.Pending) Else sum(VanDetails.Pending) End)) as AvailQty,                
    Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,                    
    TaxSuffPartOff , (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",sodetail.taxsuffered,sodetail.serial                    
    into #TempSODetail From SOAbstract, SODetail, #tempSc, Customer,             
  (Select Product_Code, DocSerial, Sum(Pending) as Pending             
  From VanStatementDetail Where DocSerial = @VanStmtID -- And (SalePrice+PTS) > 0             
  Group By Product_Code, DocSerial) VanDetails            
    WHERE SODetail.SONumber = #tempSc.itemvalue                     
    And Customer.CustomerId = SOAbstract.CustomerID                    
    And SOAbstract.SONumber = #tempSc.itemvalue                    
    And VanDetails.Product_Code = SODetail.Product_Code                 
    GROUP BY  Sodetail.serial,SODetail.Product_Code,SODetail.Batch_Number,SoDetail.SalePrice  ,                    
    Sodetail.Ecp,Sodetail.Discount,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff ,Sodetail.saletax, Sodetail.taxcode2,                    
    Sodetail.taxsuffered, Customer.Locality                    
    Having sum(Sodetail.pending) > 0                     
    Order by Sodetail.serial                    
                      
    Declare CurSODetails Cursor for Select * from #TempSODetail                    
    Open CurSODetails                     
    Fetch From CurSODetails into @ProductCode,@BatchNumber,@SalePrice,@PendingQty,                     
    @ECP,@Discount,@TaxApplicableOn,@TaxPartOff,@TaxSuffApplicableOn,                    
    @TaxSuffPartOff,@saletax,@taxsuffered,@serial                    
                      
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
      Fetch From CurSODetails into @ProductCode, @BatchNumber, @SalePrice, @PendingQty,                    
      @ECP,@Discount, @TaxApplicableOn, @TaxPartOff, @TaxSuffApplicableOn,                    
      @TaxSuffPartOff, @saletax, @taxsuffered, @serial                    
      Drop table #TempQty                     
      Close CurQty                    
      Deallocate CurQty                    
    End                    
  Close CurSODetails                    
  Deallocate CurSODetails                    
  Drop table #TempSODetail                    
  Select * from #TempUOMWiseSODetail order by Serial                    
  Drop Table #TempUOMWiseSODetail                     
  Drop table #tempSc                     
  End


