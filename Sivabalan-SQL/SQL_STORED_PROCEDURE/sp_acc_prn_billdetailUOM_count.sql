CREATE procedure [dbo].[sp_acc_prn_billdetailUOM_count](@BILLID int)    
AS    
SELECT count(1)  
FROM BillDetail
Left Join Items on BillDetail.Product_Code = Items.Product_Code 
Left Join UOM on BillDetail.UOM = UOM.UOM
Left Join BillAbstract on Billdetail.Billid = Billabstract.Billid
--, Items,UOM  ,BillAbstract   
WHERE   BillDetail.BillID = @BILLID 
	--AND BillDetail.Product_Code *= Items.Product_Code    
 --and BillDetail.UOM *= UOM.UOM  and  
 --Billdetail.Billid *= Billabstract.Billid    

-- -- -- Execute sp_acc_rpt_billdetailuom @BILLID      

