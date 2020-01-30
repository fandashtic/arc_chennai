CREATE Procedure sp_List_Amend_PO (@POFromDate Datetime,@POToDate datetime,@VendorID nVarchar (255)='%')
As 
Select Vendors.Vendor_Name, POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, POAbstract.DocumentID, POAbstract.DocumentID,POAbstract.DocumentReference from 
POAbstract,Vendors
where ((POAbstract.Status & 224) = 0) 
And Isnull(POAbstract.GRNID,0) = 0 
And Vendors.VendorID = POAbstract.VendorID 
And POAbstract.VendorID like @VendorID
And (POAbstract.PODate between @POFromDate and @POToDate)
order by Vendors.Vendor_Name, POAbstract.PONumber
