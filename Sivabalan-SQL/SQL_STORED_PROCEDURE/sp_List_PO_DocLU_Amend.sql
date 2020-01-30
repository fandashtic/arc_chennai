CREATE Procedure sp_List_PO_DocLU_Amend (@DocIDFrom int, @DocIDTo int)
As
Select Vendors.Vendor_Name, POAbstract.PONumber, POAbstract.PODate, POAbstract.RequiredDate, POAbstract.DocumentID,
POAbstract.DocumentID, POAbstract.DocumentReference  
From POAbstract, Vendors
Where Vendors.VendorID = POAbstract.VendorID And
((POAbstract.Status & 224) = 0) And 
Isnull(POAbstract.GRNID,0)=0 And
(POAbstract.DocumentID Between @DocIDFrom And @DocIDTo)
Order By Vendors.Vendor_Name, POAbstract.PONumber
