CREATE Procedure SP_Get_SODetailForInvoice(@SONo nvarchar(255))  
AS  
--This procedure returns the Pending SO Details By UOM Wise.  
Declare @ProductCode nvarchar(30)  
Declare @BatchNumber nvarchar(128)  
Declare @SalePrice decimal(18,6)  
Declare @PendingQty nvarchar(62)  
Declare @ECP decimal(18,6)  
Declare @Discount decimal(18,6)  
Declare @SaleTax decimal(18,6)  
Declare @TaxSuffered decimal(18,6)  
declare @TaxApplicableOn int  
declare @TaxPartOff decimal(18,6)  
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
 Product_Code nvarchar(30),   
 Batch_Number nvarchar(128),   
 SalePrice Decimal(18,6),   
 Quantity Decimal(18,6),  
 UomDescription nvarchar(255),  
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
  
Select @Pending = Sum(Pending), @Quantity= Sum(Quantity) From SODetail Where SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,','))
If @Pending = @Quantity
Begin
		Select * into #tempScNew from dbo.sp_splitin2rows(@sono,',')  
		Insert Into #TempUOMWiseSODetail Select SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,  
  sum(SODetail.Pending)as Quantity, UOM.Description, 
		Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,  
		TaxSuffPartOff , (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",
		sodetail.taxsuffered, SoDetail.UOM, SoDetail.UomPrice, sodetail.serial  
	 From SOAbstract, SODetail, #tempScNew, Customer, Uom  
		WHERE SODetail.SONumber = #tempScNew.itemvalue   
		And Customer.CustomerId = SOAbstract.CustomerID  
		And SOAbstract.SONumber = #tempScNew.itemvalue   
  And SoDetail.UOM = UOM.UOM
		GROUP BY  sodetail.serial,SODetail.Product_Code,SODetail.Batch_Number,SoDetail.SalePrice  ,  
		Sodetail.Ecp,Sodetail.Discount,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff ,sodetail.saletax,sodetail.taxcode2,  
		sodetail.taxsuffered, Customer.Locality, UOM.Description, SoDetail.UOM, SoDetail.UomPrice 
		having sum(sodetail.pending) > 0   
		order by sodetail.serial  

		Select * from #TempUOMWiseSODetail order by Serial  
		Drop Table #TempUOMWiseSODetail  
		Drop Table #tempScNew
End
Else
Begin
		Select * into #tempSc from dbo.sp_splitin2rows(@sono,',')  
		Select SODetail.Product_Code,SoDetail.Batch_Number,soDetail.SalePrice,  
		dbo.GetQtyAsMultiple(SODetail.Product_Code, sum(SODetail.Pending))as pending,  
		Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,  
		TaxSuffPartOff , (Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",sodetail.taxsuffered,sodetail.serial  
		into #TempSODetail From SOAbstract, SODetail, #tempSc, Customer  
		WHERE SODetail.SONumber = #tempSc.itemvalue   
		And Customer.CustomerId = SOAbstract.CustomerID  
		And SOAbstract.SONumber = #tempSc.itemvalue   
		GROUP BY  sodetail.serial,SODetail.Product_Code,SODetail.Batch_Number,SoDetail.SalePrice  ,  
		Sodetail.Ecp,Sodetail.Discount,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff ,sodetail.saletax,sodetail.taxcode2,  
		sodetail.taxsuffered, Customer.Locality  
		having sum(sodetail.pending) > 0   
		order by sodetail.serial  
		  
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
		   if @count = 1   
		   begin  
		    Select @UOM = UOM2, @UOMConversion = UOM2_Conversion   
		    From Items Where Product_Code = @ProductCode  
		   end  
		   else if @count = 2  
		   begin  
		    Select @UOM = UOM1, @UOMConversion = UOM1_Conversion   
		    From Items Where Product_Code = @ProductCode  
		   end  
		   else  
		   begin  
		    Select @UOM = UOM, @UOMConversion = 1   
		    From Items Where Product_Code = @ProductCode  
		   end   
		   select @UomDescription = Description from uom where uom = @uom  
		   Set @UOMPrice = @SalePrice * @UOMConversion  
		   set @Qty = @Qty * @UOMConversion  
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
		Drop table #TempSODetail  
		Select * from #TempUOMWiseSODetail order by Serial  
		Drop Table #TempUOMWiseSODetail   
		drop table #tempSc   
End  


