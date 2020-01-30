
Create Procedure sp_Get_UOM_Info (@ID Int)  
As  

Declare @SUOM Int  
Declare @RUOM Int  
Declare @ConversionUnit Int  
Declare @CUOM Int
  
Select @SUOM = UOM From UOM Where Description = (Select UOM From ItemsReceivedDetail  
Where ID = @ID)  
  
Select @RUOM = UOM From UOM Where Description = (Select ReportingUOM From ItemsReceivedDetail  
Where ID = @ID)  

Select @CUOM = UOM From UOM Where Description = (Select Case_UOM From ItemsReceivedDetail  
Where ID = @ID)
  
Select @ConversionUnit = ConversionID From ConversionTable   
Where ConversionUnit = (Select ConversionUnit From ItemsReceivedDetail Where ID = @ID)  
Select @SUOM, @RUOM, @ConversionUnit, UOM, ReportingUOM, ConversionUnit, @CUOM, Case_Conversion, Case_UOM
From ItemsReceivedDetail Where ID = @ID

