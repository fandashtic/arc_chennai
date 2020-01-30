CREATE Function [dbo].[fn_GetPoints_MUOM] (@Type int,@InvoiceID int,@DocSerial int)          
RETURNS decimal(18,6) AS            
BEGIN           
Declare @Product_code nvarchar(15)          
Declare @TotPoints decimal(18,6)          
Declare @Quantity decimal(18,6)           
Declare @Amount decimal(18,6)          
Declare @Count int          
Declare @PType int  --Point type 1-qty / 0-value          
Declare @Value decimal(18,6)          
Declare @Points decimal(18,6)          
Declare @CategoryID int          
Set @TotPoints=0          
    
If @Type=0 or @Type=1   --item or category          
BEGIN          
  DECLARE InvItems CURSOR KEYSET FOR          
  SELECT Product_code, Quantity,Amount from InvoiceDetail          
  WHERE InvoiceID = @InvoiceID And IsNull(SalePrice,0) > 0         
          
   Open  InvItems          
          
   Fetch From InvItems into @Product_Code,@Quantity,@Amount          
   WHILE @@FETCH_STATUS = 0          
   BEGIN          
     Set @Count=0          
     If @Type=0    --itemwise       
       BEGIN  
         Select @Count=1, @PType=PointsType, @Points=PointsDetail.Points,   
                @Value= (Case IsNull(PreUOM,0)   
                        When 0 Then PointsDetail.[value] * 1  
                        When 1 Then PointsDetail.[value] * (Select IsNull(UOM1_conversion,1) From Items Where Product_code = @Product_code)  
                        When 2 Then PointsDetail.[value] * (Select IsNull(UOM2_conversion,1) From Items Where Product_code = @Product_code) End )  
         From pointsdetail,pointsabstract Where pointsdetail.docserial=pointsabstract.docserial   
         and pointsabstract.Active=1 and pointsdetail.active=1 and PointsDetail.Product_code=@Product_code          
         and pointsabstract.DocSerial=@DocSerial    
       END  
     Else If @Type=1     --Category Wise  
       BEGIN  
         Declare @CatID Int  
         Declare @PrimaryUOM Int  
         Declare @CONVERSION Decimal(18,2)  
         Declare catList Cursor for Select categoryid,PointsType,PointsDetail.Points, PointsDetail.Value, IsNull(PointsDetail.PreUOM,0)  
         From pointsabstract inner join pointsdetail on pointsabstract.docserial = pointsdetail.docserial        
         Where pointsabstract.active=1 and pointsdetail.active=1  and Definitiontype=1  and pointsabstract.DocSerial=@DocSerial      
         Open catList        
         Fetch from catList into @CatID,@PType,@Points,@Value,@PrimaryUOM  
         --Set @Count = 0        
         WHILE @@FETCH_STATUS = 0 and @Count =0  
         BEGIN          
           IF EXISTS(Select * From items Where product_code=@Product_Code and  categoryid in (Select * From sp_get_LeafNodes(@CatID)))         
             Set @Count =1  
             IF @PrimaryUOM = 1  -- To get the Conversion Factor  
               Select @CONVERSION = IsNull(UOM1_Conversion,1) From items Where product_code=@Product_Code  
             ELSE IF @PrimaryUOM = 2   
               Select @CONVERSION = IsNull(UOM2_Conversion,1) From items Where product_code=@Product_Code  
             ELSE IF @PrimaryUOM = 0   
               Set @CONVERSION = 1  
           ELSE  
             Fetch From catList into @CatID,@PType,@Points,@Value,@PrimaryUOM  
         END        
         Deallocate catList        
       END  
     If @Count=1          
     BEGIN  
       If @PType=1   --Qty          
         Begin          
         If @Quantity>0  
           If @Type = 1   
             Set @Value = (@Value*@CONVERSION)  --> To convert value into Specified UOM  
           Set @TotPoints = @TotPoints  + (@Quantity/@Value) * @Points          
         End              
       Else if @PType=0   --Value          
         Begin          
          If @Quantity > 0   
            Set @TotPoints= @TotPoints + (@Amount/@Value)*@Points          
         End          
       End          
       Fetch from InvItems into @Product_Code,@Quantity,@Amount          
     END          
     Deallocate InvItems  
  End          
Else if @Type=2    --Invoice          
Begin          
 Select @Points=Points,@Value=[Value] from PointsAbstract where active=1 and PointsAbstract.DocSerial=@DocSerial          
 Select  @Amount=NetValue from invoiceAbstract where InvoiceID=@InvoiceID          
 Set @TotPoints = @TotPoints + (@Points/@Value)*@Amount          
End          
Return @TotPoints          
End  

