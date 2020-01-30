
Create Function GetTaxDetails_DOS_TOQ (@InvNo int)
Returns nvarchar(2000)        
As        
Begin  
  
Declare @Result nvarchar(2000) 
Declare @InvNos nvarchar(200)
Declare @Tax Decimal(18,2)
Declare @Sale_Value Decimal(18,2)  
Declare @Tax_Amt Decimal(18,2)  
Declare @Total_Tax_Amt Decimal(18,2) 
Declare @Total_Sale_Value Decimal(18,2)  


Set @InvNos= Cast(@InvNo as nvarchar(10)) + ','


Set @Result = '  |' + Space(10) +'Tax Details   ' + Space(10) + '|;'    
  
Set @Total_Tax_Amt= 0.00 
set @Total_Sale_Value=0.00

  
Set @Result =  IsNull(@Result, N'') + '|Tax Rate |     Sale   |   TaxAmt  |' + ';'  


Declare TaxData Cursor Keyset For
select taxcode, convert(Decimal(18, 2), NetSalesValue) NetSalesValue, 
    convert(Decimal(18, 2),TaxValue) TaxValue from (
    select taxcode , (sum(Gr_amt)-sum(pr_dsc)-sum(tr_Dsc)) NetSalesValue,
    sum(stpayable) TaxValue from ( 
        select Id.serial, Id.taxId, max(taxcode) taxcode, max(stpayable) stpayable, 
        sum(quantity*saleprice) Gr_amt, max(Id.Discountvalue) pr_dsc, 
        ((sum(quantity*saleprice)-max(Id.Discountvalue))*max(Ia.additionaldiscount/100)) tr_Dsc  
        from Invoiceabstract Ia, InvoiceDetail Id 
        where Ia.InvoiceId = Id.InvoiceId and ia.invoiceid IN (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
        group by Id.serial, Id.taxId) Id
    group by taxcode  
    ) rst 
Order By taxcode desc, NetSalesValue Desc




Open TaxData        
Fetch From TaxData into @Tax,@Sale_Value, @Tax_Amt
While @@Fetch_Status = 0        
Begin        
    
Set @Result =  IsNull(@Result, N'') 
		 + '|' + Cast(@Tax as nvarchar(9)) + Space(9 -Len(Cast(@Tax as nvarchar(10))))  
         + '|' + Space(12 -len(Cast(@Sale_Value as nvarchar(11)))) + Cast(@Sale_Value as nvarchar(12))  
		 --+ '|' + Space(5 -Len(Cast(@SP_Per as nvarchar(10)))) + Cast(@SP_Per as nvarchar(10)) 
         + '|' + Space(11 -len(Cast(@Tax_Amt as nvarchar(10)))) + Cast(@Tax_Amt as nvarchar(10))
         + '|;'
  Set @Total_Tax_Amt=@Total_Tax_Amt + @Tax_Amt
  set @Total_Sale_Value=@Total_Sale_Value+@Sale_Value

Fetch Next From TaxData into @Tax,@Sale_Value,@Tax_Amt
End        
  
Set @Result= @Result + '|Total    ' 					 
					 + '|' + Space(12 - Len (Cast(@Total_Sale_Value as nvarchar(12)))) + Cast(@Total_Sale_Value as nvarchar(12))
					 + '|' + Space(11 - Len (Cast(@Total_Tax_Amt as nvarchar(10)))) + Cast(@Total_Tax_Amt as nvarchar(10)) 
					 + '|;'   
--Set @Result= @Result + '|' + REPLICATE('-',35) + '|;'
  
Set @Result = SubString(@Result, 3, Len(@Result) - 2)  
  
Close TaxData       

Deallocate TaxData        

Return @Result        


End

