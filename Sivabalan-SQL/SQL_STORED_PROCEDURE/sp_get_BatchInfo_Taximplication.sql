CREATE Procedure sp_get_BatchInfo_Taximplication(@ItemCode nvarchar(255),  
            									 @Batch_Code nvarchar(255))
As  
  Select Top 1 Batch_Products.PTS,     
  Batch_Products.PTR,     
  Batch_Products.ECP,     
  Batch_Products.Company_Price  
  From Items, Batch_Products    
  Where Items.Product_Code = Batch_Products.Product_Code     
  And Items.Product_Code = @ItemCode  
  And Batch_Products.Batch_Number = @Batch_Code   
  And IsNull(Batch_Products.Free, 0) = 0    
  And IsNull(Batch_Products.Damage, 0) = 0    


