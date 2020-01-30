CREATE Procedure sp_Print_ConversionAbstract (@DocSerial int)
As
Select "Conversion No" = DocPrefix + Cast(DocumentID as nvarchar), 
"Conversion Date" = DocumentDate, "Remarks" = Remarks 
From ConversionAbstract Where DocSerial = @DocSerial
