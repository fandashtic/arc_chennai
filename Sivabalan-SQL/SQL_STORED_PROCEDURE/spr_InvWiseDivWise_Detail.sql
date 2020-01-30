Create Procedure spr_InvWiseDivWise_Detail( @invID Int,@MANUFACTURER nVarchar(255),@BRANDNAME nVarchar(255),@DocDate DateTime)
As
Begin
Declare @Delimeter as Char(1)        
Declare @cur_Div as Cursor
Declare @tmpSql as nVarchar(4000)
Declare @divName as nvarchar(255)
Declare @cur_DivSales as Cursor
Declare @netValue as decimal(18,6)
Set @Delimeter = char(15)      
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create Table #TmpMfr (Mfr nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @BRANDNAME='%'        
   Insert into #tmpDiv select BrandName from Brand        
Else        
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRANDNAME,@Delimeter)        

If @MANUFACTURER = '%'   
	Insert Into #TmpMfr Select Manufacturer_Name From Manufacturer  
Else  
	Insert Into #TmpMfr Select * From DBO.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)  

Select "Item Code" = I.Product_Code,"Item Code" = I.Product_Code,"Item Name" = I.ProductName,
"Division" = BrandName,"Quantity " = Case IA.InvoiceType 
When 1 Then sum(Quantity)
When 2 Then sum(Quantity)
When 3 Then sum(Quantity)
When 4 Then 0 - sum(Quantity)
When 5 Then 0 - sum(Quantity)
When 6 Then 0 - sum(Quantity)
end,
"Net Rate" = SalePrice,"Net Amount" = Case IA.InvoiceType
 When 1 Then sum(Amount)
When 2 Then sum(Amount)
When 3 Then sum(Amount)
When 4 Then 0 - sum(Amount)
When 5 Then 0 - sum(Amount)
When 6 Then 0 - sum(Amount)
end
From InvoiceAbstract IA,InvoiceDetail ID,Items I,Manufacturer M,Brand B
Where 
IA.InvoiceID = ID.InvoiceID
And IA.InvoiceID = @invID
And IA.Status & 128 = 0
And IA.InvoiceType in (1,2,3,4,5,6)
And B.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpDiv)     
And I.BrandID=B.BrandID     
And I.product_Code=ID.product_Code 
And M.Manufacturer_Name in (Select Mfr COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)  
And I.ManufacturerID=M.ManufacturerID 
group by I.Product_Code,I.ProductName ,BrandName,SalePrice,IA.InvoiceType 
Drop Table #tmpDiv
Drop Table #tmpMfr
End



