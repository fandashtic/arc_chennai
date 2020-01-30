Create Function [dbo].[fn_GetPoints] (@Type int,@InvoiceID int,@DocSerial int)      
RETURNS decimal(18,6) AS        
BEGIN       
declare @Product_code nvarchar(15)      
declare @TotPoints decimal(18,6)      
declare @Quantity decimal(18,6)       
declare @Amount decimal(18,6)      
declare @Count int      
declare @PType int  --Point type 1-qty / 0-value      
declare @Value decimal(18,6)      
declare @Points decimal(18,6)      
declare @CategoryID int      
set @TotPoints=0      

if @Type=0 or @Type=1   --item or category      
begin      
	DECLARE InvItems CURSOR KEYSET FOR      
	SELECT Product_code, Quantity,Amount from InvoiceDetail      
	WHERE InvoiceID = @InvoiceID And IsNull(SalePrice,0) > 0     
      
  	open  InvItems      
      
  	fetch from InvItems into @Product_Code,@Quantity,@Amount      
  	WHILE @@FETCH_STATUS = 0      
  	BEGIN      
    	set @Count=0      
	    if @Type=0    --itemwise      
        begin      
	      	select @Count=1, @PType=PointsType,@Points=PointsDetail.Points,@Value=PointsDetail.[value] from pointsdetail,pointsabstract where pointsdetail.docserial=pointsabstract.docserial      
	      	and pointsabstract.Active=1 and pointsdetail.active=1 and PointsDetail.Product_code=@Product_code      
			and pointsabstract.DocSerial=@DocSerial
      	end      
      	else if @Type=1     --Category Wise       
      	begin      
   			Declare @CatID Int    
   			Declare catList cursor for select categoryid,PointsType,PointsDetail.Points,PointsDetail.[value]    
   			from pointsabstract inner join pointsdetail on pointsabstract.docserial = pointsdetail.docserial    
   			Where pointsabstract.active=1 and pointsdetail.active=1  and Definitiontype=1  and pointsabstract.DocSerial=@DocSerial  
   			Open catList    
   			fetch from catList into @CatID,@PType,@Points,@Value    
   			--Set @Count = 0    
   			WHILE @@FETCH_STATUS = 0 and @Count =0    
     		BEGIN      
     			IF EXISTS(select * from items where product_code=@Product_Code and  categoryid in (select * from sp_get_LeafNodes(@CatID)))     
        		set @Count =1     
		     	ELSE    
          		fetch from catList into @CatID,@PType,@Points,@Value    
    		END    
    		deallocate catList    
     	end     
    	if @Count=1      
    	begin       
	      	if @PType=1   --Qty      
	      	begin      
	        	if @Quantity>0                        
	         		set @TotPoints = @TotPoints  + (@Quantity/@Value)*@Points      
	      	end          
	      	else if @PType=0   --Value      
	      	begin      
	        	if @Quantity >0       
	         		set @TotPoints= @TotPoints + (@Amount/@Value)*@Points      
	      	end      
	    end      
     fetch from InvItems into @Product_Code,@Quantity,@Amount      
  END      
End      
else if @Type=2    --Invoice      
Begin      
	select @Points=Points,@Value=[Value] from PointsAbstract where active=1 and PointsAbstract.DocSerial=@DocSerial      
	select  @Amount=NetValue from invoiceAbstract where InvoiceID=@InvoiceID      
	set @TotPoints = @TotPoints + (@Points/@Value)*@Amount      
End      
return @TotPoints      
End      

