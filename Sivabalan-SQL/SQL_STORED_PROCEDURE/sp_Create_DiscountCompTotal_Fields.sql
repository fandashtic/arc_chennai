Create Procedure sp_Create_DiscountCompTotal_Fields  
As  
Select '"' + BM.DiscDescription + '_Total_Value" = ' + '(Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = ' + Cast(Max(BM.DiscountID) as varchar) + ')'
From BillDiscountMaster BM
Group by BM.DiscDescription


