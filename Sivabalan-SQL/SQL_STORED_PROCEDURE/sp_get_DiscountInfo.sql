CREATE procedure sp_get_DiscountInfo(@GRNID nVarchar(20),@ItemSerial Int)
As
Declare @ReceivedInvoice Int

Select @ReceivedInvoice = RecdInvoiceID From GRNabstract where GRNID = @GRNID

Select DiscountPercentage,DiscountAmount,BDM.DiscDescription ,IRD.DiscountID, "Flag" = 1    
From InvoiceDiscountReceived IRD, BillDiscountMaster BDM
Where IRD.DiscountID = BDM.DiscountID And
IRD.InvoiceID = @ReceivedInvoice And 
IRD.ItemSerial = @ItemSerial
Order by Serial


