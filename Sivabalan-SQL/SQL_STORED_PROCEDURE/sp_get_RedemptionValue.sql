
Create procedure sp_get_RedemptionValue (@Points int,@FreeType int,  
@ProductCode nvarchar(50)=N'',@DocSerial Int =Null  
)    
as    
begin    
declare @Item nvarchar(50)    
declare @Qty Decimal(18,6)    
declare @Amt Decimal(18,6)    
declare @UnitPoint Decimal(18,6)    
    
if @FreeType=0       --gets the amount when enter points         
begin    
 select @Item=Productcode,@Amt=(Redemption.Value/FromPoint)*@Points from PointsAbstract,redemption where pointsabstract.active=1 and    
 pointsabstract.docserial=redemption.docserial and  
 redemption.active=1 And (pointsabstract.docserial=@DocSerial or (@DocSerial is NULL))
 select isnull(@Item,N''),@Amt    
end    
else if @FreeType=1   --gets the Qty and points when enter Grid    
begin    
 select @UnitPoint=FromPoint from redemption,PointsAbstract where    
 Pointsabstract.active=1 and redemption.active=1 and     
 pointsabstract.docserial=redemption.docserial and Redemption.productcode=@ProductCode    
 And (pointsabstract.docserial=@DocSerial or (@DocSerial is NULL))  
 set @Qty=cast((@Points/@UnitPoint) as int)    
 set @Points = (@Qty * @UnitPoint)    
 select @Qty,@Points    
end     
end    
  
