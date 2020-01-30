
CREATE Procedure sp_View_StockTransferInAbstract (@DocSerial int)    
As    
Select DocSerial, IsNull(DocPrefix, N'') + Cast(DocumentID as nvarchar),    
DocumentDate, StockTransferInAbstract.WareHouseID, WareHouse.WareHouse_Name,    
NetValue, Status, ReferenceSerial, TaxAmount,Remarks, Sti_lr_no, Sti_tran_info, Sti_narration, IsNull(Sti_Rec_date,DocumentDate) as sti_rec_date
,"taxtype"=Case When GSTFLag = 1 Then StateType Else taxtype End
From StockTransferInAbstract, WareHouse    
Where StockTransferInAbstract.DocSerial = @DocSerial And    
StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID    

