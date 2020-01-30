CREATE procedure sp_update_BillAmendItems(@Bill_ID int,   
     @Product_Code as nvarchar(50),   
     @Qty Decimal(18,6),   
     @Price Decimal(18,6),   
     @Amount Decimal(18,6),  
     @TaxSuffered Decimal(18,6),   
     @TaxAmount Decimal(18,6),   
     @Taxcode int,  
     @Discount Decimal(18,6),  
     @Batch nvarchar(255),  
     @Expiry datetime,  
     @PKD datetime,  
     @PTS Decimal(18,6),  
     @PTR Decimal(18,6),  
     @ECP Decimal(18,6),  
     @SpecialPrice Decimal(18,6),  
     @Promotion Int = 0,  
     @ExciseDuty Decimal(18,6) = 0,  
     @PurchasePriceBeforeExciseAmount Decimal(18,6) = 0,  
     @ExciseID Int = 0,  
     @VAT int = 0)  
as  

declare @grnid varchar(255)
create table #Tempgrn (grnid int)
If @Promotion = 1   
Begin  
 --when multiple grn is selected, the grnid is in form of comma separated values
 --So we have to split that value into table #tempgrn and used in where condition
 Select @GRNID=grnid From BillAbstract Where BillID = @Bill_Id
 Insert into #tempgrn Select * From dbo.sp_SplitIn2Rows(@grnid,',')
 Select @ECP = ECP From Batch_Products Where Batch_Code In (Select BatchReference  
 From Batch_Products Where Product_Code = @Product_Code And GRN_ID in (select * from #tempgrn))  
End  
drop table #Tempgrn  
  
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, Amount,  
TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,   
SpecialPrice, Promotion, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT)  
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, @TaxCode,  
@Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @Promotion,  
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT)  
  

