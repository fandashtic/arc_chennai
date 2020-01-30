CREATE procedure [dbo].[sp_insert_billcombo](@BillId int,@ComboId int,@Locality int,@comboQty Decimal(18,6),@Discount Decimal(18,6),@Flags int,@BillComboId int) 
as    
declare @ComboItem nvarchar(50)    
declare @ComponentCode nvarchar(50)    
declare @Purchase Decimal(18,6)    
declare @Quantity Decimal(18,6)    
declare @Tax Decimal(18,6)    
declare @PTS Decimal(18,6)    
declare @PTR Decimal(18,6)    
declare @ECP Decimal(18,6)    
declare @SpecialPrice Decimal(18,6)    
declare @TaxCode int    
declare @TaxType int    
declare @recQty Decimal(18,6)    
declare @comboAmt Decimal(18,6)    
declare @comboTax Decimal(18,6)    
declare @comboValue Decimal(18,6)    
if(@Locality=1)        
declare cur_bill cursor for    
select t1.combo_item_code,t1.component_item_code,"Purchase Price"=case items.purchased_at when 1 then t1.Pts when 2 then t1.ptr end,Quantity,"Tax"=case Free when 1 then 0 else Isnull(percentage,0) end,t1.PTS,t1.PTR,t1.ECP,t1.specialPrice,items.taxsuffered
,1 as TaxType from       
combo_components t1 ,tax,items where        
t1.comboId=@ComboID and        
t1.component_item_code=items.product_code        
and items.taxsuffered*=tax.tax_code        
else        
declare cur_bill cursor for    
select t1.combo_item_code, t1.component_item_code, "Purchase Price"=case items.purchased_at when 1 then t1.Pts when 2 then t1.ptr end,Quantity,"Tax"=case Free when 1 then 0 else Isnull(cst_percentage,0) end,t1.PTS,t1.PTR,t1.ECP,t1.specialPrice,items.taxsuffered,2 as TaxType from        
combo_components t1, tax, items where        
t1.comboId=@ComboId and        
t1.component_item_code=items.product_code        
and items.taxsuffered*=tax.tax_code        
        
open cur_bill    
fetch cur_bill into     
@ComboItem,@ComponentCode,@Purchase,@Quantity,@Tax,@PTS,@PTR,@ECP,@SpecialPrice,@TaxCode,@TaxType    
while(@@Fetch_Status=0)    
Begin    
    
 set @recQty=@comboQty*@Quantity    
 set @comboAmt=@recQty*@Purchase    
 if(@Flags=1)    
  set @comboTax=(@comboAmt*(@Tax/100))          
 else    
  set @comboTax=(@comboAmt-@Discount)*(@Tax/100)    
        
 set @comboValue=@comboTax + @comboAmt    
 insert into bill_combo_components(ComboId,BillId,Combo_Item_Code,Component_Item_Code,Received_Quantity,PurchasePrice,Amount,PTS,PTR,ECP,SpecialPrice,TaxCode,TaxType,TaxSuffered,TaxSufferedValue,TotalAmount,Discount,Flags)values(@BillComboId,@BillId,@ComboItem,    
 @ComponentCode,@recqty,@Purchase,@ComboAmt,@PTS,@PTR,@ECP,@SpecialPrice,@TaxCode,@TaxType,@Tax,@comboTax,@comboValue,@Discount,@Flags)    

 Update Combo_Components Set taxsuffered = @Tax Where ComboId = @ComboId and 
 Combo_Item_Code = @ComboItem and Component_Item_Code = @ComponentCode

 fetch next from cur_bill into @ComboItem,@ComponentCode,@Purchase,@Quantity,@Tax,@PTS,@PTR,@ECP,@SpecialPrice,@TaxCode,@TaxType        
 

 
End     
close cur_bill    
deallocate cur_bill
