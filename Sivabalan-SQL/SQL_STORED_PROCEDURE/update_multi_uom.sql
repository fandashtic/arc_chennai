
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

CREATE Procedure update_multi_uom(@Product_Code nvarchar(15), 
	@Batch_Code  int , @DocSerial int, @TotalQTY decimal(18,2))
as
declare @ID int
declare @ROWQTY decimal(18,2)
--cursor code --  
DECLARE UpdateQuantity CURSOR KEYSET FOR  
SELECT [id], pending FROM vanstatementdetail WHERE DocSerial = @DocSerial 
		And Product_Code = @Product_Code  And Batch_Code = @Batch_Code 
open UpdateQuantity  --open cursor
FETCH FROM UpdateQuantity INTO @Id, @ROWQTY 
 While @@FETCH_STATUS = 0  
 BEGIN  
     IF @ROWQTY >= @TotalQTY  
     BEGIN  
         UPDATE vanstatementdetail set Pending = Pending - @TotalQTY  
	         where [id] = @Id and Product_Code = @Product_Code  And Batch_Code = @Batch_Code  
         GOTO OVERNOUT  
     END  
     ELSE  
     BEGIN  
        UPDATE vanstatementdetail set Pending = Pending - @ROWQTY  
    	    where [id] = @Id and Product_Code = @Product_Code  And Batch_Code = @Batch_Code  
		set @TotalQTY = @TotalQTY - @ROWQTY  
		FETCH next FROM UpdateQuantity INTO @Id, @ROWQTY 
     END   
 END  
OVERNOUT: 
CLOSE UpdateQuantity  
DEALLOCATE UpdateQuantity  

 







