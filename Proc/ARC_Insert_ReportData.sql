/*
Select * from ReportData With (Nolock) Where Id = 993
Select * from ParameterInfo_Salem With (Nolock) Where ParameterID = 34
Select * from ParameterInfo With (Nolock) Where ParameterID = 34
*/
--Exec ARC_Insert_ReportData 993, 'Bill Vs Sales', 1, 'spr_BillVsSales', 'Click to View Bill Vs Sales Report', 151, 34, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Insert_ReportData')
BEGIN
    DROP PROC [ARC_Insert_ReportData]
END
GO
Create Proc ARC_Insert_ReportData
(
	 @ID INT
	,@Node Nvarchar(255)
	,@Action INT
	,@ActionData  Nvarchar(255)
	,@Description Nvarchar(255)
	,@Parent INT
	,@Parameters INT
	,@Image INT
	,@SelectedImage INT
	,@FormatID INT
	,@DetailCommand INT
	,@KeyType INT
	,@Inactive INT
	,@ForwardParam INT
	,@PrintType INT
	,@PrintWidth INT
	,@OverWriteParam CHAR(3)
)
As
Begin
	If Exists(Select Top 1 1 from ReportData With (Nolock) Where Id = @ID)
	BEgin		
		IF((Select Top 1 Node from ReportData With (Nolock) Where Id = @ID) = @Node)
		BEGIN
			Delete D from ReportData D With (Nolock) Where D.Id = @ID
			PRINT 'Report Deleted'
		END
		Else
		BEGIN			
			PRINT 'Report Name Mismatch'
			RETURN;
		END
	End

	Insert Into  ReportData(ID,Node,Action,ActionData,Description,Parent,Parameters,Image,SelectedImage,FormatID,DetailCommand,KeyType,Inactive,ForwardParam,PrintType,PrintWidth)
	Select @ID,@Node,@Action,@ActionData,@Description,@Parent,@Parameters,@Image,@SelectedImage,@FormatID,@DetailCommand,@KeyType,@Inactive,@ForwardParam,@PrintType,@PrintWidth
	PRINT 'Report Added'

	----Copy Parameters From Master
	--IF(@OverWriteParam = 'Yes')
	--BEGIN
	--	IF Exists(select TOP 1 1 FROM ParameterInfo WITH (NOLOCK) WHERE ParameterID = @Parameters)
	--	BEGIN
	--	DELETE D FROM ParameterInfo D WITH (NOLOCK) WHERE D.ParameterID = @Parameters
	--		PRINT 'Parameter Deleted'
	--	END
	
	--	INSERT INTO ParameterInfo(ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,OrderBy,DynamicParamID)
	--	SELECT ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,OrderBy,DynamicParamID
	--	FROM ParameterInfo_Salem D WITH (NOLOCK) WHERE D.ParameterID = @Parameters
	--END
	PRINT 'Parameter Added From Backup'

END
GO
