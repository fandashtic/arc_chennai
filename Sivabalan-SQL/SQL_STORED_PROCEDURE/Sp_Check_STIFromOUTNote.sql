Create Procedure Sp_Check_STIFromOUTNote(@DocSerial Int)
as
If Exists(select stockTransferINAbstract.DocSerial from stockTransferINAbstract , stockTransferOUTAbstractReceived
where stockTransferINAbstract.DocReference = stockTransferOUTAbstractReceived.DocSerial
And stockTransferINAbstract.DocSerial = @DocSerial)
Select 1
Else
Select 0


