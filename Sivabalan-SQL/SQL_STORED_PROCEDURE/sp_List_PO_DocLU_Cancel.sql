CREATE Procedure sp_List_PO_DocLU_Cancel (@DocIDFrom int, @DocIDTo int)
As
Select Vendors.Vendor_Name, POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, Status,
POAbstract.DocumentID, POAbstract.Value
From POAbstract, Vendors
Where Vendors.VendorID = POAbstract.VendorID And
POAbstract.Status & 192 = 0 And
(POAbstract.DocumentID Between @DocIDFrom And @DocIDTo)
Order By Vendors.Vendor_Name, POAbstract.PONumber
