CREATE PROCEDURE sp_update_reportdata (	@ID int,
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
update  ReportData set Action = @Action, Actiondata = @ActionData, Parent = @Parent, Parameters = @Parameters,
	FormatID = @FormatID, DetailCommand = @DetailCommand, KeyType = @KeyType, Inactive = @InActive, ForwardParam = @ForwardParam
Where ID = @ID
