CREATE Procedure sp_Create_DiscountComp_Fields      
As      
Select  
'"' + BM.DiscDescription + ' %" = ' + '(Select Sum(BD.DiscountPercentage) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = ' + Cast(Max(BM.DiscountID) as varchar) + ' And BD.ItemSerial = BillDetail.Serial )' +
',"' + BM.DiscDescription + '" = ' + '(Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = ' + Cast(Max(BM.DiscountID) as varchar) + ' And BD.ItemSerial = BillDetail.Serial )'
From BillDiscountMaster BM
Group by BM.DiscDescription



