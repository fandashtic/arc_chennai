CREATE Procedure sp_Save_InvoiceTaxComponents (@InvoiceID Int, @RetCust Int = 0)  
As  
Declare @ItemCode nVarchar(30)  
Declare @Locality Int  
Declare @TaxID Int  
Declare @STPayable Decimal(18, 6)  
Declare @CSTPayable Decimal(18, 6)  
Declare @TaxCode Decimal(18, 6)  
Declare @TaxCode2 Decimal(18, 6)  
Declare @Tax_Value Decimal(18, 6)  
Declare @TaxComponentCode Int  
Declare @Tax_Percentage Decimal(18, 6)  
Declare @SP_Percentage Decimal(18, 6)  
Declare @LST_Flag Int  
Declare @InvType Int  
  
Select @InvType = InvoiceType From InvoiceAbstract Where InvoiceID = @InvoiceID  
If @InvType = 2   
Begin  
 --In invoicedetail, if same item is having different tax percentage than vat tax amount should  
 --calculated for each tax amount. So Sum function is removed for taxcode and taxcode2  
 If @RetCust = 1   
  Declare TaxableItems Cursor Keyset For  
  Select Product_Code, TaxID, 1, Sum(STPayable),  
  Sum(CSTPayable), InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
  From InvoiceAbstract, InvoiceDetail, Customer  
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
  And InvoiceAbstract.CustomerID = Customer.CustomerID  
  And InvoiceAbstract.InvoiceID = @InvoiceID  
  And Customer.CustomerCategory in (4, 5)  
  And isnull(InvoiceDetail.GSTCSTaxCode,0) = 0
  Group By InvoiceDetail.Product_Code, InvoiceDetail.TaxID, InvoiceDetail.SalePrice,  
  InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
 Else  
  Declare TaxableItems Cursor Keyset For  
  Select Product_Code, TaxID, 1, Sum(STPayable),  
  Sum(CSTPayable), InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
  From InvoiceAbstract
  Inner Join  InvoiceDetail On  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
  Left Outer Join  Cash_Customer  On Cast(InvoiceAbstract.CustomerID As Int) = Cash_Customer.CustomerID  
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
  And InvoiceAbstract.InvoiceID = @InvoiceID  
  And isnull(InvoiceDetail.GSTCSTaxCode,0) = 0
  Group By InvoiceDetail.Product_Code, InvoiceDetail.TaxID, InvoiceDetail.SalePrice,  
  InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
End  
Else  
Begin  
 Declare TaxableItems Cursor Keyset For  
 Select Product_Code, TaxID, IsNull(Customer.Locality, 1), Sum(STPayable),  
 Sum(CSTPayable), InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
 From InvoiceAbstract, InvoiceDetail, Customer  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 And InvoiceAbstract.CustomerID = Customer.CustomerID  
 And InvoiceAbstract.InvoiceID = @InvoiceID  
 And isnull(InvoiceDetail.GSTCSTaxCode,0) = 0
 Group By InvoiceDetail.Product_Code, InvoiceDetail.TaxID, InvoiceDetail.SalePrice,  
 IsNull(Customer.Locality, 1),InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2  
End  
  
Open TaxableItems  
  
Fetch From TaxableItems Into @ItemCode, @TaxID, @Locality, @STPayable, @CSTPayable,  
@TaxCode, @TaxCode2  
While @@Fetch_Status = 0  
Begin  
 If @Locality = 1   
  Set @LST_Flag = 1  
 Else  
  Set @LST_Flag = 0  
 Declare TaxComp Cursor Keyset For  
 Select TaxComponent_Code, Tax_Percentage, SP_Percentage  
 From TaxComponents   
 Where Tax_Code = @TaxID   
 And LST_Flag = @LST_Flag  
 Open TaxComp  
 Fetch From TaxComp Into @TaxComponentCode, @Tax_Percentage, @SP_Percentage  
 While @@Fetch_Status = 0  
 Begin  
  If @LST_Flag = 1   
   If @TaxCode <> 0   
   Set @Tax_Value = @STPayable * (@SP_Percentage / @TaxCode)   
   Else  
   Set @Tax_Value = 0  
  Else  
   If @TaxCode2 <> 0  
   Set @Tax_Value = @CSTPayable * (@SP_Percentage / @TaxCode2)   
   Else  
   Set @Tax_Value = 0  
  Insert Into InvoiceTaxComponents   
  (InvoiceID,   
  Product_Code,  
  TaxType,  
  Tax_Code,  
  Tax_Component_Code,  
  Tax_Percentage,  
  SP_Percentage,  
  Tax_Value) Values   
  (@InvoiceID,  
  @ItemCode,  
  1,  
  @TaxID,  
  @TaxComponentCode,  
  @Tax_Percentage,  
  @SP_Percentage,  
  @Tax_Value)  
  Fetch Next From TaxComp   
  Into @TaxComponentCode, @Tax_Percentage, @SP_Percentage  
 End  
 Close TaxComp  
 DeAllocate TaxComp  
 Fetch Next From TaxableItems Into @ItemCode, @TaxID, @Locality, @STPayable,   
 @CSTPayable, @TaxCode, @TaxCode2  
End  
Close TaxableItems  
DeAllocate TaxableItems  
Select 1  
