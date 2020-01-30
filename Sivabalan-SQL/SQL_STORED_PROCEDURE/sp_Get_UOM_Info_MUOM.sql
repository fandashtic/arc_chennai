CREATE Procedure sp_Get_UOM_Info_MUOM (@ID Int)  
As  
Declare @SUOM Int  
Declare @RUOM Int  
Declare @UOM1 Int
Declare @UOM2 Int
Declare @ConversionUnit Int  
Declare @CUOM Int
  
Select @SUOM = UOM From UOM Where Description = (Select UOM From ItemsReceivedDetail  
Where ID = @ID)  
  
Select @RUOM = UOM From UOM Where Description = (Select ReportingUOM From ItemsReceivedDetail  
Where ID = @ID)  
  
Select @ConversionUnit = ConversionID From ConversionTable   
Where ConversionUnit = (Select ConversionUnit From ItemsReceivedDetail Where ID = @ID)  

Select @UOM1 = UOM From UOM Where Description = (Select UOM1 From ItemsReceivedDetail  
Where ID = @ID)  
  
Select @UOM2 = UOM From UOM Where Description = (Select UOM2 From ItemsReceivedDetail  
Where ID = @ID)  

Select @CUOM = UOM From UOM Where Description = (Select Case_UOM From ItemsReceivedDetail  
Where ID = @ID)

Select @SUOM, @RUOM, @ConversionUnit, UOM, ReportingUOM, ConversionUnit , @UOM1, @UOM2, UOM1, UOM2, @CUOM, Case_Conversion, Case_UOM 
From ItemsReceivedDetail Where ID = @ID  


