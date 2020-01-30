CREATE Procedure sp_save_forecast_abstract (	@ForeCastDate datetime,
						@DocPrefix nvarchar(255),
						@Vendor nvarchar(20),
						@DocumentDate datetime)
As
Declare @DocID int

Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 19
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 19
Commit Tran

Insert into ForeCast_Abstract (DocumentID, DocPrefix, ForeCast_Date, VendorID,
DocumentDate)
Values(@DocID, @DocPrefix, @ForeCastDate, @Vendor, @DocumentDate)
Select @@Identity, @DocID
