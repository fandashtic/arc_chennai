CREATE Procedure SP_Get_SODetailForDispatch(@SONo nvarchar(255))    
AS    
--This procedure returns the Pending SO Details in Single UOMs.    
Declare @Pending Decimal(18,6)    
Declare @Quantity Decimal(18,6)    
Declare @SONumber Int    
Declare @ProductCode nvarchar(30)    
Declare @BatchNumber nvarchar(128)    
Declare @SalePrice Decimal(18,6)    
Declare @PendingQty nvarchar(62)    
Declare @BaseQty Decimal(18,6)    
Declare @Count Int    
Declare @UOM Int    
Declare @UOMDesc nvarchar(510)    
Declare @UOMQty Decimal(18,6)    
Declare @UOMConversion Decimal(18,6)    
Declare @UOMPrice Decimal(18,6)    
Declare @Serial Int    
    
Create Table #TempUOMWiseSODetail(ProductCode nvarchar(30),     
BatchNumber nvarchar(128), SalePrice Decimal(18,6), Quantity Decimal(18,6),    
UOMDesc nvarchar(510), UOMID Int, UOMQty Decimal(18,6), UOMPrice Decimal(18,6), Serial Int)    
    
Select @Pending = Sum(Pending), @Quantity= Sum(Quantity) From SODetail Where SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,','))    
If @Pending = @Quantity    
Begin    
 Insert into #TempUOMWiseSODetail Select SODetail.Product_Code, SoDetail.Batch_Number, SoDetail.SalePrice,     
 sum(SODetail.Pending) as Quantity, Uom.Description as UOMDESC,SoDetail.UOM as UOMID, Sum(SoDetail.UOMQty), SoDetail.UOMPrice, SoDetail.SERIAL     
 From SODetail,UOM     
 WHERE SODetail.SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,',')) And    
 UOM.UOM = SoDetail.UOM     
 GROUP BY SODetail.Product_Code, SODetail.Batch_Number, SoDetail.SalePrice, Uom.Description,SoDetail.UOM,SoDetail.UOMPrice, SoDetail.SERIAL     
 Having IsNull(Sum(SODetail.Pending),0) > 0     
 Select * from #TempUOMWiseSODetail Order By Serial    
 Drop Table #TempUOMWiseSODetail     
End    
Else    
Begin    
  Select SODetail.Product_Code, SoDetail.Batch_Number, SoDetail.SalePrice,     
  Dbo.GetQtyAsMultiple(SODetail.Product_Code,sum(SODetail.Pending)) as PendingQty, SoDetail.SERIAL     
  into #TempSODetail From SODetail     
  WHERE SODetail.SONumber In (Select * From Dbo.SP_SplitIn2Rows(@SoNo,','))     
  GROUP BY SODetail.Product_Code, SODetail.Batch_Number, SoDetail.SalePrice, SoDetail.SERIAL     
  Having IsNull(Sum(SODetail.Pending),0) > 0     
      
  Declare CurSODetails Cursor for Select * from #TempSODetail    
  Open CurSODetails     
  Fetch From CurSODetails into @ProductCode, @BatchNumber, @SalePrice, @PendingQty, @Serial    
  While @@Fetch_Status = 0    
  Begin    
   Set @count = 0     
   Select * into #TempQty From Dbo.Sp_SplitIn2Rows(@PendingQty,'*')    
   Declare CurQty Cursor for Select * from #TempQty    
   Open CurQty    
   Fetch From CurQty into @UOMQty    
   While @@Fetch_Status = 0    
   Begin     
    Set @count = @count + 1    
    If @UOMQty > 0    
    Begin    
     if @count = 1     
     begin    
      Select @UOM = UOM2, @UOMConversion = UOM2_Conversion     
      From Items Where Product_Code = @ProductCode    
     end    
     else if @count = 2    
     begin    
      Select @UOM = UOM1, @UOMConversion = UOM1_Conversion     
      From Items Where Product_Code = @ProductCode    
     end    
     else    
     begin    
      Select @UOM = UOM, @UOMConversion = 1     
      From Items Where Product_Code = @ProductCode    
     end     
      
     Set @UOMPrice = @SalePrice * @UOMConversion    
     Set @BaseQty = @UOMQty * @UOMConversion    
     Select @UOMDesc = Description From UOM Where UOM = @UOM    
     Insert into #TempUOMWiseSODetail     
     Values(@ProductCode, @BatchNumber, @SalePrice, @BaseQty, @UOMDesc, @UOM, @UOMQty, @UOMPrice, @Serial)    
    End    
    Fetch From CurQty into @UOMQty    
   End    
   Fetch From CurSODetails into @ProductCode, @BatchNumber, @SalePrice, @PendingQty, @Serial     
   Drop table #TempQty     
      
   Close CurQty    
   Deallocate CurQty    
  End    
  Close CurSODetails    
  Deallocate CurSODetails    
  Drop table #TempSODetail    
  Select * from #TempUOMWiseSODetail Order By Serial    
  Drop Table #TempUOMWiseSODetail     
 End    
    
  
  


