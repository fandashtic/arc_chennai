CREATE Function GetPipelineStock (@GivenDate Datetime, @CurrentDate Datetime, @Category nvarchar(255))    
Returns Decimal(18, 6)    
As    
Begin    
Declare @CatID Int    
Declare @Value Decimal(18, 6)    
Declare @AvgSale Decimal(18, 6)    
Declare @Pipeline Decimal(18, 6)    
Declare @Month1 Int    
Declare @Year1 Int    
Declare @PreDate Datetime    
Set @PreDate = DateAdd(MM, -3, @GivenDate)    
Set @Month1 = Datepart(MM, @PreDate)    
Set @Year1 = Datepart(YY, @PreDate)    
    
Select @CatID = CategoryID From ItemCategories Where Category_Name Like @Category    
Select @Value = Sum(Quantity * PurchasePrice) From Batch_Products, Items Where     
Batch_Products.Product_Code = Items.Product_Code And    
Items.CategoryID = @CATID    
Select @AvgSale = Sum((Case InvoiceAbstract.InvoiceType When 4 Then -1 Else    
 1 End) * Amount) / 3 From InvoiceDetail,    
  Items, InvoiceAbstract Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And     
  InvoiceDetail.Product_Code = Items.Product_Code And Items.CategoryID = @CatID    
  And InvoiceAbstract.Status & 192 = 0 And InvoiceAbstract.InvoiceDate Between '01/'+Cast(@Month1 As nvarchar)+'/'+Cast(@Year1 As nvarchar)     
  And Dateadd(DD, -1, '01/'+Cast(Datepart(MM, @GivenDate) As nvarchar)+'/'+Cast(Datepart(YY, @GivenDate) As     
  nvarchar))    
If @AvgSale = 0 
set @Pipeline = 0
Else
Set @Pipeline = (@Value * 30) / @AvgSale

Return @Pipeline    
End    

