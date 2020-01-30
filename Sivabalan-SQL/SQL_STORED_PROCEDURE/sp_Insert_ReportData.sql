
CREATE Procedure sp_Insert_ReportData (	@Node nvarchar(255),
					@Action int,
					@ActionData nvarchar(255),
					@Parent int,
					@Parameters int,
					@FormatID int,
					@DetailCommand int,
					@KeyType int,
					@InActive int,
					@ForwardParam int)
as
Declare @NewID int
Select @NewID = Max(ID) + 1 From ReportData
Insert into ReportData (ID, Node, Action, ActionData, Description, Parent,
Parameters, Image, SelectedImage, FormatID, DetailCommand, KeyType, Inactive, ForwardParam,
PrintType, PrintWidth) Values (@NewID, @Node, @Action, @ActionData, NULL, @Parent,
@Parameters, 1, 1, @FormatID, @DetailCommand, @KeyType, @InActive, @ForwardParam, 0, 234)

