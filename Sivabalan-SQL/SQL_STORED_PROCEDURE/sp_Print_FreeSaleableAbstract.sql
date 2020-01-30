CREATE Procedure sp_Print_FreeSaleableAbstract (@DocSerial int)
As
Select "Conversion No" = DocPrefix + Cast(DocumentID as nvarchar), 
"Conversion Date" = DocumentDate, "Remarks" = Remarks, "User Name" = UserName
From ConversionAbstract Where DocSerial = @DocSerial And ConversionType = 1
