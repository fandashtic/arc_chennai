CREATE PROCEDURE [dbo].[spr_list_open_goods_received_note]  
AS  
SELECT  GRNID, "GRNID" = GRNPrefix.Prefix + CAST(DocumentID AS nvarchar),   
 "GRN Date" = GRNDate, "Vendor" = Vendors.Vendor_Name,  
 "PO Numbers" = PONumbers,  
 "Doc Ref" = DocRef,  
 "Branch" = ClientInformation.Description  
FROM GRNAbstract
left Outer Join Vendors on GRNAbstract.VendorID = Vendors.VendorID
Inner Join VoucherPrefix GRNPrefix on GRNPrefix.TranID = 'GOODS RECEIVED NOTE'
Left Outer Join ClientInformation on GRNAbstract.ClientID = ClientInformation.ClientID 
WHERE 
--GRNAbstract.VendorID *= Vendors.VendorID AND   
 (GRNStatus & 128) = 0 AND  
 (GRNStatus & 32) = 0 
 --AND  
 --GRNPrefix.TranID = 'GOODS RECEIVED NOTE' AND  
 --GRNAbstract.ClientID *= ClientInformation.ClientID  
ORDER BY GRNAbstract.GRNDate, GRNAbstract.VendorID  

