Create Procedure Sp_Get_TaxSuff_Details(@Product_Code as nvarchar(30)) 
as 
Select Percentage, LSTApplicableON , LSTPartOff , CSTApplicableON , CSTPartOff 
From items, Tax 
Where Product_Code = @Product_Code And Tax.Tax_Code = Items.TaxSuffered 

