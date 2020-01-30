CREATE Procedure sp_Get_GSTItemTax @Product_Code nvarchar(30)
As
      
Select Product_Code, a.Tax_Code, isnull(a.CS_TaxCode,0) GSTCSTaxCode
From Items I Left Join Tax a on I.Sale_Tax = a.Tax_Code
Where  Product_Code = @Product_Code      
   
