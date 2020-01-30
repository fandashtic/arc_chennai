CREATE procedure sp_get_BillDiscountInfo(@BillID nVarchar(20),@ItemSerial Int)    
As        
Select DiscountPercentage,DiscountAmount,BDM.DiscDescription ,IRD.DiscountID,"Flag" = 0    
From BillDiscount IRD, BillDiscountMaster BDM    
Where IRD.DiscountID = BDM.DiscountID And    
IRD.BillID = @BillID And     
IRD.ItemSerial = @ItemSerial
Order by Serial     



